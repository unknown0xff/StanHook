//# coding by *

.global _StanHookSpringBoardf
.text
.align 2

#ifdef __arm64__
_StanHookSpringBoardf:

sub sp, sp, #(16 * 6)
stp x29, x30, [sp, #(16 * 4)]

stp x0, x1, [sp, #(16*0)]
stp x2, x3, [sp, #(16*1)]
stp x4, x5, [sp, #(16*2)]
stp x6, x7, [sp, #(16*3)]

bl _stanHookGetInst
str x0, [sp]
ldr x1, [sp, #8]
bl _stanHookGetIMP
mov x9, x0

ldp x6, x7, [sp, #(16*3)]
ldp x4, x5, [sp, #(16*2)]
ldp x2, x3, [sp, #(16*1)]
ldp x0, x1, [sp, #(16*0)]

ldp x29, x30, [sp,#(16 * 4)]
add sp, sp, #(16 * 6)

br x9
#else

_StanHookSpringBoardf:
bx lr

#endif

