;									tab:8
;
; prog3.asm - starting code for ECE198KL Spring 2013 Program 3
;
; "Copyright (c) 2013 by Steven S. Lumetta.
;
; Permission to use, copy, modify, and distribute this software and its
; documentation for any purpose, without fee, and without written agreement is
; hereby granted, provided that the above copyright notice and the following
; two paragraphs appear in all copies of this software.
; 
; IN NO EVENT SHALL THE AUTHOR OR THE UNIVERSITY OF ILLINOIS BE LIABLE TO 
; ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL 
; DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, 
; EVEN IF THE AUTHOR AND/OR THE UNIVERSITY OF ILLINOIS HAS BEEN ADVISED 
; OF THE POSSIBILITY OF SUCH DAMAGE.
; 
; THE AUTHOR AND THE UNIVERSITY OF ILLINOIS SPECIFICALLY DISCLAIM ANY 
; WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE 
; PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND NEITHER THE AUTHOR NOR
; THE UNIVERSITY OF ILLINOIS HAS ANY OBLIGATION TO PROVIDE MAINTENANCE, 
; SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
;
; Author:	    Steve Lumetta
; Version:	    1.00
; Creation Date:    26 January 2013
; Filename:	    prog3.asm
; History:
;	SL	1.00	26 January 2013
;		First written.
;
	.ORIG	x3000		; starting address is x3000
	
	AND R1,R1,#0    	; R1 initialized as page counter
	LD R4,ARRAY     	; R4 holds address of array
	LD R6,DATABASE  	; R6 loaded with starting address of database

STORE_TO_MEM
	
	STR R6,R4,#0    	; Stores database's address into array address memory	

IF_NULL 
	
	LDR R5,R6,#0   		; Database value loaded into R5
	BRz COUNTER		; If NULL character, go to COUNTER
	ADD R6,R6,#1 		; Increment R6 until you have reached NULL character
	BRnzp IF_NULL	 	

COUNTER
	ADD R4,R4,#1 		; Increment array
	AND R2,R2,#0 		; R2 becomes counter for the 3 possible choices 
	ADD R2,R2,#3 		 

CHOICES
	ADD R6,R6,#1 		; Increment R6 
	LDR R5,R6,#0 		; Value inside address of R6 put into R4
	STR R5,R4,#0 		; Value of database address stored into array
	ADD R4,R4,#1 		; Increment R4
	ADD R2,R2,#-1 		; Decrement choice counter
	BRnp CHOICES   		; Go back to CHOICES if counter isn't 0
	
	ADD R4,R4,#-3 		; R4 moved back to print choices
	JSR PRINT_FOUR_HEX 	; Go to print four hex digits
	ADD R6,R6,#1 		; Increment R6
	ADD R1,R1,#1 		; Increments page number counter
	LDR R5,R6,#0 		; Value inside address of R6 loaded into R5
	BRnp STORE_TO_MEM 	; Loop back to printing the first character of the next string
	JSR PROG_3_SUB
	HALT	


; Subroutine PRINT_HEX_DIGIT
;   input: R3 -- 8-bit value to be printed as hex (high bits ignored)
;   caller-saved registers: R7 (as always with LC-3)
;   callee-saved registers: all other registers
;

PRINT_HEX_DIGIT

; registers used in this subroutine
;   R2 -- ASCII character to be printed
;   R3 -- 8-bit value to be printed as hex (high bits ignored)
;   R4 -- bit counter
;   R5 -- digit counter
;   R6 -- temporary

	ST R0,R0_SAVE		; store registers R0-R7 to keep them safe
	ST R1,R1_SAVE
	ST R2,R2_SAVE
	ST R3,R3_SAVE
	ST R4,R4_SAVE
	ST R5,R5_SAVE
	ST R6,R6_SAVE
	ST R7,R7_SAVE	

	; print low 8 bits of R3 as hexadecimal

	; shift R3 up 8 bits
	AND R2,R2,#0		; initialize shift count to 8
	ADD R2,R2,#8
SHIFT_LOOP
	ADD R3,R3,R3		; shift one bit
	ADD R2,R2,#-1		; count down
	BRp SHIFT_LOOP		; keep going until we're done

	AND R5,R5,#0		; initialize digit count to 0
DIG_LOOP
	AND R4,R4,#0		; initialize bit count to 0
	AND R2,R2,#0		; initialize current digit to 0
BIT_LOOP
	ADD R2,R2,R2		; double the current digit (shift left)
	ADD R3,R3,#0		; is the MSB set?
	BRzp MSB_CLEAR
	ADD R2,R2,#1		; if so, add 1 to digit
MSB_CLEAR
	ADD R3,R3,R3		; now get rid of that bit (shift left)
	ADD R4,R4,#1		; increment the bit count

	ADD R6,R4,#-4		; have four bits yet?
	BRn BIT_LOOP		; if not, go get another

	ADD R6,R2,#-10		; is the digit >= 10?
	BRzp HIGH_DIGIT		; if so, we need to print a letter
	LD R6,ASC_ZERO		; add '0' to digits < 10
	BRnzp PRINT_DIGIT

HIGH_DIGIT
	LD R6,ASC_HIGH		; add 'A' - 10 to digits >= 10

PRINT_DIGIT
	ADD R2,R2,R6		; calculate the digit
	JSR PRINT_CHAR		; print the digit

	ADD R5,R5,#1		; increment the digit count
	ADD R6,R5,#-2		; printed both digits yet?
	BRn DIG_LOOP		; if not, go print another

	LD R0,R0_SAVE	        ; load registers R0-R7 to keep them safe
	LD R1,R1_SAVE		; 
	LD R2,R2_SAVE		; 
	LD R3,R3_SAVE		;
	LD R4,R4_SAVE		; 
	LD R5,R5_SAVE		; 
	LD R6,R6_SAVE		;
	LD R7,R7_SAVE		;

	RET

	; data for PRINT_HEX subroutine

ASC_ZERO	.FILL x0030	; ASCII '0'
ASC_HIGH	.FILL x0037	; ASCII 'A' - 10
R0_SAVE		.BLKW #1
R1_SAVE		.BLKW #1
R2_SAVE		.BLKW #1
R3_SAVE		.BLKW #1
R4_SAVE		.BLKW #1
R5_SAVE		.BLKW #1
R6_SAVE		.BLKW #1
R7_SAVE		.BLKW #1


; Subroutine PRINT_CHAR
;   input: R2 -- 8-bit ASCII character to print to monitor
;   caller-saved registers: R7 (as always with LC-3)
;   callee-saved registers: all other registers

PRINT_CHAR
	ST R0,PRINT_CHAR_R0	; save R0 to memory
	ST R7,PRINT_CHAR_R7	; save R7 to memory...why?	
	ADD R0,R2,#0		; copy from R2
PCL	
	LDI R0, DSR             ; R0 <- mem[mem[DSR]]   aka   R0 <- mem[xFE04]
	BRzp PCL		; if not ready, loop back

	STI R2, DDR             ; mem[mem[DDR]] <- data   aka  mem[xFE06] <- R2
	LD R0,PRINT_CHAR_R0	; load R0 to memory
	LD R7,PRINT_CHAR_R7	; load R7 to memory...why?

	RET

	; data for PRINT_CHAR subroutine


PRINT_CHAR_R0	.BLKW #1
PRINT_CHAR_R7	.BLKW #1
DSR             .FILL xFE04 	; given to us in notes
DDR             .FILL xFE06 	; given to us in notes

; Subroutine PRINT_FOUR_HEX: This subroutine prints 4 hex digits (starting with page counter number)
; and places a space between each of them. Once all 4 have been printed, the subroutine goes to a new
; line and repeats the steps for the new page until all pages have been accounted for.

; input: R0 - Page number
; input: R2 - Pointer to following three values (address)
; R1: Page number counter
; R2: Used to print for PRINT_CHAR
; R3: Used to print for PRINT_HEX_DIGIT
; R4: Keep track of and hold addresses
; R5: 3 choice counter


PRINT_FOUR_HEX 
	
	ST R0,R0_SAVED 		; Save all registers  
	ST R1,R1_SAVED 		
	ST R2,R2_SAVED 		 
	ST R3,R3_SAVED 		 
	ST R4,R4_SAVED 		 
	ST R5,R5_SAVED 		 
	ST R6,R6_SAVED 		 
	ST R7,R7_SAVED 		 

	
	LD R2,SPACE 		; R2 loaded with space bar ascii value 	 	
	ADD R3,R1,#0 		; Page number counter loaded into R3 
	JSR PRINT_HEX_DIGIT 	; Print page number 
	JSR PRINT_CHAR 		; Print space 
	AND R5,R5,#0 		; Starts counter for printing characters  
	ADD R5,R5,#3 		

PRINT_LOOP

	LD R2,SPACE 		; R2 loaded with space bar ascii value again	
	LDR R3,R4,#0 		; Value in memory of address in R4 loaded into R3 
	JSR PRINT_HEX_DIGIT 	; Print the hex digits 
	JSR PRINT_CHAR 		; Print space 
	ADD R4,R4,#1 		; Increment address of array 
	ADD R5,R5,#-1 		; Decrement counter; if not 0, loop back to print more characters 
	BRnp PRINT_LOOP 	

	LD R2,NEW_LINE 		; R2 loaded with new line ascii value 
	JSR PRINT_CHAR 		; Print new line 

	LD R0,R0_SAVED 		; Restores all registers 
	LD R1,R1_SAVED 		
	LD R2,R2_SAVED 		
	LD R3,R3_SAVED 		 
	LD R4,R4_SAVED 		 
	LD R5,R5_SAVED 		 
	LD R6,R6_SAVED 		 
	LD R7,R7_SAVED 		 

	RET			
 
R0_SAVED .BLKW #1 		; Store and save registers when entering subroutine 
R1_SAVED .BLKW #1 
R2_SAVED .BLKW #1 
R3_SAVED .BLKW #1 
R4_SAVED .BLKW #1 
R5_SAVED .BLKW #1 
R6_SAVED .BLKW #1 
R7_SAVED .BLKW #1 

; You may need to move these strings to be close to your game play loop.

; Start of code in MP3

; Step 1 (Print out starting message)
PROG_3_SUB	
	LEA R0, P3_START_STR		; Load register R0 with starting string "Starting adventure!"
	PUTS				; Output it to the screen
 
; Step 2 (Begin going to correct page)
PAGE_CHECKER
	LD R4,ARRAY			; Load register R4 with the array 
	ADD R6,R6,R6			; Begin multiplication by 4
	ADD R6,R6,R6
	ADD R0,R4,R6
	LDR R1,R0,#0

; Step 3 (Output)
OUTPUT_CHAR
	PUTS

; Step 4 (Check if it is at the end of the game)
CHECK_END
	ADD R4,R4,#1			
	BRnp GET_INPUT
	LEA R0, P3_END_STR		; See if it is end of game
	PUTS				; Output it to the screen

; Step 5 (Get user input and echo the key to the screen)
GET_INPUT
	LEA R0, P3_PROMPT_STR		; Input String
	PUTS	

; Step 6 (check if input is valid)
CHECK_INPUT
	GETC
	AND R2,R2,#0			; Clear R2
	ADD R2,R0,#0
	JSR PRINT_CHAR
	AND R5,R5,#0
	ADD R5,R5,#1
	ADD R3,R2,R5
	BRz ERROR
	ADD R2,R2,#-1			; If input is 1, we go to step 2
	BRnz PAGE_CHECKER
	ADD R2,R2,#-1			; If input is 2, we go to step 2
	BRz PAGE_CHECKER
	ADD R2,R2,#-1			; If input is 3, we go to step 2
	BRz PAGE_CHECKER

ERROR
	LEA R0, P3_INVALID_STR		; Else, we want to output an error message
	BRnzp OUTPUT_CHAR

HALT

SPACE.FILL x0020 		; Hex value of a spare bar
NEW_LINE .FILL x000A		; hex value of new line
DATABASE .FILL x5000 		; Starting address of database
ARRAY .FILL x4000 		; Starting address of array			

P3_START_STR	.STRINGZ "\n\n--- Starting adventure. ---\n\n"
P3_PROMPT_STR	.STRINGZ "Please enter your choice: "
P3_INVALID_STR	.STRINGZ "\n\n--- Invalid choice. ---\n\n"
P3_END_STR	.STRINGZ "\n\n--- Ending adventure. ---\n\n"



	; the directive below tells the assembler that the program is done
	; (so do not write any code below it!)

	.END