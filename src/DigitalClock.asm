;Digital Clock Version 2
;AM/PM feature added

.model  small

draw_row			macro	_row,	_col1,	_col2,	_color
			local	l1
;draws line on row = _row
;from column _col1 to _col2 with _color
			mov		ah,		0ch			;draw pixel
			mov		bh,		0			;page
			mov		al,		_color		;color
			mov		cx,		_col1		;column
			mov		dx,		_row		;row
	l1:		int		10h					;draw
			inc		cx					;next column
			cmp		cx,		_col2		;compare
			jle		l1					;not done yet
			endm

draw_column			macro	_col,	_row1,	_row2,	_color
			local	l2
;draws line on column = _col
;from row _row1 to _row2 with _color
			mov		ah,		0ch			;draw pixel
			mov		bh,		0			;page
			mov		al,		_color		;color
			mov		cx,		_col		;column
			mov		dx,		_row1		;row
	l2:		int		10h					;draw
			inc		dx					;next row
			cmp		dx,		_row2		;compare
			jle		l2					;not done yet
			endm

.stack  100h

.data
colshft			dw		0				;shift amount for column
rowshft			dw		0				;shift amount for row
tmpcol1			dw		0				;temporary column value
tmpcol2			dw		0				;temporary column value
tmpcol3			dw		0				;temporary column value
tmprow1			dw		0				;temporary row value
tmprow2			dw		0				;temporary row value
tmprow3			dw		0				;temporary row value
fontcolor		db		31				;color of the font
amflag			db		0				;flag to check am or pm
time_buf        db      '00:00:00$'     ;time buffer hr:min:sec
new_vec			dw		?, ?
old_vec			dw		?, ?

.code

convert             proc
;converts to ascii
;input al = number
;output ax = ascii digits, al = high digit, ah = low digit
            xor     ah,     ah      ;clear ah
            mov     dl,     10      ;divide ax by 10
            div     dl              ;ah = remainder, al = quotient
            or      ax,     3030h   ;convert to ascii
            ret
convert             endp


get_time            proc
;get time and store ascii digits in time buffer
;input bx = address of time buffer
            mov     ah,     2ch     ;get time
            int 21h                 ;ch = hr, cl = min, dh = sec
			mov		amflag,	1		;set am flag to be false
;convert hours to ascii and store
            mov     al,     ch      ;hour
            cmp		al,		11		;if hour <= 11
            jng		l5
            cmp		al,		24		;if hour >= 24
            jnl		l5
            mov		amflag,	0		;amflag true
    l5:     cmp		al,		12		;if hour > 12
            jg		l4
            jmp		l3				;hour <= 12
	l4:		sub		al,		12
    l3:		cmp		al,		0
			jne		l6
			mov		al,		12
	l6:		call    convert         ;convert to ascii
            mov     [bx],   ax      ;store
;convert minutes to ascii and store
            mov     al,     cl      ;minute
            call    convert         ;convert to ascii
            mov     [bx+3], ax      ;store
;convert seconds to ascii and store
            mov     al,     dh      ;seconds
            call    convert         ;convert to ascii
            mov     [bx+6], ax      ;store

            ret
get_time            endp

time_int			proc
;interrupt procedure activated by timer
			push	ds					;save ds
			mov		ax,		@data		;set to data seg
			mov		ds,		ax
;get new time
			lea		bx,		time_buf	;bx points to time buffer
			call	get_time			;store time in buffer
;print first digit of hour value
			mov		rowshft,	65
			mov		colshft,	30
			call	print_black
			mov		al,		'0'
			cmp		[bx],	al
			jne		h11
			call	print0
			jmp		h1d
	h11:	inc		al
			cmp		[bx],	al
			jne		h12
			call	print1
			jmp		h1d
	h12:	inc		al
			cmp		[bx],	al
			jne		h13
			call	print2
			jmp		h1d
	h13:	inc		al
			cmp		[bx],	al
			jne		h14
			call	print3
			jmp		h1d
	h14:	inc		al
			cmp		[bx],	al
			jne		h15
			call	print4
			jmp		h1d
	h15:	inc		al
			cmp		[bx],	al
			jne		h16
			call	print5
			jmp		h1d
	h16:	inc		al
			cmp		[bx],	al
			jne		h17
			call	print6
			jmp		h1d
	h17:	inc		al
			cmp		[bx],	al
			jne		h18
			call	print7
			jmp		h1d
	h18:	inc		al
			cmp		[bx],	al
			jne		h19
			call	print8
			jmp		h1d
	h19:	call	print9
	h1d:
;print second digit of hour value
			mov		rowshft,	65
			mov		colshft,	70
			call	print_black
			mov		al,		'0'
			cmp		[bx+1],	al
			jne		h21
			call	print0
			jmp		h2d
	h21:	inc		al
			cmp		[bx+1],	al
			jne		h22
			call	print1
			jmp		h2d
	h22:	inc		al
			cmp		[bx+1],	al
			jne		h23
			call	print2
			jmp		h2d
	h23:	inc		al
			cmp		[bx+1],	al
			jne		h24
			call	print3
			jmp		h2d
	h24:	inc		al
			cmp		[bx+1],	al
			jne		h25
			call	print4
			jmp		h2d
	h25:	inc		al
			cmp		[bx+1],	al
			jne		h26
			call	print5
			jmp		h2d
	h26:	inc		al
			cmp		[bx+1],	al
			jne		h27
			call	print6
			jmp		h2d
	h27:	inc		al
			cmp		[bx+1],	al
			jne		h28
			call	print7
			jmp		h2d
	h28:	inc		al
			cmp		[bx+1],	al
			jne		h29
			call	print8
			jmp		h2d
	h29:	call	print9
	h2d:
;print a colon
			mov		rowshft,	65
			mov		colshft,	100
			call	print_colon
;print first digit of minute value
			mov		rowshft,	65
			mov		colshft,	120
			call	print_black
			mov		al,		'0'
			cmp		[bx+3],	al
			jne		m11
			call	print0
			jmp		m1d
	m11:	inc		al
			cmp		[bx+3],	al
			jne		m12
			call	print1
			jmp		m1d
	m12:	inc		al
			cmp		[bx+3],	al
			jne		m13
			call	print2
			jmp		m1d
	m13:	inc		al
			cmp		[bx+3],	al
			jne		m14
			call	print3
			jmp		m1d
	m14:	inc		al
			cmp		[bx+3],	al
			jne		m15
			call	print4
			jmp		m1d
	m15:	inc		al
			cmp		[bx+3],	al
			jne		m16
			call	print5
			jmp		m1d
	m16:	inc		al
			cmp		[bx+3],	al
			jne		m17
			call	print6
			jmp		m1d
	m17:	inc		al
			cmp		[bx+3],	al
			jne		m18
			call	print7
			jmp		m1d
	m18:	inc		al
			cmp		[bx+3],	al
			jne		m19
			call	print8
			jmp		m1d
	m19:	call	print9
	m1d:
;print second digit of minute value
			mov		rowshft,	65
			mov		colshft,	160
			call	print_black
			mov		al,		'0'
			cmp		[bx+4],	al
			jne		m21
			call	print0
			jmp		m2d
	m21:	inc		al
			cmp		[bx+4],	al
			jne		m22
			call	print1
			jmp		m2d
	m22:	inc		al
			cmp		[bx+4],	al
			jne		m23
			call	print2
			jmp		m2d
	m23:	inc		al
			cmp		[bx+4],	al
			jne		m24
			call	print3
			jmp		m2d
	m24:	inc		al
			cmp		[bx+4],	al
			jne		m25
			call	print4
			jmp		m2d
	m25:	inc		al
			cmp		[bx+4],	al
			jne		m26
			call	print5
			jmp		m2d
	m26:	inc		al
			cmp		[bx+4],	al
			jne		m27
			call	print6
			jmp		m2d
	m27:	inc		al
			cmp		[bx+4],	al
			jne		m28
			call	print7
			jmp		m2d
	m28:	inc		al
			cmp		[bx+4],	al
			jne		m29
			call	print8
			jmp		m2d
	m29:	call	print9
	m2d:
;print a colon
			mov		rowshft,	65
			mov		colshft,	190
			call	print_colon
;print first digit of second value
			mov		rowshft,	65
			mov		colshft,	210
			call	print_black
			mov		al,		'0'
			cmp		[bx+6],	al
			jne		s11
			call	print0
			jmp		s1d
	s11:	inc		al
			cmp		[bx+6],	al
			jne		s12
			call	print1
			jmp		s1d
	s12:	inc		al
			cmp		[bx+6],	al
			jne		s13
			call	print2
			jmp		s1d
	s13:	inc		al
			cmp		[bx+6],	al
			jne		s14
			call	print3
			jmp		s1d
	s14:	inc		al
			cmp		[bx+6],	al
			jne		s15
			call	print4
			jmp		s1d
	s15:	inc		al
			cmp		[bx+6],	al
			jne		s16
			call	print5
			jmp		s1d
	s16:	inc		al
			cmp		[bx+6],	al
			jne		s17
			call	print6
			jmp		s1d
	s17:	inc		al
			cmp		[bx+6],	al
			jne		s18
			call	print7
			jmp		s1d
	s18:	inc		al
			cmp		[bx+6],	al
			jne		s19
			call	print8
			jmp		s1d
	s19:	call	print9
	s1d:
;print second digit of second value
			mov		rowshft,	65
			mov		colshft,	250
			call	print_black
			mov		al,		'0'
			cmp		[bx+7],	al
			jne		s21
			call	print0
			jmp		s2d
	s21:	inc		al
			cmp		[bx+7],	al
			jne		s22
			call	print1
			jmp		s2d
	s22:	inc		al
			cmp		[bx+7],	al
			jne		s23
			call	print2
			jmp		s2d
	s23:	inc		al
			cmp		[bx+7],	al
			jne		s24
			call	print3
			jmp		s2d
	s24:	inc		al
			cmp		[bx+7],	al
			jne		s25
			call	print4
			jmp		s2d
	s25:	inc		al
			cmp		[bx+7],	al
			jne		s26
			call	print5
			jmp		s2d
	s26:	inc		al
			cmp		[bx+7],	al
			jne		s27
			call	print6
			jmp		s2d
	s27:	inc		al
			cmp		[bx+7],	al
			jne		s28
			call	print7
			jmp		s2d
	s28:	inc		al
			cmp		[bx+7],	al
			jne		s29
			call	print8
			jmp		s2d
	s29:	call	print9
	s2d:
;print am/pm
			mov		rowshft,	125
			mov		colshft,	245
			cmp		amflag,		1		;if amflag is true
			jne		pp
			mov		fontcolor,	0		;set black
			call	printP
			mov		fontcolor,	31		;set white
			call	printA
			jmp		mp
	pp:		mov		fontcolor,	0		;set black
			call	printA
			mov		fontcolor,	31		;set white
			call	printP
	mp:		mov		rowshft,	125
			mov		colshft,	260
			call	printM

			pop		ds
			iret
time_int			endp

setup_int           proc
;saves old vector and sets up new vector
;input:	al = interrupt number
;		di = address of buffer for old vector
;		si = address of buffer containing new vector
;save old interrupt vector
			mov		ah,		35h		;35h gets vector
			int		21h				;es:bx = vector
			mov		[di],	bx		;save offset
			mov		[di+2],	es		;save segment
;setup new vector
			mov		dx,		[si]	;dx has offset
			push	ds				;save ds
			mov		ds,		[si+2]	;ds has segment number
			mov		ah,		25h		;25h sets vector
			int		21h
			pop		ds				;restore ds
			ret
setup_int			endp

main                proc
            mov     ax,     @data
            mov     ds,     ax          ;initialize ds

;set graphics mode to vga 320x200 256 color
			mov		ah,		0			;set mode
			mov		al,		13h			;to 320x200 256
			int		10h

;setup interrupt procedure by
;placing segment:offset of time_int in new_vec
			mov		new_vec,	offset	time_int
			mov		new_vec+2,	seg		time_int
			lea		di,		old_vec		;di points to vector buffer
			lea		si,		new_vec		;si points to new vector
			mov		al,		1ch			;timer interrupt
			call	setup_int			;setup new interrupt vector
;read keyboard
			mov		ah,		0
			int		16h
;restore old interrupt vector
			lea		di,		new_vec		;di points to vector buffer
			lea		si,		old_vec		;si points to old vector
			mov		al,		1ch			;timer interrupt
			call	setup_int			;restore old vector
;reset to text mode
			mov		ah,		0
			mov		al,		3
			int		10h
;exit
            mov     ah,     4ch     ;return
            int 21h                 ;to dos
main                endp

print0				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print0				endp

print1				proc

			mov		ax,			colshft
			mov		tmpcol1,	20
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print1				endp

print2				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow2,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow2,	fontcolor

			ret
print2				endp

print3				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print3				endp

print4				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print4				endp

print5				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow2,	fontcolor
			draw_column		tmpcol2,	tmprow2,	tmprow3,	fontcolor

			ret
print5				endp

print6				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow2,	tmprow3,	fontcolor

			ret
print6				endp

print7				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print7				endp

print8				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print8				endp

print9				proc

			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
print9				endp

print_colon			proc

			mov		ax,			colshft
			mov		tmpcol1,	8
			add		tmpcol1,	ax
			mov		tmpcol2,	12
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	16
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow2,	fontcolor

			mov		ax,			colshft
			mov		tmpcol1,	8
			add		tmpcol1,	ax
			mov		tmpcol2,	12
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	30
			add		tmprow1,	ax
			mov		tmprow2,	34
			add		tmprow2,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow2,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow2,	fontcolor

			ret
print_colon			endp

print_black			proc
			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	30
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	20
			add		tmprow2,	ax
			mov		tmprow3,	50
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	0
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	0
			draw_row		tmprow3,	tmpcol1,	tmpcol2,	0
			draw_column		tmpcol1,	tmprow1,	tmprow3,	0
			draw_column		tmpcol2,	tmprow1,	tmprow3,	0

			ret
print_black			endp

printA				proc
			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	10
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	7
			add		tmprow2,	ax
			mov		tmprow3,	20
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor

			ret
printA				endp

printP				proc
			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	10
			add		tmpcol2,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow2,	7
			add		tmprow2,	ax
			mov		tmprow3,	20
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol2,	fontcolor
			draw_row		tmprow2,	tmpcol1,	tmpcol2,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow2,	fontcolor

			ret
printP				endp

printM				proc
			mov		ax,			colshft
			mov		tmpcol1,	0
			add		tmpcol1,	ax
			mov		tmpcol2,	7
			add		tmpcol2,	ax
			mov		tmpcol3,	20
			add		tmpcol3,	ax
			mov		ax,			rowshft
			mov		tmprow1,	0
			add		tmprow1,	ax
			mov		tmprow3,	20
			add		tmprow3,	ax
			draw_row		tmprow1,	tmpcol1,	tmpcol3,	fontcolor
			draw_column		tmpcol1,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol2,	tmprow1,	tmprow3,	fontcolor
			draw_column		tmpcol3,	tmprow1,	tmprow3,	fontcolor

			ret
printM				endp

end main
