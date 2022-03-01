section .data
    extern len_cheie, len_haystack
section .text
    global columnar_transposition
;; void columnar_transposition(int key[], char *haystack, char *ciphertext);
columnar_transposition:
    
    push    ebp
    mov     ebp, esp
    pusha 

    mov edi, [ebp + 8]   ;key
    mov esi, [ebp + 12]  ;haystack
    mov ebx, [ebp + 16]  ;ciphertext
    
    xor eax,eax
    xor ecx, ecx
    xor edx, edx

    jmp get_key

    null_char_2:
        pop edx ; am parcurs toate cheile , deci iesim
        jmp exit
    null_char:
        push edx 
        
        mov edx, [len_cheie]
        dec edx
        
        cmp eax, edx ; daca ne aflam pe ultima cheie , iesim din program
        jz null_char_2
        
        pop edx     ; daca nu ne aflam pe ultima cheie, trecem la urmatoarea peste a sarii caracterul inexistent
                    ; din matrice ("casuta neagra" de pe exemplul de pe OCW)
        
        inc eax

        jmp get_key
    last_char:
        push edx
        mov dl, byte [esi + edx]
        
        dec ecx
        
        mov byte [ebx + ecx], dl
        
        pop edx
        jmp exit
    get_next_key:
        push edx 
        mov edx, [len_cheie]
        
        dec edx
        
        cmp eax, edx ; verificam cheia sa nu fie ultima din vector de key => 
                     ; caz in care am parcurs toate coloanele si vom iesi
        jz null_char_2
        
        pop edx

        inc eax 
        
        jmp get_key
    get_key:
        mov edx, [edi + 4 * eax] ; edx contine acum o cheie
        jmp build_cipher
    build_cipher:
        cmp edx, [len_haystack] ; cazul pentru caracterul inexistent din matrice (ultima patratica neagra din exemplul de pe ocw)
        jz null_char
        
        cmp ecx, [len_haystack] ; cand ajungem la ultimul caracter
        jz last_char
    
        push edx
        mov dl, byte [esi + edx]

        mov byte [ebx + ecx], dl
    
        inc ecx
        pop edx
        
        add edx, [len_cheie] ; luam urmatorul char din haystack (ne deplasam in jos pe coloana)
        
        cmp edx, [len_haystack]
        ja get_next_key
        
        push eax
        mov eax, [len_haystack]
        
        add eax, 1
        
        cmp ecx, eax ; cand counter ecx este mai mare decat lungimea haystack-ului
        
        je exit ; atunci iesim 
        pop eax

        jmp build_cipher
    
    exit:

        popa
        leave
        ret