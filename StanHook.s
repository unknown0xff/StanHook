//# coding by *

.global _StanHookSpringBoardf
.text
.align 2

#ifdef __arm64__
_StanHookSpringBoardf:

sub sp, sp, #(16 * 10)
stp x29, x30, [sp, #(16 * 8)]

stp x0, x1, [sp, #(16*0)]
stp x2, x3, [sp, #(16*1)]
stp x4, x5, [sp, #(16*2)]
stp x6, x7, [sp, #(16*3)]

stp d0, d1, [sp, #(16*4)]
stp d2, d3, [sp, #(16*5)]
stp d4, d5, [sp, #(16*6)]
stp d6, d7, [sp, #(16*7)]

bl _stanHookGetInst
str x0, [sp]
ldr x1, [sp, #8]
bl _stanHookGetIMP
mov x9, x0

ldp d0, d1, [sp, #(16*4)]
ldp d2, d3, [sp, #(16*5)]
ldp d4, d5, [sp, #(16*6)]
ldp d6, d7, [sp, #(16*7)]

ldp x0, x1, [sp, #(16*0)]
ldp x2, x3, [sp, #(16*1)]
ldp x4, x5, [sp, #(16*2)]
ldp x6, x7, [sp, #(16*3)]

ldp x29, x30, [sp,#(16 * 8)]
add sp, sp, #(16 * 10)

br x9
#else

_StanHookSpringBoardf:
bx lr

#endif

