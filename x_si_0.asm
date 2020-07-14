.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern scanf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
	game_title db "                                                ---Tic-Tac-Toe---", 10, 13, 0
	game_board db "This is the game board:", 10, 13, 0
	table_comp1 db "----++---++----", 10, 13, 0
	table_comp2 db "| 1 || 2 || 3 |", 10, 13, 0
	table_comp3 db "| 4 || 5 || 6 |", 10, 13, 0
	table_comp4 db "| 7 || 8 || 9 |", 10, 13, 0
	available_moves db "The only available moves are 1-9. Player1 uses X, Player2 uses 0. Player1 begins.", 10, 13, 0
	enter_move_1 db "Enter your move(Player1): ", 0
	enter_move_2 db "Enter your move(Player2): ", 0
	warning1 db "Please enter valid data", 10, 13, 0
	warning2 db "This is your last chance to enter valid data", 10, 13, 0
	move_info_1 db "Player1's choice: ", 0
	move_info_2 db "Player2's choice: ", 0
	won_X db "Player1(X) won", 10, 13, 0
	won_0 db "Player2(0) won", 10, 13, 0
	draw_announcement db "It's a draw", 10, 13, 0
	restart_message db "If you want to play again press 1+ENTER, else 0+ENTER. 2+2 is 4 - 1 that's 3 quick maths", 10, 13, 0
	you_re_safe db "You're safe for the moment. Just don't lose the opportunity to win", 10, 13, 0
	start_game db 0
	move1 db 0
	move2 db 0
	trash db 0, 0, 0; fara acest trash primele doua valori din vector se schimba fara nicio explicatie
	v db 9 dup('-'), 0
	freq db 9 dup(0), 0
	sugestii db 9 dup('-'), 0
	freq_s db 9 dup(0), 0
	var dw 0
	h_border db "____", 0
	v_border db "|", 0
	format_in db "%d", 0
	format_c db " %c ", 0
	format_c_in db "%c", 0
	clrscr db "-", 10, 13, 0
	new_line db 10, 13, 0
	turn db 0
	winner db 0
	draw_detector db 0
	restart_game db 0
	poz_sugestie db 0
	
.code
start:
	mov esi, 0; partea de reset, in cazul in care se alege "play again"
	mov edi, 0
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov draw_detector, 0
	next:
		mov v[esi], '-'
		mov freq[esi], 0
		mov sugestii[esi], '-'
		mov freq_s[esi], 0
		add esi, 1
		cmp esi, 9
		jne next
	;afisarea titlului, a tablei de joc si a informatiilor referitoare la modul de joc
	push offset game_title
	call printf
	add esp, 4
	push offset game_board
	call printf
	add esp, 4
	
	push offset table_comp1
	call printf
	add esp, 4
	push offset table_comp2
	call printf
	add esp, 4
	push offset table_comp1
	call printf
	add esp, 4
	push offset table_comp3
	call printf
	add esp, 4
	push offset table_comp1
	call printf
	add esp, 4
	push offset table_comp4
	call printf
	add esp, 4
	push offset table_comp1
	call printf
	add esp, 4
	
	push offset available_moves
	call printf
	add esp, 4
	
	mov turn, 1 ;Este randul primului jucator. Avem nevoie la inceput de aceasta variabila pentru avertismente
	mov ebx, 0 ;Tot pentru avertismente
	
	;fiecare player isi introduce mutarea
	player1_move:
		push offset new_line
		call printf
		add esp, 4
		push offset enter_move_1
		call printf
		add esp, 4
		push offset move1
		push offset format_in
		call scanf
		add esp, 8
		jmp move_check1
	player2_move:
		push offset new_line
		call printf
		add esp, 4
		push offset enter_move_2
		call printf
		add esp, 4
		push offset move2
		push offset format_in
		call scanf
		add esp, 8
		jmp move_check2
		
	;verificarea validitatii pozitiilor alese
	move_check1:
		cmp move1, 9
		jg adv1
		mov edx, 0
		sub move1, 1
		mov dl, move1
		cmp v[edx], '-'
		je put_x
		jne adv1
	move_check2:
		mov edx, 0
		sub move2, 1
		mov dl, move2
		cmp v[edx], '-'
		je put_0
		jne adv1
	;partea de avertismente, in cazul in care mutarile nu sunt valide
	adv1:    	;primul avertisment
		inc ebx
		cmp ebx, 2
		jge adv2
		push offset new_line
		call printf
		add esp, 4
		push offset warning1
		call printf
		add esp, 4
		cmp turn, 1
		je player1_move
		jne player2_move
	adv2:		;al doilea avertisment
		cmp ebx, 3
		je turn_verif
		push offset new_line
		call printf
		add esp, 4
		push offset warning2
		call printf
		add esp, 4
		cmp turn, 1
		je player1_move
		jne player2_move
	;verificarea turei
	turn_verif:		
		cmp turn, 1
		je winner_0
		jne winner_X
	;adauga in tabel X, respectiv 0
	put_x:
		mov v[edx], 'X'
		mov freq[edx], 1
		mov turn, 2
		mov esi, 0
		call draw_table
		jmp finish_table
	put_0:
		mov v[edx], '0'
		mov freq[edx], 1
		mov turn, 1
		mov esi, 0
		call draw_table
		jmp finish_table
		
	;deseneaza tabelul dupa fiecare tura
	draw_table proc
		loop_row:
		cmp esi, 9
		je ret_tag
		push offset new_line
		call printf
		add esp, 4
		push offset table_comp1
		call printf
		add esp, 4
		mov edi, 0
		loop_column:
			cmp edi, 3
			je loop_row
			push offset v_border
			call printf
			add esp, 4
			mov eax, 0
			mov al, v[esi]
			push eax
			push offset format_c
			call printf
			add esp, 8
			push offset v_border
			call printf
			add esp, 4
			inc edi
			inc esi
			jmp loop_column
		ret_tag:
			ret
	draw_table endp
	
	finish_table:
		push offset new_line
		call printf
		add esp, 4
		push offset table_comp1
		call printf
		add esp, 4
		jmp table_check ;optional
		
	;aici incepe partea de verificare a tabelului. In cazul in care exista 3 simboluri identice pozitionate in linie, se trece la verificarea frecventei
	table_check:
		check_0_1:
			mov al, v[0]
			mov bl, v[1]
			cmp al, bl
			je table_check1
		check_3_4:
			mov al, v[3]
			mov bl, v[4]
			cmp al, bl
			je table_check2
		check_6_7:
			mov al, v[6]
			mov bl, v[7]
			cmp al, bl
			je table_check3
		check_0_3:
			mov al, v[0]
			mov bl, v[3]
			cmp al, bl
			je table_check4
		check_1_4:
			mov al, v[1]
			mov bl, v[4]
			cmp al, bl
			je table_check5
		check_2_5:
			mov al, v[2]
			mov bl, v[5]
			cmp al, bl
			je table_check6
		check_0_4:
			mov al, v[0]
			mov bl, v[4]
			cmp al, bl
			je table_check7
		check_2_4:
			mov al, v[2]
			mov bl, v[4]
			cmp al, bl
			je table_check8
		
		continue:
			;jmp suggestion_builder
			add draw_detector, 1
			mov al, draw_detector
			cmp al, 9
			je draw
			mov ebx, 0 ;resetam contorul pentru avertismente
			cmp turn, 1
			je player1_move
			jne player2_move
		
	table_check1:
		mov cl, v[2]
		cmp al, cl
		je freq_check1
		jne check_3_4
	table_check2:
		mov cl, v[5]
		cmp al, cl
		je freq_check2
		jne check_6_7
	table_check3:
		mov cl, v[8]
		cmp al, cl
		je freq_check3
		jne check_0_3
	table_check4:
		mov cl, v[6]
		cmp al, cl
		je freq_check4
		jne check_1_4
	table_check5:
		mov cl, v[7]
		cmp al, cl
		je freq_check5
		jne check_2_5
	table_check6:
		mov cl, v[8]
		cmp al, cl
		je freq_check6
		jne check_0_4
	table_check7:
		mov cl, v[8]
		cmp al, cl
		je freq_check7
		jne check_2_4
	table_check8:
		mov cl, v[6]
		cmp al, cl
		je freq_check8
		jne continue
	;verificarea frecventei. Verifica daca simbolurile au fost adaugate de playeri sau daca sunt cele setate implicit la inceputul programului
	freq_check1:
		mov al, freq[0]
		and al, freq[1]
		and al, freq[2]
		mov bl, v[0]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_3_4
	freq_check2:
		mov al, freq[3]
		and al, freq[4]
		and al, freq[5]
		mov bl, v[3]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_6_7
	freq_check3:
		mov al, freq[6]
		and al, freq[7]
		and al, freq[8]
		mov bl, v[6]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_0_3
	freq_check4:
		mov al, freq[0]
		and al, freq[3]
		and al, freq[6]
		mov bl, v[0]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_1_4
	freq_check5:
		mov al, freq[1]
		and al, freq[4]
		and al, freq[7]
		mov bl, v[1]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_2_5
	freq_check6:
		mov al, freq[2]
		and al, freq[5]
		and al, freq[8]
		mov bl, v[2]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_0_4
	freq_check7:
		mov al, freq[0]
		and al, freq[4]
		and al, freq[8]
		mov bl, v[0]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne check_2_4
	freq_check8:
		mov al, freq[2]
		and al, freq[4]
		and al, freq[6]
		mov bl, v[2]
		mov winner, bl
		cmp al, 1
		je winner_check
		jne continue
		
	;verificarea castigatorului
	winner_check:
		mov al, winner
		cmp al, 'X'
		je winner_X
		jne winner_0
	winner_X:
		push offset new_line
		call printf
		add esp, 4
		push offset won_X
		call printf
		add esp, 4
		jmp end_game
	winner_0:
		push offset new_line
		call printf
		add esp, 4
		push offset won_0
		call printf
		add esp, 4
		jmp end_game
	draw:
		push offset new_line
		call printf
		add esp, 4
		push offset draw_announcement
		call printf
		add esp, 4
		jmp end_game
		
	;daca se alege sa se reia jocul, se printeaza niste spatii pentru a elibera consola
	put_space:
		mov ebx, 20
		print_lines:
		push offset new_line
		call printf
		add esp, 4
		sub ebx, 1
		cmp ebx, 0
		je start
		jne print_lines
	;aici se fac alegerile la finalul jocului
	end_game:
		push offset restart_message
		call printf
		add esp, 4
		push offset restart_game
		push offset format_in
		call scanf
		add esp, 8
		mov ebx, 0
		mov bl, restart_game
		cmp bl, 1
		je put_space
		jne final

	final:
	push 0
	call exit
end start
