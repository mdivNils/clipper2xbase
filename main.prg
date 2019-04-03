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

// In the example, various variables are initialized.
// They can be edited by Get objects created with
// different options.

PROCEDURE DbeSys()
   DbeSetDefault()
RETURN

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
         	//PStammData()
       	CASE zeitmen = 2
          //azkonto()

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
PROCEDURE AZKonto()
***********************************************************
LOCAL xScreen     := SAVESCREEN( 0, 0, MAXROW(), MAXCOL())
LOCAL i, j			:= 0
LOCAL nWahl			:= 0
LOCAL aPersonen 	:= {}
LOCAL aUser			:= {}
LOCAL aTage 		:= {}
LOCAL aMonate		:= {}
LOCAL aWochen		:= {}
LOCAL cBuch 		:= " "
LOCAL dVon 			:= dBis := DATE()
LOCAL dDatum, cAnAb, nSekunden

DbUseArea(.T., , "aerzte")
DbEval( {|| AAdd( aPersonen, { aerzte->username, RecNo() } ),;
			 AAdd( aUser, aerzte->username) },;
          {|| !Deleted() .AND. !Empty( aerzte-username ) } )

//nWahl := gbrMenu(10, 10, aUser, NIL, .T.)

IF nWahl = 0
	DbCloseArea()
   RETURN
ENDIF
DbGoTo( aPersonen[ nWahl, 2 ] )

//fenster( 10, 10, 14, 70, .T. )
@ 1,1 GET cBuch PICT "!"
@ 2,1 GET dVon
@ 3,1 GET dBis
read
//wclose()

***********************************************************
PROCEDURE zeit_anab (_anab)
***********************************************************

RETURN

***********************************************************
FUNCTION fenster(nWidth, nHeight, posX, posY)
***********************************************************
file := 1
RETURN file

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
