# Name: Varun Poondi
# Net-ID: VMP190003
# Prof: Yi Zhao
# Date: 11/29/2021

# This program employs the use of stacks to implement the mergeSort algorithm. It works by sorting the values by shiftvalue  2, then 4, then
# 8, 16, and finally 32 numbers. Since there is only 1 stack available, the newly updated list is stored at the top of the old list.
# For example if we currently have a list that is sorted by 2 elements at a time, we the sort 4 elements at a time and store it on top of 
# the old list. We the merge the newly sorted list to the old sorted list to complete our mergeSort for that shift value. 
# If the final shift value equals to the size of the list, that means our list is completely sorted and we can print out the stack
# Implements concepts of sorting from project 5

# Program Flow
# 1) Get user Input 
# 2) Sort input by current shift val
# 3) Merge new array into main array
# 4) Until the current shift val == the main array, keep on repeating steps 2 and 3
# 5) Print out the sorted list
# 6) Exit Program


# Constant Registers Used (Important):
# $t0:	holds size of the number of user inputs
# $t8:	points to the bottom of the stack
# $t9: 	points to the top of the stack
# $s2:	holds in value of sub array 1
# $s3: 	holds in value of sub array 2

# The rest of the registers are often used interchangable, but these are
# some of the import constants to take notice. 



.data
	prompt1: .asciiz "Number of Integers: "
	prompt2: .asciiz "Enter Integer: "
	newLine: .asciiz "\n"
	space: .asciiz " "
	
	currentStack: .asciiz "Current Stack: "

.text
.globl main

main:
	li $v0, 4		# print out prompt1
	la $a0, prompt1 
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0 		# stack size in t0
	
	addi $t1, $zero, 0	# counter
	addi $t2, $zero, 0	# result from slt t1 and t0

	move $t8, $sp
	
	fori:	
		addi $t1, $t1, 1
		
		li $v0, 4		# print out prompt1
		la $a0, prompt2 
		syscall
	
		li $v0, 5
		syscall
		move $s0, $v0 		# stack size in t0

		addi $sp, $sp, -4	# move to the next address
		sw $s0, 0($sp)		# save data to the first open spot in the stack
		
		move $t9, $sp
		
		slt $t2, $t1, $t0 	# if x < 8 return 1 else 0
		bgtz $t2, fori		# branch if the counter is greater than the stack size
	
	# newline	
	li $v0, 4
	la $a0, newLine
	syscall
	
	addi $t8, $t8, -4 		# set t8 to point to the beginning of the stack
	addi $t9, $t9, 0  		# set t9 to point to the end of the stack	
	
	addi $t1, $zero, 1
	sort:
		beq $t1, $t0, printOutStack				# if out shift val equals the stack size, the list is sorted		
		move $s5, $t1						# holds the size of sub array 1
		move $s6, $t1 						# holds the size of sub array 2	
		add $s7, $s5, $s6					# hold a edditable copy of the shift amountt
		move $s4, $t8						# current position to start, will change after each shift	
		addi $s0, $zero, 0
		
		li $t5, 0						# starting location 					
		mul $t6, $t1, 4						# starting location + 1
	
		loop:
			beq $s0, $t0, exitLoop				# if our counter = the stack size, then we are done sorting with our current shift val
			blez $s7, shifter				# if total number of values in list is either less than equal to zero, exit	

			sub $s2, $s4, $t5				# shift amount = (C * shift) + 4
			lw $s2, 0($s2)					# store value A
			sub $s3, $s4, $t6				# get the updated shift amount 	
			lw $s3, 0($s3)					# store value B

			beqz $s5, extractList2				# exhaustive case A
			beqz $s6, extractList1				# exhaustive case B

			slt $t4, $s2, $s3				# 32 < -32 , 0
			bgtz $t4, extractList2				# if A < B, extract from list 2
			beqz $t4, extractList1				# else extract from list 1
		
		extractList1:
			addi $sp, $sp, -4				# move to the next address
			sw $s2, 0($sp)					# store the val into the stack
			subi $s5, $s5, 1				# decrement sublist size
			add $t5, $t5, 4					# move to the next index
			j getNext					

		extractList2:
			addi $sp, $sp, -4				# move to the next address
			sw $s3, 0($sp)					# store the val into the stack
			subi $s6, $s6, 1				# decrement sublist size
			add $t6, $t6, 4					# move to the next index
			j getNext		

		getNext:
			addi $s0, $s0, 1				# increment the counter 
			subi $s7, $s7, 1				# subtract from shift total and update buffer
			j loop

		shifter:
			move $t5, $t6					# t5 is needed to update address of t6
			mul $t6, $t1, 4					# shift 4 
			add $t6, $t6, $t5				# update new address
			
			move $s5, $t1						# holds the size of sub array 1
			move $s6, $t1 						# holds the size of sub array 2	
			add $s7, $s5, $s6					# hold a edditable copy of the shift amount
			
			j loop

		exitLoop:
			mul $t1, $t1, 2					# update the shift val
			j merge					# perform merge
			
	merge:			
		move $sp, $t8			# points to the end of the stack
		move $s4, $t9			# points to the top of the stack
		addi $s4, $s4, -4		# points to the top + 1 of the stack
		addi $s5, $zero, 0		# counter
		fori3:
			lw $s3, 0($s4)		# get the value from the top stack
			sw $s3, 0($sp)		# store the value into the bottom stack
			addi $sp, $sp, -4	# update top stack address
			addi $s4, $s4, -4	# update bottom stack address
			addi $s5, $s5, 1	# update counter
			bne $s5, $t0, fori3	# brack back to fori3 if counter != stack size
		
		move $sp, $t9			# reset stack pointer
		j sort				# jump back to the sort

	printOutStack:
		addi $t1, $zero, 0
		addi $sp $sp, -4
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		li $v0, 4
		la $a0, currentStack
		syscall
		
		fori2:
			addi $t1, $t1, 1		
			addi $sp $sp 4			# enter into the stack
			lw $s0, 0($sp)			# get the current element in the stack	
				
			li $v0, 1
			move $a0, $s0			# print out current val
			syscall
			
			li $v0, 4
			la $a0, space			# print space
			syscall
			
			slt $t2, $t1, $t0		# if the counter != the stack size, branch to the fori2 
			bnez $t2, fori2
			move $sp $t9			# reset the sp to the top of the stack
		
		j exit 					# exit the program
		
	exit:
		li $v0, 10
		syscall
		
		
		