# CS 61C Summer 2015 Project 2-2 
# linker-tests/test_linker_utils.s

#==============================================================================
#                         linker_utils.s Test Cases
#==============================================================================

.include "../linker-src/linker_utils.s"
.include "test_core.s"

#-------------------------------------------
# Test Data - Feel free to add your own
#-------------------------------------------

.data
# Test strings
test_label1:	.asciiz "Label 1"
test_label2:	.asciiz "Label 2"
test_label3:	.asciiz "Label 3"
test_label4:	.asciiz "Label 4"
test_label5:	.asciiz "Label 5"
test_label6:	.asciiz "Label 6"
test_label7:	.asciiz "Label 7"
test_label8:	.asciiz "Label 8"

# Symbol Table
sym_7:		.word test_label7 0xc 0
sym_6:		.word test_label6 0xf4 sym_7
sym_5:		.word test_label5 0xabc sym_6
sym_4:		.word test_label4 0x24 sym_5
sym_3:		.word test_label3 0xa8 sym_4
sym_2:		.word test_label2 0x0aaaaaac sym_3
sym_tbl:		.word test_label1 0x0ababab0 sym_2

# Relocation Table
rel_5:		.word test_label5 40 0
rel_4:		.word test_label8 100 rel_5
rel_3:		.word test_label2 128 rel_4
rel_2:		.word test_label1 32 rel_3
rel_tbl:		.word test_label3 24 rel_2

.globl main
.text
#-------------------------------------------
# Test driver
#-------------------------------------------
main:
	print_str(test_header_name)
	
	print_newline()
	jal test_inst_needs_relocation
	
	print_newline()
	jal test_relocate_inst

	li $v0, 10
	syscall

#-------------------------------------------
# Tests inst_needs_relocation() from linker_utils.s
#-------------------------------------------	
test_inst_needs_relocation:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	print_str(test_inst_needs_relocation_name)
	
	li $a0, 0x0c001234
	jal inst_needs_relocation
	check_int_equals($v0, 1)
	
	li $a0, 0x08100010
	jal inst_needs_relocation
	check_int_equals($v0, 1)
	
	li $a0, 0x09100010
	jal inst_needs_relocation
	check_int_equals($v0, 1)
	
	li $a0, 0x2a00c0f0
	jal inst_needs_relocation
	check_int_equals($v0, 0)
	
	li $a0, 0x0
	jal inst_needs_relocation
	check_int_equals($v0, 0)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra

#-------------------------------------------
# Tests calc_relocate_inst() from linker_utils.s
#-------------------------------------------
test_relocate_inst:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	print_str(test_relocate_inst_name)
	
	la $a0, 0x0c001234
	li $a1, 40
	la $a2, sym_tbl
	la $a3, rel_tbl
	jal relocate_inst
	check_uint_equals($v0, 0x0c0002af)
	
	la $a0, 0x09100010
	li $a1, 32
	la $a2, sym_tbl
	la $a3, rel_tbl
	jal relocate_inst
	check_uint_equals($v0, 0x0aaeaeac)
	
	# Not in symbol table
	la $a0, 0x0c001234
	li $a1, 100
	la $a2, sym_tbl
	la $a3, rel_tbl
	jal relocate_inst
	check_int_equals($v0, -1)
	
	# Not in reloc table
	la $a0, 0x0c001234
	li $a1, 200
	la $a2, sym_tbl
	la $a3, rel_tbl
	jal relocate_inst
	check_int_equals($v0, -1)
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra


.data
test_header_name:		.asciiz "Running test linker_utils:\n"

test_inst_needs_relocation_name:	.asciiz "Testing inst_needs_relocation():\n"
test_relocate_inst_name:	.asciiz "Testing relocate_inst():\n"
