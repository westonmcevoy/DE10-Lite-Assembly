.text
.global sum_two
sum_two:
	add r2, r4, r5
	ret
.global op_three
op_three:
	subi sp, sp, 8
	stw ra, 4(sp)
	stw r6, (sp)
	call op_two		# Test with sum_two
	ldw r6, (sp)
	mov r4, r2
	mov r5, r6
	call op_two		# Test with sum_two
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret
.global fibonacci
fibonacci:
	subi sp, sp, 12
	stw ra, 8(sp)

	movi r1, 1
	ble r4, r1, done
	subi r4, r4, 1
	stw r4, 4(sp)
	call fib
	ldw r4, 4(sp)
	mov r3, r2
	
	subi r4, r4, 1
	stw r3, (sp)
	call fib
	ldw r3, (sp)
	mov r5, r2
	add r2, r3, r5
	ldw ra, 8(sp)
	addi sp, sp, 12
	ret	
done:
	mov r2, r4 
	ldw ra, 8(sp)
	addi sp, sp, 12
	ret


