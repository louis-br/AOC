.data
.equ SWI_SETLED,        0x201    @LEDs on/off                       r0
.equ SWI_CheckBlack,    0x202    @check Black button
.equ SWI_CheckBlue,     0x203    @check press Blue button
.equ SWI_DRAW_INT,      0x205    @display an int on LCD             r0, r1, r2
.equ SWI_CLEAR_DISPLAY, 0x206    @clear LCD
.equ SWI_CLEAR_LINE,    0x208    @clear a line on LCD
.equ SWI_EXIT,          0x11     @terminate program
.equ RIGHT_LED,         0x01     @bit patterns for LED lights
.equ LEFT_BLACK_BUTTON, 0x02     @bit patterns for black buttons
.equ BLUE_KEY_00,       1<<0     @button(0)
.equ BLUE_KEY_01,       1<<1     @button(1)
.equ BLUE_KEY_02,       1<<2     @button(2)
.equ BLUE_KEY_03,       1<<3     @button(3)
.equ BLUE_KEY_04,       1<<4     @button(4)
.equ BLUE_KEY_05,       1<<5     @button(5)
.equ BLUE_KEY_06,       1<<6     @button(6)
.equ BLUE_KEY_07,       1<<7     @button(7)
.equ BLUE_KEY_08,       1<<8     @button(8)
.equ BLUE_KEY_09,       1<<9     @button(9)
.equ BLUE_KEY_10,       1<<10    @button(10)
.equ BLUE_KEY_11,       1<<11    @button(11)
.equ BLUE_KEY_12,       1<<12    @button(12)
.equ BLUE_KEY_13,       1<<13    @button(13)
.equ BLUE_KEY_14,       1<<14    @button(14)
.equ BLUE_KEY_15,       1<<15    @button(15)
pilha:  .space 24
.align
.text
start:
    ldr r9, =pilha
    mov r1, #0
    mov r2, #0
    mov r3, #0
    swi SWI_CLEAR_DISPLAY
    b print
loop:
    swi SWI_CheckBlue   @                                    13    10 9 8   6 5 4   2 1 0
                        @ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0 1 1 1 0 1 1 1
    cmp r0, #0
    beq loop
enter:
    tst r0, #BLUE_KEY_12
    cmpne r1, #6
    strne r2, [r9, r1, lsl #2]
    addne r1, r1, #1
    movne r3, r2
    movne r2, #0
    bne print
digit:
    mov r8, #10
    mov r7, #10
    tst r0, #BLUE_KEY_00
    movne r8, #1
    tst r0, #BLUE_KEY_01
    movne r8, #2
    tst r0, #BLUE_KEY_02
    movne r8, #3
    tst r0, #BLUE_KEY_04
    movne r8, #4
    tst r0, #BLUE_KEY_05
    movne r8, #5
    tst r0, #BLUE_KEY_06
    movne r8, #6
    tst r0, #BLUE_KEY_08
    movne r8, #7
    tst r0, #BLUE_KEY_09
    movne r8, #8
    tst r0, #BLUE_KEY_10
    movne r8, #9
    tst r0, #BLUE_KEY_13
    movne r8, #0
    cmp r8, #10
    mlane r2, r7, r2, r8
operation:
    cmp r1, #0
    beq print
    tst r0, #BLUE_KEY_03
    addne r2, r3, r2
    bne operation_end
    tst r0, #BLUE_KEY_07
    subne r2, r3, r2
    bne operation_end
    tst r0, #BLUE_KEY_11
    mulne r2, r3, r2
    bne operation_end
    tst r0, #BLUE_KEY_14 + BLUE_KEY_15
    beq print
    mov r8, r2
    mov r2, #0
divide:
    subs r3, r3, r8
    addge r2, r2, #1
    bge divide
    add r3, r3, r8 
    tst r0, #BLUE_KEY_14
    movne r2, r3
operation_end:
    mov r0, r1
    subs r1, r1, #1
    movmi r1, #0
    ldr r3, [r9, r1, lsl #2]
    swi SWI_CLEAR_LINE
print:
    mov r0, r1
    swi SWI_CLEAR_LINE
    mov r0, #0
    swi SWI_DRAW_INT
    b loop
exit:    
    swi SWI_EXIT