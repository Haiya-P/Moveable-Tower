.global _start
.text

_start:
	bl openJoystick
	 cmp x0,#0
   	 blt ._start_exit
   	 
	bl openfb
	cmp x0,#0
	blt ._start_exit
	mov x8,x0
    
  	  #red
   	 mov x0,#31
   	 mov x1,#0
   	 mov x2,#0
   	 bl getColor
   	 mov x6,x0

   	    
   	 #starting dot
   	 mov x12, #7
   	 mov x13, #7
	mov x2,x6
   	mov x0,x12
	mov x1, x13
   	 bl setPixel

	mov x9, #0
	mov x10, #0
.color_tower:
        mov x2, #0
        bl drawTower
        mov x2,x6
        bl drawTower
        b .main

.set_red:
        mov x0, #31
        mov x1, #0
        mov x2, #0
        bl getColor
        mov x6, x0
        b .color_tower

.set_green:
        mov x0, #0
        mov x1, #63
        mov x2, #0
        bl getColor
        mov x6,x0
        b .color_tower

.set_blue:
        mov x0, #0
        mov x1, #0
        mov x2, #31
        bl getColor
        mov x6,x0
        b .color_tower

.main:
        bl getJoystickValue
        mov x4, x0
        cmp x4, #0
        blt ._start_fbclose

        cmp x4, #5
        bne .no_click

	cmp x10,#0
	bne .click_release

	mov x10,#1
	add x9,x9,#1

	cmp x9,#1
	beq .set_red
	cmp x9,#2
	beq .set_green
	cmp x9,#3
	beq .set_blue

	b ._start_fbclose

.click_release:
	mov x10,#0
	b .main

.no_click:	
	mov x2, #0
	bl drawTower
	
	//up
	cmp x4,#1
	bne .right
	cmp x13,#0
	beq .draw
	sub x13,x13,#1
	b .draw

.down:
        cmp x4,#3
        bne .left
        cmp x13,#7
        beq .draw
        add x13,x13,#1
        b .draw

.right:
	cmp x4,#2
	bne .down
	cmp x12,#7
	beq .draw
	add x12,x12,#1
	b .draw


.left:
	cmp x4,#4
	bne .draw
	cmp x12, #0
	beq .draw
	sub x12,x12,#1
	b .draw

.draw:
    mov x2, x6
        bl drawTower
	b .main

  
._start_fbclose:
	bl clear
	bl closefb

._start_exit:
	bl closeJoystick
	cmp x0,#0
	blt ._start_exit
	mov x8,#94
	svc #0

clear:
        #get the color black and store it in x2
       sub sp,sp,#32
	str lr,  [sp, #0]
    str x12, [sp, #8]    
    str x13, [sp, #16]  

        mov x0,#0
        mov x1,#0
        mov x2,#0
 
        bl getColor
        mov x2,x0

        mov x13,#7

.clear_begin_outer_loop:
        cmp x13,#0
    	b.lt .clear_exit
        mov x12,#7
.clear_begin_inner_loop:
        cmp x12,#0
        b.lt .clear_exit_inner_loop
        #set pixel
        mov x0,x12
        mov x1,x13
        bl setPixel
        sub x12,x12,#1
        b .clear_begin_inner_loop
.clear_exit_inner_loop:
        sub x13,x13,#1
        b .clear_begin_outer_loop
.clear_exit:
	ldr lr,  [sp, #0]
    ldr x12, [sp, #8]   
    ldr x13, [sp, #16]   
    add sp, sp, #32
       ret

drawTower:
    sub  sp, sp, #48
    str  lr,  [sp, #0]
    str  x19, [sp, #8]
    str  x20, [sp, #16]
    str  x21, [sp, #24]
    str  x22, [sp, #32]
    str  x23, [sp, #40]

        mov  x19, x12            
	mov  x20, x13          

        cmp  x20, #7
        beq  .single_dot

       mov  x21, x20          

.outer_row:
    	cmp  x21, #7
        bgt  .done            
	
        sub  x22, x21, x20     

        sub  x23, x19, x22
    	cmp  x23, #0
   	 bge  .xs_ok
   	 mov  x23, #0
.xs_ok:

   	 add  x22, x19, x22
   	 cmp  x22, #7
   	 ble  .xe_ok
   	 mov  x22, #7
.xe_ok:

.fill_row:
    cmp  x23, x22
    bgt  .next_row

    mov  x0, x23           
    mov  x1, x21           

    bl   setPixel          
    add  x23, x23, #1
    b    .fill_row

.next_row:
   	 add  x21, x21, #1      
   	 b    .outer_row

.single_dot:
   	 mov  x0, x19
   	 mov x1, x20
	bl   setPixel

.done:
	ldr  x19, [sp, #8]
	ldr x20, [sp, #16]
	ldr x21, [sp, #24]
	ldr x22, [sp, #32]
    	ldr x23, [sp, #40]
    	ldr  lr,  [sp, #0]
   	 add sp, sp, #48
   	 ret