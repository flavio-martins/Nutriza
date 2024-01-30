#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP054   º Autor ³ Flávio Martins     º Data ³  28/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz a alteração do dado registrado na classifica~ção do    º±±
±±º          ³ Produto                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Nutriza S.A.                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PCP054()

	Private cPallet := space(TamSx3("ZP4_PALETE")[1])
	Private cCodCls := space(TamSx3("ZZS_COD")[1])
	Private cDescri := space(TamSx3("ZZS_DESCRI")[1])

	//              TDialog():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ]          , [ uParam6 ], [ uParam7 ], [ uParam8 ], [ uParam9 ], [ nClrText ], [ nClrBack ], [ uParam12 ], [ oWnd ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ uParam17 ], [ nWidth ], [ nHeight ], [ lTransparent ] )
	Private oDlg	:= TDialog():New(180      ,180       ,350         ,500         ,'Manutenção de Pallets',            ,            ,             ,            ,CLR_BLACK    ,CLR_WHITE    ,              ,         ,.T.        ,             ,              ,              ,          ,             , .F.             )
	//              TSay():New( [ nRow ], [ nCol ], [ bText ]     , [ oWnd ], [ cPicture ], [ oFont ], [ uParam7 ], [ uParam8 ], [ uParam9 ], [ lPixels ], [ nClrText ], [ nClrBack ], [ nWidth ], [ nHeight ], [ uParam15 ], [ uParam16 ], [ uParam17 ], [ uParam18 ], [ uParam19 ], [ lHTML ], [ nTxtAlgHor ], [ nTxtAlgVer ] )
	Private oSay1	:= TSay():New(10      ,09       ,{||'Pallet'}          ,oDlg    ,             ,          ,            ,            ,            ,.T.        ,CLR_BLUE       ,CLR_WHITE   ,200        ,20          ,             ,             ,             ,             ,             ,         ,                ,               )
	Private oSay2	:= TSay():New(35      ,09       ,{||'Classificação'}   ,oDlg    ,             ,          ,            ,            ,            ,.T.        ,CLR_BLUE       ,CLR_WHITE   ,200        ,20          ,             ,             ,             ,             ,             ,         ,                ,               )
	Private oSay3	:= TSay():New(43      ,45       ,{||cDescri}           ,oDlg    ,             ,          ,            ,            ,            ,.T.        ,CLR_BLUE       ,CLR_WHITE   ,200        ,20          ,             ,             ,             ,             ,             ,         ,                ,               )
	//               TGet():New( [ nRow ], [ nCol ], [ bSetGet ]                                       , [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ]                                                                  , [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )
	Private oGet1	:= TGet():New( 017    , 009     , { | u | If( PCount() == 0, cPallet, cPallet := u ) },oDlg     ,  060      , 010        , "!@"     ,{|| bPallet(cPallet)}                                                                             , 0          , 16777215     ,         ,.F.          ,             ,.T.        ,            ,.F.          ,          ,.F.          ,.F.         ,            ,.F.           ,.F.          ,             ,"cPallet"      ,             ,             ,             , .F.          ,              ,             ,               ,              ,               ,                ,               ,                     ,            )
	Private oGet2	:= TGet():New( 042    , 009     , { | u | If( PCount() == 0, cCodCls, cCodCls := u ) },oDlg     ,  030      , 010        , "!@"     ,{|| cDescri := POSICIONE("ZZS", 1, xFilial("ZZS") + cCodCls, "ZZS_DESCRI"),oSay3:REFRESH(),.T.} , 0          , 16777215     ,         ,.F.          ,             ,.T.        ,            ,.F.          ,          ,.F.          ,.F.         ,            ,.F.           ,.F.          ,             ,"cCodCls"      ,             ,             ,             , .F.          ,              ,             ,               ,              ,               ,                ,               ,                     ,            )
	//                 TButton():New( [ nRow ], [ nCol ], [ cCaption ], [ oWnd ], [ bAction ]        , [ nWidth ], [ nHeight ], [ uParam8 ], [ oFont ], [ uParam10 ], [ lPixel ], [ uParam12 ], [ uParam13 ], [ uParam14 ], [ bWhen ], [ uParam16 ], [ uParam17 ] )
	Private oTBtn1	:= TButton():New( 065     , 035     , "Sai&r"     ,oDlg     ,{||Close(oDlg)}      , 40       ,10           ,            ,          ,             ,.T.        ,             ,             ,             ,           ,             ,    )
	Private oTBtn2	:= TButton():New( 065     , 085     , "&OK"       ,oDlg     ,{||bOK (cPallet)}    , 40       ,10           ,            ,          ,             ,.T.        ,             ,             ,             ,           ,             ,    )

	oGet1:cF3 := "ZP4"
	oGet2:cF3 := "ZZS"
	//oGet1:SetFocus()

	oDlg:Activate(, , ,.T., , , , ,)

Return



Static Function bPallet(cPallet)

	Local cAlias	:= GETNEXTALIAS()

	BeginSQL Alias cAlias

		SELECT ZP4_PALETE, ZP4_CODCLA, ZZS_COD, ZZS_DESCRI
		FROM %TABLE:ZP4% A
		LEFT JOIN %TABLE:ZZS% B ON B.ZZS_COD = A.ZP4_CODCLA AND B.ZZS_FILIAL = %EXP:XFILIAL('ZZS')% AND B.%NOTDEL%
		WHERE A.ZP4_PALETE = %EXP:cPallet%
		AND A.ZP4_FILIAL = %EXP:XFILIAL('ZP4')%
		AND A.%NOTDEL%

	EndSQL

	cCodCls := (cAlias)->ZP4_CODCLA
	cDescri := (cAlias)->ZZS_DESCRI

	oGet2:Refresh()
	oSay3:Refresh()
	//oGet1:SetFocus()

Return .T.



Static Function bOK (cPallet)

	dbSelectArea("ZP4")
	dbSetOrder(1)

	If ZP4->(dbSeek(xFilial("ZP4")+cPallet))
		RecLock("ZP4", .F.)
		ZP4_CODCLA := cCodCls
		MsUnlock()
	Else
		MsgStop("Problemas ao Alterar o Registro!",'Manutenção de Pallets')
	EndIF

	cPallet := space(TamSx3("ZP4_PALETE")[1])
	cCodCls := space(TamSx3("ZZS_COD")[1])
	cDescri := space(TamSx3("ZZS_DESCRI")[1])

	oGet1:Refresh()
	oGet2:Refresh()
	oSay3:Refresh()
	oGet1:SetFocus()

Return