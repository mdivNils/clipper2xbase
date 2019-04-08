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

#include "Xbp.ch"

******************************************************************
* GUI Menubar erstellen
******************************************************************
PROCEDURE menuCreate( oMenuBar, name, oDlg )
   LOCAL oMenu

   // how should our menu bar look
   oMenu := XbpMenu():new( oMenuBar ):create()
   oMenu:title := "Benutzer"
   oMenu:addItem( { "~Anmelden", {|| StartupWindow()} } ) //Melde den benutzer an, Modal mit login Form bzw Zeichenabfrage
   oMenu:addItem( { "~Abmelden", {|| exitProgram()} } ) //Melde den benutzer ab
   oMenu:addItem( { "~Stundenauswertung", {|| exitProgram()} } ) //offne fenster mit der stundenauswertung

   oMenuBar:addItem({oMenu, NIL})

RETURN



PROCEDURE StartupWindow()
   LOCAL oDlg, drawingArea, oXbp
   LOCAL oParent := AppDesktop()
   LOCAL aControls, aData
   LOCAL username, password

   oDlg            := XbpDialog():new( oParent )
   oDlg:visible    := .F.
   oDlg:clientSize := {300,280}
   oDlg:taskList   := .F.
   oDlg:titleBar   := .T.
   oDlg:title		 := "Benutzer Anmeldung"
   oDlg:border     := XBPDLG_DLGBORDER
   oDlg:close      := {|mp1,mp2,obj| obj:destroy() }
   oDlg:create()
   CenterControl( oDlg )

   drawingArea     := oDlg:drawingArea
   drawingArea:setFontCompoundName( "8.Helv" )

   // Username Field

   oXbp         := XbpStatic():new( oStatic,, {10,240}, {80,20} )
     oXbp:caption := "Username:"
   oXbp:options := XBPSTATIC_TEXT_LEFT
   oXbp:create()

   oXbp := XbpSLE():new(oStatic, , {110, 240}, {180,20} )
   oXbp:tabSTop := .T.  // stop when SLE Field is reached
   oXbp:bufferLength := 35
   //oXbp:group := XBP_WITHIN_GROUP
   oXbp:dataLink := {|x| IIf( x==NIL, TRIM(username), username := x ) }
   oXbp:create()
   oXbp:setData()
   oXbp:killInputFocus := {|x, y, oXbp| oXbp:getData()}
   AAdd(aControls, oXbp)   // add new Form Input to Menu Array

   // Password Field

   oXbp         := XbpStatic():new( oStatic,, {310,240}, {80,20} )
   oXbp:caption := "Password:"
   oXbp:options := XBPSTATIC_TEXT_LEFT
   oXbp:create()

   oXbp        := XbpSLE():new(oStatic,,{410,240}, {180,20})
   oXbp:tabStop := .T.
   oXbp:bufferLength := 35
   //oXbp:group := XBP_WITHIN_GROUP
   oXbp:dataLink := {|x| IIf( x==NIL, TRIM(password), password := x ) }
   oXbp:create()
   oXbp:setData()
   oXbp:killInputFocus := {|x, y, oXbp| oXbp:getData()}
   AAdd(aControls, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , {12,12}, {120,24} )
   oXbp:caption    := "Anmelden"
   oXbp:create()
   oXbp:activate   := {|| exitProgram() }

   oDlg:show()

RETURN



// exit Programm
PROCEDURE exitProgram()
   LOCAL nButton, oXbp
   // set focus to the new window
   oXbp := SetAppFocus()
   // create a confirm box with yes and no
   nButton := ConfirmBox( , ;
                 "Wollen Sie das Programm wirklich beenden ?", ;
                 "Programm Beenden", ;
                  XBPMB_YESNO , ;
                  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )

   IF nButton == XBPMB_RET_YES
      // close all open database connections and unload all drivers, then quit
      CLOSE ALL
      DbeUnload("CDXDBE")
      DbeUnload("DBFDBE")
      DbeUnload("FOXDBE")
      QUIT
   ENDIF
   // wenn nicht geschlossen setzte unserem Fenster wieder den focus
   SetAppFocus( oXbp )
RETURN

