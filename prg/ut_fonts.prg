//___ manejo de fuentes © Paco García 2006 ____________________________________//

#pragma BEGINDUMP
#include "Windows.h"
#include "hbapi.h"

HB_FUNC( GETDEFAULTFONTNAME )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retc( lf.lfFaceName );
}

HB_FUNC( GETDEFAULTFONTHEIGHT )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfHeight );
}

HB_FUNC( GETDEFAULTFONTWIDTH )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfWidth );
}

HB_FUNC( GETDEFAULTFONTITALIC )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfItalic );
}

HB_FUNC( GETDEFAULTFONTUNDERLINE )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfUnderline );
}

HB_FUNC( GETDEFAULTFONTBOLD )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) ( lf.lfWeight == 700 ) );
}

HB_FUNC( GETDEFAULTFONTSTRIKEOUT )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );
      GetObject( ( HFONT ) hFont  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
      hb_retl( (BOOL) lf.lfStrikeOut );
}


HB_FUNC( GETDEFAULTFONTNAME2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retc( lf.lfFaceName );
}

HB_FUNC( GETDEFAULTFONTHEIGHT2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );
   	GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retni( lf.lfHeight );
}

HB_FUNC( GETDEFAULTFONTWIDTH2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retni( lf.lfWidth );
}

HB_FUNC( GETDEFAULTFONTITALIC2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );

   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retl( (BOOL) lf.lfItalic );
}

HB_FUNC( GETDEFAULTFONTUNDERLINE2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retl( (BOOL) lf.lfUnderline );
}

HB_FUNC( GETDEFAULTFONTBOLD2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );

   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
   hb_retl( (BOOL) ( lf.lfWeight == 700 ) );
}

HB_FUNC( GETDEFAULTFONTSTRIKEOUT2 )
{
      NONCLIENTMETRICS info;
      HFONT hFont;
      LOGFONT lf;
      info.cbSize = sizeof(info);
      SystemParametersInfo( SPI_GETNONCLIENTMETRICS, sizeof(info), &info, 0 );
      hFont = CreateFontIndirect( &info.lfMenuFont );

      GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      DeleteObject( hFont );
      hb_retl( (BOOL) lf.lfStrikeOut );
}


#pragma ENDDUMP
