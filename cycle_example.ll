; ModuleID = 'cycle_test.ll'
source_filename = "cycle_test.ll"

define i32 @A(i32 %x) {
entry:
  %b_val = call i32 @B(i32 %x)
  %res = add i32 %b_val, 1     ; A's marker
  ret i32 %res
}

define i32 @B(i32 %x) {
entry:
  %c_val = call i32 @C(i32 %x)
  %res = add i32 %c_val, 2     ; B's marker
  ret i32 %res
}

define i32 @C(i32 %x) {
entry:
  %a_val = call i32 @A(i32 %x)
  %res = add i32 %a_val, 3     ; C's marker
  ret i32 %res
}

define i32 @main() {
entry:
  %x = add i32 0, 10
  %res = call i32 @A(i32 %x)
  ret i32 %res
}