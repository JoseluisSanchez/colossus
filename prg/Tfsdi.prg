#include "FiveWin.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

//----------------------------------------------------------------------------//

CLASS TFsdi FROM TDialog
   DATA nGridBottom, nGridRight
   CLASSDATA lRegistered AS LOGICAL
   METHOD New( oWnd, lPixels ) CONSTRUCTOR
   METHOD NewGrid(nSplit, cDbfFile)
	METHOD NewMenu()
   METHOD AdjClient() // INLINE oApp():oWndMain:AdjClient()
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oWnd ) CLASS TFsdi
   local aClient := GetClientRect (oWnd:hWnd )

   ::nTop    := oApp():oToolBar:nHeight + 4
   ::nLeft   := 0
   ::nBottom := aClient[3] - 28 // oApp():oWndMain:oMsgBar:nHeight
   ::nRight  := aClient[4]
   ::nStyle  := nOR( WS_CHILD, 4 )
   ::oFont   := oApp():oFont
   ::lHelpIcon    := .f.

   ::lTransparent := .f.
   ::nGridBottom  := (::nBottom / 2) // - oApp():oToolBar:nHeight
   ::nGridRight   := (::nRight / 2 )
   ::aControls    := {}

   ::SetColor( CLR_WHITE, GetSysColor(15) )
   ::Register( nOr( CS_VREDRAW, CS_HREDRAW ) )

   SetWndDefault( Self )          //  Set Default DEFINEd Window

return Self

//----------------------------------------------------------------------------//

METHOD NewGrid() CLASS TFsdi
	local oCol, i
	local aTipo    := {i18n("Sitio web"), i18n("Archivo"), i18n("Otro")}
   local nClOrder := 1 // VAL(GetPvProfString("Browse", "Order","1", oApp():cIniFile))
   local nClRecno := 1 // VAL(GetPvProfString("Browse", "Recno","1", oApp():cIniFile))
	local cState   := GetPvProfString("Browse", "State","", oApp():cIniFile)
   local nSplit   := GETDEFAULTFONTHEIGHT2()*(-9.5)//IIF(LargeFonts(),120,120)

	oApp():oWndMain:cTitle := oApp():cAppName+oApp():cVersion+" · "+oApp():cDbfFile+".dat"
   oApp():oGrid := TXBrowse():New( oApp():oDlg )
   oApp():oGrid:nTop    := 00
   oApp():oGrid:nLeft   := nSplit+2
   oApp():oGrid:nBottom := oApp():oDlg:nGridBottom
   oApp():oGrid:nRight  := oApp():oDlg:nGridRight

	oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->Clconcepto}
   oCol:cHeader  := i18n("Servicio")
   oCol:nWidth   := 134
   oCol:bLClickHeader := {|| CambiaOrden( 1) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==1,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClUsuario }
   oCol:cHeader  := i18n("Usuario")
   oCol:nWidth   := 108
   oCol:bLClickHeader:= {|| CambiaOrden( 2 ) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==2,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClClave }
   oCol:cHeader  := i18n("Clave")
   oCol:nWidth   := 118
   oCol:bLClickHeader:= {|| CambiaOrden( 3 ) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==3,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClMateria }
   oCol:cHeader  := i18n("Materia")
   oCol:nWidth   := 118
   oCol:bLClickHeader:= {|| CambiaOrden( 4 ) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==4,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || DtoC(CL->ClFchAdq) }
   oCol:cHeader  := i18n("Obtención")
   oCol:nWidth   := 72
   oCol:bLClickHeader:= {|| CambiaOrden( 5 ) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==5,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || DtoC(CL->ClFchCad) }
   oCol:cHeader  := i18n("Caducidad")
   oCol:nWidth   := 72
   oCol:bLClickHeader:= {|| CambiaOrden( 6 ) }
   oCol:AddResource("SORT1")
   oCol:AddResource("SORT2")
   oCol:nHeadBmpNo    := IIF(nClOrder==6,1,2)
   oCol:nHeadBmpAlign := AL_RIGHT

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClInternet }
   oCol:cHeader  := i18n("Internet")
   oCol:nWidth   := 110

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClFtp }
   oCol:cHeader  := i18n("F.T.P.")
   oCol:nWidth   := 110

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || CL->ClEmail }
   oCol:cHeader  := i18n("E-mail")
   oCol:nWidth   := 110

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := { || iif(CL->ClTipo$"123",aTipo[VAL(CL->ClTipo)],"") }
   oCol:cHeader  := i18n("Tipo clave")
   oCol:nWidth   := 72

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
		oCol:bLDClickData  := {|| ClEdita(oApp():oGrid, .f.) }
   NEXT

  	oApp():oGrid:SetRDD()
	oApp():oGrid:CreateFromCode()
   oApp():oGrid:bKeyDown := {|nKey| ClTecla(nKey,oApp():oGrid) }
   oApp():oGrid:bChange  := { || RefreshCont() }
	oApp():oGrid:RestoreState( cState )

	Ut_BrwRowConfig( oApp():oGrid, "CL" )

return nil

//----------------------------------------------------------------------------//

METHOD NewMenu() CLASS TFsdi
	local nSplit   := GETDEFAULTFONTHEIGHT2()*(-9.5)//IIF(LargeFonts(),120,120)
   local i, nClOrder, nClRecno
   local aTipo    := {i18n("Sitio web"), i18n("Archivo"), i18n("Otro")}
   local aVItems[16]

   @  2, 6 VMENU oApp():oVMenu SIZE nSplit - 12, ::nBottom OF oApp():oDlg ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oApp():oVMenu:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oApp():oVMenu        ;
      CAPTION i18n("Claves")+tran(CL->(OrdKeyNo()),'999')+" / "+tran(CL->(OrdKeyCount()),'999') ;
      HEIGHT 25                        ;
      COLOR GetSysColor(9), GetSysColor(3), GetSysColor(2) ;
      VERTICALGRADIENT                 ;
      IMAGE "COLOSSUS"

	DEFINE VMENUITEM OF oApp():oVMenu    ;
      HEIGHT 2 SEPARADOR

   DEFINE VMENUITEM aVItems[1]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Nueva clave")         ;
      IMAGE "SH_NUEVO"                 ;
      ACTION ClEdita(oApp():oGrid,.t.)   ;
      LEFT 10

   DEFINE VMENUITEM aVItems[2]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Modificar clave")     ;
      IMAGE "SH_MODIF"                 ;
      ACTION ClEdita(oApp():oGrid,.f.)   ;
      LEFT 10

   DEFINE VMENUITEM aVItems[3]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Borrar clave")        ;
      IMAGE "SH_BORRAR"                ;
      ACTION ClBorra( oApp():oGrid )     ;
      LEFT 10

   DEFINE VMENUITEM aVItems[4]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Buscar clave")        ;
      IMAGE "SH_BUSCA"                 ;
      ACTION ClBusca(oApp():oGrid,)      ;
      LEFT 10

   DEFINE VMENUITEM aVItems[5]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Imprimir claves")      ;
      IMAGE "SH_IMPRIMIR"              ;
      ACTION ClImprime(oApp():oGrid)   ;
      LEFT 10

   DEFINE VMENUITEM OF oApp():oVMenu    ;
      INSET HEIGHT 10

   DEFINE VMENUITEM aVItems[6]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Tabla de materias");
      IMAGE "SH_MATERIA"               ;
      ACTION Materia(.f.,,,oApp():oGrid) ;
      LEFT 10

   DEFINE VMENUITEM OF oApp():oVMenu    ;
      INSET HEIGHT 10

   DEFINE VMENUITEM aVItems[7]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Copiar usuario al portapapeles");
      IMAGE "SH_CLIP2"                 ;
      ACTION ( oApp():oClp:Empty(),oApp():oClp:setText(Rtrim(CL->ClUsuario)),;
               MsgInfo(i18n("Usuario copiado al portapapeles.")));
      LEFT 10

   DEFINE VMENUITEM aVItems[8]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Copiar clave al portapapeles");
      IMAGE "SH_CLIP1"                 ;
      ACTION ( oApp():oClp:Empty(),oApp():oClp:setText(SubStr(CL->ClClave,1,VAL(Cl->Cllong))),;
               MsgInfo(i18n("Clave copiada al portapapeles.")));
      LEFT 10

   DEFINE VMENUITEM aVItems[9]         ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Ver el portapapeles") ;
      IMAGE "SH_CLIP3"                 ;
      ACTION ClpView(oApp():oClp)        ;
      LEFT 10

	/*
   DEFINE VMENUITEM OF oApp():oVMenu    ;
      INSET HEIGHT 10

   MENU oApp():oMenu POPUP
      MENUITEM i18n("Ayuda del programa") ;
         ACTION IIF(!IsWinNt(),;
            winExec("start "+rtrim(TakeOffExt(GetModuleFileName(GetInstance()))+".chm")),;
            ShellExecute(GetActiveWindow(),'Open',TakeOffExt(GetModuleFileName(GetInstance()))+".chm",,,4));
         RESOURCE 'sh_help'
      MENUITEM i18n("Acerca de") ACTION AppAbout(.f.) ;
         RESOURCE 'sh_about'
      MENUITEM i18n("Licencia Creative Commons") ;
         ACTION ShellExecute(GetActiveWindow(),'Open',oApp():cPath+"Creative Commons Deed_"+oApp():cLanguage+".mht",,,4);
         RESOURCE 'SH_CC'
      MENUITEM i18n("Web de alanit en internet")   ;
         ACTION GoWeb("http://www.alanit.com")     ;
         RESOURCE 'SH_INTERNET'
      SEPARATOR
      MENUITEM i18n("Especificar impresora...")       ;
         ACTION PrinterSetup()                     ;
         RESOURCE 'sh_imprimir'
      SEPARATOR
      MENUITEM i18n("Regenerar índices")           ;
         ACTION ( nClOrder  := CL->(OrdNumber()),;
                  nClRecno  := CL->(Recno())    ,;
						oApp():oGrid:Hide()				,;
 						oApp():lGridHided := .t.		,;
                  Ut_Indexar()                  ,;
                  DbCloseAll()                  ,;
                  DB_OPEN(oApp():cDbfFile,'CL') ,;
                  CL->(OrdSetFocus(nClOrder))   ,;
                  CL->(DbGoTo(nClRecno))        ,;
						oApp():oGrid:Show()				,;
						oApp():lGridHided := .f.		,;
                  oApp():oGrid:Refresh() )       ;
         RESOURCE 'SH_INDEXA2'
      MENUITEM i18n("Configuración de la rejilla de datos...")    ;
         ACTION Ut_BrwColConfig( oApp():oGrid, "State" ) ;
         RESOURCE 'SH_GRID'
      //MENUITEM i18n("Configuración del programa...")  ;
      //   ACTION AppConfig(oApp():cInifile)              ;
      //   RESOURCE 'SH_CONF'
   ENDMENU

   DEFINE VMENUITEM aVItems[13]     ;
      OF oApp():oVMenu               ;
      CAPTION i18n("Utilidades")    ;
      IMAGE "SH_TOOLS"              ;
      MENU oApp():oMenu             ;
      LEFT 10
	*/

   DEFINE VMENUITEM OF oApp():oVMenu ;
      INSET HEIGHT 10

   DEFINE VMENUITEM aVItems[8]          ;
      OF oApp():oVMenu                  ;
      CAPTION i18n("Cambiar contraseña");
      IMAGE "SH_PASSWD"                 ;
      ACTION ClPwdChange()	 				 ;
      LEFT 10

   DEFINE VMENUITEM OF oApp():oVMenu ;
      INSET HEIGHT 10
   /*
   IF oApp():cLanguage != "ES"
      DEFINE VMENUITEM OF oApp():oVMenu   ;
         CAPTION "Cambiar idioma a Español"        ;
         ACTION ( oApp():cLanguage := 'ES', Idioma(.t.) )  ;
         IMAGE 'SH_18ES' LEFT 10
   ELSE
      DEFINE VMENUITEM OF oApp():oVMenu   ;
         CAPTION "Change language to English"      ;
         ACTION ( oApp():cLanguage := 'EN', Idioma(.t.) )  ;
         IMAGE 'SH_18EN' LEFT 10
   ENDIF

   DEFINE VMENUITEM OF oApp():oVMenu   ;
      INSET HEIGHT 10
   */

   DEFINE VMENUITEM aVItems[14]     ;
      OF oApp():oVMenu               ;
      CAPTION i18n("Salir")         ;
      IMAGE "SH_SALIR"              ;
      ACTION oApp():oDlg:End()      ;
      LEFT 10
return NIL

METHOD AdjClient() CLASS TFsdi
return nil
