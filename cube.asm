assume cs:codesg
data segment
	db 'wordabc',0
	db 'unix',0
	db 'wind',0
	db 'good',0
data ends

codesg segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	

	mov cx,4
lp:	
call cap_cuberest
inc si
loop lp
	
	mov ax,4c00h
	int 21h
	
cap_cuberest: ;子程序初始化
	push cx
	cap_cube1:	
		mov ch,0
		mov cl,[si]
		jcxz ok
		and byte ptr [si],11011111b
		inc si
		jmp cap_cube1

	ok:
		pop cx
		ret


codesg ends
end start
