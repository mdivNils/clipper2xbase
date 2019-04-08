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
#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"
#include "Font.ch"
#include "dac.ch"

/* Overloaded AppSys which does nothing
 */
PROCEDURE AppSys

RETURN

/* This is our main procedure
 */
PROCEDURE Main
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg, aPos[2], aSize, nWidth, nHeight
   LOCAL oXbp

   // get our screen resolution/size
   aSize    := SetAppWindow():currentSize()
   // create a window based on our screen size divide by 2
   nWidth   := Int( (aSize[1] / 2) )
   nHeight  := Int( (aSize[2] / 2) )
   // center the window
   aPos[1]  := Int( (aSize[1]-nWidth ) / 2 )
   aPos[2]  := Int( (aSize[2]-nHeight) / 2 )

   // create a new Dialog/Window
   oDlg := XbpDialog():new( ,,{10,10}, {nHeight,nWidth},, .F. )
   oDlg:icon     := 1
   oDlg:taskList := .T.
   oDlg:title    := "Zeiterfassung"
   oDlg:drawingArea:ClipChildren := .T.
   // tell the X button what to do when clicked
   oDlg:close := {|mp1,mp2,obj| exitProgram() }
   oDlg:create( ,, aPos, {nWidth, nHeight},, .F.)
   oDlg:drawingArea:setFontCompoundName( FONT_DEFPROP_SMALL )

   // display window and set focus to it
   oDlg:show()
   SetAppWindow( oDlg )
   SetAppFocus ( oDlg )

   oMenuBar := oDlg:menuBar()
   menuCreate( oMenuBar )

   // permanent loop to wait for events and handle them, needed or the window will be closed instant
   DO WHILE .T.
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

RETURN


PROCEDURE userLogin( username, password )
	// login for user


RETURN
