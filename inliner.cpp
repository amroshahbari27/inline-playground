#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <iostream>
#include <stack>

using namespace llvm;

// Function to inline a call site
bool InlineFun(CallBase *call) {
  if (!call) {
    errs() << "skipping inline: call site is null\n";
    return false;
  }

  if (!call->getCalledFunction()) {
    errs() << "skipping inline: indirect call or unresolved callee: ";
    call->print(errs());
    errs() << "\n";
    return false;
  }

  Function *Callee = call->getCalledFunction();
  errs() << "inlining call to function: " << Callee->getName() << " inside "
         << call->getFunction()->getName() << "\n";
  InlineFunctionInfo IFI;
  bool Success = InlineFunction(*call, IFI).isSuccess();
  errs() << (Success ? "inlining successful\n" : "inlining failed\n");
  return Success;
}

// Bottom-up recursive inlining with cycle-safe handling
void IterativeInline(Function *F,
                     SmallPtrSetImpl<Function *> &VisitedFunctions) {

  std::stack<CallBase *> CallsStack;
  VisitedFunctions.insert(F);

  // Start with the top function, initializing the stack with its calls
  for (auto &BB : *F) {
    for (auto &I : BB) {
      if (auto *CB = dyn_cast<CallBase>(&I)) {
        Function *Callee = CB->getCalledFunction();
        if (!Callee || Callee->isDeclaration())
          continue;

        // If the callee is not visited yet, push it onto the stack
        if (!VisitedFunctions.contains(Callee)) {
          CallsStack.push(CB);
        }
      }
    }
  }

  while (!CallsStack.empty()) {
    CallBase *CB = CallsStack.top();

    // Check if the callee is already visited, then inline it, and pop the stack
    Function *Callee = CB->getCalledFunction();
    if (VisitedFunctions.contains(Callee)) {
      InlineFun(CB);
      CallsStack.pop();
      continue;
    }
    // If not, visit the callee and push its calls onto the stack, keeping the
    // current call in the stack
    VisitedFunctions.insert(Callee);
    for (auto &BB : *Callee) {
      for (auto &I : BB) {
        if (auto *CB = dyn_cast<CallBase>(&I)) {
          Function *Callee = CB->getCalledFunction();
          if (!Callee || Callee->isDeclaration())
            continue;
          CallsStack.push(CB);
        }
      }
    }
  }
}

int main(int argc, char **argv) {
  if (argc != 3) {
    errs() << "usage: " << argv[0] << " <input.ll> <top_function_name>\n";
    return 1;
  }

  LLVMContext Context;
  SMDiagnostic Err;
  std::unique_ptr<Module> M = parseIRFile(argv[1], Err, Context);
  if (!M) {
    errs() << "failed to parse IR file: " << argv[1] << "\n";
    Err.print(argv[0], errs());
    return 1;
  }

  Function *Top = M->getFunction(argv[2]);
  if (!Top) {
    errs() << "function " << argv[2] << " not found in module\n";
    return 1;
  }

  errs() << "starting recursive inlining from: " << Top->getName() << "\n";

  SmallPtrSet<Function *, 32> VisitedFunctions;
  IterativeInline(Top, VisitedFunctions);

  errs() << "final module after inlining:\n";
  M->print(outs(), nullptr);
  return 0;
}
