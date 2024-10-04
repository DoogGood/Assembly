
; =================================================
; Name:   Greedy snake
; Date:   2023-12-13
; email:  liqinglin0314@aliyun.com
; =================================================

assume cs:codeseg, ds:dataseg, ss:stackseg

dataseg segment

  ; 蛇身体坐标数据
  snakeBody   dw 1001 dup (0)

  ; 身体图案
  body        db 0dbh
  ; 身体颜色
  snakeColor  db 02h
  ; 食物坐标位置
  food        dw 0
  ; 食物颜色
  foodColor   db 04h
  ; 原来 int9 中断地址暂存
  oldint9     dw 2 dup (0)
  ; 状态：0 游戏中 1 退出 2 暂停 3 游戏失败 4 准备
  gameStatus  db 4
  ; 初始方向
  initTarget  db 'R'
  ; 方向
  target      db 'R'
  ; 速度
  speed       dw 05h
  ; 初始长度
  initLen     dw 3
  ; 长度
  len         dw 3
  ; 得分
  score       dw 0
  ; 开始提示信息
  startStr    db "                                                                                "
              db "                       Welcome to Greedy snake!                                 "
              db "                                                                                "
              db "                       Author: Allen                                            "
              db "                       Email : liqinglin0314@aliyun.com                         "
              db "                                                                                "
              db "                       Instruction:                                             "
              db "                                                                                "
              db "                                                    Num1   slow                 "
              db "                                                    Num2                        "
              db "              w                P    suspend         Num3                        "
              db "                               R    restart         Num4                        "
              db "          A   S   D            ESC  exit            Num5   fast                 "
              db "                                                                                ", 0

  ; 游戏结束提示
  gameoverStr db "GAME OVER!", 0
  ; 游戏得分提示
  scoreStr    db "Your score is", 0
  ; 重玩提示
  restartStr  db "Press the R key to restart!", 0
  ; 种子
  seed        dw 1998h 
  ; 种子
  seed2       dw 0314h

dataseg ends

stackseg segment

  db 128 dup (0)

stackseg ends

codeseg segment

  start:  mov ax, stackseg
          mov ss, ax
          mov sp, 128

          mov ax, dataseg
          mov ds, ax

          ; 安装 int9 中断按键服务
          call short instKey

          ; 清屏
          call short clearDis

          ; 准备界面
          call short readly
readly_s1:cmp gameStatus[0], 4
          je readly_s1

          ; 初始化程序
          call short init

      s:  ; 运动
          call short run

          ; 游戏暂停
suspend:  cmp gameStatus[0], 2
          je suspend

          ; 游戏失败
game_fail:cmp gameStatus[0], 3
          je game_fail

          ; 游戏正常循环
          cmp gameStatus[0], 0
          je s

          ; 复原之前 int9 的中断程序
          call short unKey

          mov ax, 4c00h
          int 21h

          ; 显示单个字符函数 
          ; @ dh 行 
          ; @ dl 列 
          ; @ ch 颜色
          ; @ cl 内容
display1: push es
          push di
          push ax

          mov ax, 0b800h
          mov es, ax
          mov di, 0

          mov al, 160
          mul dh
          add di, ax

          mov al, 2
          mul dl
          add di, ax

          mov word ptr es:[di], cx

          pop ax
          pop di
          pop es
          ret

          ; 显示单个方块函数 
          ; @ dh 行 
          ; @ dl 列 
display2: push es
          push di
          push ax
          push ds

          mov ax, dataseg
          mov ds, ax

          mov ax, 0b800h
          mov es, ax
          mov di, 0

          mov al, 160
          mul dh
          add di, ax

          mov al, 4
          mul dl
          add di, ax

          mov word ptr es:[di], cx
          mov word ptr es:[di + 2], cx

          pop ds
          pop ax
          pop di
          pop es
          ret

          ; 游戏准备界面
  readly: push es
          push di
          push ax
          push ds
          push cx
          push bx

          mov ax, dataseg
          mov ds, ax

          call short dis_logo

          mov ax, 0b800h
          mov es, ax
          mov di, 7 * 160

          mov bx, 0
          mov ch, 0
  red_s1: mov cl, startStr[bx]
          jcxz red_end
          mov byte ptr es:[di], cl
          mov byte ptr es:[di + 1], 02h
          inc bx
          add di, 2
          jmp red_s1

 red_end: pop bx
          pop cx
          pop ds
          pop ax
          pop di
          pop es
          ret

          ; logo显示
dis_logo: push ax
          push ds
          push cx
          push dx
          
          mov ax, dataseg
          mov ds, ax

          mov dh, 4
          mov dl, 6

          mov cx, 6
 logo_s1: push cx
          mov ch, snakeColor[0]
          mov cl, body[0]
          call short display2
          pop cx
          inc dl
          loop logo_s1

          mov cx, 2
 logo_s2: push cx
          mov ch, snakeColor[0]
          mov cl, body[0]
          call short display2
          pop cx
          dec dh
          loop logo_s2

          mov cx, 7
 logo_s3: push cx
          mov ch, snakeColor[0]
          mov cl, body[0]
          call short display2
          pop cx
          inc dl
          loop logo_s3

          mov dh, 3
          mov dl, 24
          mov ch, foodColor[0]
          mov cl, body[0]
          call short display2

          pop dx
          pop cx
          pop ds
          pop ax
          ret

          ; 游戏结束
 dis_g_o: push es
          push di
          push ax
          push ds
          push cx
          push bx

          mov ax, dataseg
          mov ds, ax

          mov gameStatus[0], 3

          mov ax, 0b800h
          mov es, ax
          mov di, 10 * 160 + 70

          ; GAME OVER!
          mov bx, 0
          mov ch, 0
  dis_s1: mov cl, gameoverStr[bx]
          jcxz dis_scord
          mov byte ptr es:[di], cl
          mov byte ptr es:[di + 1], 82h
          inc bx
          add di, 2
          jmp dis_s1

          ; SCORE
dis_scord:mov bx, 0
          mov ch, 0
  dis_s2: mov cl, scoreStr[bx]
          jcxz dis_press
          mov byte ptr es:[di + 292], cl
          mov byte ptr es:[di + 293], 82h
          inc bx
          add di, 2
          jmp dis_s2

          ; Press the R key to restart
dis_press:mov bx, 0
          mov ch, 0
  dis_s3: mov cl, restartStr[bx]
          jcxz dis_nu
          mov byte ptr es:[di + 292 + 284], cl
          mov byte ptr es:[di + 293 + 284], 82h
          inc bx
          add di, 2
          jmp dis_s3

  dis_nu: ; 显示得分
          mov ax, score[0]
 dis_nu1: mov bl, 10
          div bl

          cmp ax, 0
          je dis_end
          add ah, 48
          mov byte ptr es:[di + 292 + 8 - 54], ah
          mov byte ptr es:[di + 293 + 8 - 54], 84h

          mov ah, 0
          sub di, 2
          
          jmp dis_nu1

 dis_end: pop bx
          pop cx
          pop ds
          pop ax
          pop di
          pop es
          ret

          ; 重置游戏
restart:  push ax
          push ds

          mov ax, dataseg
          mov ds, ax

          ; 清屏
          call short clearDis

          ; 速度复原
          mov speed[0], 5h

          ; 积分清空
          mov score[0], 0

          ; 初始化方向
          mov al, initTarget[0]
          mov target[0], al

          ; 蛇长度初始化
          mov ax, initLen[0]
          mov len[0], ax

          ; 调用初始化函数
          call short init

          pop ds
          pop ax
          retf

          ; 显示完整蛇身体
 disAll:  push ax
          push ds
          push bx
          push cx

          mov ax, dataseg
          mov ds, ax

          mov bx, 0
          mov cx, len[0]
 all_s:   mov dx, snakeBody[bx]
          push cx
          mov ch, snakeColor[0]
          mov cl, body[0]
          call short display2
          pop cx
          add bx, 2
          loop all_s
          
          pop cx
          pop bx
          pop ds
          pop ax
          ret

          ; 消除位移之后，尾部最后一个方块
clearend: push ax
          push ds
          push dx
          push cx
          push bx
          
          mov ax, dataseg
          mov ds, ax

          mov bx, len[0]
          add bx, bx
          mov dx, snakeBody[bx]
          mov cx, 0
          call short display2

          pop bx
          pop cx
          pop dx
          pop ds
          pop ax
          ret

          ; 安装中断按键程序
instKey:  push ax
          push ds
          push si
          push es
          push di
          push cx

          mov ax, dataseg
          mov ds, ax

          mov ax, 0
          mov es, ax

          push es:[9 * 4]
          pop oldint9[0]
          push es:[9 * 4 + 2]
          pop oldint9[2]

          mov ax, seg do0
          mov ds, ax
          mov si, offset do0

          mov ax, 0
          mov es, ax
          mov di, 200h

          mov cx, offset do0end - offset do0
          cld
          rep movsb

          mov word ptr es:[9 * 4], 200h
          mov word ptr es:[9 * 4 + 2], 0

          pop cx
          pop di
          pop es
          pop si
          pop ds
          pop ax
          ret

          ; 恢复之前 int9 程序指向
  unKey:  push ax
          push es

          mov ax, dataseg
          mov ds, ax

          mov ax, 0
          mov es, ax

          push oldint9[0]
          pop es:[4 * 9]
          push oldint9[2]
          pop es:[4 * 9 + 2]

          pop es
          pop ax
          ret

          ; 初始化
   init:  ; 设置初始蛇的身体数据
          call short set_ibd
          
          ; 显示蛇的身体
          call short disAll

          ; 随机生成食物
          call short random

          ret

          ; 设置初始蛇的身体数据
 set_ibd: push ax
          push ds
          push dx
          push bx
          push cx

          mov ax, dataseg
          mov ds, ax

          mov dh, 12
          mov dl, 15
          mov bx, 0
          add dl, byte ptr len[1]
          mov cx, len[0]
 ibd_s0:  mov snakeBody[bx], dx
          dec dl
          add bx, 2
          loop ibd_s0

          pop cx
          pop bx
          pop dx
          pop ds
          pop ax
          ret

          ; 运动
     run: push ax
          push ds
          push dx
          push cx
          
          mov ax, dataseg
          mov ds, ax

          mov dx, snakeBody[0]

          cmp target[0], 'U'
          jne run_D
          dec dh
          jmp run_dis
          
   run_D: cmp target[0], 'D'
          jne run_L
          inc dh
          jmp run_dis

   run_L: cmp target[0], 'L'
          jne run_R
          dec dl
          jmp run_dis

   run_R: cmp target[0], 'R'
          jne run_over
          inc dl

 run_dis: ; 运动
          call short move
          call short check
          ; 判断是否游戏结束
          cmp gameStatus[0], 0
          jne run_over
          
          ; 显示食物
          mov dx, food[0]
          mov cl, body[0]
          mov ch, foodColor[0]
          call short display2

          ; 消除位移之后最后一个尾巴块
          call short clearend

          ; 显示全部身体
          call short disAll

          ; 延时
          call short delay

run_over: pop cx
          pop dx
          pop ds
          pop ax
          ret

          ; 蛇身体列表集体向高位位移一个字
          ; dx 新的蛇头的坐标
          ; 
    move: push ax
          push bx
          push ds

          mov ax, dataseg
          mov ds, ax

          mov bx, len[0]
          add bx, bx

  move_s: mov ax, snakeBody[bx - 2]
          mov snakeBody[bx], ax
          sub bx, 2
          cmp bx, 0
          jne move_s

          mov snakeBody[0], dx

          pop ds
          pop bx
          pop ax
          ret

          ; 校验是否违规结束 或 吃到食物
   check: push ax
          push ds
          push cx
          push di

          mov ax, dataseg
          mov ds, ax

          mov ax, snakeBody[0]

          ; 碰撞右侧墙壁
          cmp al, 40 - 1
          ja g_o

          ; 碰撞左侧墙壁
          cmp al, 0
          jb g_o

          ; 碰撞上方墙壁
          cmp ah, 0
          jb g_o

          ; 碰撞下方墙壁
          cmp ah, 25 - 1
          ja g_o

          ; 咬到自己身体
          mov di, 2             ; 忽略头部，从第二节身体开始
          mov cx, len[0]
          dec cx                ; 循环计数也需要少算一个头部
  self_s: mov ax, snakeBody[di]
          ; 碰到了身体
          cmp ax, snakeBody[0]
          je g_o
          ; 碰到了食物
          cmp ax, food[0]
          je levelup
          add di, 2
          loop self_s

          jmp ct_game

     g_o: call short dis_g_o
          jmp ct_game

 levelup: inc len[0]            ; 身体长度+1
          inc score[0]          ; 分数+1
          call short random     ; 生成新的食物

 ct_game: pop di
          pop cx
          pop ds
          pop ax
          ret

          ; 随机生成蛇的食物
  random: push ax
          push ds
          push cx
          push bx
          push dx
          push di

          mov ax, dataseg
          mov ds, ax

          ; 获取时间秒数，用于生成随机数
re_create:mov al, 0
          out 70h, al
          in al, 71h
          mov ah, al
          add ax, seed[0]
          mov cl, 3
          shr ax, cl

          mov bx, ax
          mov dl, 40
          div dl
          mov byte ptr food[0], ah

          mov ax, bx
          add ax, seed2[0]
          mov cl, 3
          shr ax, cl

          mov dl, 25
          div dl
          mov byte ptr food[1], ah

          mov dx, food[0]
          
          mov di, 0
          mov cx, len[0]
    rd_s: mov ax, snakeBody[di]
          cmp ax, dx
          je re_create
          add di, 2
          loop rd_s

          pop di
          pop dx
          pop bx
          pop cx
          pop ds
          pop ax
          ret

          ; 清屏
clearDis: push ax
          push es
          push di
          push cx

          mov ax, 0b800h
          mov es, ax
          mov di, 0

          mov cx, 4000
   clr_s: mov word ptr es:[di], 0
          inc di
          loop clr_s

          pop cx
          pop di
          pop es
          pop ax
          ret

          ; 蛇和食物闪烁，暂停
   blbl:  push ax
          push ds
          push bx
          push cx

          mov ax, dataseg
          mov ds, ax

          mov bx, 0
          mov cx, len[0]
 blbl_s:  mov dx, snakeBody[bx]
          push cx
          mov ch, snakeColor[0]
          mov cl, body[0]
          ; 蛇身体闪烁
          or ch, 10000000b
          call short display2
          pop cx
          add bx, 2
          loop blbl_s
          
          ; 食物闪烁
          mov dx, food[0]
          mov cl, body[0]
          mov ch, foodColor[0]
          or ch, 10000000b
          call short display2

          pop cx
          pop bx
          pop ds
          pop ax
          retf

          ; 延迟
  delay:  push ax
          push dx
          push ds
          
          mov ax, dataseg
          mov ds, ax

          mov dx, speed[0]
          mov ax, 0
    s1:   sub ax, 1
          sbb dx, 0
          cmp ax, 0
          jne s1
          cmp dx, 0
          jne s1

          pop ds
          pop dx
          pop ax
          ret

          ; 重写后的按键中断程序
    do0:  push ax
          push bx
          push ds
          push dx
          push cx

          mov ax, dataseg
          mov ds, ax

          in al, 60h

          pushf

          pushf
          pop bx
          and bh, 11111100b
          push bx
          popf

          call dword ptr oldint9[0]

          ; 方向调节
          ; 键盘 W 按下
          cmp al, 11h
          jne dkn_a
          cmp target[0], 'D'
          je board_1
          mov target[0], 'U'
board_1:  jmp do0over
          
          ; 键盘 A 按下
  dkn_a:  cmp al, 1Eh
          jne dkn_s
          cmp target[0], 'R'
          je board_2
          mov target[0], 'L'
board_2:  jmp do0over

          ; 键盘 S 按下
  dkn_s:  cmp al, 1Fh
          jne dkn_d
          cmp target[0], 'U'
          je board_3
          mov target[0], 'D'
board_3:  jmp do0over

          ; 键盘 D 按下
  dkn_d:  cmp al, 20h
          jne dkn_1
          cmp target[0], 'L'
          je board_4
          mov target[0], 'R'
board_4:  jmp do0over

          ; 速度调节
          ; 数字 1 按下
  dkn_1:  cmp al, 02h
          jne dkn_2
          mov speed[0], 05h
          jmp do0over

          ; 数字 2 按下
  dkn_2:  cmp al, 03h
          jne dkn_3
          mov speed[0], 04h
          jmp do0over

          ; 数字 3 按下
  dkn_3:  cmp al, 04h
          jne dkn_4
          mov speed[0], 03h
          jmp do0over

          ; 数字 4 按下
  dkn_4:  cmp al, 05h
          jne dkn_5
          mov speed[0], 02h
          jmp do0over

          ; 数字 5 按下
  dkn_5:  cmp al, 06h
          jne dkn_p
          mov speed[0], 01h
          jmp do0over

          ; 键盘 P 按下 游戏暂停
  dkn_p:  cmp al, 19h
          jne dkn_r
          cmp gameStatus[0], 0
          jne p_ne_1
          mov gameStatus[0], 2
          ; 屏幕闪烁
          call far ptr blbl
          jmp do0over

 p_ne_1:  cmp gameStatus[0], 2
          jne do0over
          mov gameStatus[0], 0
          jmp do0over
          
          ; 键盘 R 按下
  dkn_r:  cmp al, 13h
          jne dkn_spe
          ; 判断游戏是不是失败状态，只有失败状态这个按键才有效
          cmp gameStatus[0], 3
          jne do0over
          call far ptr restart
          mov gameStatus[0], 0
          jmp do0over

          ; 键盘 space 按下
dkn_spe:  cmp al, 39h
          jne dkn_esc
          ; 判断游戏是不是准备状态，只有准备状态这个按键才有效
          cmp gameStatus[0], 4
          jne do0over
          call far ptr restart
          mov gameStatus[0], 0
          jmp do0over

          ; 键盘 ESC 按下 退出游戏
dkn_esc:  cmp al, 01h
          jne do0over
          mov gameStatus[0], 1

do0over:  pop cx
          pop dx
          pop ds
          pop bx
          pop ax
          iret

 do0end:  nop

codeseg ends

end start

