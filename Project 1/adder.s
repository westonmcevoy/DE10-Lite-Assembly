.include    "address_map_nios2.s" 

.text        

.global     _start 
_start:                         
        movia   r2, LED_BASE    # Address of LEDs
        movia   r3, SW_BASE     # Address of switches

LOOP:                           
        ldwio   r4, (r3)        # Read the state of switches
        andi    r5, r4, 0b1111100000
        srli    r5, r5, 0x5
        andi    r6, r4, 0b0000011111
        add		r7, r5, r6
        stwio   r7, (r2)
        br      LOOP            
.end         
