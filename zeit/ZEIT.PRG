#include "\clip53\include\aku.ch"
#include "inkey.ch"
#include "llibG.ch"
#INCLUDE "box.CH"
#INCLUDE "blob.CH"
#INCLUDE "dbstruct.CH"
#INCLUDE "dbinfo.CH"
#INCLUDE "llibbtoo.CH"


STATIC bGrafik := .T.


FUNC main()
PUBLIC caz := "\praxis\"
SET DATE GERMAN
SET SCOR OFF
SET EXCL OFF
SET CENTURY ON

REQUEST DBFMEMO
MEMOSETSUPER("DBFNTX")

pinit()

SET EVENTMASK TO INKEY_ALL

tone(300,2)

IF MPRESENT()
	MSETCURSOR( .T. )
ENDIF

* DefColors()

SETCOLOR( Farb_Attrib )
CLEAR
aku_logo()

DO WHILE .T.

	@ 10,10 PROM "1. Anmelden"
	@ 11,10 PROM "2. Abmelden"
	@ 12,10 PROM "3. Stundenauswertung"

//	@ 14,10 PROM "M. Mitarbeiterstammdaten festlegen"
//	@ 15,10 PROM "A. Arbeitszeitkonto"

	@ 17,10 PROM "E. Ende"

	MENU TO zeitmen

	DO CASE

	   CASE zeitmen = 1
			Zeit_Anab("1")

	   CASE zeitmen = 2
			Zeit_anab("0")

	   CASE zeitmen = 3
			Zeit_anab("2")

	   CASE zeitmen = 4 .OR. LASTKEY() = K_ESC
			EXIT

	   CASE zeitmen = 5
			PStammData()

		CASE zeitmen = 6
			azkonto()

	ENDCASE

ENDDO
CLOS DATA
QUIT


***********************************************************
FUNC AZKonto()
***********************************************************
LOCAL xScreen 		:= SAVESCREEN( 0, 0, MAXROW(), MAXCOL())
LOCAL i, j 			:= 0
LOCAL nWahl 		:= 0
LOCAL aPersonen 	:= {}
LOCAL aUser			:= {}
LOCAL aTage 		:= {}
LOCAL aMonate		:= {}
LOCAL aWochen		:= {}
LOCAL dDatum, cAnAb, nSekunden
LOCAL cBuch := " "
LOCAL dVon := dBis := DATE()

DBUSEAREA( .T. , "DBFNTX", "aerzte" )
DBEVAL( {|| AADD( aPersonen, { aerzte->username, RECNO() } ),;
				AADD( aUser, aerzte->username ) },;
			{|| !DELETED() .AND. !EMPTY( aerzte->username ) } )

nWahl := gbrMenu( 10, 10, aUser, NIL, .T. )
IF nWahl = 0
	DBCLOSEAREA()
	RETURN( NIL )
ENDIF
DBGOTO( aPersonen[ nWahl, 2 ] )

fenster( 10, 10, 14, 70, .T. )
@ 1,1 GET cBuch PICT "!"
@ 2,1 GET dVon
@ 3,1 GET dBis
read
wclose()

DBUSEAREA( .T. , "DBFNTX", "zeiten" )
SET INDEX TO zeiten
DBSEEK( cBuch )
i := 0
DO WHILE zeiten->buchstabe = cBuch
	IF zeiten->datum < dVon .OR. zeiten->datum > dBis
		DBSKIP()
		LOOP
	ENDIF
	dDatum := zeiten->datum
	cAnAb := zeiten->anab
	nSekunden := TIMETOSEC( zeiten->zeit )
	DBSKIP()
	nGesH := 0
	IF zeiten->datum = dDatum .AND. cAnAb = "1" .AND. zeiten->anab = "0"
		nStunden := (TIMETOSEC( zeiten->zeit ) - nSekunden) / 60 / 60
		nGesH := nGesH + nStunden
*		AADD( aZeiten, { zeiten->datum, nStunden, nGesH } )
		cMonat := STR( YEAR( zeiten->datum ), 4, 0 ) + ;
						SUBSTR( "0" + LTRIM( STR( MONTH( zeiten->datum ), 2, 0)), -2 )
		nPos := ASCAN( aMonate, {|aEle| aEle[ 1 ] == cMonat })
		IF nPos = 0
			AADD( aMonate, { cMonat, 0, 0, 172, 0, 0 } )
			nPos := LEN( aMonate )
		ENDIF
		aMonate[ nPos, 3 ] := aMonate[ nPos, 3 ] + nStunden
		DBSKIP()
	ENDIF
ENDDO
ASORT( aMonate, NIL, NIL, {|aEle1, aEle2| aEle1[ 1 ] < aEle2[ 1 ] } )
nKumIst := 0
nKumSoll := 0
FOR i := 1 TO LEN( aMonate )
	nKumIst := nKumIst + aMonate[ i, 3 ]
	aMonate[ i, 5 ] := nKumIst
	nKumSoll := nKumSoll + aMonate[ i, 4 ]
	aMonate[ i, 6 ] := nKumSoll
	aMonate[ i, 1 ] := SUBSTR( aMonate[ i, 1 ], 5, 2 ) + "/" + ;
								SUBSTR( aMonate[ i, 1 ], 1, 4 )
	aMonate[ i, 2 ] := aMonate[ i, 5 ] - aMonate[ i, 6 ]
NEXT

oArrServer := ArrServer():New( aMonate )
oGraph := GraphWindow():New( 3, 1, MAXROW()-1, MAXCOL()-1,;
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

RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), xScreen )
RETURN( NIL )




***********************************************************
FUNC PStammData()
***********************************************************
LOCAL GetList 	:= {}
LOCAL xScreen 	:= SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )
LOCAL aPersonen := {}
LOCAL nPerson 	:= 1
LOCAL bVar1		:= .F.
LOCAL bVar2		:= .F.
LOCAL oCB1
CLEAR
aku_logo()
*@ 4, 1 SAY "Mitarbeiter-Stammdaten"

DBUSEAREA( .T. , "DBFNTX", "aerzte" )
DBEVAL( {|| AADD( aPersonen, { aerzte->username, RECNO() } ) },;
			{|| !DELETED() .AND. !EMPTY( aerzte->username ) } )
DO WHILE .T.

	RLOCK()

	@  4, 22, 12, 70 GET nPerson LISTBOX aPersonen ;
							CAPTION "&Mitarbeiter          " ;
							DROPDOWN SCROLLBAR ;
		STATE {|| DBGOTO( aPersonen[ nPerson, 2 ] ), READKILL( .T. ), 	RLOCK() }
	@  6, 22 GET aerzte->passwort ;
							CAPTION "&Passwort             "
	@  7, 22 GET aerzte->datum ;
							CAPTION "Datum letzte énderung" ;
							WHEN .F.
	@ 08, 22 GET aerzte->pwablauf ;
							CAPTION "Passwort lÑuft ab am "

AADD( GetList, CHECKBOX( 11, 21, "Zeitkontenmodell     " ) )
oCB1 := ATAIL( GetList )
ATAIL( GetList ):capCol := 21 - LEN( ATAIL( GetList ):caption )
ATAIL( GetList ):buffer := aerzte->zeitkonto
ATAIL( GetList ):fblock := {|| aerzte->zeitkonto := oCB1:buffer }
ATAIL( GetList ):sblock := {|| aerzte->zeitkonto := oCB1:buffer }
ATAIL( GetList ):Display()

	@ 12, 20 GET aerzte->zeitkonto ;
							CHECKBOX ;
							CAPTION "Zeitkontenmodel" ;
							STATE {|| DBCOMMIT() }
	@ 12, 22 GET aerzte->zk_von ;
							CAPTION "Erîffnung Zeitkonto  " ;
							WHEN aerzte->zeitkonto
	@ 13, 22 GET aerzte->zk_bis ;
							CAPTION "Laufzeit Zeitkonto   " ;
							WHEN aerzte->zeitkonto
	@ 14, 22 GET aerzte->zk_stunden ;
							CAPTION "Vereinbarte Stunden  " ;
							WHEN aerzte->zeitkonto
/*
	@ 17, 22 GET aerzte->abeginn PICT "99:99" ;
							CAPTION "Arbeitsbeginn um     "

	@ 18, 22 GET aerzte->feierabend PICT "99:99" ;
							CAPTION "Feierabend um        "
*/
	@ 17, 22 GET aerzte->faktor_ue ;
							CAPTION "öberstunden-Faktor   "

	@ 19, 22 GET bVar2 PUSHBUTTON CAPTION "Arbeitszeiten-Tabelle" ;
											COLOR farb_attPB

*	GFRAME( 3, 340, 630, 410, 7, 15, 8, 3, 3, 3, 3, LLG_MODE_SET )
*	GRECT( x1, y1, x2, y2, bMode, aDigit[ i, DIGIT_FIELDCOLOR ], LLG_MODE_SET )

*	DISPBOX( 21, 0, 25, 79, nGrafBox )
	@ 21,  0 SAY "Gespeicherte KVK-Daten"
	@ 22,  0 SAY "Patientenname"
	@ 23,  0 SAY "Mitglieds-Nr."
	@ 24,  0 SAY "Stra·e"
	@ 25,  0 SAY "PLZ, Ort"

	@ 22, 22 SAY TRIM( aerzte->kvk_name ) + ", " + TRIM( aerzte->kvk_vor ) COLOR "R/N*"
	@ 23, 22 SAY TRIM( aerzte->kvk_mgnr ) COLOR "R/N*"
	@ 24, 22 SAY TRIM( aerzte->kvk_str ) COLOR "R/N*"
	@ 25, 22 SAY aerzte->kvk_plz + " " + TRIM( aerzte->kvk_ort ) COLOR "R/N*"

	@ 29,  1 GET bVar1 PUSHBUTTON CAPTION "&Speichern" ;
											COLOR farb_attPB ;
											STATE {|| READKILL(.T.) } ;
											STYLE "[]"
	@ 29, 24 GET bVar1 PUSHBUTTON CAPTION "&KVK-Daten einlesen und speichern" ;
											COLOR farb_attPB ;
											STATE {|| READKILL(.T.) } ;
											STYLE "[]"
	@ 29, 71 GET bVar1 PUSHBUTTON CAPTION "&Abbruch" ;
											COLOR farb_attPB ;
											STATE {|| READKILL(.T.) } ;
											STYLE "[]"
	READ
	IF LASTKEY() = K_ESC
		EXIT
	ENDIF
ENDDO

RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), xScreen )
RETURN( NIL )


***********************************************************
FUNC zeit_anab (_anab)
***********************************************************
/*
			an-/abmelden am System
*/

M_Buch = " "
SET CURS ON
fenster( 10, 10, 12, 70, .T.)
@ 1,1 SAY "Geben Sie Ihr Zeichen ein: " GET M_Buch PICT "!"
READ
wclose()
IF LASTKEY() = 27 .OR. EMPTY( m_buch )
	RETURN( NIL )
ENDIF

USE aerzte
LOCA FOR buchstabe = m_buch
IF !FOUND()
   msg("Zeichen existiert nicht!")
	USE
   RETU
ELSE
   MUser = USERNAME
ENDIF
USE
IF _anab = "2"							&& Listenfunktion
   Zeit_List()
	RETU
ENDIF
mtime = TIME()
nSec := SECONDS()
OPEN_Zeiten()
SET ORDE TO 2
SEEK m_buch+DESCEND( DTOS( DATE() ) )
IF anab = _anab
   MSG("ACHTUNG! Sie sind bereits "+if(anab="1","AN","AB")+"-gemeldet!")
	USE
   RETU
ENDIF
fenster( 10, 10, 14, 70, .T.)
@ 1,1 SAY "Sie sind USER " + TRIM(muser)+"."
IF _anab = "1"										// anmelden
   @ 2,1 SAY "Angemeldet um: "+mtime
ELSE                                      // abmelden
   @ 2,1 SAY "Abgemeldet um: "+mtime
ENDIF
@ 3,1 SAY "BestÑtigen mit RETURN, Abbruch mit ESC!"
INKEY(0)
wclose()
IF LASTKEY() = K_RETURN
   APPE BLAN
   REPL 	buchstabe WITH m_buch, datum WITH DATE(), anab WITH _anab,;
		 	zeit WITH mtime
	IF TYPE( "zeiten->sekunden" ) = "N"
		zeiten->sekunden := nSec
	ENDIF
	USE
   MSG("Ist registriert!")
ENDIF
USE
RETURN(NIL)



***********************************************************
FUNC Zeit_List
***********************************************************
/*
			Liste Zeiten fÅr User
*/
mdatum  = DATE()
mdatum2 = DATE()
m_bs    = "B"
fenster( 10, 10, 14, 70, .T.)
@ 1,1 SAY "Zeiten vom: " GET mdatum
@ 2,1 SAY "bis zum   : " GET mdatum2
@ 3,1 SAY "Bild/Druck: " GET m_bs 		PICT "!" VALID(m_bs $ "BD")
READ
WCLOSE()
IF EMPTY(mdatum) .OR. LASTKEY() = 27
	RETURN(.T.)
ENDIF
IF mdatum2 < mdatum
   MSG("Datum 1 mu· <= Datum 2!")
	RETURN(.T.)
ENDIF

OPEN_Zeiten()
SET SOFT ON
SEEK m_buch+DTOS( mdatum )
SET SOFT OFF
IF m_bs = "D"
   fenster( 10, 10, 12, 70, .T.)
   @ 1,1 SAY "Bitte warten, drucke Liste ..."
	SET DEVI TO PRIN
   max_line = 58
ELSE
   max_line = 19
ENDIF
zeile     = 1
kopf()
gzeit     = 0
gzeit2    = 0
gtag      = 0
AltDatum  = CTOD("  .  .  ")

DO WHILE buchstabe = m_buch .AND. DTOS(datum) <= DTOS(mdatum2)

   @ zeile,10 SAY datum
   @ zeile,20 SAY IF( anab = "1", "an", "ab")
   IF anab = "1"
      @ zeile,30 SAY zeit
	  	gzeit2 = TIMETOSEC( zeit )
	ELSE
      @ zeile,40 SAY zeit
	  	@ zeile,60 SAY SECTOTIME( TIMETOSEC( zeit)-gzeit2)
      Zeile = Zeile + 1
	  	IF datum != altdatum						// wenn Datumswechsel
	     	AltDatum = Datum
	     	gtag  = gtag  + 1						// Arbeitstage
	  	ENDIF
   ENDIF

   IF anab = "1"
      gzeit = gzeit - TIMETOSEC( zeit )
	ELSE
      gzeit = gzeit + TIMETOSEC( zeit )
	ENDIF

	SKIP
   IF zeile > max_line
      wmr()
	  	kopf()
	ENDIF

ENDDO
GesamtSekunden = gzeit
GesamtStunden  = FLOOR(GesamtSekunden / (60*60))			// Floor() gibt nÑchste
                                                        	// kleinere ganze Zahl zurÅck
GesamtSekunden = GesamtSekunden - (GesamtStunden*60*60)
GesamtMinuten  = Floor(GesamtSekunden/60)
GesamtSekunden = GesamtSekunden - (GesamtMinuten*60)

@ zeile  ,10 SAY REPL("_",60)
@ zeile+1,10 SAY "Arbeitstage ...: " + STR(GTag,5,0)
@ zeile+2,10 SAY "Arbeitsstunden : " + STR(GesamtStunden,5,0)
@ zeile+3,10 SAY "Arbeitsminuten : " + STR(GesamtMinuten,5,0)
@ zeile+4,10 SAY "Arbeitssekunden: " + STR(GesamtSekunden,5,0)
wmr()
SET DEVI TO SCRE
WCLOSE()
USE
CLEA


***********************************************************
FUNC wmr
***********************************************************
IF m_bs = "B"
   WAIT CHR(10)+CHR(13)+"Weiter mit RETURN ..." TO taste
ENDIF
RETURN(NIL)


***********************************************************
FUNC kopf
***********************************************************
IF m_bs = "B"
	CLEA
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
FUNC open_zeiten
***********************************************************
USE zeiten EXCL
IF FILE("zeiten.ntx")
   SET INDEX TO zeiten
ELSE
   fenster( 10, 10, 12, 70, .T.)
   @ 1,1 SAY "Bitte einen Moment, reorganisiere Datei ..."
   INDEX ON BUCHSTABE+DTOS(datum) TO zeiten
	WCLOSE()
ENDIF
IF FILE("zeitend.ntx")
   SET INDEX TO zeitenD
ELSE
   Fenster(10,10,12,70,.t.)
   @ 1,1 SAY "Bitte einen Moment, reorganisiere Datei ..."
   INDEX ON buchstabe+DESCEND(DTOS(datum)+zeit) TO zeitenD
	WCLOSE()
ENDIF
SET INDEX TO zeiten, zeitend


***********************************************************
FUNC aku_logo()
***********************************************************
* LOCAL cTempColor := SETCOLOR( farb_attrib)
*DISPBOX( 0, 0, 2, 79, LLG_BOX_GRAY_SQUARE, CHR(1)+CHR(8))
DISPBOX( 0, 0, 2, 79, nGrafBox )
@ 1,1  SAY "Zeit-Management"
@ 1,56 SAY "by AKU Informatik GmbH"
* SETCOLOR( cTempColor )
RETURN( NIL )









