#include 'totvs.ch'
#include 'topconn.ch'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP006()	 ºAutor  ³Infinit     º Data ³ 02/05/13   	    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Entrada de Tœneo											    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function PCP006()
	Private lAuto := Select('SX2')==0
	If lAuto
		RpcClearEnv()
		RpcSetType(3)
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES  "ZP1","ZP6","SZ6"  USER "evandro.gomes  " PASSWORD "Lucca@2012" MODULO "PCP"
		U_PCP006A(1)
	Else
		U_PCP006A(2)
	Endif
Return
**********************************
**********************************
**********************************

User Function PCP006A(nTipo)

	Local oFntGet1 := TFont():New("Tahoma",,034,,.T.,,,,,.F.,.F.)
	Local oFntGet2 := TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private oContado
	Private nContado := 0
	Private oEtiq
	Private nTamRec := (TamSX3("H6_XETIQ")[1])+1
	Private cEtiq := Space(nTamRec)
	Private oSaidaE
	Private oSaidaO
	Private cSaida := ""
	Private oDlg
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	//->Analiza se usu‡rio pode acessar esta rotina
	If nTipo==2
		If !U_APPFUN01("Z6_ENTRTCA")=="S"
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return
		Endif
	Endif

	DEFINE MSDIALOG oDlg TITLE "Apontamento Producao" FROM 000, 000  TO 450, 410 COLORS 0, 16777215 PIXEL

	@ 002, 002 SAY oSay1 PROMPT "Contador" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oContado VAR nContado SIZE 050, 020 OF oDlg COLORS 0, 16777215 FONT oFntGet2 READONLY F3 "SH1" PIXEL
	@ 010, 055 BUTTON oBtnZera PROMPT "Zerar" SIZE 037, 020 OF oDlg ACTION bZera() PIXEL
	@ 037, 002 MSGET oEtiq VAR cEtiq SIZE 200, 025 OF oDlg COLORS 16711680, 16777215 FONT oFntGet1 VALID bValEtiq() PIXEL
	@ 030, 002 SAY oSay2 PROMPT "Etiqueta" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 002 GET oSaidaE VAR cSaida OF oDlg MULTILINE SIZE 200, 150 COLORS 16777215, 255 FONT oFntGet2 READONLY HSCROLL PIXEL
	@ 070, 002 GET oSaidaO VAR cSaida OF oDlg MULTILINE SIZE 200, 150 COLORS 4227072, 16777215 FONT oFntGet2 READONLY HSCROLL PIXEL
	oSaidaE:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oSaidaO:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")

	oSaidaE:Hide()
	oSaidaO:Hide()
	oEtiq:SetFocus()

	ACTIVATE MSDIALOG oDlg CENTERED

Return
**********************************
**********************************
**********************************

Static Function bZera()
	nContado := 0
	oEtiq:SetFocus()
	oContado:Refresh()
Return
**********************************
**********************************
**********************************

Static Function bValEtiq()
	Local _cMsg := ""

	If Len(AllTrim(cEtiq)) > 0
		ZP1->(dbSetOrder(1))
		ZP6->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial()+cEtiq))
			If ZP6->(dbSeek(xFilial()+cEtiq))
				bMsgErr("JA EXISTE APONTAMENTO PARA ESTA ETIQUETA!!!")
			Else
				If bAponta()
					_cMsg += "Produto: "+ZP1->ZP1_CODPRO+CHR(10)
					_cMsg += "Descricao: "+AllTrim(Posicione("SB1",1,xFilial("SB1")+ZP1->ZP1_CODPRO,"B1_DESC"))+CHR(10)
					_cMsg += "Lote:"+ZP1->ZP1_LOTE
					bMsgOk(_cMsg)
					nContado++
					oContado:Refresh()
					oEtiq:SetFocus()
				EndIf
			EndIf
		Else
			bMsgErr("ETIQUETA NÃO LOCALIZADA NA BASE DE DADOS!!!")
		EndIf
	Else
		cEtiq := Space(nTamRec)
		oEtiq:Refresh()
		//oEtiq:SetFocus()
	EndIf
Return
**********************************
**********************************
**********************************

Static Function bMsgOk(_cMsg)
	cEtiq := Space(nTamRec)
	cSaida := _cMsg
	oSaidaE:Hide()
	oSaidaO:Show()
	oSaidaE:Refresh()
	oSaidaO:Refresh()
	oEtiq:Refresh()
	oEtiq:SetFocus()
Return
**********************************
**********************************
**********************************

Static Function bMsgErr(_cMsg)
	cEtiq := Space(nTamRec)
	cSaida := _cMsg
	oSaidaE:Show()
	oSaidaO:Hide()
	oSaidaE:Refresh()
	oSaidaO:Refresh()
	Tone()
	oEtiq:Refresh()
	oEtiq:SetFocus()
Return

**********************************
**********************************
**********************************
Static Function bAponta()

	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+cEtiq))

		If ZP1->ZP1_REPROC == "S"
			bMsgErr(OemToAnsi("Error: Etiqueta Reprocessada"))
			Return .F.
		Endif

		If !Empty(ZP1->ZP1_CARGA)
			bMsgErr(OemToAnsi("Error: Etiqueta Ja expedida"))
			Return .F.
		Endif

		If ZP1->ZP1_STATUS == "1"
			bMsgErr(OemToAnsi("Error: Caixa Ativada"))
			Return .F.
		Endif

		If ZP1->ZP1_STATUS == "5"
			bMsgErr(OemToAnsi("Error: Etiqueta Exlcuida por inventario"))
			Return .F.
		Endif

		RecLock("ZP6",.T.)
		ZP6->ZP6_FILIAL	:= xFilial("ZP6")
		ZP6->ZP6_ETIQ		:= cEtiq
		ZP6->ZP6_DATA		:= Date()
		ZP6->ZP6_HORA		:= Time()
		ZP6->ZP6_USUARI	:= cUserName
		ZP6->(MsUnLock())

		//->Lod. Registro
		If Len(AllTrim(cEtiq)) > 16
			If !Empty(AllTrim(SubStr(cEtiq,1,16)))
				U_PCPRGLOG(_nTpLog,SubStr(cEtiq,1,16),"69","Etiq. com mais de 16 caract.")
			Endif	
		Else
			U_PCPRGLOG(_nTpLog,cEtiq,"13","")
		Endif
	Else
		If !Empty(AllTrim(SubStr(cEtiq,1,16)))
			U_PCPRGLOG(_nTpLog,SubStr(cCodEti,1,16),"69","Etiqueta nao encontrada")
		Endif
	Endif
	
Return(.T.)

