.global _start
_start:
	movia r1, 0xFF200020		# address of first four seven segments
	movia gp, 0xFF200050		# address of buttons				
	mov r11, r0					# initialize state of buttons to 0
	
initiate1:
	movia r3, pattern1			# r3 will contain the first pattern
    movi r4, 8					# r4 will contain the total number of characters and be used to increment
	mov r2, r0					# r2 will be used to load the next letter	
scroll1:
	mov   r10, r11       		# r10 is "prior state":r10
    ldwio r11, (gp)  			# Read "current state":r11
    bne   r10, r0, continue1    # If "prior state" is "pressed" => loop to continue1
    bne   r11, r0, initiate2    # else if currently "pressed", loop to initiate2
continue1:
	subi r4, r4, 1				# decrement r4 to signify a character being processed
	ldbu r5, (r3)				# load a byte(character) of the message
	slli r2, r2, 8				# shift r2 left by 8
	or r2, r2, r5				# or r2 and r5 to produce new message
	stwio r2, (r1)				# display message
	call delay500ms				# wait
	addi r3, r3, 1				# increment to next character
	bne r4, r0, scroll1			# if more characters are left, loop to scroll1
	br initiate1 				# else loop to initiate1

initiate2:
	movia r8, pattern2			# r8 will contain the second pattern
	movi r4, 8					# r4 will contain the total number of characters and be used to decrement
	mov r2, r0					# r2 will be used to load the next letter
scroll2:
	mov   r10, r11       		# r10 is "prior state":r10
    ldwio r11, (gp)  			# Read "current state":r11
    bne   r10, r0, continue2    # If "prior state" is "pressed" => loop to continue2
    bne   r11, r0, initiate1    # else if currently "pressed", loop to initiate1
continue2:
	subi r4, r4, 1				# decrement r4 to signify a character being processed
	ldbu r5, (r8)				# load a byte(character) of the message
	srli r2, r2, 8				# shift r2 right by 8
	slli r5, r5, 24				# shift r5 left by 24
	or r2, r2, r5				# or r2 and r5 to produce new message
	stwio r2, (r1)				# display message
	call delay500ms				# wait
	addi r8, r8, 1				# increment to next character
	bne r4, r0, scroll2			# if more characters are left, loop to scroll2
	br initiate2				# else loop to initiate2

#  delay500ms()  -- Delay for 500ms on DE10-Lite
delay500ms:
    movi   r6, 500      # Fall-through to delayNms(1)
                        # Since call is not used, ra properly remains unchanged
delayNms:
    movui  r7, 33333           #  <------.	should really be 33333 on the board(3k for cpulator)
d1msLoop:                     #  <---.  |
    subi   r7, r7, 1          #      |  |
    bne    r7, r0, d1msLoop   #  ----'  |
                              #         |
    subi   r6, r6, 1          #         |
    bne    r6, r0, delayNms   #  -------'

    ret
	
.data
pattern2: 
.byte	0x4F, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
pattern1:
.byte	0x79, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
