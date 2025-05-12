[*] Building inliner.cpp...
[+] Build complete.
[*] Running inliner on uri_example.ll (starting from main)...
starting recursive inlining from: main
entering function: main
entering function: A
entering function: B
entering function: C
entering function: D
inlining call to function: D inside C
inlining successful
inlining call to function: C inside B
inlining successful
inlining call to function: B inside A
inlining successful
inlining call to function: C inside A
inlining successful
inlining call to function: A inside main
inlining successful
final module after inlining:
[+] Output written to uri_example.ll.out
