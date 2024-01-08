.include    "address_map_nios2.s" 

.text  
      
.global _start
_start:
	movia r1, 0xFF200020	# address of first four seven segments
	mov r2, r0				# r2 will be used to load the next letter
	movia r3, message		# r3 will contain the message
	movi r4, 18				# r4 will contain the total number of characters and be used to increment
	
scroll:
	subi r4, r4, 1			# decrement r4 everytime a character is displayed
	ldbu r5, (r3)			# load a byte(character) from the message into r5
	slli r2, r2, 8			# shift r2 right 8
	or r2, r2, r5			# or r2 and r5 to place the next character
	stwio r2, (r1)			# display r2 with new character
	call delay500ms			# wait
	addi r3, r3, 1			# increment to the next character in the message
	bne r4, r0, scroll		# if characters are left, loop back
	movi r4, 3				# set up count for next messages
blink1:
	subi r4, r4, 1			# decrement r4 everytime a message is displayed
	movia r2, 0x49494949	# load message
	stwio r2, (r1)			# display message
	call delay500ms			# wait and fall through to blink2
blink2:
	movia r2, 0x36363636	# load message
	stwio r2, (r1)			# display message
	call delay500ms			# wait
	bne r4, r0, blink1		# if another loop is needed, loop back to blink1
	movi r4, 3				# else reinitialize for next loop
blink3:
	subi r4, r4, 1			# decrement r4 everytime a message is displayed
	movia r2, 0xFFFFFFFF	# load message
	stwio r2, (r1)			# display message
	call delay500ms			# wait
blink4:
	movia r2, 0x00000000	# load message
	stwio r2, (r1)			# display message
	call delay500ms			# wait
	bne r4, r0, blink3		# if another loop is needed, loop back to blink3
	br _start				# else restart
	
#  delay500ms()  -- Delay for 500ms on DE10-Lite
delay500ms:
    movi   r6, 500      # Fall-through to delayNms(1)
                        # Since call is not used, ra properly remains unchanged
delayNms:
    movui  r7, 33333          #  <------.	should really be 33333 on the board(3k for cpulator)
d1msLoop:                     #  <---.  |
    subi   r7, r7, 1          #      |  |
    bne    r7, r0, d1msLoop   #  ----'  |
                              #         |
    subi   r6, r6, 1          #         |
    bne    r6, r0, delayNms   #  -------'

    ret
	
.data
message: # H   E     L     L      O          B      U    F     F     S     -     -    -
.byte	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7F, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00
	
