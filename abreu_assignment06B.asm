TITLE Combos     (abreu_assignment06B.asm)

; Author: James Cameron Abreu
; Course: CS271-400
; Project ID: Assignment 06-B
; Date: 3/15/2016
; Description: This program may help the user prepare for any combinations 
;  test! It uses some advanced MASM concepts such as low-level string to 
;  decimal processing, string operations, stack operations, local variables, 
;  macros, and more! I took time to document my logic and code, so I hope you 
;  enjoy 'Combos'!


; INCLUDE FILES -------------------------------------------------------------------------
INCLUDE Irvine32.inc

; LINE NUMBERS: (for cool folks that 'gg' to lines in vim)------|
;																|
;	constants.......................40							|
;	macros..........................90							|
;	.data...........................120							|
;	procedure prototypes............190							|
;																|
;	PROCEDURES (tab implies nested usage):						|
;		MAIN........................200							|
;		introduction................260							|
;		showProblem.................300							|
;			getRandomRange..........360							|
;		getData.....................390							|
;			stringToDec.............440							|
;			stringSize..............520							|
;		combinations................560							|
;			factorial...............650							|
;		showResults.................710							|
;		tryAgain....................770							|
;																|
;----------------------------------------------------------------


; CONSTANTS -----------------------------------------------------------------------------

; The following formula is used:
;									____n!____
;									r!(n - r)!

; Program Name:
PROGRAM_NAME EQU <"Combos, a Combination Quiz by James Cameron Abreu", 0>

; User input
MAX_CHARS = 20		; max input buffer

; Calculation constants:
N_MIN = 3
N_MAX = 12

; ASCII: 
TAB = 9
ASCII_0	= 48
ASCII_9 = 57
ASCII_Y = 121
ASCII_Y_UP = 89

; stack position using DWORDs
STK_D0 = 8
STK_D1 = 12
STK_D2 = 16
STK_D3 = 20
STK_D4 = 24

; stack positions (for DWORDS) after calling pushad instruction
AFTERAD_D0 = 36
AFTERAD_D1 = 40
AFTERAD_D2 = 44
AFTERAD_D3 = 48

; combination PROC, LOCAL VARIABLES:
COMB_NUM		EQU DWORD PTR [ebp - 4]
COMB_DEN		EQU DWORD PTR [ebp - 8]
COMB_R_FAC		EQU DWORD PTR [ebp - 12]
COMB_NR_FAC		EQU DWORD PTR [ebp - 16]

; tryAgain PROC, LOCAL VARIABLES:
TRY_BUFFER		EQU BYTE PTR [ebp - MAX_CHARS]






; MACROS --------------------------------------------------------------------------------

; WRITES a string to the screen with given argument:
; (Courtesy of macro lecture week 09)
mWriteString MACRO buffer
	push	edx
	mov		edx, OFFSET buffer
	call	writeString
	pop		edx
ENDM


; READS a string from user input int a given argument:
; (Courtesy of macro lecture week 09)
mReadString MACRO varName
	push	ecx
	push	edx
	mov		edx, OFFSET varName
	mov		ecx, (SIZE OF varName) - 1 ; null terminated char
	call	readString
	pop		edx
	pop		ecx
ENDM







; DATA SEGMENT---------------------------------------------------------------------------
.data

; MAIN

; introduction
intro_title			BYTE		PROGRAM_NAME
intro_instructions	BYTE		"Instructions: Combos is a quiz program developed "
					BYTE		"to give extra practice in calculating combinations "
					BYTE		"using the following formula: ", 0
intro_formula1		BYTE		TAB, TAB, "____n!____", 0
intro_formula2		BYTE		TAB, TAB, "r!(n - r)!", 0
intro_limits1		BYTE		"Limitations: A minimum of ", 0
intro_limits2		BYTE		" and a maximum of ", 0
intro_limits3		BYTE		" will be used for 'n'", 0

; showProblem
minN				DWORD		N_MIN
maxN				DWORD		N_MAX
n					DWORD		?
r					DWORD		?
showProb_Q			BYTE		"Question: ", 0
showProb_n			BYTE		"N, the number of elements in the set: ", 0
showProb_r			BYTE		"R, the number of elements to choose from the set: ", 0
; getRandomRange

; getData
getData_prompt		BYTE		"How many ways can you choose? Your answer: ", 0
userInput			BYTE		MAX_CHARS DUP (0)

; stringSize
actualSize			DWORD		0	

; stringToDec
answerConverted		DWORD		?
inputError			BYTE		"The data entered was invalid", 0

; combinations
finalSum			DWORD		1 ; must be '1' to begin. 

; factorial
result				DWORD		?

; showResults
showR_answer1		BYTE		"For a set of ", 0
showR_answer2		BYTE		" items in a set of ", 0
showR_answer3		BYTE		", there are ", 0
showR_answer4		BYTE		" combinations.", 0

showR_right			BYTE		"Yes! You are correct!", 0
showR_wrong			BYTE		"Don't give up! Review your math and try again!", 0
showR_LB			BYTE		"------------------------------------------------------------", 0

; tryAgain
tryAgain_prompt		BYTE		"Would you like to try another problem?", 0
tryAgain_inst		BYTE		"(Enter 'Y' for yes or 'N' to quit): ", 0
tryAgain_thanks		BYTE		"Thanks for playing ", PROGRAM_NAME, 0
quit				DWORD		0



; DEBUG
D_stringSize		BYTE		"Your string size was: ", 0
D_TAB				BYTE		TAB, 0






; PROCEDURE PROTOTYPES-------------------------------------------------------------------

; stringSize
stringSize PROTO,
	pInput: PTR BYTE,			; address that will store the string input
	pInputSize: PTR DWORD		; pointer to DWORD storage for size




; CODE SEGMENT---------------------------------------------------------------------------
.code
main PROC
	; Random Seed
	CALL	randomize

	; Introduction
	CALL	introduction

	GAME_LOOP: 
	; Show a problem:
	PUSH	OFFSET r
	PUSH	OFFSET n
	PUSH	maxN
	PUSH	minN
	Call	showProblem

	; Get data from user:
	PUSH	OFFSET answerConverted
	PUSH	OFFSET actualSize
	PUSH	LENGTHOF userInput
	PUSH	OFFSET	userInput
	CALL	getData

	; Calculate:
	PUSH	OFFSET result
	PUSH	r
	PUSH	n
	CALL	combinations

	; show answer to user:
	PUSH	r
	PUSH	n
	PUSH	result
	PUSH	answerConverted
	Call	showResults

	; try again?
	PUSH	OFFSET quit
	call	tryAgain

	mov		eax, quit
	cmp		eax, 0
	je		GAME_LOOP

	exit	; exit to operating system
main ENDP












; ------------------------------------------------------------------
introduction PROC
;
; Description: Displays the title, program description, and program 
;  limitations.
; Receives: none
; Returns: none
; Registers Modified: none
; ------------------------------------------------------------------

	mWriteString	intro_title
	call			CrLf
	call			CrLf

	mWriteString	intro_instructions
	call			CrLf
	mWriteString	intro_formula1
	call			CrLf	
	mWriteString	intro_formula2
	call			CrLf	
	call			CrLf	

	mWriteString	intro_limits1
	mov				eax, N_MIN
	call			writeDec
	mWriteString	intro_limits2
	mov				eax, N_MAX
	call			writeDec
	mWriteString	intro_limits3
	call			CrLf
	call			CrLf

	ret
introduction ENDP






; ------------------------------------------------------------------
showProblem PROC
;
; Description: Generates a problem by getting a random integer for 
;  n and r, then displays the problem for the user to work on. 
; Receives: see parameters
; Returns: 
; Registers Modified: none
; Parameters: (in stack style, reverse order):
	; argument3 = @R
	; argument2 = @N
	; argument1 = maxN
	; argument0 = minN
	pushad
	mov				ebp, esp
	
	; get random n, between min and max-------
	push			[ebp + AFTERAD_D1]	; max
	push			[ebp + AFTERAD_D0]	; min
	call			getRandomRange
	; mov random eax into our n variable:
	mov				edx, [ebp + AFTERAD_D2]
	mov				[edx], eax

	; get random r, between 1 and n-----------
	mov				edx, [edx]			; max
	push			edx
	mov				edx, 1
	push			edx					; min
	call			getRandomRange
	; mov random eax into our r
	mov				edx, [ebp + AFTERAD_D3]
	mov				[edx], eax

	; display question------------------------
	mWriteString	showProb_Q
	call			CrLf

	mWriteString	showProb_n
	mov				eax, [EBP + AFTERAD_D2]
	mov				eax, [eax]
	call			writeDec
	call			CrLF

	mWriteString	showProb_r
	mov				eax, [EBP + AFTERAD_D3]
	mov				eax, [eax]
	call			writeDec
	call			CrLf

	popad
	ret	16
showProblem ENDP







; ------------------------------------------------------------------
getRandomRange PROC USES ebp edx ebx
;
; Description: Gets a random integer within a range, leaves result in eax
; Receives: see parameters
; Returns: random int between min and max returned in eax
; Registers Modified: EAX
; Parameters: (in stack style, reverse order):
	; argument1 = max, DWORD (ebp + 20)
	; argument0 = min, DWORD (ebp + 16)
	mov				ebp, esp
	
	mov				edx, [EBP + 16]
	mov				ebx, [EBP + 20]

	mov				eax, ebx	; eax = min
	sub				eax, edx	; (max - min)
	call			randomRange
	add				eax, edx	; eax + min

	ret	8
getRandomRange ENDP








; ------------------------------------------------------------------
getData PROC
;
; Description: Prompts the user to enter an answer. Then takes that string 
;  and converts it to a combined digit using low level programming. 
; Receives: see parameters
; Returns: none
; Registers Modified: none
; Parameters: (in stack style, reverse order):
	; argument3 = OFFSET result of input variable
	; argument2 = OFFSET actual bytes entered variable
	; argument1 = LENGTHOF input variable
	; argument0 = OFFSET input variable
; ------------------------------------------------------------------
	pushad			; 32 bytes pushed onto stack
	mov				ebp, esp

	; "Your answer: "
	mWriteString	getData_prompt

	; get string from user and store in userInput
	mov				edx, [EBP + AFTERAD_D0]
	mov				ecx, [EBP + AFTERAD_D1]
	dec				ecx ; null terminated string
	call			ReadString
	
	; convert to dec:
	INVOKE stringSize,  [EBP + AFTERAD_D0], [EBP + AFTERAD_D2]
	; now EBP + AFTERAD_D2 contains the offset of the input actual size (in chars)

	push	[EBP + AFTERAD_D3]
	push	[EBP + AFTERAD_D2]
	push	[EBP + AFTERAD_D0]
	call	stringToDec ; automatically pops 12 bytes

	popad
	ret 12
getData ENDP












; ------------------------------------------------------------------
stringToDec PROC
;
; Description: Low-Level programming. Converts a string of digits (if any 
;  exist) into a combined decimal number, which is stored in a result
; Receives: 
; Returns: none
; Registers Modified: none
; Parameters (in stack style reverse order):
	; argument2 = result
	; argument1 = Actual count of bytes in string 
	; argument0 = @input
; constants used:
	; ASCII_0 : 48
	; ASCII_9 : 57
; Algorithm Used:
	; x = 0
	; for k = 0 to length(string) - 1 {
		; if 48 <= string[k] <= 57
			; x = 10 * x + (str[k] - 48)
		; else
			; break. Show error message
	; }
; ------------------------------------------------------------------
	pushad			; 32 bytes pushed onto stack
	mov				ebp, esp
	
	mov				esi, [EBP + AFTERAD_D0] ; starting location of string array
	mov				ecx, [EBP + AFTERAD_D1] ; @size of string
	mov				ecx, [ecx]				; size of string

	; x = 0
	mov				eax, 0					; accumulator

	; for k = 0 to length(string) - 1 {
	STRINGTODEC_ADDDIGIT:
		mov			dl, [esi]
		cmp			dl, ASCII_0
		jb			STRINGTODEC_ERROR

		cmp			dl, ASCII_9
		ja			STRINGTODEC_ERROR

	VALID_INPUT:
		; multiply eax by 10
		mov			ebx, 10
		mul			ebx	

		; convert single digit to its numerical value
		mov			edx, 0
		mov			dl, [esi] ; (mov back)
		sub			dl, ASCII_0

		; add to eax:
		add			eax, edx
	
		; k++:
		inc			esi
		loop		STRINGTODEC_ADDDIGIT

		; store result:
		mov			ebx, [EBP + AFTERAD_D2]
		mov			[ebx], eax

		; finished:
		jmp			STRINGTODEC_END

	STRINGTODEC_ERROR:
		mWriteString	inputError

	STRINGTODEC_END:
	popad
	ret 12
stringToDec ENDP






; ------------------------------------------------------------------
stringSize PROC USES edi eax edx,
	pInput: PTR BYTE,			; string passed in by reference
	pInputSize: PTR DWORD		; pointer to DWORD storage for size
; Description: Uses string processing to check the size of the string 
;  (not including terminating zero). Stores in parameter pInputSize.
; Receives: see parameters
; Returns: none
; Registers Modified: none
; Parameters: (in stack style, reverse order):
	; argument3 = OFFSET result of input variable
	; argument2 = OFFSET actual bytes entered variable
	; argument1 = LENGTHOF input variable
	; argument0 = OFFSET input variable
; ------------------------------------------------------------------
	mov		esi, pInput 
	mov		edx, 0				; temp accumulator

	STRINGSIZE_COUNT: 
		cmp		BYTE PTR[esi], 0	; check if end of string
		je		STRINGSIZE_END
		inc		esi
		inc		edx					; size++

		jmp		STRINGSIZE_COUNT

	STRINGSIZE_END:

		; store result in argument
		mov		eax, [pInputSize]
		mov		[eax], edx

		ret
stringSize ENDP






; ------------------------------------------------------------------------
combinations PROC
; 
; Implementation note: This procedure implements the following algorithm:
;	____n!____
;	r!(n - r)!
; receives: see parameters
; returns: result of above algorithm
; preconditions: n and r must be positive, n must be greater than r
; registers changed: none
; Parameters (in stack style reverse order):
	; argument2 = @result
	; argument1 = r
	; argument0 = n
; ------------------------------------------------------------------------
	pushad
	mov			ebp, esp

	;-------------------------------------------------------------------|
	sub			esp, 16		; LOCAL VARIABLES:							|
	;	 COMB_NUM		= DWORD PTR [ebp - 4]  = numerator				|
	;	 COMB_DEN		= DWORD PTR [ebp - 8]  = denominator			|
	;	 COMB_R_FAC		= DWORD PTR [ebp - 12] = denominator leftside r!|
	;	 COMB_NR_FAC	= DWORD PTR [ebp - 16] = denominator (n - r)!	|
	;-------------------------------------------------------------------|

	COMB_NUMERATOR: ; (n!)
		mov		eax, [EBP + AFTERAD_D0]
		push	eax				; push n

		mov		COMB_NUM, 1
		lea		eax, COMB_NUM
		push	eax				; push @ COMB_NUM (local)
		call	factorial

	COMB_DENOMINATOR: ; r!(n - r)!

		; r!
		mov		eax, [EBP + AFTERAD_D1]
		push	eax				; push r

		mov		COMB_R_FAC, 1
		lea		eax, COMB_R_FAC
		push	eax				; push @ COMB_R_FAC (local)
		call	factorial

		; (n - r)!
		mov		eax, [EBP + AFTERAD_D0]
		sub		eax, [EBP + AFTERAD_D1]
		push	eax				; push (n - r)

		mov		COMB_NR_FAC, 1
		lea		eax, COMB_NR_FAC
		push	eax				; push @ COMB_NR_FAC (local)
		call	factorial

		; multiply together:
		mov		eax, COMB_R_FAC
		mov		ebx, COMB_NR_FAC
		mul		ebx

		mov		COMB_DEN, eax

	COMB_DIVIDE:
		mov		eax, COMB_NUM
		mov		ebx, COMB_DEN
		div		ebx

		mov		ebx, [EBP + AFTERAD_D2]
		mov		[ebx], eax

	COMB_CLEANUP:
	mov		esp, ebp	; remove locals from stack
	popad
	ret
combinations ENDP














; ------------------------------------------------------------------------
factorial PROC
; RECURSIVE procedure to calculate the factorial of any positive number
; Implementation note: This procedure implements the following recursive 
; algorithm:
;	if (n <= 1)
;		return 1;
;	else
;		return n * factorial(n - 1);
;
; receives: starting value 'n' on stack, @sum on stack
; returns: factorial = n*(factorial(n - 1))
; preconditions: n must be positive, argument 0 MUST have a value of 1
; registers changed: none
; Parameters (in stack style reverse order):
	; argument1 = n
	; argument0 = @Final sum of factorial (must be 1 to start)
; ------------------------------------------------------------------------
	pushad
	mov			ebp, esp
	
	mov			eax, [EBP + AFTERAD_D0]		; @final sum of factorial in eax
	mov			eax, [eax]					; final sum of factorial in eax (dereferenced)
	mov			ebx, [EBP + AFTERAD_D1]		; n in ebx

	cmp			ebx, 1
	jbe			FACTORIAL_BASE
	jmp			FACTORIAL_RECURSE

	FACTORIAL_BASE:
		jmp				FACTORIAL_END

	FACTORIAL_RECURSE:
		; multiply finalSum by n
		mul				ebx

		; store in pointer:
		mov				edx, [EBP + AFTERAD_D0]
		mov				[edx], eax

		; n = (n - 1)
		dec				ebx

		; push arguments to stack and call recursively
		push		ebx							; push n
		mov			eax, [EBP + AFTERAD_D0]		
		push		eax							; push @finalSum
		call		factorial

	FACTORIAL_END:
	popad
	ret	8
factorial ENDP







; ------------------------------------------------------------------
showResults PROC
;
; Description: Takes in an answer to a problem, and a user answer and 
;  displays a message according to their equality
; Receives: see parameters
; Returns: none
; Registers Modified: none
; Parameters: (in stack style, reverse order):
	; argument3 = r
	; argument2 = n
	; argument1 = realAnswer
	; argument0 = userAnswer
	pushad
	mov				ebp, esp


	call			CrLf
	mWriteString	showR_answer1
	mov				eax, [ebp + AFTERAD_D3]		; r
	call			writeDec
	mWriteString	showR_answer2
	mov				eax, [ebp + AFTERAD_D2]		; n
	call			writeDec
	mWriteString	showR_answer3
	mov				eax, [ebp + AFTERAD_D1]		; real answer
	call			writeDec
	mWriteString	showR_answer4
	call			CrLf

	; compare user answer to actual answer:
	mov				eax, [ebp + AFTERAD_D0]		; user answer
	mov				ebx, [ebp + AFTERAD_D1]		; real answer
	cmp				eax, ebx
	jne				showResults_WRONG

	showResults_RIGHT:
		mWriteString	showR_Right
		jmp				showResults_CLEANUP

	showResults_WRONG:
		mWriteString	showR_wrong

	showResults_CLEANUP:
	call			CrLf
	mWriteString	showR_LB
	call			CrLf
	popad
	ret 8 
showResults ENDP










; ------------------------------------------------------------------
tryAgain PROC
;
; Description: Asks user if he or she would like to display another 
;  problem. Entering either 'y' or 'Y' will allow the user to play 
;  the game again.
; Receives: see parameters
; Returns: 1 for quit, 0 for play again
; Registers Modified: none
; Parameters: (in stack style, reverse order):
	; argument0 = @try again (DWORD)
	pushad
	mov				ebp, esp

	;-------------------------------------------------------------------|
	sub			esp, MAX_CHARS		; LOCAL VARIABLES:					|
	;	TRY_BUFFER		EQU BYTE PTR [ebp - MAX_CHARS]					|
	;-------------------------------------------------------------------|

	call			CrLf
	mWriteString	tryAgain_prompt
	call			CrLf
	mWriteString	tryAgain_inst


	; read input (into local variable)
		lea				edx, [ebp - 4]
		mov				ecx, 2 ; only read first char entered: 
		call			ReadString

	; calculate input:
		mov				eax, 0 ; zero out
		mov				al, [ebp - 4]

		; ASCII_Y = 121
		cmp				eax, ASCII_Y
		je				TRYAGAIN_YES

		; ASCII_Y_UP = 89
		cmp				eax, ASCII_Y_UP
		jne				TRYAGAIN_NO

	TRYAGAIN_YES:
		mov				eax, [EBP + AFTERAD_D0]
		mov				ebx, 0
		mov				[eax], ebx
		call			CrLf
		jmp				TRYAGAIN_CLEANUP

	TRYAGAIN_NO:
		mov				eax, [EBP + AFTERAD_D0]
		mov				ebx, 1
		mov				[eax], ebx
		call			CrLf
		mWriteString	tryAgain_thanks
		call			CrLf

	TRYAGAIN_CLEANUP:
		mov		esp, ebp	; remove locals from stack
		popad
		ret 8 
tryAgain ENDP





END main
