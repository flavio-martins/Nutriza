#Include "PROTHEUS.CH"

/*

R O T I N A  D E S C O N T I N U A D A
R O T I N A  D E S C O N T I N U A D A
R O T I N A  D E S C O N T I N U A D A
R O T I N A  D E S C O N T I N U A D A
R O T I N A  D E S C O N T I N U A D A
R O T I N A  D E S C O N T I N U A D A

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCP019() 	 บAutor  ณEvandro Gomes     บ Data ณ 02/05/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Consulta Etiquetas 											บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NUTRIZA							                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
Parametro			Tipo			Descri็ใo
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

*/  
User Function PCP019()
	Private oDados
	Private cDados := ""
	Private oEtiq
	Private cEtiq := Space(17)
	Private oFont1 := TFont():New("Tahoma",,024,,.T.,,,,,.F.,.F.)
	Private oSay1
	Private oDlg

	DEFINE MSDIALOG oDlg TITLE "Consulta Etiqueta" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	@ 002, 002 SAY oSay1 PROMPT "Etiqueta" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oEtiq VAR cEtiq SIZE 070, 010 OF oDlg VALID bValEtiq() COLORS 0, 16777215 PIXEL
	@ 029, 002 GET oDados VAR cDados OF oDlg MULTILINE SIZE 395, 215 COLORS 0, 16777215 FONT oFont1 READONLY HSCROLL PIXEL
	@ 010, 080 BUTTON Limpar PROMPT "Limpar" SIZE 037, 012 OF oDlg ACTION bLimpa() PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function bValEtiq()
	Local _lRet := .T.
	Local _cEOL := CHR(13)+CHR(10)

	If Len(AllTrim(cEtiq)) <= 0
		Return(_lRet)
	EndIf

	cDados:= ""
	cEtiq := AllTrim(Upper(cEtiq))

	SB1->(dbSetOrder(1))
	If SubStr(cEtiq,1,2) == "90"
		ZP4->(dbSetOrder(1))
		If ZP4->(dbSeek(xFilial()+cEtiq))
			SB1->(dbSeek(xFilial()+ZP4->ZP4_PRODUT))
			cDados += "Etiqueta: "+ZP4->ZP4_PALETE+_cEOL
			cDados += "Tipo: Palete"+_cEOL
			cDados += "Origem: "+If(Len(AllTrim(ZP4->ZP4_USABER))<=0,"eData","Protheus")+_cEOL
			cDados += "Produto: "+SubStr(SB1->B1_COD,1,5)+"-"+SB1->B1_DESC+_cEOL
			cDados += "Quantidade Etiquetas: "+AllTrim(Str(ZP4->ZP4_CONTAD))+_cEOL+_cEOL
			cDados += "Abertura Paletiza็ใo"+_cEOL
			cDados += "Usuario:"+ZP4->ZP4_USABER+_cEOL
			cDados += "Data/Hora:"+DToC(ZP4->ZP4_DTABER)+"/"+ZP4->ZP4_HRABER+_cEOL+_cEOL
			cDados += "Fechamento Paletiza็ใo"+_cEOL
			cDados += "Usuario:"+ZP4->ZP4_USFECH+_cEOL
			cDados += "Data/Hora:"+DToC(ZP4->ZP4_DTFECH)+"/"+ZP4->ZP4_HRFECH+_cEOL+_cEOL
			DAK->(dbSetOrder(1))
			If DAK->(dbSeek(xFilial()+ZP4->ZP4_CARGA))
				cDados += "Carregamento"+_cEOL
				cDados += "Carga: "+ZP4->ZP4_CARGA+_cEOL
				cDados += "Abertura"+_cEOL
				cDados += "Usuario:"+DAK->DAK_XUSABE+_cEOL
				cDados += "Data/Hora:"+DToC(DAK->DAK_XDTABE)+"/"+DAK->DAK_XHRABE+_cEOL+_cEOL
				cDados += "Fechamento"+_cEOL
				cDados += "Usuario:"+DAK->DAK_XUSFEC+_cEOL
				cDados += "Data/Hora:"+DToC(DAK->DAK_XDTFEC)+"/"+DAK->DAK_XHRFEC+_cEOL+_cEOL
			EndIf

		Else
			cDados := "Etiqueta Invแlida"
		EndIf
	Else
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial()+cEtiq))
			SB1->(dbSeek(xFilial()+ZP1->ZP1_CODPRO))
			cDados += "Etiqueta: "+ZP1->ZP1_CODETI+_cEOL
			cDados += "Tipo: Caixa"+_cEOL
			cDados += "Origem: "+If(ZP1->ZP1_EDATA=="S","eData","Protheus")+_cEOL
			cDados += "Produto: "+SubStr(SB1->B1_COD,1,5)+"-"+SB1->B1_DESC+_cEOL
			cDados += "Palete: "+ZP1->ZP1_PALETE+_cEOL+_cEOL
			cDados += "Impressใo"+_cEOL
			cDados += "Usuario:"+ZP1->ZP1_USIMPR+_cEOL
			cDados += "Data/Hora:"+DToC(ZP1->ZP1_DTIMPR)+"/"+ZP1->ZP1_HRIMPR+_cEOL+_cEOL
			ZP6->(dbSetOrder(1))
			If ZP6->(dbSeek(xFilial()+cEtiq))
				cDados += "Entrada TCA"+_cEOL
				cDados += "Usuario:"+ZP6->ZP6_USUARI+_cEOL
				cDados += "Data/Hora:"+DToC(ZP6->ZP6_DATA)+"/"+ZP6->ZP6_HORA+_cEOL+_cEOL
			EndIf

			cDados += "Estoque: "+If(ZP1->ZP1_STATUS == "1","SIM","NรO")+_cEOL
			If ZP1->ZP1_STATUS == "1"
				cDados += "Entrada Estoque"+_cEOL
				cDados += "Data/Hora:"+DToC(ZP1->ZP1_DTATIV)+"/"+ZP1->ZP1_HRATIV+_cEOL+_cEOL
			EndIf

			ZP4->(dbSetOrder(1))
			If ZP4->(dbSeek(xFilial()+ZP1->ZP1_PALETE))
				cDados += "Abertura Paletiza็ใo"+_cEOL
				cDados += "Usuario:"+ZP4->ZP4_USABER+_cEOL
				cDados += "Data/Hora:"+DToC(ZP4->ZP4_DTABER)+"/"+ZP4->ZP4_HRABER+_cEOL+_cEOL
				cDados += "Fechamento Paletiza็ใo"+_cEOL
				cDados += "Usuario:"+ZP4->ZP4_USFECH+_cEOL
				cDados += "Data/Hora:"+DToC(ZP4->ZP4_DTFECH)+"/"+ZP4->ZP4_HRFECH+_cEOL+_cEOL
			EndIf
			DAK->(dbSetOrder(1))
			If DAK->(dbSeek(xFilial()+ZP1->ZP1_CARGA))
				cDados += "Carregamento"+_cEOL
				cDados += "Carga: "+ZP1->ZP1_CARGA+_cEOL
				cDados += "Abertura"+_cEOL
				cDados += "Usuario:"+DAK->DAK_XUSABE+_cEOL
				cDados += "Data/Hora:"+DToC(DAK->DAK_XDTABE)+"/"+DAK->DAK_XHRABE+_cEOL+_cEOL
				cDados += "Fechamento"+_cEOL
				cDados += "Usuario:"+DAK->DAK_XUSFEC+_cEOL
				cDados += "Data/Hora:"+DToC(DAK->DAK_XDTFEC)+"/"+DAK->DAK_XHRFEC+_cEOL+_cEOL
			EndIf
		Else
			cDados := "Etiqueta Invแlida"
		EndIf
	EndIf
	cEtiq := Space(17)
	oDados:Refresh()
	oEtiq:Refresh()
	oEtiq:SetFocus()
Return(_lRet)

Static Function bLimpa()
	cDados := ""
	cEtiq := Space(17)
	oEtiq:Refresh()
	oDados:Refresh()
Return

/*





*/
