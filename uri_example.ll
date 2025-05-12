; ModuleID = 'inliner_test.ll'
source_filename = "inliner_test.ll"

define i32 @D(i32 %x) {
entry:
  %ret = add i32 %x, 1     ; Marker for D
  ret i32 %ret
}

define i32 @C(i32 %x) {
entry:
  %d_val = call i32 @D(i32 %x)
  %ret = add i32 %d_val, 2 ; Marker for C
  ret i32 %ret
}

define i32 @B(i32 %x) {
entry:
  %c_val = call i32 @C(i32 %x)
  %ret = add i32 %c_val, 3 ; Marker for B
  ret i32 %ret
}

define i32 @A(i32 %x) {
entry:
  %b_val = call i32 @B(i32 %x)
  %c_val = call i32 @C(i32 %x)
  %ret = add i32 %b_val, %c_val ; Combines two call results
  ret i32 %ret
}

define i32 @main() {
entry:
  %x = add i32 0, 100         
  %res = call i32 @A(i32 %x)
  ret i32 %res
}
