#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH
#INCLUDE 'PARMTYPE.CH'
#define DS_MODALFRAME   128

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  PCP055  º Autor ³ Flávio Martins     º Data ³  17/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem de Pallet picking, agrupador de caixas em um      º±±
±±º          ³ ùnico pallet.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA S.A                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PCP055()

	Private oDlgPal, oSay1, oData, oSay2, oPalete, oSay8, oPBase, oSay9, oPStrech, oSay3, oClassifi
	Private oSay4, oDescClas, oSay3, oCodigo, oSay4, oIdEtiq, oSay7, oContado, oSay17, _oCapPale
	Private oStatusOK, oStatusER, oEtiquetas
	Private oFntSt := TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)

	Private dData		:= date()
	Private cPalete		:= Space(TamSx3("ZP4_PALETE")[1])
	Private nPBase      := 0
	Private nPStrech    := 0
	Private cClassifi   := Space(TamSx3("ZZS_COD")[1])
	Private cDescClas   := Space(TamSx3("ZZS_DESCRI")[1])
	Private cCodigo     := Space(TamSx3("B1_COD")[1])
	Private cProduto    := Space(TamSx3("B1_DESC")[1])
	Private cIdEtiq     := Space(TamSx3("ZP1_CODETI")[1])
	Private nContado    := 0
	Private _nCapPale   := 0
	Private cStatus     := ""
	Private aEtiquetas  := {}

	Aadd(aEtiquetas,{"","","",""})

	DEFINE MSDIALOG oDlgPal TITLE "Remontagem de pallet picking" FROM 000, 000  TO 600, 500 COLORS 0, 16777215 PIXEL

	@ 002, 002 SAY oSay1 PROMPT "Data" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oData VAR dData SIZE 040, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
	@ 002, 050 SAY oSay2 PROMPT "Palete" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 010, 050 MSGET oPalete VAR cPalete SIZE 065, 010 OF oDlgPal COLORS 0, 16777215 valid fEtiquetas(cPalete, @aEtiquetas) When .T. PIXEL
	@ 002, 120 SAY oSay8 PROMPT "Peso Base" SIZE 035, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 010, 120 MSGET oPBase VAR nPBase SIZE 035, 010 OF oDlgPal PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL
	@ 002, 170 SAY oSay9 PROMPT "Peso Strech" SIZE 035, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 010, 170 MSGET oPStrech VAR nPStrech SIZE 035, 010 OF oDlgPal PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL

	@ 025, 002 SAY oSay3 PROMPT "Classificação" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 032, 002 MSGET oClassifi VAR cClassifi SIZE 045, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
	@ 025, 050 SAY oSay4 PROMPT "Descrição" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 032, 050 MSGET oDescClas VAR cDescClas SIZE 150, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

	@ 048, 002 SAY oSay3 PROMPT "Código" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 054, 002 MSGET oCodigo VAR cCodigo SIZE 045, 010 OF oDlgPal COLORS 0, 16777215 when .F. PIXEL
	@ 048, 050 SAY oSay4 PROMPT "Produto" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 054, 050 MSGET oProduto VAR cProduto SIZE 150, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

	@ 222, 002 SAY oSay5 PROMPT "Identificação" SIZE 050, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 229, 002 MSGET oIdEtiq VAR cIdEtiq SIZE 060, 010 OF oDlgPal COLORS 0, 16777215 /*Valid Iif(Upper(AllTrim(cIdEtiq))="FECHAR",oDlgPal:End(),Iif(bValEtiq(_cOpc),.T.,oIdEtiq:SetFocus()))*/ PIXEL

	@ 222, 082 SAY oSay7 PROMPT "Contador" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 229, 082 MSGET oContado VAR nContado SIZE 025, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

	@ 222, 132 SAY oSay17 PROMPT "Qtd. Palete" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 229, 132 MSGET _oCapPale VAR _nCapPale SIZE 025, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

	@ 069, 002 LISTBOX oEtiquetas Fields HEADER "Identificação","Lote","Dt. Producao","Dt. Validade" SIZE 197, 150 OF oDlgPal PIXEL ColSizes 50,50

	@ 267, 000 GET oStatusOK VAR cStatus OF oDlgPal MULTILINE SIZE 200, 055 COLORS 0, 32768 FONT oFntSt READONLY HSCROLL PIXEL
	@ 267, 000 GET oStatusER VAR cStatus OF oDlgPal MULTILINE SIZE 200, 055 COLORS 0, 255 FONT oFntSt READONLY HSCROLL PIXEL
	oStatusER:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oStatusOK:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")
	@ 032, 207 BUTTON oGrava PROMPT "Fechar" SIZE 037, 012 OF oDlgPal Action oDlgPal:End() PIXEL


	// Don't change the Align Order
	oStatusOK:Align := CONTROL_ALIGN_BOTTOM
	oStatusER:Align := CONTROL_ALIGN_BOTTOM

	oStatusOK:Hide()
	oStatusER:Hide()

	ACTIVATE MSDIALOG oDlgPal CENTERED

Return



Static Function fEtiquetas(cPalete, aEtiquetas)

	aEtiquetas := {}
	ZP1->(dbSetOrder(2))
	ZP1->(dbSeek(xFilial()+cPalete))
	While !ZP1->(EOF()) .AND. ZP1->ZP1_FILIAL == xFilial("ZP1") .AND. ZP1->ZP1_PALETE == cPalete
		aAdd(aEtiquetas,{ZP1->ZP1_CODETI,ZP1->ZP1_LOTE,DToC(ZP1->ZP1_DTPROD),DToC(ZP1->ZP1_DTVALI)})
		ZP1->(dbSkip())
	EndDo

	If Len(aEtiquetas) <= 0
		Aadd(aEtiquetas,{"","","",""})
	EndIf

	oEtiquetas:SetArray(aEtiquetas)
	//oEtiquetas:bLine := {|| {aEtiquetas[oEtiquetas:nAt,1],aEtiquetas[oEtiquetas:nAt,2],aEtiquetas[oEtiquetas:nAt,3],aEtiquetas[oEtiquetas:nAt,4]}}
	//oEtiquetas:bLDblClick := {|| oEtiquetas:DrawSelect()}
	oEtiquetas:refresh()
	oDlgPal:refresh()
	oIdEtiq:SetFocus()
Return .t.
