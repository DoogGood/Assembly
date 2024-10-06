assume cs:codesg
data segment

db 20 dup(0)

data ends



codesg segment
start:
	mov ax,data
	mov ds,ax
	mov ax,12666
	mov si,20
	mov dx,0
	call dtoc
	mov ax,4c00h
	int 21h
dtoc:
	push bx
	mov bx,10
	div bx    ;除法结果ax为商，dx为余数
	add dx,30h
	mov ds:[si],dx
	mov cx,ax
	mov dx,0
	dec si
	dec si
	jcxz ok
	jmp dtoc
	
ok:	pop bx
	ret


codesg ends
end start