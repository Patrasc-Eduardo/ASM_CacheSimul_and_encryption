# CACHE simulation / Columnar transposition cipher / ROTP encryption

Patrasc Andrea-Eduardo

# ROTP.asm

Ne folosim de formula data in enunt

```C
cipher[i] = plain[i] ^ key[len - i - 1]
```

## Registrii

* Contorul i = **eax**
* Cipher = **edx**
* Plain = **esi**
* Key = **edi**
* Len = **ecx**

## Flow :

* Luam un contor.
* Preluam , succesiv cu ajutorul contorului, octetii de la sfarsitul key-ului.
* Pe octetii preluati vom efectua un xor cu octetii din textul plain.
* Se efectueaza operatiile de mai sus pana cand construim in intregim cipher_text (pana cand ecx devine 0 -> folosim instructiunea **loop**)

# Ages.asm

## Registrii :

* **edx** = len
* **esi** = present
* **edi** = dates
* **ecx** = all_ages
  
## Etichete :

* **build ages** : Aici vom parcurge toate elementele din vectorul dates. Vom prelua anul curent si cel de nastere pentru fiecare persoana si in functie de relatia intre aceste 2 valori, vom sari pe alte etichete.
* **bigger_present_year** : Eticheta la care se ajunge daca anul curent > anul de nastere. Aici se vor prelua luna curenta si luna de nastere si in functie de relatia intre aceste 2 valori, vom sari pe alte etichete.
* **year_zero** : Eticheta in care ajungem daca anul curent < anul de nastere, sau anul curent == anul de nastere. Aici varsta claculata va fi 0.
* **same_month**: Eticheta in care se ajunge daca luna curenta == luna de nastere. In acest caz, discutia se va face in functie de ziua de nastere si cea curenta.
* **diff_year** : Eticheta care va cacula varsta ca "an curent - an nastere".
* **diff_year_minus_one** : Eticheta care va cacula varsta ca "an curent - an nastere - 1".
* **back** : Eticheta ajutatare care duce la eticheta "build_ages" de construire a a

## Flow : 

* Implementarea incepe de la eticheta "build_ages" si pornim spre etichetele aflate deasupra acesteia.
* Daca anul curent > anul de nastere sarim pe eticheta bigger_present_year care verifica relatia intre luna actuala si cea de nastere. Daca luna curenta > luna de nastere atunci varsta = an curent - an de nastere , else varsta = an curent - an nastere - 1.
* Procesul de verificare al relatiilor se va face si pentru luni.
* Daca anul curent < anul de nastere sau anul curent == anul de nastere => varsta = 0


# Columnar.asm

## Registrii :

* **edi** : key
* **esi** : haystack
* **ebx** : ciphertext
  
## Etichete : 

* **build_cipher** : Aici se va forma cipher_text dupa logica

  ```C
    cipher[i] = *(haystack + key + len_key);
    len_key += len_key;
    if (len_key > len_haystack) next_key;
  ``` 

Ex : Pentru exemplul de pe OCW . Cand key = 0 vom lua caracterele de pe pozitiile 0 5 10 15 20 ale lui haystack. Pentru key = 2 vom aveam 2 7 12 17 22
etc.

* **get_key** : Aici se va lua o cheie din vectorul de keys si se va intra in build_cipher.

* **get_next_key** : Atunci cand parcurgem matricea pe coloana si ajungem la ultima coloana (in cazul nostru, cand edx > len_key) intram pe aceasta eticheta pentru a incrementa trecerea la urmatoare cheie din vectorul de keys.
  
* **last_char** : Eticheta in care ajungem atunci cand in build_cipher dam de ultimul caracter (contorul **ecx** devine de lungimea cheii). Aici inseram pur si simplu ultimul caracter in cipher_text.
  
* **null_char** : Eticheta in care intram atunci cand contorul **edx** (cel cu care parcurgem haystackul pentru a prelua doar caracterele necesare) este fix egal cu lungimea haystackului => In acest caz, se va incerca preluarea unui caracter inexistent din matrice ("casuta neagra" de pe exemplul de pe OCW). Acest lucru va fi evitat de operatiile din aceasta eticheta.

* **nul_char_2** : Eticheta care trateaza un caz suplimentar pentru situatia de mai sus si anume cand ne aflam pe ultima cheie. Daca ne aflam pe ultima cheie nu vom mai incrementa si trece la urmatoarea ci doar vom iesi in program.
  

## Flow :

Flow-ul general se bazeaza pe functia/eticheta "build_cipher" care isi propune sa aplice formula din codul de mai sus. Totdata, sunt tratate si cazul in care ajungem pe ultimul caracter si cel in care ajungem la caracterul inexistent.


# Cache.asm

## Registrii :

* **eax** : address of reg
* **ebx** : tags
* **ecx** : cache
* **edx** : address
* **edi** : to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
  
## Etichete :

* **search_tag** : Iteram prin vectorul de tags si daca gasim tag-ul calculat mergem pe eticheta CACHE_HIT, else mergem pe CACHE_MISS.
  
* **CACHE_MISS** : Aducem in cache pe linia *to_replace* (**edi**) tag-ul calculat. Aducem valoarea din cache aflata la linia *to_replace*(**edi**) si coloana *offset*(**edx**). Punem toate valorile (vor fi 8 octeti care nu incap intr-un registru obisnuit) din tag in linia *to_replace* (**edi**) a cache-ului.
  
* **CACHE_HIT** : Daca tag-ul este gasit, ajungem pe aceasta eticheta unde doar aducem valoarea in registrul bun. Valoarea este luata din cache de la linia *to_replace* (**edi**) si coloana *offset*(**edx**).
  
## Flow :

Calculam tag-ul. Iteram prin vectorul de tags(**ebx**) si daca gasim tag-ul calculat, mergem pe eticheta **CACHE_HIT**. Altfel, mergem pe eticheta **CACHE_MISS**. 
