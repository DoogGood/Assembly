assume cs:code
data segment
db 'welcome to masm!',0
data ends

code segment
start:
	mov dh,24 ;第8行
	mov dl,3 ;第3列
	mov bx,2 ;颜色属性
	mov ax,data
	mov ds,ax
	mov si,0
	
	call show_str
	mov ax,4c00h
	int 21h
	
show_str:
		push bx  ;初始化所用寄存器
		push cx
		push dx
		push si
		push di
		push es
		
		
		mov ax,0b800h   ;es段寄存器指向25x80显存段
		mov es,ax
		mov di,0
		
		
		mov al,dh
		mov ah,160   ;计算行数对应结果
		mul ah
		
		push ax     ;结果放入栈中
		
		mov al,dl   ;计算列对应结果
		mov ah,2
		mul ah
		
		mov di,ax    ;结果放入di中
		pop ax       
		add di,ax   ;设定显存目标位置di
	
show_str1:
		mov cx,ds:[si]  ;cx存储字符串
		jcxz show_str_end       ;判断是否为0
		
		
		mov ax,ds:[si]
		mov es:[di],ax
		mov es:[di+1],bx
		add di,2
		inc si
		jmp show_str1
		
show_str_end:
		
		pop es
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		ret
code ends
end start 