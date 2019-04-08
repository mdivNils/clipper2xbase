//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// This is a standard win32 exe.
/// </summary>
///
///
/// <remarks>
/// </remarks>
///
///
/// <copyright>
/// Your-Company. All Rights Reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////

#include "Common.ch"
#include "Inkey.ch"
#include "box.ch"
#include "dbstruct.ch"
#include "AppEvent.ch"
// Benˆtigte Bibliotheken f¸r WOpen() und WClose()
#pragma library( "XBTBASE1.LIB" )
#pragma library( "XBTBASE2.LIB" )

// statisch variable bGrafik auf True
STATIC bGrafik := .T.


PROCEDURE Main()
	LOCAL nEvent, mp1, mp2
   PUBLIC caz := "\praxis\"
   SET DATE TO GERMAN
   SET CENTURY ON

   //REQUEST DBFMEMO
   //pinit()

   // beep sound for 2 sec
   Tone(300, 2)

   // check if mouse is on when not turn it on
   IF SetMouse(.F.)
           SetMouse(.T.)
      SET CURSOR ON
   ELSEIF SetMouse(.T.)
           SET CURSOR ON
   ENDIF

   CLEAR
   aku_logo()

   DO WHILE .T.

   @ 10, 10 PROM "1. Anmelden"
   @ 11, 10 PROM "2. Abmelden"
   @ 12, 10 PROM "3. Stundenauswertung"
   // @ 14 ,10 PROM "M. Mitarbeiterstammdaten festlegen"
   // @ 15,10 PROM "A. Arbeitszeitkonto"
   @ 17, 10 PROM "E. Ende"

   MENU TO zeitmen

   	DO CASE

         CASE zeitmen = 1
            Zeit_Anab("1")

          CASE zeitmen = 2
            Zeit_Anab("0")

          CASE zeitmen = 3
            Zeit_Anab("2")

          CASE zeitmen = 4 .OR. LastKey() = K_ESC
             EXIT
          CASE zeitmen = 5
            PStammData()
          CASE zeitmen = 6
     			azkonto()

      ENDCASE
   ENDDO
   CLOSE DATABASE
   QUIT

   //SET EVENTMASK TO INKEY_ALL
   DO WHILE .T.
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

RETURN


***********************************************************
FUNCTION wmr
***********************************************************
IF m_bs = "B"
   WAIT CHR(10)+CHR(13)+"Weiter mit RETURN ..." TO taste
ENDIF
RETURN(NIL)



***********************************************************
FUNCTION kopf
***********************************************************
IF m_bs = "B"
        CLEAR
ENDIF
@ 1,10 SAY "Zeiten fÅr USER: " + muser
@ 2,10 SAY "Zeitraum vom: "+DTOC(mdatum)+"  bis zum: "+DTOC(mdatum2)
@ 3,10 SAY "Datum"
@ 3,30 SAY "Zeit AN"
@ 3,40 SAY "Zeit AB"
@ 3,60 SAY "Zeit Summe"
@ 4,10 SAY REPL("_",60)
Zeile = 5
RETURN(NIL)



***********************************************************
FUNCTION fenster(nTop, nLeft, nBottom, nRight, clearScreen)
***********************************************************
LOCAL window
WInit()
window := WOpen(nTop, nLeft, nBottom, nRight, clearScreen)
RETURN window



***********************************************************
FUNCTION gbrMenu(posX, posY, aUser)
***********************************************************
nVal := 1
RETURN nVal



***********************************************************
PROCEDURE aku_logo()
***********************************************************
        LOCAL nGrafBox
        DispBox(0, 0, 2, 79, nGrafBox)
   @ 1,1  SAY "Zeit-Management"
        @ 1,56 SAY "by AKU Informatik GmbH"
RETURN



***********************************************************
* vorr¸bergehende Lˆsung f¸r das Checkbox problem
PROCEDURE CHECKBOX(nRow, nCol, caption)
***********************************************************
//AAdd( GetList, CHECKBOX( 11, 21, "Zeitkontenmodell     " ) )
LOCAL oXbp

oXbp := XbpCheckbox():new()
oXbp:caption := caption
oXbp:create(, , {nRow, nCol})

RETURN

