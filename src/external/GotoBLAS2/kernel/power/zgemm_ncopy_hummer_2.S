/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2009. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"
	
#define	M	r3
#define	N	r4
#define	A	r5
#define	LDA	r6
#define B	r7

#define AO1	r8
#define AO2	r9

#define J	r12

#define INC	r30
#define INC2	r31

#define c01	f0
#define c02	f1
#define c03	f2
#define c04	f3
#define c05	f4
#define c06	f5
#define c07	f6
#define c08	f7
#define c09	f8
#define c10	f9
#define c11	f10
#define c12	f11
#define c13	f12
#define c14	f13
#define c15	f14
#define c16	f15

	PROLOGUE
	PROFCODE

	li	r0, -16

	stfpdux	f14, SP, r0
	stfpdux	f15, SP, r0
	
	stwu	r31,  -4(SP)
	stwu	r30,  -4(SP)

	slwi	LDA, LDA, ZBASE_SHIFT

	cmpwi	cr0, M, 0
	ble-	LL(99)
	cmpwi	cr0, N, 0
	ble-	LL(99)

	li	INC,  1 * SIZE
	li	INC2, 2 * SIZE
	subi	B, B, 2 * SIZE

	andi.	r0, A,   2 * SIZE - 1
	bne	LL(100)

	subi	A, A, 2 * SIZE
	srawi.	J,  N,  1
	ble	LL(20)
	.align 4
LL(11):
	mr	AO1, A
	add	AO2, A,   LDA
	add	A,   AO2, LDA

	srawi.	r0,  M,  3
	mtspr	CTR, r0
	ble	LL(15)
	.align 4

LL(12):
	LFPDUX	c01,   AO1, INC2
	LFPDUX	c02,   AO2, INC2
	LFPDUX	c03,   AO1, INC2
	LFPDUX	c04,   AO2, INC2
	LFPDUX	c05,   AO1, INC2
	LFPDUX	c06,   AO2, INC2
	LFPDUX	c07,   AO1, INC2
	LFPDUX	c08,   AO2, INC2

	LFPDUX	c09,   AO1, INC2
	LFPDUX	c10,   AO2, INC2
	LFPDUX	c11,   AO1, INC2
	LFPDUX	c12,   AO2, INC2
	LFPDUX	c13,   AO1, INC2
	LFPDUX	c14,   AO2, INC2
	LFPDUX	c15,   AO1, INC2
	LFPDUX	c16,   AO2, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c02,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c04,   B, INC2
	STFPDUX	c05,   B, INC2
	STFPDUX	c06,   B, INC2
	STFPDUX	c07,   B, INC2
	STFPDUX	c08,   B, INC2
	STFPDUX	c09,   B, INC2
	STFPDUX	c10,   B, INC2
	STFPDUX	c11,   B, INC2
	STFPDUX	c12,   B, INC2
	STFPDUX	c13,   B, INC2
	STFPDUX	c14,   B, INC2
	STFPDUX	c15,   B, INC2
	STFPDUX	c16,   B, INC2
	bdnz	LL(12)
	.align 4
	
LL(15):
	andi.	r0,  M,  7
	ble	LL(19)

	andi.	r0,  M,  4
	beq	LL(16)

	LFPDUX	c01,   AO1, INC2
	LFPDUX	c02,   AO2, INC2
	LFPDUX	c03,   AO1, INC2
	LFPDUX	c04,   AO2, INC2
	LFPDUX	c05,   AO1, INC2
	LFPDUX	c06,   AO2, INC2
	LFPDUX	c07,   AO1, INC2
	LFPDUX	c08,   AO2, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c02,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c04,   B, INC2
	STFPDUX	c05,   B, INC2
	STFPDUX	c06,   B, INC2
	STFPDUX	c07,   B, INC2
	STFPDUX	c08,   B, INC2
	.align 4

LL(16):
	andi.	r0,  M,  2
	beq	LL(17)

	LFPDUX	c01,   AO1, INC2
	LFPDUX	c02,   AO2, INC2
	LFPDUX	c03,   AO1, INC2
	LFPDUX	c04,   AO2, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c02,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c04,   B, INC2
	.align 4

LL(17):
	andi.	r0,  M,  1
	beq	LL(19)

	LFPDUX	c01,   AO1, INC2
	LFPDUX	c02,   AO2, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c02,   B, INC2
	.align 4

LL(19):
	addic.	J, J, -1
	bgt	LL(11)
	.align 4

LL(20):
	andi.	J,  N,  1
	ble	LL(99)

	mr	AO1, A

	srawi.	r0,  M,  2
	mtspr	CTR, r0
	ble	LL(25)
	.align 4

LL(22):
	LFPDUX	c01,   AO1, INC2
	LFPDUX	c03,   AO1, INC2
	LFPDUX	c05,   AO1, INC2
	LFPDUX	c07,   AO1, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c05,   B, INC2
	STFPDUX	c07,   B, INC2
	bdnz	LL(22)
	.align 4
	
LL(25):
	andi.	r0,  M,  3
	ble	LL(99)

	andi.	r0,  M,  2
	beq	LL(27)

	LFPDUX	c01,   AO1, INC2
	LFPDUX	c03,   AO1, INC2

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	.align 4

LL(27):
	andi.	r0,  M,  1
	beq	LL(99)

	LFPDUX	c01,   AO1, INC2

	STFPDUX	c01,   B, INC2
	.align 4

LL(99):
	addi	SP, SP, -4

	lwzu	r30,   4(SP)
	lwzu	r31,   4(SP)

	subi	SP, SP, 12
	li	r0, 16

	lfpdux	f15, SP, r0
	lfpdux	f14, SP, r0
	addi	SP, SP, 16
	blr
	.align 4

LL(100):
	subi	A, A, 1 * SIZE
	srawi.	J,  N,  1
	ble	LL(120)
	.align 4
LL(111):
	mr	AO1, A
	add	AO2, A,   LDA
	add	A,   AO2, LDA

	srawi.	r0,  M,  2
	mtspr	CTR, r0
	ble	LL(115)
	.align 4

LL(112):
	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC
	LFDUX	c03,   AO2, INC
	LFDUX	c04,   AO2, INC

	LFDUX	c05,   AO1, INC
	LFDUX	c06,   AO1, INC
	LFDUX	c07,   AO2, INC
	LFDUX	c08,   AO2, INC

	LFDUX	c09,   AO1, INC
	LFDUX	c10,   AO1, INC
	LFDUX	c11,   AO2, INC
	LFDUX	c12,   AO2, INC
	fsmfp	c01, c02

	LFDUX	c13,   AO1, INC
	fsmfp	c03, c04
	LFDUX	c14,   AO1, INC
	fsmfp	c05, c06
	LFDUX	c15,   AO2, INC
	fsmfp	c07, c08
	LFDUX	c16,   AO2, INC
	fsmfp	c09, c10

	STFPDUX	c01,   B, INC2
	fsmfp	c11, c12
	STFPDUX	c03,   B, INC2
	fsmfp	c13, c14
	STFPDUX	c05,   B, INC2
	fsmfp	c15, c16
	STFPDUX	c07,   B, INC2

	STFPDUX	c09,   B, INC2
	STFPDUX	c11,   B, INC2
	STFPDUX	c13,   B, INC2
	STFPDUX	c15,   B, INC2
	bdnz	LL(112)
	.align 4
	
LL(115):
	andi.	r0,  M,  3
	ble	LL(119)

	andi.	r0,  M,  2
	beq	LL(117)

	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC
	LFDUX	c03,   AO2, INC
	LFDUX	c04,   AO2, INC

	LFDUX	c05,   AO1, INC
	LFDUX	c06,   AO1, INC
	LFDUX	c07,   AO2, INC
	LFDUX	c08,   AO2, INC

	fsmfp	c01, c02
	fsmfp	c03, c04
	fsmfp	c05, c06
	fsmfp	c07, c08

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c05,   B, INC2
	STFPDUX	c07,   B, INC2
	.align 4

LL(117):
	andi.	r0,  M,  1
	beq	LL(119)

	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC
	LFDUX	c03,   AO2, INC
	LFDUX	c04,   AO2, INC

	fsmfp	c01, c02
	fsmfp	c03, c04

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	.align 4

LL(119):
	addic.	J, J, -1
	bgt	LL(111)
	.align 4

LL(120):
	andi.	J,  N,  1
	ble	LL(999)

	mr	AO1, A

	srawi.	r0,  M,  2
	mtspr	CTR, r0
	ble	LL(125)
	.align 4

LL(122):
	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC
	LFDUX	c03,   AO1, INC
	LFDUX	c04,   AO1, INC

	LFDUX	c05,   AO1, INC
	LFDUX	c06,   AO1, INC
	LFDUX	c07,   AO1, INC
	LFDUX	c08,   AO1, INC

	fsmfp	c01, c02
	fsmfp	c03, c04
	fsmfp	c05, c06
	fsmfp	c07, c08

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	STFPDUX	c05,   B, INC2
	STFPDUX	c07,   B, INC2
	bdnz	LL(122)
	.align 4
	
LL(125):
	andi.	r0,  M,  3
	ble	LL(999)

	andi.	r0,  M,  2
	beq	LL(127)

	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC
	LFDUX	c03,   AO1, INC
	LFDUX	c04,   AO1, INC

	fsmfp	c01, c02
	fsmfp	c03, c04

	STFPDUX	c01,   B, INC2
	STFPDUX	c03,   B, INC2
	.align 4

LL(127):
	andi.	r0,  M,  1
	beq	LL(999)

	LFDUX	c01,   AO1, INC
	LFDUX	c02,   AO1, INC

	fsmfp	c01, c02
	STFPDUX	c01,   B, INC2
	.align 4

LL(999):
	addi	SP, SP, -4

	lwzu	r30,   4(SP)
	lwzu	r31,   4(SP)

	subi	SP, SP, 12
	li	r0, 16

	lfpdux	f15, SP, r0
	lfpdux	f14, SP, r0
	addi	SP, SP, 16
	blr
	EPILOGUE
