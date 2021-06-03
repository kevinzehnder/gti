format binary as 'img'
include 'LIB\FASMARM.INC'

BCM2835_BASE = $3F000000
GPIO_BASE =  $200000
TIMER_BASE = $3000
TIMER_CNT = $4          ; Hardware Adresse des System Timers ist 0x7E003000.
LED_AN = 0x1C
LED_AUS = 0x28
DAUER = 0x1F4           ; 500

;Initialisierung Stack
mov sp, 0x8000

;Initialisierung GPIO
mov r0, BCM2835_BASE    ; Hardware Adresse der Peripherie in r0 speichern
orr r0, r0, GPIO_BASE   ; r0 'logisch und' mit GPIO_Base um zu den GPIO Adressen zu kommen. Das Resultat ist 0x3F200000.

mov r1,#1               ; 1 wird nach r1 gespeichert
lsl r1,#12              ; r1 wird 12 bits nach links geshiftet.
str r1,[r0,#0x8]        ; schreibt nach r0+OFFSET(memory addresse) den Wert von r1
                        ; (an die Memory Adresse die in r0 steht, nicht ins Register r0)
                        ; dadurch wird GPIO24 Port auf Output gestellt

; Funktion die eine gesamte Nachricht morst
morsemessage:
adr r4, alphabet        ; Adresse der Lookup Table in r4 speichern
add r5, r4, 0x7F        ; Position für S nach r4 speichern
bl morsecharacter
mov r3, #3
bl pause

adr r4, alphabet        ; Adresse der Lookup Table in r4 speichern
add r5, r4, 0x63        ; Position für O nach r4 speichern
bl morsecharacter
mov r3, #3
bl pause

adr r4, alphabet        ; Adresse der Lookup Table in r4 speichern
add r5, r4, 0x7F        ; Position für S nach r4 speichern
bl morsecharacter
mov r3, #7
bl pause

b morsemessage


; Funktion die ein Parameter erhält und diesen mittels MORSECODE ausgibt
; der Parameter wird in r5 übergeben.
morsecharacter:
push {lr}

ldrb r1, [r5]           ; Morse Wert aus Lookup Tabelle 'alphabet' auslesen
add r5, r5, #1          ; r5 hochzählen

b first
next:                   ; beim ersten Leuchten pro Buchstaben überspringen
push {r1}               ; save registers (caller)
mov r10, DAUER
sub sp, sp, #4
str r10,[sp]
bl timer
add sp, sp, #4
pop {r1}i               ; restore registers (caller)

first:
mov r10, DAUER          ; Parameter setzen
mul r10, r10, r1

sub sp, sp, #4          ; Platz auf Stack allozieren
str r10,[sp]            ; Parameter auf Stack pushen
bl leuchten             ; Funktion "leuchten" aufrufen
add sp, sp, #4          ; Parameter löschen

ldrb r1, [r5]           ; nächsten Morsewert auslesen
add r5,r5,#1
cmp r1, #0
bne next

pop {pc}

; Wartezeit zwischen Symbolen oder Worten
pause:
mov r4, DAUER
mul r3, r3, r4
push {lr}
push {r3}
bl timer
pop {r3}
pop {pc}

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


; Timerfunktion mit Parameter vom Stack
timer:
mov r1, BCM2835_BASE      ; Hardware Adresse der Peripherie in r1 speichern.
orr r1, r1, TIMER_BASE    ; r1 'logisch und' mit TIMER_BASE um zu den Timer Adressen zu kommen.
ldr r2, [r1, TIMER_CNT]   ; aktuelle Zeit in r2 ablegen (r1 + offset TIMER_CNT)
ldr r3, [sp]              ; Parameter "Wartezeit" vom Stack nach r3 lesen
mov r4, #1000             ; #1000 nach r4 speichern
mul r3, r3, r4            ; Wartezeit mit r4 multiplizieren
add r3, r2, r3            ; r2 + Wartezeit rechnen = Zielzeit. Nach r3 speichern.

wait1$:                   ; busy waiting bis Zielzeit erreicht
 ldr r2, [r1, TIMER_CNT]  ; aktuelle Zeit in r2 ablegen
 cmp r2, r3               ; r7 und Zielzeit vergleichen
 bls wait1$               ; wenn Zielzeit <= aktuelle Zeit, dann fertig, sonst wait1$

mov pc, lr                ; programcounter zurücksetzen auf link register. lr wurde von bl automatisch gesetzt als Rücksprungadresse.
                          ; r14 heisst auch lr (link register)
                          ; r15 heisst auch pc (program counter)


; LED Leuchtfunktion
leuchten:
mov r11, sp               ; aktuellen Stackpointer nach r11 laden als "Base" / "Frame" Pointer.
sub sp, #4                ; 1 Byte Platz auf Stack allozieren
str lr, [sp]              ; lr (Rücksprungadresse) auf den Stack speichern

  mov r1,#1
  lsl r1,#24
  str r1,[r0,LED_AN]      ; anzünden

  ldr r2,[r11]            ; Paramter "Zeitfaktor" vom Stack auslesen und nach r2 laden. Ab Base Pointer.
  sub sp,#4               ; Stackpointer 4 Bytes runtersetzen
    str r2,[sp]           ; Register2 als Parameter auf den Stack speichern. Benötigt 4 Byte, da 32bit.
    bl timer              ; branch link timer (Sprung zu timer:)
  add sp, #4              ; 'Parameter vom Stack löschen' bzw. Stackpointer zurücksetzen. Adresse vergessen. Whatever.
                          ; Bringt hier eigentlich nichts mehr.

  mov r1,#1
  lsl r1,#24
  str r1,[r0,LED_AUS]     ; löschen

mov sp, r11               ; Stackpointer wiederherstellen am Ende der Funktion bzw. vor Rücksprung.
ldr pc, [sp, #-4]         ; Zurückspringen auf anfänglich gespeicherte Position.
