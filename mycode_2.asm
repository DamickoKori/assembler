#make_EXE#
 
cseg segment 'code'

; Переход на новую строку в консоли
new_line macro
	push	ax
    mov 	ah, 0eh
    mov 	al, 0ah
    int 	10h
    mov 	al, 0dh
    int 	10h
    pop 	ax  
endm

; Очистка строки 
; addr_str 	- адрес строки
clear_s macro addr_str
local loop_begin
	push	si
	push 	cx
	mov		len, 0
	mov		si, offset addr_str
loop_begin:
	mov		[si], '$'
	inc 	si
	loop 	loop_begin
	pop 	cx
	pop 	si
endm

; Вывод строки, передаваемую как параметром
; str - строка
print macro str
local point, code
	jmp		point
	code	db	str
	db		'$'
	
point:		
	push	ds
	push	cs
	pop		ds
	print_s	code
	pop		ds
endm

; Вывод строки
; addr_str - адрес строки
print_s macro addr_str 
	push	ax
	push 	dx
	mov 	dx, offset addr_str
	mov		ah, 09h
	int		21h
	pop 	dx
	pop 	ax	
endm

; Вывод числа
; Происходит конвертирование из числа в строку, в len
; заносятится кол-во битов, несущие информацию
; addr_str 	- адрес строки
; num 		- число
print_n macro addr_str, num 
local div_to_zero, reverse, exit
	push 	si
	push 	ax
	push 	bx
	mov		len, 0
	mov		ax, num
	mov		bx, 10
	xor		cx, cx        
	mov		si, offset addr_str
	
div_to_zero:
	xor		dx, dx     
	div		bx
	add		dx, '0'
	mov		[si], dx
	inc 	len
	inc		cx
	inc		si
	cmp		ax, 0
	jnz		div_to_zero 
    
    dec		si
    mov		di, si
    mov		si, offset addr_str	
    
reverse:     
	mov 	al, [si]
    mov 	bl, [di]
    xchg 	al, bl 
    mov 	[si], al
    mov 	[di], bl
    inc 	si
    dec 	di
    cmp 	si, di
	jg 		exit
	cmp 	si, di
	jnz 	reverse
exit:
    
	print_s	addr_str  
	pop		bx
	pop		ax
	pop		si	
endm

; Вывод значения с клавиатуры в переменную
out_to macro addr_num
local input_char, add_num, exit 
	push 	ax
	push	bx
	push 	cx
	push	dx
	xor		bx, bx
	mov		cx, 10
		
input_char:
	mov 	ah, 01h
	int 	21h
	cmp 	al, 13
	jz 		exit
	xor		ah, ah
	sub		al, '0'
	cmp		bx, 0
	jz		add_num
    push	ax
    mov		ax, bx
    mul		cx
    mov		bx, ax
    pop		ax
    
add_num:
	add		bx, ax

	jmp		input_char
exit:

	new_line
	mov		addr_num, bx
	pop		dx
	pop		cx
	pop 	bx 
	pop		ax
endm

; Помещение строки в файл
; Сохраняет только len байт информации
; addr_file_name	- адрес строки с названием файла
; addr_result_str	- адрес строки с результатом
string_to_file macro addr_file_name, addr_result_str 
	push	si
	push	di
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	mov 	ah, 3ch
	mov 	cx, 0
	mov 	dx, offset addr_file_name
	int 	21h
    
	mov 	ah, 3dh
	mov 	al, 2
	mov 	dx, offset addr_file_name
	int 	21h
	mov 	si, ax 
	
	mov 	ah, 40h  
	mov 	bx, si
	mov 	dx, offset addr_result_str  
	mov 	cx, len   
	int 	21h   
	
	mov 	ah, 3eh
	mov 	bx, si
	int 	21h
	push 	dx
	push 	cx
	push 	bx
	push 	ax
	pop 	di	
	pop 	si
endm 

; Помещение строки из файла в строку
; Сохраняет максимум len_max байт информации
; addr_file_name	- адрес строки с названием файла
; addr_result_str	- адрес строки с результатом
file_to_string macro addr_file_name, addr_result_str 
	push	si
	push	di
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	mov 	ah, 3ch
	mov 	cx, 0
	mov 	dx, offset addr_file_name
	int 	21h 
	
	mov 	ah, 3dh
	mov 	al, 2
	mov 	dx, offset addr_file_name
	int 	21h
	mov 	si, ax  
	
	mov		ah, 3fh
	mov		bx, si
	mov		dx, offset addr_result_str
	mov		cx, len_max
	int		21h 
	
	mov 	ah, 3eh
	mov 	bx, si
	int 	21h
	push 	dx
	push 	cx
	push 	bx
	push 	ax
	pop 	di	
	pop 	si
endm

_main:
    mov		ax, dseg
    mov 	ds, ax

; Вычислить значение выражения (1260-450) / 2 + 310*3. Полученный результат записать в регистр SI. Ответ 1335.    
	
	; Инициализация значений 
	print	'Input A: '
	out_to 	a 
	
	print	'Input B: '
	out_to 	b
	
	print	'Input C: '
	out_to 	c 
  	
  	; Вычисление выражения
  	mov		ax, a
  	sub		ax, b
  	mov		bx, 2
  	div		bx
  	mov		res, ax
  	
  	mov		ax, c
  	mov		bx, 3
  	mul		bx
  	
  	add		res, ax
  	
  	; Вывод результата на экран
  	print	'Result: '
  	print_n	string, res 
  	
  	; Вывод результата в файл
  	string_to_file file_name, string
  	
  	; Очистка строки
  	clear_s res
  	  
    mov 	ah, 4ch
    int		21h
cseg ends

dseg segment byte
	; Переменные
	a 	dw ?
	b 	dw ?
	c 	dw ?	
	res dw ?
	
	; Библиотечные переменные
	string	db 8 dup('$') 
	len_max = $ - string
	len dw ?
	file_name db 'myfile.txt', 0
dseg ends
end _main