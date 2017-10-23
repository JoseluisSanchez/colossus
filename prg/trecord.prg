//
// Modificada sobre la clase proporcionada por Marcelo Via Giglio en http://forums.fivetechsupport.com/viewtopic.php?f=6&t=34402
//

#include "FIVEWIN.CH"

CLASS TRecord

   DATA aData, aFields
   METHOD new() CONSTRUCTOR
   METHOD FieldGet( nField )       INLINE ::aData[ nField ]
   METHOD FieldName( nField )      INLINE ::aFields[ nField ]
   METHOD FieldPos( cFieldName )   INLINE AScan( ::aFields, Upper( cFieldName ) )
   METHOD FieldPut( cFieldName, uVal )
   METHOD LastRec()                INLINE Len( ::aData )
   METHOD FieldLen()               INLINE Len( ::aData )
   METHOD loadFromAlias( cAlias )
   METHOD saveToAlias( cAlias )
   METHOD blankFromAlias( cAlias )
   METHOD show()
   ERROR HANDLER OnError( cMsg, nError )

ENDCLASS

// ------------------------------------------------------------------------------
METHOD new()

   // ------------------------------------------------------------------------------

   ::aData   := {}
   ::aFields := {}

   RETURN( Self )

// ------------------------------------------------------------------------------
METHOD FieldPut( cFieldName, uVal )

   // ------------------------------------------------------------------------------
   LOCAL pos := ::FieldPos( cFieldName )

   IF pos = 0
      AAdd( ::AFields, Upper( cFieldName ) )
      AAdd( ::aData, uVal )
   ELSE
      ::aData[ pos ] := uVal
   ENDIF

   RETURN NIL

// ------------------------------------------------------------------------------
METHOD OnError( uValor, nError )

   // ------------------------------------------------------------------------------
   LOCAL cMensaje := Upper ( AllTrim( __GetMessage() ) )

   IF SubStr( cMensaje, 1, 1 ) == "_"  // ASIGNACION
      ::FieldPut( SubStr( cMensaje, 2 ), uValor )
   ELSE
      RETURN ::FieldGet( ::FieldPos( cMensaje )  )
   ENDIF

   RETURN NIL

// ------------------------------------------------------------------------------
METHOD loadFromAlias( cAlias )

   // ------------------------------------------------------------------------------
   LOCAL i
   FOR i := 1 TO ( cAlias ) ->( FCount() )
      ::FieldPut( ( cAlias ) ->( FieldName( i ) ), ( cAlias ) ->( FieldGet( i ) ) )
   NEXT

   RETURN NIL

// ------------------------------------------------------------------------------
METHOD blankFromAlias( cAlias )

   // ------------------------------------------------------------------------------
   LOCAL i, cInit

   FOR i := 1 TO ( cAlias ) ->( FCount() )
      DO CASE
      CASE ( cAlias )->( FieldName( i ) ) == "C"
         cinit := Space( Len( ( cAlias )->( FieldName( i ) ) ) )
      CASE ( cAlias )->( FieldName( i ) ) == "N"
         cinit := 0
      CASE ( cAlias )->( FieldName( i ) ) == "D"
         cinit := Date()
      CASE ( cAlias )->( FieldName( i ) ) == "M"
         cInit := Space( 255 )
      CASE ( cAlias )->( FieldName( i ) ) == "L"
         cinit := .F.
      ENDCASE
      ::FieldPut( ( cAlias ) ->( FieldName( i ) ), cInit )
   NEXT

   RETURN NIL


// ------------------------------------------------------------------------------
METHOD saveToAlias( cAlias )

   // ------------------------------------------------------------------------------
   LOCAL i, pos

   FOR i := 1 TO Len( ::aData ) // (cAlias) -> ( FCOUNT() )
      pos := FieldPos( ::aFields[ i ] )
      IF pos != 0
         FieldPut( pos, ::aData[ i ] ) // FIELDPUT de Harbour
      ENDIF
   NEXT

   RETURN NIL

// ------------------------------------------------------------------------------
METHOD show()

   // ------------------------------------------------------------------------------
   LOCAL a := {}

   AEval( ::AFIELDS, {| b, i| AAdd( a, { ::AFIELDS[ i ], ::aData[ i ] } ) } )
   xBrowse( a )

   RETURN NIL
