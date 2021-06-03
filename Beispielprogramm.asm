format binary as 'img'
include 'LIB\FASMARM.INC'

BCM2837_BASE = $3F000000
GPIO_BASE =  $200000

;Initialisierung GPIO
;Zieladresse berechnen
mov r0, BCM2837_BASE
orr r0, r0, GPIO_BASE

;Zu setzender Inhalt berechnen 
mov r1,#1
lsl r1,#12

;Inhalt an Zieladresse + Offset speichern
str r1,[r0,#0x8]

loop:
mov r1,#1
lsl r1,#24
str r1,[r0,#0x1C]  ;anzünden...

mov r4, #0xFF000  ; Warteschleife
wait1$:
 sub r4,#1
 cmp r4,#0
 bne wait1$

str r1,[r0,#0x28]  ;löschen...

mov r4, #0xFF000  ; Warteschleife
wait2$:
 sub r4,#1
 cmp r4,#0
 bne wait2$

b loop

