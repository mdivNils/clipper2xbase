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
// damit geht wOpen und wClose
#pragma library( "XBTBASE1.LIB" )
#pragma library( "XBTBASE2.LIB" )

// In the example, various variables are initialized.
// They can be edited by Get objects created with
// different options.

STATIC bGrafik := .T.

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
PROCEDURE AZKonto()
***********************************************************
LOCAL xScreen     := WSaveScreen( 0, 0, MAXROW(), MAXCOL())
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

WInit()
fenster( 10, 10, 14, 70, .T. )
@ 1,1 GET cBuch PICT "!"
@ 2,1 GET dVon
@ 3,1 GET dBis
read
WClose()

DbUseArea(.T.,,"zeiten")
SET INDEX TO zeiten

DbSeek(cBuch)
i := 0
DO WHILE zeiten->buchstabe = cBuch
   IF zeiten->datum < dVon .OR. zeiten->datum > dBis
		DbSkip()
		Loop
	ENDIF
   dDatum := zeiten->datum
   cAnAb := zeiten->anab
	nSekunden := TimeToSec( zeiten->zeit )
   DbSkip()
   nGesh := 0
   IF zeiten->datum = dDatum .AND. cAnAb = "1" .AND. zeiten->anab = "0"
		nStunden := (TimeToSec( zeiten->zeit ) - nSekunden) / 60 / 60
		nGesH := nGesH + nStunden
*		AADD( aZeiten, { zeiten->datum, nStunden, nGesH } )
		cMonat := Str( Year( zeiten->datum ), 4, 0 ) + ;
						SubStr( "0" + LTrim( Str( Month( zeiten->datum ), 2, 0)), -2 )
		nPos := AScan( aMonate, {|aEle| aEle[ 1 ] == cMonat })
		IF nPos = 0
			AAdd( aMonate, { cMonat, 0, 0, 172, 0, 0 } )
			nPos := Len( aMonate )
		ENDIF
		aMonate[ nPos, 3 ] := aMonate[ nPos, 3 ] + nStunden
		DbSkip()
	ENDIF
ENDDO
ASort( aMonate, NIL, NIL, {|aEle1, aEle2| aEle1[ 1 ] < aEle2[ 1 ] } )
nKumIst := 0
nKumSoll := 0
FOR i := 1 TO Len( aMonate )
	nKumIst := nKumIst + aMonate[ i, 3 ]
	aMonate[ i, 5 ] := nKumIst
	nKumSoll := nKumSoll + aMonate[ i, 4 ]
	aMonate[ i, 6 ] := nKumSoll
	aMonate[ i, 1 ] := SubStr( aMonate[ i, 1 ], 5, 2 ) + "/" + ;
								SubStr( aMonate[ i, 1 ], 1, 4 )
	aMonate[ i, 2 ] := aMonate[ i, 5 ] - aMonate[ i, 6 ]
NEXT

/* geht momentan nicht da er die ArrServer und GraphWindow Funktion nicht kennt.
oArrServer := ArrServer():New( aMonate )
oGraph := GraphWindow():New( 3, 1, MaxRow()-1, MaxCol()-1,;
		 	 oArrServer, "Auslastung Stunden pro Monat" )
oGraph:AutoLayout( oGraph:DataSource )
oGraph:Graph:AxisX:Title := "Monat"
oGraph:Graph:AxisYLeft:Title := "Stunden"

oColumn := oGraph:Graph:GetColumnInGraph( 1 )
oColumn:Title := "Saldo"
oColumn := oGraph:Graph:GetColumnInGraph( 2 )
oColumn:Title := "IST p.M."
oColumn := oGraph:Graph:GetColumnInGraph( 3 )
oColumn:Title := "SOLL p.M."
oColumn := oGraph:Graph:GetColumnInGraph( 4 )
oColumn:Title := "IST kum."
oColumn := oGraph:Graph:GetColumnInGraph( 5 )
oColumn:Title := "SOLL kum"

oGraph:Graph:Legend:Visible := .T.
oGraph:Graph:NumRowInView := LEN( aMonate )

oGraph:Open():Read():Close()

*/
RestScreen(0,0, MaxRow(), MaxCol(), xScreen)
RETURN NIL

***********************************************************
FUNCTION PStammData()
***********************************************************
LOCAL GetList 	:= {}
LOCAL xScreen 	:= SaveScreen( 0, 0, MaxRow(), MaxCol() )
LOCAL aPersonen := {}
LOCAL nPerson 	:= 1
LOCAL bVar1		:= .F.
LOCAL bVar2		:= .F.
LOCAL oCB1
CLEAR
aku_logo()
*@ 4, 1 SAY "Mitarbeiter-Stammdaten"

DbUseArea(.T., , "aerzte")

***********************************************************
PROCEDURE zeit_anab (_anab)
***********************************************************

RETURN

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
