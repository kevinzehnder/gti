format binary as 'img'
include 'LIB\FASMARM.INC'

; Konstanten setzen
BCM2837_BASE = $3F000000   ; Adresse der Peripherie
GPIO_BASE =  $200000       ; Adresse der GPIO Pins ist 0x3F200000
TIMER_BASE = $3000         ; Adresse des System Timers ist 0x3F003000.
TIMER_CNT = $4
LED_AN = 0x1C
LED_AUS = 0x28
DAUER = 0xC8              ; Standard Dit Dauer in ms

;Initialisierung Stack
mov sp, 0x8000

;Initialisierung GPIO
mov r0, BCM2837_BASE    ; Hardware Adresse der Peripherie in r0 speichern
orr r0, r0, GPIO_BASE   ; r0 'logisch und' mit GPIO_Base um zu den GPIO Adressen zu kommen. Das Resultat ist 0x3F200000.

mov r1,#1               ; 1 wird nach r1 gespeichert
lsl r1,#12              ; r1 wird 12 bits nach links geshiftet.
str r1,[r0,#0x8]        ; schreibt nach r0+OFFSET(memory addresse) den Wert von r1
                        ; (an die Memory Adresse die in r0 steht, nicht ins Register r0)
                        ; dadurch wird GPIO24 Port auf Output gestellt


; Funktion die eine gesamte Nachricht morst
morsemessage:
adr r0, alphabet        ; Adresse der Lookup Table in r0 speichern
add r3, r0, 0x7F        ; Position für "S" nach r3 speichern
bl morsecharacter

mov r3, #3              ; Wartezeit zwischen Symbolen nach r3 speichern
bl timer

adr r0, alphabet
add r3, r0, 0x63
bl morsecharacter

mov r3, #3
bl timer

adr r0, alphabet        ; Adresse der Lookup Table in r4 speichern
add r3, r0, 0x7F        ; Position für "S" nach r4 speichern
bl morsecharacter

mov r3, #7              ; Wartezeit zwischen Worten nach r3 speichern
bl timer

b morsemessage


; Funktion die einen Parameter erhält und diesen mittels morse code ausgibt
; der Parameter wird in r3 übergeben.
morsecharacter:
push {lr, r4, r6}

mov r6, r3              ; Parameter (Adresse) zwischenspeichern
ldrb r4, [r6], #1       ; Morse Wert aus Lookup Tabelle 'alphabet' auslesen nach r4 und r6 hochzählen
;add r6, r6, #1         ; r6 hochzählen

b first
next:                   ; beim ersten Leuchten pro Buchstaben überspringen
mov r3, #1
bl timer

first:
mov r3, r4
bl leuchten             ; Funktion "leuchten" aufrufen

ldrb r4, [r6], #1       ; nächsten Morsewert auslesen
;add r6, r6, #1         ; ist nicht mehr nötig. wird direkt in ldrb ausgeführt mit , #1
cmp r4, #0              ; prüfen ob wir schon am Ende sind für dieses Zeichen

bne next

pop {pc, r4, r6}


; Timerfunktion mit Parameter in r3
timer:
mov r0, BCM2837_BASE      ; Hardware Adresse der Peripherie in r1 speichern.
orr r0, r0, TIMER_BASE    ; r1 'logisch und' mit TIMER_BASE um zu den Timer Adressen zu kommen.
ldr r1, [r0, TIMER_CNT]   ; aktuelle Zeit in r1 ablegen (r0 + offset TIMER_CNT)

; Zielzeit berechnen
mov r2, DAUER             ; Basislänge nach r2             
mul r2, r2, r3            ; Basislänge mit Faktor multiplizieren
mov r3, #1000             ; #1000 nach r3 speichern
mul r2, r2, r3            ; DAUER mit r3 multiplizieren für ms

add r3, r1, r2            ; aktuelle Zeit + Wartezeit = Zielzeit. Nach r3 speichern.

; Busy waiting bis Zielzeit erreicht
wait1$:
 ldr r1, [r0, TIMER_CNT]  ; aktuelle Zeit in r1 ablegen
 cmp r1, r3               ; r1 und Zielzeit vergleichen
 bls wait1$               ; wenn Zielzeit <= aktuelle Zeit, dann fertig, sonst wait1$

mov pc, lr


; LED Leuchtfunktion
leuchten:
push {lr, r4, r5}

mov r4, BCM2837_BASE
orr r4, r4, GPIO_BASE
mov r5, #1
lsl r5, #24
str r5,[r4,LED_AN]      ; löschen

bl timer                ; timer 

str r5,[r4,LED_AUS]     ; löschen

pop {pc, r4, r5}


; Lookup Table
alphabet:
db 'a',1,3,0,0,0,0
db 'b',3,1,1,1,0,0
db 'c',3,1,3,1,0,0
db 'd',3,1,1,0,0,0
db 'e',1,0,0,0,0,0
db 'f',1,1,3,1,0,0
db 'g',3,3,1,0,0,0
db 'h',1,1,1,1,0,0
db 'i',1,1,0,0,0,0
db 'j',1,3,3,3,0,0
db 'k',3,1,3,0,0,0
db 'l',1,3,1,1,0,0
db 'm',3,3,0,0,0,0
db 'n',3,1,0,0,0,0
db 'o',3,3,3,0,0,0
db 'p',1,3,3,1,0,0
db 'q',3,3,1,3,0,0
db 'r',1,3,1,0,0,0
db 's',1,1,1,0,0,0
db 't',3,0,0,0,0,0
db 'u',1,1,3,0,0,0
db 'v',1,1,1,3,0,0
db 'w',1,3,3,0,0,0
db 'x',3,1,1,3,0,0
db 'y',3,1,1,3,0,0
db 'z',3,3,1,1,0,0
db '1',3,3,3,3,3,0
db '3',1,3,3,3,3,0
db '0',1,1,3,3,3,0
db '3',1,1,1,3,3,0
db '4',1,1,1,1,3,0
db '5',1,1,1,1,1,0
db '6',3,1,1,1,1,0
db '7',3,3,1,1,1,0
db '8',3,3,3,1,1,0
db '9',3,3,3,3,1,0
