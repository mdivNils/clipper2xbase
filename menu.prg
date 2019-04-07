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
#include "Appevent.ch"

PROCEDURE menuCreation( oDlg)
   // creating our menu
   LOCAL drawingArea, oStatic, oXbp
   LOCAL aControls, aData
   LOCAL username, password

   drawingArea := oDlg:drawingArea

   IF (Empty( drawingArea:childList() ))
      /*
       * New Input Field "Username"
      */

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

      /*
       * New Input Field "PAssword"
      */

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
   ENDIF
RETURN
