# Adapted from Kooros Stopwatch code by Wes McEvoy

.section .reset, "ax"
.global _start
_start:
    movia    sp, 0x1000      # Initialize stack
    movia    gp, 0xFF200000  # Base address for MMIO
    jmpi     main

#======== Exception Section ========    
.section .exceptions, "ax"
ExceptionHandler:          # Address 0x00000020
    # "Internal Exception" (not an IRQ) => return
    rdctl    et, ipending  # Determine what interrupt occurred
    bne      et, r0, ExternalException	# If software interrupt, return
    eret                   # No IRQ => return
ExternalException:
    subi    ea, ea, 4      # Rewind pc to restart interrupted instruction

    # ISR Prologue		   # Save ra and initialize other variables
    subi    sp, sp, 4
	stw 	ra, (sp)
	movi	r3, 3
	movi	r6, 6
	
	
	

    # Assure IRQ# is IRQ#1 (Pushbutton PPI), none other.
    andi    r2, et, 0b10    	# IRQ#1 => Pushbutton PPI
    beq     r2, r0, ISR_NotIRQ1	# Else go to timer interrupt
    
    ldwio   et, 0x5C(gp)    	# Read  Pushbutton Edgecapture register
    stwio   et, 0x5C(gp)    	# Reset Pushbutton Edgecapture register

    # Button 1 adds 1 to LEDs, Button 0 subtracts
	beq		et, r3, ISR_Done	# If both pressed, ignore
    subi    et, et, 1       	# {2,1} -> {1,0}
    beq     et, r0, Pushbutton0
Pushbutton1:    # SLOWER
	beq 	r4, r0, ISR_Done	# If at minimum speed, ignore
	subi 	r4, r4, 1			# Decrement speed
	movi    r2, 0b1000			# Stop timer momentarily
	stwio   r2, 0x2004(gp)  	# STOP
	
	stwio   r2, 0x2004(gp)  	# STOP
	ldwio   r2, 0x200c(gp)		# Load upper bits
	slli	r2, r2, 16			# Shift to make room for lower bits
    ldwio   r5, 0x2008(gp)      # Load lower bits
	or		r2, r2, r5			# Or low and high bits
	
	slli    r2, r2, 1			# Reduce speed by half
	
	stwio   r2, 0x2008(gp)  	# Write lower 16 bits
    srli    r2, r2, 16			# Shift
    stwio   r2, 0x200c(gp)		# Write upper bits
	
	movi    r2, 0b111			# Restart
	stwio   r2, 0x2004(gp)  	# START | CONT | ITO
	
	br ISR_Done
Pushbutton0:     # FASTER
	beq		r4, r6, ISR_Done	# If at maximum speed, ignore
	addi	r4, r4, 1			# Increment speed
	movi    r2, 0b1000			# Stop timer momentarily
	stwio   r2, 0x2004(gp)  	# STOP
	ldwio   r2, 0x200c(gp)		# Load upper bits
	slli	r2, r2, 16			# Shift to make room for lower bits
    ldwio   r5, 0x2008(gp)      # Load lower bits
	or		r2, r2, r5			# Or low and high bits
	
	srli	r2, r2, 1			# Increase speed by double
	
	stwio   r2, 0x2008(gp)  	# Write lower 16 bits
    srli    r2, r2, 16			# Shift
    stwio   r2, 0x200c(gp)		# Write upper bits
	
	movi    r2, 0b111			# Restart
	stwio   r2, 0x2004(gp)  	# START | CONT | ITO

    br ISR_Done
ISR_NotIRQ1:
    andi    r2, et, 0b01    	# IRQ#0 => First Interval Timer
    beq     r2, r0, ISR_Done	# If no interrupt, exit
    
    # Reset Timer's IRQ1 assertion
    stwio   r0, 0x2000(gp)  	# Reset the "TO" bit

    # Display Message
	bne		r8, r0, scroll		# Skip initialization if mid-message
initialize:
	movia   r7, message			# Load message
	movi 	r8, 15				# Number of characters
	mov 	r9, r0				# Initialize "scroll"
	br scroll
	
scroll:
	subi r8, r8, 1				# Decrement characters
	ldbu r10, (r7)				# Load one character
	slli r9, r9, 8				# Shift message
	or r9, r9, r10				# Or in new character
	stwio r9, 0x20(gp)			# Write back
	addi r7, r7, 1				# Increment characters

ISR_Done:    
    # ISR Epilogue
    ldw     ra, (sp)
    addi    sp, sp, 4

    eret
	
#====== Code Section: Main Prog ======    
.text
main:
    # Configure Pushbutton Keyswitches for IRQ#1
    movi    r2, 0b11        # Enable both Pushbutton Keyswitches
    stwio   r2, 0x58(gp)    # Pushbutton PPI Interrupt Mask register

    # Configure First Timer to generate 100Hz IRQ#0
    movia   r2, 100000000   # Divisor 1e8: 1Hz
    stwio   r2, 0x2008(gp)  # Lower 16-bits of divisor
    srli    r2, r2, 16
    stwio   r2, 0x200c(gp)  # Upper 16-bits of divisor
    movi    r2, 0b111
	stwio   r2, 0x2004(gp)  # START | CONT | ITO

    # 7-Segment LED initial value
	stwio	r0, 0x20(gp)
    stwio   r0, 0x30(gp)
	movi	r4, 3			# Initialize speed

    movi    r2, 0b11        # Enable IRQ#0 & IRQ#1
    wrctl   ienable, r2
    
    movi    r2, 0b01        # Set status.PIE bit
    wrctl   status, r2      # Enabling Processor Interrupts
	
loop:
	br loop					# Loop for main

.data
message: # H   E     L     L      O          B      U    F     F     S     
.byte	0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7F, 0x3E, 0x71, 0x71, 0x6D, 0x00, 0x00, 0x00, 0x00