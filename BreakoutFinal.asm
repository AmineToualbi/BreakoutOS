.model tiny
	.code
start:
		mov ax,1234h
    mov ax,cs
    mov ds,ax
    mov ax,0b800h
  	mov es,ax

; --- YOUR CODE GOES HERE ---

cli ;TO TAKE INTO ACCOUNT KEY STROKES !

;Draw paddle (33 -> 42), 20
;Shape:
;mov si, 3266
mov si, paddx
add si, 3199
whilelooppaddle: ;label to jump back to
			cmp si, 3284 ;check if si = position of last block forming paddle = if we continue drawing or not
			jg leavelooppaddle
			mov al, " "  ;character stored to display
			mov [es:si], al ;write al into screen at position
			;Color:
			add si, 1
			mov al, 21h
			mov [es:si], al ;write color stored at position
			add si, 1
jmp whilelooppaddle

leavelooppaddle:


;Draw blocks
mov si, 502
whileloopblock:
cmp si, 582
jg leaveloopblock
mov al, ' '
mov [es:si], al
add si, 1
mov al, 55h
mov [es:si], al
add si, 3
jmp whileloopblock

leaveloopblock:

  ;Draw ball at 40, 10
  ;Shape:
movloop:
	mov si, ballx
	add si, bally
  mov al, ' ' ;character stored to display
  mov [es:si], al ;write al into screen at position
  ;Color:
	mov al, 0	;3.1 = set color to black
  mov [es:si], al ;write color stored at position

	;Step 4 => Make the ball bounce.
	;If ball hits top
		mov ax, bally
		cmp ax, 1 ;if ball is at top of the screen = position at 0
		jle notmovloop0
		jmp checkleft
		notmovloop0:
		mov ax, balldy ;balldy = by how many bites we go up
		mov bx, 0
		sub bx, ax ;balldy is now = negative nbr so it goes down
		mov balldy, bx
	checkleft:
		mov ax, ballx
		cmp ax, 1 ;was 0
		jle notmovloop1
		jmp checkright
		notmovloop1:
		mov ax, balldx
		mov bx, 0
		sub bx, ax
		mov balldx, bx
	;If ball hits right
	checkright:
		mov ax, ballx
		cmp ax, 159
		jge notmovloop2
		jmp checkbottom
		notmovloop2:
		mov ax, balldx
		mov bx, 0
		sub bx, ax
		mov balldx, bx
		;If ball hits bottom
		checkbottom:
		mov ax, bally
		cmp ax, 3840
		jl notgameover
		jmp endgame
		notgameover:

	;Read ballx and balldx into registers + add them = movement
	mov si, ballx
	add si, balldx
	mov ballx, si ;new x-coordinate after movement
	mov si, bally
	add si, balldy
	mov bally, si ;new y-coordinate after movement

	;draw ball after mov
	mov si, ballx
	add si, bally
  mov al, ' ';character stored to display
  mov [es:si], al ;write al into screen at position
  ;Color:
  mov al, 11h ;10 = blue + 1 for background
  mov [es:si], al ;write color stored at position

	;Delay
	mov cx, 3000h
	delay:	sub cx,1
	jnz checkkey
	jmp movloop
	checkkey:
	;Listen to key strokes & change position of paddle before calling movloop
	in al, 64h
	and al, 1
	jnz continue0
	jmp bouncecheck
	continue0:
	in al, 60h
	cmp al, 4bh ;4bh = left arrow
	je moveleft
	cmp al, 4dh ;4dh = right arrow
	je moveright
	jmp clrbuff

	moveleft:
	sub paddx, 2 ;Substract 2 from paddx = new position
	;Draw square at pos
	 mov si, paddx
   add si, 3200
	 mov al, 21h
	 mov [es:si], al
	 ;Delete square at most right
	 mov si, paddx
	 add si, 3200
	 add si, 20
	 mov al, 0
 	mov [es:si], al
 	jmp clrbuff

 	 moveright:
 	 ;Delete square at most left
 	 mov si, paddx
	 add si, 3200
 	 mov al, 0
 	 mov [es:si], al
 	 ;Draw square at paddx+20
	 mov si, paddx
	 add si, 3200
 	 add si, 20
 	 mov [es:si], al
 	 mov al, 21h
 	 mov[es:si], al
 	 ;Add 2 to paddx for new position
 	 add paddx, 2
	 jmp clrbuff

 		clrbuff:
 		in al, 60h
 		in al, 64h
 		and al, 1
 		jnz clrbuff

		bouncecheck:
		;Step 6 = ball bounces off the paddle.
			;Is ball going down?
			mov ax, balldy
			cmp ax, 0
			jge continue
			jmp nokey
			continue:
			;Is bally past top of the paddle
			mov ax, bally
			cmp ax, 3040
			jge continue1
			jmp nokey
			continue1:
			;Is ballx rigt of paddx
			mov ax, ballx
			mov bx, paddx
			cmp ax, paddx
			jge continue2
			jmp nokey
			continue2:
			mov ax, ballx
			mov bx, paddx
			add bx, 20
			cmp ax, bx
			jle continue3
			jmp nokey
			continue3:
			mov ax, balldy
			mov bx, 0
			sub bx, ax
			mov balldy, bx

 		nokey:

		jmp delay


;Create space in memory to hold variables
	bally dw 1600 ;current x location of ball
	ballx dw 81 ;current y location of ball
	balldy dw 0ff60h ;-160 in 2's complement, or 1 row up
	balldx dw	2	;+2 or 1 space to the right
	paddx dw 67 ;left pos of paddle, starts at 33 from left or 67 bytes in

endgame:
		;mov ah,0			; ah=0 means exit to dos
		;int 21h
		jmp start
		end
