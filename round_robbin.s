.extern _etext
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss

.equ RCC_AHB1ENR,0x40023830
.equ GPIOD_MODER,0x40020C00
.equ GPIOD_OTYPER,0x40020C04
.equ GPIOD_OSPEEDR,0x40020C08
.equ GPIOD_PUPDR,0x40020C0C
.equ GPIOD_ODR,0x40020C14
.equ sys_csr ,0xe000e010
.equ sys_rlr ,0xe000e014
.equ sys_cur ,0xe000e018
.equ sys_clr ,0xe000e01c
.equ SYS_EXCE_CNTRL,0xe000ed24
.equ timeout ,0x000fffff
.equ int_ctrl,0xE000ED04

.section .bss
  array: .space 10

.section .data
  task_fun: .word task1,task2,task3,task4
  task_sp: .word 0x2001FC00, 0x2001F800,0x2001F400, 0x2001F000
  current_task: .word 0


.section .vector
    vector_table:
          .word 0x20020000
          .word reset_handler
          .org 0x0C
          .word HardFault_Handler
          .word MemManage_Handler
          .word BusFault_Handler
          .word UsageFault_Handler
          .org 0x38
          .word PendSVC_handler
          .word systic_handler
          .zero 400

.section .text
   .type reset_handler, %function
   reset_handler:
          ldr r1, =_etext
          ldr r2, =_sdata
          ldr r3, =_edata
       up:mov r0,#0
          ldrb r0,[r1] 
          strb r0,[r2]
          add r1,r1,#1
          add r2,r2,#1 
          cmp r2, r3
          bne up
          ldr r1,=_sbss
          ldr r2,=_ebss
          mov r3,#0
     next:strb r3,[r1]
          add r1,r1,#1
          cmp r1,r2
          bne next
          b main

.section .text
    .type main,%function
    main:
          bl excep_init
          bl led_init
          bl systick_init
          bl psp_init
          bl init_task_sp
          b task1

.section .text
   .type delay,%function
   delay:ldr r6, =0x00000400
     del:sub r6,r6,#1
         cmp r6,#0
          bne del
          bx lr
                    

.section .text
    .type PendSVC_handler,%function
    PendSVC_handler:
                    mrs r0,psp
                    //stmdb r0!,{r4-r11}
                    sub r0,r0,#32
                    str r4,[r0]
                    str r5,[r0,#4]
                    str r6,[r0,#8]
                    str r7,[r0,#12]
                    mov r7,r8
                    str r7,[r0,#16]
                    mov r7,r9
                    str r7,[r0,#20]
                    mov r7,r10
                    str r7,[r0,#24]
                    mov r7,r11
                    str r7,[r0,#28]
                    ldr r1,=current_task
                    ldr r2,[r1]
                    mov r3,#4
                    mul r3,r3,r2
                    ldr r4,=task_sp
                    str r0,[r4,r3]
                    add r2,r2,#1
                    cmp r2,#4
                    bne skip
                    mov r2,#0
               skip:str r2,[r1]
                    mov r3,#4
                    mul r3,r3,r2
                    ldr r0,[r4,r3]
                    //ldm r0!,{r4-r11}
                    ldr r4,[r0]
                    ldr r5,[r0,#4]
                    ldr r6,[r0,#8]
                    ldr r7,[r0,#12]
                    ldr r3,[r0,#16]
                    mov r8,r3
                    ldr r3,[r0,#20]
                    mov r9,r3
                    ldr r3,[r0,#24]
                    mov r10,r3
                    ldr r3,[r0,#28]
                    mov r11,r3
                    add r0,r0,#32
                    msr psp,r0
                    bx lr 
                 

.section .text   
     .type systic_handler, %function
     systic_handler:
                    ldr r0,=int_ctrl
                    ldr r1,[r0]
                    mov r2,#1
                    lsl r2,r2,#28
                    orr r1,r2,r1
                    str r1,[r0] 
                    bx lr 
                    
 
.section .text
     .type led_init,%function
     led_init:mov r0,#8
             ldr r1,=RCC_AHB1ENR
             ldr r2,[r1]
             orr r2,r2,r0
             str r2,[r1]
             ldr r1,=GPIOD_MODER 
             ldr r2,[r1]
             ldr r0, =0x00ffffff
             and r2,r2,r0
             ldr r0, =0x55000000
             orr r2,r2,r0
             str r2,[r1]
             ldr r1, =GPIOD_OTYPER
             ldr r2, [r1]
             ldr r0, =0xffff0fff
             and r2,r2,r0
             str r2, [r1]
             ldr r1,=GPIOD_OSPEEDR
             ldr r2,[r1]
             ldr r0, =0x00ffffff
             and r2,r2,r0
             str r2,[r1]
             ldr r1,=GPIOD_PUPDR
             ldr r2,[r1]
             ldr r0, =0x00ffffff
             and r2,r2,r0
             str r2,[r1]
             bx lr

.section .text
         .type systick_init,%function
         systick_init:
   	              mov r5, #0
	              ldr r0, =sys_csr
	              ldr r1, =sys_rlr
	              ldr r2, =sys_csr
	              ldr r3, =timeout
	              str r3, [r1]
	              mov r3, #0x00
	              str r3, [r2]
	              mov r3, #0x07
	              str r3, [r0]
                      bx lr

.section .text 
         .type psp_init,%function
         psp_init:
                 ldr r0,=task_sp
                 ldr r1,[r0]
                 msr psp,r1
                 ldr r2,=0x02
                 msr control,r2
                 bx lr
.section .text
         .type init_task_sp,%function
         init_task_sp:
                      ldr r0,=0x01000000
                      ldr r1,=0xfffffffd
                      ldr r3,=task_sp
                      mov r2,#0
            init_again:mov r4,#4
                      ldr r6,=task_fun
                      mul r4,r4,r2
                      ldr r5,[r3,r4]
                      sub r5,r5,#4
                      str r0,[r5]
                      sub r5,r5,#4
                      ldr r7,[r6,r4]
                      str r7,[r5]
                      sub r5,r5,#4
                      str r1,[r5]
                      mov r7,#0
                      mov r6,#0
           init_again1:sub r5,r5,#4
                      str r6,[r5]
                      add r7,r7,#1
                      cmp r7,#13
                      bne init_again1
                      str r5,[r3,r4]
                      add r2,r2,#1
                      cmp r2,#4
                      bne init_again
                      bx lr

.section .text 
         .type task1, %function
         task1:
              ldr r1,=GPIOD_ODR
              ldr r0, =0x00001000
              ldr r2,[r1]
              orr r0,r0,r2
              str r0,[r1]
              bl delay
              ldr r0, =0xffffefff
              ldr r2,[r1]
              and r0,r0,r2
              str r0,[r1]
              bl delay
              b task1


.section .text 
         .type task2, %function
         task2:
              ldr r1,=GPIOD_ODR
              ldr r0, =0x00002000
              ldr r2,[r1]
              orr r0,r0,r2
              str r0,[r1]
              bl delay
              ldr r0, =0xffffdfff
              ldr r2,[r1]
              and r0,r0,r2
              str r0,[r1]
              bl delay
              b task2

.section .text 
         .type task3, %function
         task3:
             ldr r1,=GPIOD_ODR
	     ldr r0, =0x00004000
	     ldr r2,[r1]
	     orr r0,r0,r2
	     str r0,[r1]
             bl delay
	     ldr r0, =0xffffbfff
	     ldr r2,[r1]
	     and r0,r0,r2
             str r0,[r1]
             bl delay
             b task3

.section .text 
         .type task4, %function
         task4:
             ldr r1,=GPIOD_ODR
	     ldr r0, =0x00008000
	     ldr r2,[r1]
	     orr r0,r0,r2
	     str r0,[r1]
             bl delay
	     ldr r0, =0xffff7fff
	     ldr r2,[r1]
	     and r0,r0,r2
	     str r0,[r1]
             bl delay
             b task4

.section .text
         .type excep_init,%function
         excep_init:
                   ldr r0,=SYS_EXCE_CNTRL
                   ldr r1,=0x00070000
                   ldr r2,[r0]
                   orr r2,r2,r1
                   str r2,[r0]
                   bx lr

.section .text
         .type HardFault_Handler,%function
         HardFault_Handler:
                           bl .
        
.section .text
         .type MemManage_Handler,%function
          MemManage_Handler:
                            bl .


.section .text
         .type BusFault_Handler,%function
          BusFault_Handler:
                           bl .



.section .text
         .type UsageFault_Handler,%function
          UsageFault_Handler:
                             bl .


