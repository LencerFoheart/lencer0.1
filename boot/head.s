#
# Small/boot/head.s
#
# (C) 2012-2013 Yafei Zheng
# V0.0 2012-12-7 10:44:39
# V0.1 2013-01-30 02:40:57
#
# Email: e9999e@163.com, QQ: 1039332004
#

# **************************************************************************************************
# ��������GNU as 2.21.1
#
# head.s����Ҫ�������£�
#	1.��������GDT��IDT���ں˶�ջ������0�û�̬��ջ��
#	2.����Ĭ���ж�
# **************************************************************************************************

.globl startup_32

SCRN_SEL	= 0x18				# ��Ļ��ʾ�ڴ��ѡ���

.text
startup_32:
	movl	$0x10,%eax
	mov		%ax,%ds
	lss		init_stack,%esp
# ���µ�λ����������GDT,IDT
	call	setup_gdt
	call	setup_idt
	movl	$0x10,%eax
	mov		%ax,%ds
	mov		%ax,%es
	mov		%ax,%fs
	mov		%ax,%gs
	lss		init_stack,%esp
# OK! We begin to run the MAIN function now.
	movl	$0,scr_loc
	pushl	$main
#debug:
#	jmp		debug
	ret

# ----------------------------------------------------
.align 4
setup_gdt:
	lgdt	gdt_new_48
	ret

.align 4
setup_idt:
	pushl	%edx
	pushl	%eax
	pushl	%ecx
	pushl	%edi
	lea		ignore_int,%edx
	movl	$0x00080000,%eax
	mov		%dx,%ax
	movw	$0x8e00,%dx			# �ж������ͣ���Ȩ��0
	lea		idt,%edi
	movl	$256,%ecx
rp:	movl	%eax,(%edi)
	movl	%edx,4(%edi)
	addl	$8,%edi
	dec		%ecx
	cmpl	$0,%ecx
	jne		rp
	lidt	idt_new_48
	popl	%edi
	popl	%ecx
	popl	%eax
	popl	%edx
	ret

.align 4
write_char:
	pushl	%ebx
	pushl	%gs
	movw	$SCRN_SEL,%bx
	mov		%bx,%gs
	movl	scr_loc,%ebx
	shl		$1,%ebx
	movw	%ax,%gs:(%ebx)
	shr		$1,%ebx
	inc		%ebx
	cmpl	$2000,%ebx
	jne		1f
	movl	$0,%ebx
1:	movl	%ebx,scr_loc
	popl	%gs
	popl	%ebx
	ret

.align 4
ignore_int:
	pushl	%ds
	pushl	%eax	
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	movl	$0x0449,%eax		# �ַ�"I"�����ԣ���ɫ �ڵ� ����˸ ������
	movl	$0x10,%ebx
	mov		%bx,%ds
	call	write_char
	xorb	%al,%al
	inb		$0x64,%al			# 8042������64h�˿�λ0���鿴��������Ƿ��������������һ���ַ�
	andb	$0x01,%al
	cmpb	$0, %al
	je		1f
	inb		$0x60,%al			# ���������������һ���ַ�
	mov		$0x02,%ah
	movl	$0x10,%ebx
	mov		%bx,%ds
	call	write_char
# ����ע�͵Ĵ��������μ������룬Ȼ�����������ڸ�λ�������롣��8042��Ҳ���Բ���
#	inb		$0x61,%al
#	orb		$0x80,%al
#	.word	0x00eb,0x00eb		# �˴���2��jmp $+2��$Ϊ��ǰָ���ַ������ʱ���ã���ͬ
#	outb	%al,$0x61
#	andb	$0x7f,%al
#	.word	0x00eb,0x00eb
#	outb	%al,$0x61
1:	movb	$0x20,%al			# ��8259A��оƬ����EOI����,����ISR�е���Ӧλ����
	outb	%al,$0x20
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	popl	%ds
	iret

# ----------------------------------------------------
scr_loc:						# ��Ļ��ǰ��ʾλ�ã������Ͻǵ����½�������ʾ���ж��ַ�
	.long 0

# GDT,IDT����
.align 4
gdt_new_48:
	.word 256*8-1
	.long gdt

idt_new_48:
	.word 256*8-1
	.long idt

.align 8
gdt:
	.quad 0x0000000000000000
	.quad 0x00c09a00000007ff	# ����Σ�ѡ���0x08��
	.quad 0x00c09200000007ff	# ���ݶΣ�ѡ���0x10��
	.quad 0x00c0920b80000002	# ��ʾ�ڴ�Σ�ѡ���0x18����ʱ
	.fill 252,8,0

idt:
	.fill 256,8,0

# �ں˳�ʼ����ջ��Ҳ�Ǻ�������0���û�ջ
.align 4
	.fill 128,4,0
init_stack:
	.long init_stack
	.word 0x10
