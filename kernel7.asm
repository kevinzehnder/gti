BCM2835_BASE = $3F000000
GPIO_BASE =  $200000 ; Adresse, an der die GPIO anfangen

format binary as 'img' ; Festlegen, zu welchem Dateityp compiled wird
include 'LIB\FASMARM.INC'

; Initialisierung GPIO
mov r0, BCM2835_BASE
orr r0, r0, GPIO_BASE

; GPIO24 ist im GPFSEL2 (= 0x3F200008)
; an den Bits 14-12  (als Ouput = '001')
mov r1,#1 ; Wert in R1 mit "1" initialisieren
lsl r1,#12
str r1,[r0,#0x8]  ; GPIO24 Port auf Output stellen

; <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
; <+++++++++++++++++++++++++++++++++ START Haupt-Routine ++++++++++++++++++++++++++++>
; <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
loop: ; Endlose Schleife

    ; <______________________ Das erste "S" in "SOS" ________________________________>
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    erstesS:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl blinkKurz
        cmp r5,#0 ; Ueberpruefen, ob der Wert in R5 gleich "0" ist
        bne erstesS ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <______________________________________________________________________________>
    
    
    ; <------------------------------- KURZE Pause #1 ------------------------------->
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    breakone:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl pauseKurz
        cmp r5,#0
        bne breakone ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <------------------------------------------------------------------------------>
    
    
    ; <______________________________ Das "O" in "SOS" ______________________________>
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    firsto:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl blinkLang
        cmp r5,#0 ; Ueberpruefen, ob der Wert in R5 gleich "0" ist
        bne firsto ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <______________________________________________________________________________>
    
    
    ; <------------------------------- KURZE Pause #2 ------------------------------->
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    breaktwo:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl pauseKurz
        cmp r5,#0
        bne breaktwo ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <------------------------------------------------------------------------------>


    ; <___________________________ Das zweite "S" in "SOS" __________________________>
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    zweitesS:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl blinkKurz
        cmp r5,#0
        bne zweitesS ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <______________________________________________________________________________>
    
    
    ; <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LANGE Pause ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>
    mov r5, #3 ; Wert in R5 mit "3" initialisieren
    breaks:
        sub r5,#1 ; Vom Wert in R5 "1" subtrahieren
        bl pauseLang
        cmp r5,#0
        bne breaks ; Falls der Wert in R5 NICHT gleich "0" war: wieder nach oben
    ; <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>

b loop
; <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
; <+++++++++++++++++++++++++++++++ ENDE Haupt-Routine +++++++++++++++++++++++++++++++>
; <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>


; <************************* Subroutine fuer kurzes Blinken *************************>
blinkKurz:
    mov r1,#1 ; Wert in R1 mit "1" initialisieren
    lsl r1,#24
    str r1,[r0,#0x1C]  ; LED an (SET = 0x3F20001C)
    mov r4, #0x0EFFF  ; kurz
    
    wait1$:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne wait1$
    
    str r1,[r0,#0x28]  ; LED aus (CLEAR = 0x3F200028)
    
    mov r4, #0xFF000  ; selbe pause
    wait2$:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne wait2$ ; Falls der Wert in R4 NICHT gleich "0" war: wieder nach oben
bx lr ; An die Position zurueckspringen, an der die Subroutine aufgerufen wurde
; <***********************************************************************************>


; <.......................... Subroutine fuer langes Blinken .........................>
blinkLang:
    mov r1,#1 ; Wert in R1 mit "1" initialisieren
    lsl r1,#24
    str r1,[r0,#0x1C]  ; LED an (SET = 0x3F20001C)
    
    mov r4, #0xFF000  ; Wert in R4 mit 0xFF000 (4095) initialisieren
    wait3$:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne wait1$ ; Falls der Wert in R4 NICHT gleich "0" war: wieder nach oben
    
    str r1,[r0,#0x28]  ; LED aus (CLEAR = 0x3F200028)

    mov r4, #0xFF000  ; Wert in R4 mit 0xFF000 (4095) initialisieren
    wait4$:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne wait2$ ; Falls der Wert in R4 NICHT gleich "0" war: wieder nach oben
bx lr ; An die Position zurueckspringen, an der die Subroutine aufgerufen wurde
; <...................................................................................>


; <,,,,,,,,,,,,,,,,,,,,,,,,,,, Subroutine fuer kurze Pause ,,,,,,,,,,,,,,,,,,,,,,,,,,,>
pauseKurz:
    mov r4, #0x00FFF ; R4 mit 0xFF000 (4095) initialisieren
    shorty:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne shorty ; Falls der Wert in R4 NICHT gleich "0" war: wieder nach oben
bx lr ; An die Position zurueckspringen, an der die Subroutine aufgerufen wurde
; <,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,>


; <*************************** Subroutine fuer lange Pause ***************************>
pauseLang:
    mov r4, #0xFF000 ; R4 mit 0xFF000 (1044480) initialisieren
    longy:
        sub r4,#1 ; Vom Wert in R4 "1" subtrahieren
        cmp r4,#0 ; Ueberpruefen, ob der Wert in R4 gleich "0" ist
        bne longy ; Falls der Wert in R4 NICHT gleich "0" war: wieder nach oben
bx lr ; An die Position zurueckspringen, an der die Subroutine aufgerufen wurde
; <***********************************************************************************>
