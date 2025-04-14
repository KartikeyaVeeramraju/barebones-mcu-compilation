
stm32_startup.o:     file format elf32-littlearm


Disassembly of section .text:

00000000 <reset_handler>:
   0:	b480      	push	{r7}
   2:	af00      	add	r7, sp, #0
   4:	bf00      	nop
   6:	46bd      	mov	sp, r7
   8:	bc80      	pop	{r7}
   a:	4770      	bx	lr

0000000c <nmi_handler>:
   c:	b480      	push	{r7}
   e:	af00      	add	r7, sp, #0
  10:	bf00      	nop
  12:	46bd      	mov	sp, r7
  14:	bc80      	pop	{r7}
  16:	4770      	bx	lr

00000018 <hard_fault_handler>:
  18:	b480      	push	{r7}
  1a:	af00      	add	r7, sp, #0
  1c:	e7fe      	b.n	1c <hard_fault_handler+0x4>

0000001e <memmanage_fault_handler>:
  1e:	b480      	push	{r7}
  20:	af00      	add	r7, sp, #0
  22:	e7fe      	b.n	22 <memmanage_fault_handler+0x4>

00000024 <bus_fault_handler>:
  24:	b480      	push	{r7}
  26:	af00      	add	r7, sp, #0
  28:	e7fe      	b.n	28 <bus_fault_handler+0x4>

0000002a <usage_fault_handler>:
  2a:	b480      	push	{r7}
  2c:	af00      	add	r7, sp, #0
  2e:	e7fe      	b.n	2e <usage_fault_handler+0x4>

00000030 <svc_handler>:
  30:	b480      	push	{r7}
  32:	af00      	add	r7, sp, #0
  34:	bf00      	nop
  36:	46bd      	mov	sp, r7
  38:	bc80      	pop	{r7}
  3a:	4770      	bx	lr

0000003c <debug_monitor_handler>:
  3c:	b480      	push	{r7}
  3e:	af00      	add	r7, sp, #0
  40:	bf00      	nop
  42:	46bd      	mov	sp, r7
  44:	bc80      	pop	{r7}
  46:	4770      	bx	lr

00000048 <pendsv_handler>:
  48:	b480      	push	{r7}
  4a:	af00      	add	r7, sp, #0
  4c:	e7fe      	b.n	4c <pendsv_handler+0x4>

0000004e <systick_handler>:
  4e:	b480      	push	{r7}
  50:	af00      	add	r7, sp, #0
  52:	bf00      	nop
  54:	46bd      	mov	sp, r7
  56:	bc80      	pop	{r7}
  58:	4770      	bx	lr

Disassembly of section .isr_vector:

00000000 <vectors>:
   0:	20020000 	andcs	r0, r2, r0
	...

Disassembly of section .comment:

00000000 <.comment>:
   0:	43434700 	movtmi	r4, #14080	; 0x3700
   4:	4728203a 			; <UNDEFINED> instruction: 0x4728203a
   8:	4120554e 			; <UNDEFINED> instruction: 0x4120554e
   c:	45206d72 	strmi	r6, [r0, #-3442]!	; 0xfffff28e
  10:	6465626d 	strbtvs	r6, [r5], #-621	; 0xfffffd93
  14:	20646564 	rsbcs	r6, r4, r4, ror #10
  18:	6c6f6f54 	stclvs	15, cr6, [pc], #-336	; fffffed0 <systick_handler+0xfffffe82>
  1c:	69616863 	stmdbvs	r1!, {r0, r1, r5, r6, fp, sp, lr}^
  20:	3031206e 	eorscc	r2, r1, lr, rrx
  24:	322d332e 	eorcc	r3, sp, #-1207959552	; 0xb8000000
  28:	2e313230 	mrccs	2, 1, r3, cr1, cr0, {1}
  2c:	20293031 	eorcs	r3, r9, r1, lsr r0
  30:	332e3031 			; <UNDEFINED> instruction: 0x332e3031
  34:	3220312e 	eorcc	r3, r0, #-2147483637	; 0x8000000b
  38:	30313230 	eorscc	r3, r1, r0, lsr r2
  3c:	20343238 	eorscs	r3, r4, r8, lsr r2
  40:	6c657228 	sfmvs	f7, 2, [r5], #-160	; 0xffffff60
  44:	65736165 	ldrbvs	r6, [r3, #-357]!	; 0xfffffe9b
  48:	Address 0x0000000000000048 is out of bounds.


Disassembly of section .ARM.attributes:

00000000 <.ARM.attributes>:
   0:	00002d41 	andeq	r2, r0, r1, asr #26
   4:	61656100 	cmnvs	r5, r0, lsl #2
   8:	01006962 	tsteq	r0, r2, ror #18
   c:	00000023 	andeq	r0, r0, r3, lsr #32
  10:	2d453705 	stclcs	7, cr3, [r5, #-20]	; 0xffffffec
  14:	0d06004d 	stceq	0, cr0, [r6, #-308]	; 0xfffffecc
  18:	02094d07 	andeq	r4, r9, #448	; 0x1c0
  1c:	01140412 	tsteq	r4, r2, lsl r4
  20:	03170115 	tsteq	r7, #1073741829	; 0x40000005
  24:	01190118 	tsteq	r9, r8, lsl r1
  28:	061e011a 			; <UNDEFINED> instruction: 0x061e011a
  2c:	Address 0x000000000000002c is out of bounds.

