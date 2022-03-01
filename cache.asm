
CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS

MASK_TAG EQU -8 ; SAU  >> 3

MASK_OFFSET EQU 7 ; AND 7 pentru primii 3 biti

section .data
    adr DQ 0
section .text
    global load
;; void load(char* reg, char** tags, char cache[CACHE_LINES][CACHE_LINE_SIZE], char* address, int to_replace);
load:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
    
    mov ecx, [ebp + 20]
    mov [adr], ecx

    mov ecx, [ebp + 16] ; cache
   
    and edx, -8 ; luam doar ultimii 29 biti

    mov eax, edx ; tag
    mov esi, eax ; tag

    mov edx, [adr]
    and edx, 7 ; offset
    
    mov edi, 0

    jmp search_tag
    CACHE_HIT:
        mov [ecx + 8 * edi], esi
        
        pop ebx
        
        push esi
        
        mov esi, [ecx + 8 * edi]
        mov esi, [esi + edx]
        mov [eax], esi ; aducem valoarea in registru BUNNN
        pop esi
        jmp exit
    
    search_tag:
        push ebx
        mov ebx, [ebx + edi * 4] ; iteram prin vectorul de tags prin contorul "edi"
        add edi, 1
        
        cmp esi, ebx ; daca tag-ul calculat este gasit, vom merge in CACHE_HIT
        je CACHE_HIT
        
        pop ebx
        cmp edi, CACHE_LINES
        jnz search_tag
        
    
    jmp CACHE_MISS
    CACHE_MISS:
        mov eax, [ebp + 8]  ; address of reg
        mov ebx, [ebp + 12] ; tags
        mov ecx, [ebp + 16] ; cache
        mov edi, [ebp + 24] ; to_replace   
        
        mov [ecx + 8 * edi], esi ; aducem in cache[to_replace]

        push esi
        mov esi, [ecx + 8 * edi]
        mov esi, [esi + edx]
        mov [eax], esi ; aducem valoarea in registru
        pop esi


        push eax
        xor eax, eax 
        xor ebx, ebx
        xor edx, edx
    put_in_cache:
        
        mov eax, [esi + ebx]
        
        lea edx, [ecx + 8 * edi]
        lea edx, [edx + ebx]

        mov [edx], eax

        add ebx, 1
        cmp ebx, 8
        jnz put_in_cache
        
        pop eax
       
        mov ebx, [ebp + 12] ; resetam valoarea vectorului tags
        mov [ebx + 4 * edi], esi ; punem valoarea dorita si in tags
        
        jmp exit

   
exit:
    
    popa
    leave
    ret
    


