section .data
    myString: db "Hello, World!", 0
section .text
    global rotp
;; void rotp(char *ciphertext, char *plaintext, char *key, int len);
rotp:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len
    ;; DO NOT MODIFY

    
    mov eax, 0
build_cipher: 
    xor ebx, ebx
    inc eax ; contor [1..len]
    
    movzx ebx, byte [edi + ecx - 1] ; luam byte-ul corespunzator lui key[len - i - 1]

    xor bl, byte [esi + eax - 1] ; facem operatia din enunt plain[i] ^ key[len - i - 1] , unde plain[i] = byte [esi + eax - 1]
    mov byte [edx + eax - 1], bl
    loop build_cipher

    
    popa
    leave
    ret
    