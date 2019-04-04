//////////////////////////////////////////////////////////////////////
///
/// <summary>
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
// here will be all functions so our main.prg isnt so bloated and unreadable

***********************************************************
PROCEDURE AZKonto()
***********************************************************
LOCAL xScreen     := WSaveScreen( 0, 0, MAXROW(), MAXCOL())
LOCAL i, j                        := 0
LOCAL nWahl                        := 0
LOCAL aPersonen         := {}
LOCAL aUser                        := {}
LOCAL aTage                 := {}
LOCAL aMonate                := {}
LOCAL aWochen                := {}
LOCAL cBuch                 := " "
LOCAL dVon                         := dBis := Date()
LOCAL dDatum, cAnAb, nSekunden

DbUseArea(.T.,"DBFNTX", "aerzte")
DbEval( {|| AAdd( aPersonen, { aerzte->username, RecNo() } ),;
            AAdd( aUser, aerzte->username) },;
            {|| !Deleted() .AND. !Empty( aerzte-username ) } )

nWahl := gbrMenu(10, 10, aUser, NIL, .T.)

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
*                AADD( aZeiten, { zeiten->datum, nStunden, nGesH } )
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
PROCEDURE PStammData()
***********************************************************
LOCAL GetList         := {}
LOCAL xScreen         := SaveScreen( 0, 0, MaxRow(), MaxCol() )
LOCAL aPersonen := {}
LOCAL nPerson         := 1
LOCAL bVar1                := .F.
LOCAL bVar2                := .F.
LOCAL oCB1
CLEAR
aku_logo()
*@ 4, 1 SAY "Mitarbeiter-Stammdaten"

DbUseArea(.T., , "aerzte")
DbEval( {|| AAdd( aPersonen, { aerzte->username, RecNo() } ) },;
             {|| !Deleted() .AND. !Empty( aerzte->username ) } )

DO WHILE .T.
        RLock()
   /*
   @  4, 22, 12, 70 GET nPerson LISTBOX aPersonen
                                                  CAPTION "&Mitarbeiter         " ;
                                                  DROPDOWN SCROLLBAR ;
                STATE {|| DbgotTo( aPersonen[ nPerson, 2 ] ), ReadKill( .T. ), RLock() }
        @  6, 22 GET aerzte->passwort;
                                                  //CAPTION "&Passwort            "
        @  7, 22 GET aerzte->datum
                                                  //CAPTION "Datum letzte ?nderung";
                                                  WHEN .F.
        @ 08, 22 GET aerzte->pwablauf
                                                  ///CAPTION "Passwort l?uft ab am "
    */
   AAdd( GetList, CHECKBOX( 11, 21, "Zeitkontenmodell     " ) )
   oCB1 := ATail( GetList )
   ATail( GetList ):capCol := 21 - Len( ATail( GetList ):caption )
   ATail( GetList ):buffer := aerzte->zeitkonto
   ATail( GetList ):fblock := {|| aerzte->zeitkonto := oCB1:buffer }
   ATail( GetList ):sblock := {|| aerzte->zeitkonto := oCB1:buffer }
   ATail( GetList ):Display()

   /*
   @ 12, 20 GET aerzte->zeitkonto ;
                                                        CHECKBOX ;
                                                        CAPTION "Zeitkontenmodel" ;
                                                        STATE {|| DbCommit() }
        @ 12, 22 GET aerzte->zk_von ;
                                                        CAPTION "Er?ffnung Zeitkonto  " ;
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
**
        @ 17, 22 GET aerzte->faktor_ue ;
                                                        CAPTION "?berstunden-Faktor   "

        @ 19, 22 GET bVar2 PUSHBUTTON CAPTION "Arbeitszeiten-Tabelle" ;
                                                                                        COLOR farb_attPB

*        GFRAME( 3, 340, 630, 410, 7, 15, 8, 3, 3, 3, 3, LLG_MODE_SET )
*        GRECT( x1, y1, x2, y2, bMode, aDigit[ i, DIGIT_FIELDCOLOR ], LLG_MODE_SET )

*        DISPBOX( 21, 0, 25, 79, nGrafBox )
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
                                 */
        READ
        IF LASTKEY() = K_ESC
                EXIT
        ENDIF
ENDDO

RETURN
***********************************************************
* an und abmelden am system
PROCEDURE zeit_anab (_anab)
***********************************************************
LOCAL buchstabe
M_Buch = " "
SET CURSOR ON

fenster(10, 10, 12, 70, .T.)
@ 1,1 SAY "Geben Sie Ihr Zeichen ein: " GET M_Buch PICT "!"
READ
WClose()
IF LASTKEY() = 27 .OR. EMPTY( m_buch )
   RETURN( NIL )
ENDIF

USE aerzte
buchstabe = M_Buch
IF !Found(buchstabe)
   MsgBox("Zeichen existieren nicht!")
   USE
   RETURN
ELSE
   MUser = USERNAME
ENDIF
USE
IF _anab = "2"
        Zeit_list()
   RETURN
ENDIF

mTime = Time()
nSec := Seconds()
open_Zeiten()

SEEK m_buch+DESCEND( DTOS( DATE() ) )
IF anab = _anab
   MsgBox("ACHTUNG! Sie sind bereits "+if(anab="1","AN","AB")+"-gemeldet!")
   RETURN
ENDIF
fenster( 10, 10, 14, 70, .T.)
@ 1,1 SAY "Sie sind USER " + Trim(muser)+"."
IF _anab = "1"                                                                                // anmelden
   @ 2,1 SAY "Angemeldet um: "+mtime
ELSE                                      // abmelden
   @ 2,1 SAY "Abgemeldet um: "+mtime
ENDIF
@ 3,1 SAY "Best?tigen mit RETURN, Abbruch mit ESC!"
Inkey(0)
WClose()
IF LastKey() = K_RETURN
   APPE BLAN
   REPL         buchstabe WITH m_buch, datum WITH Date(), anab WITH _anab,;
                         zeit WITH mtime
        IF TYPE( "zeiten->sekunden" ) = "N"
                zeiten->sekunden := nSec
        ENDIF
        USE
   MsgBox("Ist registriert!")
ENDIF
USE
RETURN(NIL)

***********************************************************
PROCEDURE Zeit_List
***********************************************************
/*
                        Liste Zeiten fÅr User
*/
mdatum  = Date()
mdatum2 = Date()
m_bs    = "B"
fenster( 10, 10, 14, 70, .T.)
@ 1,1 SAY "Zeiten vom: " GET mdatum
@ 2,1 SAY "bis zum   : " GET mdatum2
@ 3,1 SAY "Bild/Druck: " GET m_bs                 PICT "!" VALID(m_bs $ "BD")
READ
WClose()
IF Empty(mdatum) .OR. LastKey() = 27
        RETURN(.T.)
ENDIF
IF mdatum2 < mdatum
   MsgBox("Datum 1 mu· <= Datum 2!")
        RETURN(.T.)
ENDIF

Open_zeiten()
SET SOFT ON
SEEK m_buch+DTOS( mdatum )
SET SOFT OFF
IF m_bs = "D"
   fenster( 10, 10, 12, 70, .T.)
   @ 1,1 SAY "Bitte warten, drucke Liste ..."
        SET DEVICE TO PRINT
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
                  gzeit2 = TimeToSec( zeit )
        ELSE
      @ zeile,40 SAY zeit
                  @ zeile,60 SAY SecToTime( TimeToSec( zeit)-gzeit2)
      Zeile = Zeile + 1
                  IF datum != altdatum                                                // wenn Datumswechsel
                     AltDatum = Datum
                     gtag  = gtag  + 1                                                // Arbeitstage
                  ENDIF
   ENDIF

   IF anab = "1"
      gzeit = gzeit - TimeToSec( zeit )
        ELSE
      gzeit = gzeit + TimeToSec( zeit )
        ENDIF

        SKIP
   IF zeile > max_line
      wmr()
                  kopf()
        ENDIF

ENDDO
GesamtSekunden = gzeit
GesamtStunden  = Floor(GesamtSekunden / (60*60))                        // Floor() gibt n?chste
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
SET DEVICE TO SCREEN
WClose()
USE
CLEAR

RETURN

***********************************************************
PROCEDURE Open_zeiten
***********************************************************
USE zeiten EXCL
IF File("zeiten.ntx")
   SET INDEX TO zeiten
ELSE
   fenster(10, 10, 12, 70, .T.)
   @ 1,1 SAY "Bitte einen Moment, reorganisiere Datei ..."
   INDEX ON BUCHSTABE+DTOS(datum) TO zeiten
        WClose()
ENDIF
IF File("zeitend.ntx")
   SET INDEX TO zeitenD
ELSE
   fenster(10,10,12,70, .T.)
   @ 1,1 SAY "Bitte einen Moment, reorganisiere Datei ..."
   INDEX ON buchstabe+DESCEND(DTOS(datum)+zeit) TO zeitenD
   WClose()
ENDIF
SET INDEX TO zeiten, zeitend

RETURN
