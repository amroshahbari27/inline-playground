[*] Building inliner.cpp...
[+] Build complete.
[*] Running inliner on cycle_example.ll (starting from main)...
starting recursive inlining from: main
inlining call to function: A inside C
inlining successful
inlining call to function: C inside B
inlining successful
inlining call to function: B inside A
inlining successful
inlining call to function: A inside main
inlining successful
final module after inlining:
[+] Output written to cycle_example.ll.out
