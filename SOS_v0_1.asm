format binary as 'img'
include 'LIB\FASMARM.INC'

BCM2835_BASE = $3F000000
GPIO_BASE =  $200000
TIMER_BASE = $3000
TIMER_CNT = $4          ; Hardware Adresse des System Timers ist 0x7E003000.
LED_AN = 0x1C
LED_AUS = 0x28
DAUER = 0x1F4            ; 500

;Initialisierung Stack
mov sp, 0x8000


;Initialisierung GPIO
mov r0, BCM2835_BASE    ; Hardware Adresse der Peripherie in r0 speichern
orr r0, r0, GPIO_BASE   ; r0 'logisch und' mit GPIO_Base um zu den GPIO Adressen zu kommen. Das Resultat ist 0x3F200000.

mov r1,#1              ; 1 wird nach r1 gespeichert
lsl r1,#12             ; r1 wird 12 bits nach links geshiftet.
str r1,[r0,#0x8]       ; schreibt nach r0+OFFSET(memory addresse) den Wert von r1
                       ; (an die Memory Adresse die in r0 steht, nicht ins Register r0)
                       ; dadurch wird GPIO24 Port auf Output gestellt


; Bestimmte Reihenfolge morsen
; nachricht:


; TESTSIGNAL ausgeben im Endlos-Loop (einmal lang, einmal kurz) - nicht mehr benötigt.
loop:

mov r9, LED_AN          ; Parameter setzen 
mov r10, DAUER          ; Parameter setzen
sub sp, sp, #8          ; Platz auf Stack allozieren
str r9,[sp]             ; Parameter auf Stack speichern
str r10,[sp, #4]        ; Parameter auf Stack pushen
bl led                  ; Funktion "led" aufrufen
add sp, #8              ; Parameter löschen


mov r9, LED_AUS
mov r10, DAUER           ; Parameter setzen
sub sp, sp, #8          ; Platz auf Stack allozieren
str r9,[sp]             ; Parameter auf Stack speichern
sub sp, sp, #8          ; Platz auf Stack allozieren
str r9,[sp]             ; Parameter auf Stack speichern
str r10,[sp, #4]        ; Parameter auf Stack pushen
bl led                  ; Funktion "led" aufrufen
add sp, #8              ; Parameter löschen


mov r9, LED_AN
mov r10, DAUER           ; Parameter setzen
    mov r7, #3
    mul r10, r7, r10
sub sp, sp, #8          ; Platz auf Stack allozieren
str r9,[sp]             ; Parameter auf Stack speichern
str r10,[sp, #4]        ; Parameter auf Stack pushen
bl led                  ; Funktion "led" aufrufen
add sp, #8              ; Parameter löschen


mov r9, LED_AUS
mov r10, DAUER           ; Parameter setzen
sub sp, sp, #8          ; Platz auf Stack allozieren
str r9,[sp]             ; Parameter auf Stack speichern
str r10,[sp, #4]        ; Parameter auf Stack pushen
bl led                  ; Funktion "led" aufrufen
add sp, #8              ; Parameter löschen

b loop



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


; LED-Funktion mit 2 Paramete. Ein/Aus (Parameter1) + Warten (Dauer Parameter 2)
led:
mov r11, sp               ; aktuellen Stackpointer nach r11 laden als "Base" / "Frame" Pointer.
sub sp, #4                ; 1 Byte Platz auf Stack allozieren
str lr, [sp]              ; lr (Rücksprungadresse) auf den Stack speichern

  mov r1,#1
  lsl r1,#24
  ldr r2,[r11]            ; Parameter "Ein oder Aus" auslesen nach r2 laden
  str r1,[r0,r2]          ; "anzünden oder löschen"

  ldr r2,[r11, #4]        ; Paramter "Zeitfaktor" vom Stack auslesen und nach r2 laden. Ab Base Pointer.
  sub sp,#4               ; Stackpointer 4 Bytes runtersetzen
    str r2,[sp]           ; Register2 als Parameter auf den Stack speichern. Benötigt 4 Byte, da 32bit.
    bl timer              ; branch link timer (Sprung zu timer:)
  add sp, #4              ; 'Parameter vom Stack löschen' bzw. Stackpointer zurücksetzen. Adresse vergessen. Whatever.
                          ; Bringt hier eigentlich nichts mehr.

mov sp, r11               ; Stackpointer wiederherstellen am Ende der Funktion bzw. vor Rücksprung.
ldr pc, [sp, #-4]         ; Zurückspringen auf anfänglich gespeicherte Position.


; Zeichen MORSEN
; morsen:

; Funktion erhält vom Stack die Adresse zum Zeichen in der Tabelle
; Dann muss diese Adresse gemorst werden.


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
db ' ',7,0,0,0,0,0