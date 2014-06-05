

#xcommand @ <nTop>, <nLeft> VMENU [ <oAch> ] ;
               [ SIZE <nWidth>, <nHeigth> ] ;
               [ <dlg:OF,DIALOG> <oDlg> ] ;
               [ ACTION <uAction,...> ] ;
               [ ON CHANGE <uChange,...> ] ;
               [ FONT <oFont> ] ;
               [ HEIGHT ITEM <nHItem> ] ;
               [ <mode: CENTER, RIGHT, MULTILINE> ] ;
               [ <under: UNDERLINE, INSET, SOLID, XBOX> ];
               [ <lBorder: BORDER> ] ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane> ] ] ;
               [ COLORBORDE <nClrBorde> ] ;
               [ COLORSELECT <nClrTextSelect>[, <nClrPaneSelect> ]  ] ;
               [ MARGIN <nMargen> ] ;
               [ SPEEDS <nSpeed> ] ;
               [ <selectionmode: NONE, LFILLED, RFILLED, FILLED, LFOLDER, RFOLDER> ] ;
               [ ATTACH TO <oAttach> ] ;
      => ;
          [ <oAch> := ] TVMenu():New( <nTop>, <nLeft>, <nWidth>, <nHeigth>, <oDlg> ,;
                           [{|Self|<uAction>}]                                     ,;
                           [<nClrText>]                                            ,;
                           [<nClrPane>]                                            ,;
                           [<oFont>]                                               ,;
                           [<.lBorder.>]                                           ,;
                           [<nClrBorde>]                                           ,;
                           [<nHItem>]                                              ,;
                           [ Upper(<(mode)>) ]					   ,;
                           [ Upper(<(under)>) ]					   ,;
                           [ <nMargen> ]					   ,;
                           [ <nClrPaneSelect> ]                                    ,;
                           [ <nSpeed> ]                                            ,;
                           [ Upper(<(selectionmode)>) ]                            ,;
                           [{|Self|<uChange>}]                                     ,;
                           [ <nClrTextSelect>]                                     ,;
                           [ <oAttach>] )



#xcommand DEFINE TITLE OF <oVMenu> ;
               [ CAPTION <cCaption> ] ;
               [ HEIGHT <nHTitle> ] ;
               [ FONT <oFont> ] ;
               [ COLOR <nClrText>[,<nClrPane> [,<nClrPane2>[,<nSteps> ] ] ] ] ;
               [ <lVGrad: VERTICALGRADIENT  > ] ;
               [ <lMirrowGrad: MIRROW > ] ;
      	       [ IMGBTN <cBtnUp>[, <cBtnDown>]] ;
               [ IMAGE <cImage> ] ;
               [ ICON <cIcon> ] ;
               [ <mode: CENTER, RIGHT, MULTILINE> ] ;
               [ <lOpenClose:OPENCLOSE > ] ;
               [ RADIOBTN <nRadio> ] ;
               [ <lRoundSquare:ROUNDSQUARE > ] ;
               [ RADIOSQUARE <nRadSqr> ] ;
               [ LEFTIMAGE <nLeftImg> ] ;
               [ LEFT <nLeft> ] ;
      => ;
          <oVMenu>:SetTitle( [ <cCaption>       ]  ,;
                           [ <nHTitle>        ]  ,;
                           [ <oFont>          ]  ,;
                           [ <nClrText>       ]  ,;
                           [ <nClrPane>       ]  ,;
                           [ <nClrPane2>      ]  ,;
                           [ <nSteps>         ]  ,;
                           [ <.lVGrad.>       ]  ,;
                           [ <cImage>         ]  ,;
                           [ Upper(<(mode)>)  ]  ,;
                           [ <cIcon>          ]  ,;
                           [ <cBtnUp>         ]  ,;
                           [ <cBtnDown>       ]  ,;
                           [ <.lOpenClose.>   ]  ,;
                           [ <nRadio>         ]  ,;
                           [ <.lRoundSquare.> ]  ,;
                           [ <.lMirrowGrad.>  ]  ,;
                           [ <nRadSqr>        ]  ,;
                           [ <nLeft>          ]  ,;
                           [ <nLeftImg>       ]  )








#xcommand DEFINE VMENUITEM [ <oItem> ] ;
               [ WIDTH <nWidth> ] ;
               [ HEIGHT <nHeigth> ] ;
               [ TOP <nTop> ] ;
               [ LEFT <nLeft> ] ;
               [ OF <oVMenu> ] ;
               [ ACTION <uAction,...> ] ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane>[,<nClrPane2>[,<nSteps>] ] ] ] ;
               [ <lVGrad: VERTICALGRADIENT > ] ;
               [ <lMirrowGrad: MIRROW > ] ;
               [ CAPTION <cCaption> ] ;
	       [ IMAGE <image> [, <imageover> ] ] ;
	       [ <lIcon: ICON> ] ;
	       [ <lGroup: GROUP> ] ;
               [ <separator: SEPARADOR, LINE, INSET, DOTDOT > ] ;
               [ <mode: CENTER, RIGHT, MULTILINE > ] ;
               [ LEFTIMAGE <nLeftImg> ] ;
               [ <imagesite: IMAGECENTER, IMAGERIGHT > ] ;
               [ <lUnderline: UNDERLINE > ] ;
               [ MENU <oPopup> ] ;
               [ COLORSEPARADOR <nColorSep> ];
               [ COLORSELECT <nClrTextSelect>[, <nClrPaneSelect>  ] ] ;
               [ TOOLTIP <cToolTip> ];
      => ;
          [ <oItem> := ] TVItem():New( <oVMenu>              ,;
                                       <cCaption>            ,;
                                       <image>               ,;
                                       <imageover>           ,;
                                       <.lGroup.>            ,;
                                       <nClrText>            ,;
                                       <nClrPane>            ,;
                                       [Upper(<(mode)>)]     ,;
                                       [Upper(<(imagesite)>)],;
                                       <nHeigth>             ,;
                                       <nLeft>               ,;
                                       [Upper(<(separator)>)],;
                                       <nWidth>              ,;
                                       <.lUnderline.>        ,;
                                       <nLeftImg>            ,;
                                       <nClrPane2>           ,;
                                       <.lVGrad.>            ,;
                                       [{|Self|<uAction>}]   ,;
                                       <oPopup>              ,;
                                       [<nClrPaneSelect>]    ,;
                                       [<nClrTextSelect>]    ,;
                                       [ <.lMirrowGrad.>]    ,;
                                       [ <nSteps>]           ,;
                                       [ <cToolTip> ]        ,;
                                       <nColorSep>,;
                                       [ <.lIcon.>],;
                                       [ <nTop> ] )



