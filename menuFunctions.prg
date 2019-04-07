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
   oMenu        := XbpMenu():New(oMenuBar):create()
   oMenu:title  := "~Datenbank"
   oMenu:addItem( { "~View Table",     {|| exitProgram()  } } )
   oMenu:addItem( { "~Open FPT",     {|| exitProgram() } } )
   oMenu:addItem( { "~Exit",           {|| exitProgram() } } )

   oMenuBar:addItem({oMenu, NIL})
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

