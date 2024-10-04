assume cs:codesg

data segment
db 'welcome to masm!'
data ends


codesg segment
;绿色2h 绿底红色24h 白底蓝色71h
;'welcome to masm!'15个字符
;0722h
start:
	mov ax,0b800h ;段地址
	mov es,ax ;es为目标段地址
	mov ax,data ;ds 存放数据段地址
	mov ds,ax
	
	mov bx,0 ;循环的递增变量
	mov cx,16
	mov si,1600 ;line 显示的位置25x80
	
l1:
	mov ah,2h
	mov al,ds:[bx]
	mov es:[si+64],ax
	
	mov ah,24h
	mov es:[si+64+160],ax
	
	mov ah,71h
	mov es:[si+64+160+160],ax
	
	inc bx
	add si,2
loop l1
	

	mov ax,4c00h
	int 21h
codesg ends
end start
