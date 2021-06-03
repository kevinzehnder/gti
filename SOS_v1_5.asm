format binary as 'img'
include 'LIB\FASMARM.INC'

; Konstanten setzen
BCM2837_BASE = $3F000000   ; Adresse der Peripherie
GPIO_BASE =  $200000       ; Adresse der GPIO Pins ist 0x3F200000
TIMER_BASE = $3000         ; Adresse des System Timers ist 0x3F003000.
TIMER_CNT = $4
LED_AN = 0x1C
LED_AUS = 0x28
DAUER = 0xC8               ; Standard Dit Dauer in ms

;Initialisierung Stack
mov sp, 0x8000

;Initialisierung GPIO
mov r0, BCM2837_BASE    ; Hardware Adresse der Peripherie in r0 speichern
orr r0, r0, GPIO_BASE   ; r0 'logisch und' mit GPIO_Base um zu den GPIO Adressen zu kommen.

mov r1,#1               ; 1 wird nach r1 gespeichert
lsl r1,#12              ; r1 wird 12 bits nach links geshiftet.
str r1,[r0,#0x8]        ; schreibt nach r0+OFFSET(memory addresse) den Wert von r1
                        ; dadurch wird GPIO24 Port auf Output gestellt


; Funktion die eine gesamte Nachricht morst
morsemessage:
mov r6, #0              ; Variable "im Wort" festlegen auf false
adr r4, message         ; Adresse der message nach r4

nextcharacter:
ldrb r5, [r4], #1       ; ASCII Wert auslesen. r4 hochzählen 
cmp r5, ' '             
beq wordbreak           ; Wortende? 
bls endofline           ; Ende der Nachricht?

movs r3, r6 
blne timer              ; wenn wir im Wort sind, mach noch ein Dit Pause


mov r3, r5              ; Parameter für morsecharacter setzen
bl morsecharacter       ; Zeichen morsen
mov r6, #3              ; Variable "im Wort" festlegen auf true
b nextcharacter

wordbreak:
mov r3, #7              ; Wartezeit nach Wort (7 Dit)
bl timer
mov r6, #0              ; Variable "nicht im Wort" festlegen auf false
b nextcharacter

endofline:
mov r3, #7             ; Wartezeit nach Nachricht (7 Dit)
bl timer
b morsemessage



; Funktion die ein Zeichen morst
; erhält ASCII Wert des Zeichens als Parameter in r3
morsecharacter:
push {lr, r4, r6}

; Parameter (ASCII Wert) in ArrayIndex (von alphabet) umrechnen und nach r0 sichern
sub r0, r3, #55         ; ASCII Wert von 'A'-10 von r3 subtrahieren nach r0
cmp r0, #10             ; r0 und 10 vergleichen
subls r0, r3, '0'       ; falls LS -> ASCII Wert von '0' von r3 subtrahieren


; Adresse suchen und nach r3 sichern
mov r1, #6              
mul r0, r0, r1          ; Index mit 6 multiplizieren (6 Bytes pro Tabellenzeile)
adr r3, alphabet        ; Startadresse von alphabet nach r3
add r3, r0              ; r3 erhöhen um r0 (Index * 6)


mov r6, r3              ; Adresse zwischenspeichern
ldrb r4, [r6], #1       ; Morse Wert aus Lookup Tabelle 'alphabet' auslesen nach r4 und r6 hochzählen

b first
next:                   ; beim ersten Leuchten pro Buchstaben überspringen
mov r3, #1
bl timer

first:
mov r3, r4
bl leuchten             ; Funktion "leuchten" aufrufen

ldrb r4, [r6], #1       ; nächsten Morsewert auslesen und r6 hochzählen
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
db 3,3,3,3,3,0  ; 0
db 1,3,3,3,3,0  ; 1
db 1,1,3,3,3,0  ; 2
db 1,1,1,3,3,0  ; 3
db 1,1,1,1,3,0  ; 4
db 1,1,1,1,1,0  ; 5
db 3,1,1,1,1,0  ; 6
db 3,3,1,1,1,0  ; 7
db 3,3,3,1,1,0  ; 8
db 3,3,3,3,1,0  ; 9
db 1,3,0,0,0,0  ; A
db 3,1,1,1,0,0  ; B
db 3,1,3,1,0,0  ; C
db 3,1,1,0,0,0  ; D
db 1,0,0,0,0,0  ; E
db 1,1,3,1,0,0  ; F
db 3,3,1,0,0,0  ; G
db 1,1,1,1,0,0  ; H
db 1,1,0,0,0,0  ; I
db 1,3,3,3,0,0  ; J
db 3,1,3,0,0,0  ; K
db 1,3,1,1,0,0  ; L
db 3,3,0,0,0,0  ; M
db 3,1,0,0,0,0  ; N
db 3,3,3,0,0,0  ; O
db 1,3,3,1,0,0  ; P
db 3,3,1,3,0,0  ; Q
db 1,3,1,0,0,0  ; R
db 1,1,1,0,0,0  ; S
db 3,0,0,0,0,0  ; T
db 1,1,3,0,0,0  ; U
db 1,1,1,3,0,0  ; V
db 1,3,3,0,0,0  ; W
db 3,1,1,3,0,0  ; X
db 3,1,1,3,0,0  ; Y
db 3,3,1,1,0,0  ; Z

; Nachricht
message:
db 'SOS'
db 0