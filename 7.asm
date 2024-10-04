assume cs:code
data segment
 db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984','1985'   ;byte  8位数据  一共84个字节（年元素）
 db '1986','1987','1988','1989','1990','1991','1992','1993','1994','1995'
 
 dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514,345980  ;double word 32位数据   一共84个字节（收入元素）
 dd 590827,803530,1183000,1843000,2758000,3753000,4649000,5937000
 
 dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226   ;word 16位数据    一共42字节  （雇员人数元素）
 dw 11542,14430,15257,17800
data ends

stack segment
 dw 0,0,0,0,0,0,0
stack ends

table segment
 db 21 dup ('year summ ne ?? ')  ;人均数据:5,3,2a...
table ends  

code segment
start:  ;开始用语

mov ax,data  ;ds段寄存器放data段地址 076a:0
mov ds,ax
mov ax,table  ;es段寄存器放目标table段地址 0779:0
mov es,ax


mov cx,21  ;21次循环
mov si,0  ;si归零，用于记录偏移
mov bx,0  ;bx归零

put:  ;存放year和income
				mov ax,ds:[si]	;year 12
				mov es:[bx],ax
				mov ax,ds:[si+2]  ;year 34
				mov es:[bx+2],ax
				mov ax,ds:[si+84]  ;income 12
				mov es:[bx+6],ax
				mov ax,ds:[si+84+2] ;income 34
				mov es:[bx+8],ax
				add si,4
				add bx,10h
loop put

				mov cx,21
				mov si,0
				mov bx,0
emp:  ;存放雇员
				mov ax,ds:[si+84+84]
				mov es:[bx+10],ax
				add si,2
				add bx,10h
loop emp

				
				
				mov cx,21
				mov si,0
				mov di,0
				mov bx,0
ave:  ;计算雇员
				mov ax,ds:[si+84]  ;低位放ax，高位放dx，偏移越小位越小
				mov dx,ds:[si+84+2]
				div word ptr ds:[di+84+84]
				mov es:[bx+0dh],ax
				add si,4
				add di,2
				add bx,10h
loop ave

				
				

				
				; 拿捏
				

mov ax,4c00h   ;结束语
int 21h

code ends
end start



