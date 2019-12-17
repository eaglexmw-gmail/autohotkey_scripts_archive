; Simplest usage:
DebugBIF()

; Examples that should trigger a debug message:
RegExMatch("abc", "(") ; Regex compile error.
NumPut(0, "") ; Invalid second parameter.
NumGet(var, 1) ; Invalid parameters.
Mod(1,0) ; Divide-by-zero.
