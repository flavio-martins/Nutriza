#INCLUDE "rwmake.ch"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP036() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Pesagem de Cargaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±± Por: Evandro Gomes
±± Em: 11/11/2016
±± DescriCAo:
±± ATIVADA A INC. DE PESO ATRAVƒS DO TIKET DE PESAGEM NÌO PODENDO MAIS OBTER
±± PESO DE FORMA MANUAL OU OBPER PESO DA BALAN‚A.
±± O PARAMERO MV_PCPTKFT ATIVA ESTA OP‚ÌO. .F. ATIVA E .T. DESATIVA
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function PCP013()


	Private oBtnImp
	Private oBtnPeso
	Private oCarga
	Private oDtHrEnt
	Private oDtHrSai
	Private oExpedidor
	Private oFont1 	:= TFont():New("Tahoma",,056,,.T.,,,,,.F.,.F.)
	Private oFont2 	:= TFont():New("Tahoma",,022,,.T.,,,,,.F.,.F.)
	Private oGroup2
	Private oGroup3
	Private oLacre
	Private oMotor
	Private oNmMotor
	Private oPerDif
	Private oPesCarga
	Private oPesDif
	Private oPesEmb
	Private oPesEnt
	Private oPesMan
	Private oPesMerc
	Private oPesoBal
	Private oPesSai
	Private oPesTot
	Private oPlaca
	Private oTicket
	Private cTicket	:=CriaVar("ZPC_TICKET",.F.)
	Private nPerDif 	:= 0
	Private nPesCarga	:= 0
	Private nPesDif 	:= 0
	Private nPesEmb 	:= 0
	Private nPesEnt 	:= 0
	Private nPesMerc 	:= 0
	Private nPesoBal 	:= 0
	Private nPesSai 	:= 0
	Private nPesTot 	:= 0
	Private cCarga 	:= DAK->DAK_COD
	Private cLacre 	:= DAK->DAK_XLACRE
	Private cMotor 	:= DAK->DAK_MOTORI
	Private cNmMotor 	:= If(Len(AllTrim(DAK->DAK_MOTORI))>0,Posicione("DA4",1,xFilial("DA4")+DAK->DAK_MOTORI,"DA4_NOME"),"")
	Private cPlaca	:= If(Len(AllTrim(DAK->DAK_CAMINH))>0,Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_PLACA"),"")
	Private cTransp 	:= Posicione("SA4",1,xFilial("SA4")+DA3->DA3_XCODTR,"A4_NOME")
	Private cExpedidor := DAK->DAK_XUSFEC
	Private lPesMan 	:= DAK->DAK_XPESMA
	Private cDtHrEnt 	:= DToC(DAK->DAK_XDTPEE)+"-"+DAK->DAK_XHRPEE
	Private cUserEnt 	:= DAK->DAK_XUPESE
	Private cDtHrSai 	:= DToC(DAK->DAK_XDTPES)+"-"+DAK->DAK_XHRPES
	Private cUserSai 	:= DAK->DAK_XUPESS
	Private oTransp
	Private oUserEnt
	Private oUserSai
	Private oDlg
	Private lEntrada	:= Len(AllTrim(DAK->DAK_XUPESE)) <= 0
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _lPCPTKFT	:= GetNewPar("MV_PCPTKFT",.F.)

	//->Testa ambientes que podem ser usados
	/*If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
	Alert("Ambiente nao homologado para o uso desta rotina!!!")
	Return .F.
	Endif*/

	If !lEntrada .AND. DAK->DAK_XSTEXP <> "F"
		MsgStop("Ja foi realizada a pensagem de entrada para esta carga. Para realizar a pesagem de saída a carga deve estar expedida")
		Return
	EndIf

	If _lPCPTKFT
		bIniPeso()
	Endif

	DEFINE MSDIALOG oDlg TITLE "Registro de Pesagem - Saída de Carga" FROM 000, 000  TO 470, 590 COLORS 0, 16777215 PIXEL

	@ 002, 002 SAY oSay1 PROMPT "Placa" SIZE 025, 007 OF oDlg COLORS 0, 16777215  PIXEL
	@ 010, 002 MSGET oPlaca VAR cPlaca SIZE 040, 010 OF oDlg VALID bValPlaca() COLORS 0, 16777215 WHEN _lPCPTKFT PIXEL
	@ 002, 045 SAY oSay2 PROMPT "Transportador" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 045 MSGET oTransp VAR cTransp SIZE 100, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 002, 147 SAY oSay3 PROMPT "Motorista" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 147 MSGET oMotor VAR cMotor SIZE 040, 010 OF oDlg VALID bValMotor() COLORS 0, 16777215 F3 "DA4" PIXEL
	@ 010, 190 MSGET oNmMotor VAR cNmMotor SIZE 100, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 025, 002 SAY oSay4 PROMPT "Carga" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 032, 002 MSGET oCarga VAR cCarga SIZE 040, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 025, 045 SAY oSay5 PROMPT "Expedidor" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 032, 045 MSGET oExpedidor VAR cExpedidor SIZE 075, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 025, 122 SAY oSay6 PROMPT "Lacre(s)" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 032, 122 GET oLacre VAR cLacre OF oDlg MULTILINE SIZE 167, 020 COLORS 0, 16777215 READONLY HSCROLL PIXEL

	If !_lPCPTKFT
		lPesMan:=.T.
	Endif

	@ 052, 005 SAY oSay12 PROMPT "Ticket" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 059, 005 MSGET oTicket VAR cTicket SIZE 290, 015 OF oDlg PICTURE "@!" COLORS 0, 16777215 FONT oFont2 F3 "ZPCTIK" WHEN IIF(!_lPCPTKFT,.T.,.F.) VALID U_fRetTick(cTicket) PIXEL

	@ 080, 002 GROUP oGroup2 TO 151, 057 PROMPT "Pesagem Entrada" OF oDlg COLOR 0, 16777215 PIXEL
	@ 080, 062 GROUP oGroup3 TO 151, 117 PROMPT "Pesagem Saida" OF oDlg COLOR 0, 16777215 PIXEL
	@ 080, 122 MSGET oPesoBal VAR nPesoBal SIZE 167, 042 OF oDlg PICTURE "@E 999,999" COLORS 65280, 0 FONT oFont1 When IIF(!_lPCPTKFT,.F.,lPesMan) Valid IIF(!_lPCPTKFT,.T.,bValPeso()) PIXEL
	@ 088, 005 MSGET oUserEnt VAR cUserEnt SIZE 050, 010 OF oGroup2 COLORS 0, 16777215 READONLY PIXEL
	@ 103, 005 MSGET oDtHrEnt VAR cDtHrEnt SIZE 050, 010 OF oGroup2 COLORS 0, 16777215 WHEN _lPCPTKFT PIXEL
	@ 088, 065 MSGET oUserSai VAR cUserSai SIZE 050, 010 OF oGroup3 COLORS 0, 16777215 READONLY PIXEL
	@ 103, 065 MSGET oDtHrSai VAR cDtHrSai SIZE 050, 010 OF oGroup3 COLORS 0, 16777215 WHEN _lPCPTKFT PIXEL
	@ 128, 122 CHECKBOX oPesMan VAR lPesMan PROMPT "Pesagem Manual" SIZE 055, 008 OF oDlg COLORS 0, 16777215 ON CHANGE bPesMan() PIXEL
	@ 130, 185 BUTTON oBtnImp PROMPT "Imprimir" SIZE 037, 012 OF oDlg ACTION bImp() PIXEL
	If _lPCPTKFT
		@ 130, 232 BUTTON oBtnPeso PROMPT "Peso" SIZE 037, 012 OF oDlg ACTION bPeso() When !lPesMan PIXEL
	Endif

	@ 153, 005 SAY oSay7 PROMPT "Peso Entrada" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 153, 067 SAY oSay8 PROMPT "Peso Saida" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 153, 130 SAY oSay9 PROMPT "Peso Carga" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 153, 193 SAY oSay13 PROMPT "Diferença" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 160, 005 MSGET oPesEnt VAR nPesEnt SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 160, 067 MSGET oPesSai VAR nPesSai SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 160, 130 MSGET oPesCarga VAR nPesCarga SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 160, 193 MSGET oPesDif VAR nPesDif SIZE 025, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 160, 245 MSGET oPerDif VAR nPerDif SIZE 015, 015 OF oDlg PICTURE "@E 9999.99" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 180, 005 SAY oSay10 PROMPT "Peso Mercadoria" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, 067 SAY oSay11 PROMPT "Peso Embalagem" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 180, 130 SAY oSay12 PROMPT "Peso Total" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 187, 005 MSGET oPesMerc VAR nPesMerc SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
	@ 187, 067 MSGET oPesEmb VAR nPesEmb SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

	@ 187, 130 MSGET oPesTot VAR nPesTot SIZE 050, 015 OF oDlg PICTURE "@E 999,999" COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

	DEFINE SBUTTON oSButton3 FROM 217, 015 TYPE 06 OF oDlg ENABLE ACTION bImp()
	DEFINE SBUTTON oSButton1 FROM 217, 217 TYPE 01 OF oDlg ENABLE ACTION bOk()
	DEFINE SBUTTON oSButton2 FROM 217, 257 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	Return

	******************************************************************************************************

Static Function bOk()
	Local lRet	:= .T.
	If !bValMotor()
		Return .F.
	Endif
	DA3->(dbSetOrder(3))
	If DA3->(dbSeek(xFilial()+cPlaca))
		RecLock("DAK",.F.)
		DAK->DAK_CAMINH := DA3->DA3_COD
		DAK->DAK_MOTORI := cMotor
		DAK->DAK_XUPESE := cUserEnt
		DAK->DAK_XUPESS := cUserSai
		DAK->DAK_XDTPEE := CToD(SubStr(cDtHrEnt,1,10))
		DAK->DAK_XDTPES := CToD(SubStr(cDtHrSai,1,10))
		DAK->DAK_XHRPEE := SubStr(cDtHrEnt,12,8)
		DAK->DAK_XHRPES := SubStr(cDtHrSai,12,8)
		DAK->DAK_XPESEN := nPesEnt
		DAK->DAK_XPESSA := nPesSai
		DAK->DAK_XPESMA := lPesMan
		DAK->DAK_TICKET := cTicket
		DAK->(MsUnLock())
		If !lEntrada
			bImp()
		EndIf
		oDlg:End()
	Else
		MsgStop("Veiculo nao encontrado.","PCP013")	
		Return .F.
	Endif
	Return(lRet)

	******************************************************************************************************
Static Function bPesMan()
	nPesoBal := 0
	oPesoBal:Refresh()
	If !_lPCPTKFT
		oBtnPeso:Refresh()
	Endif
	If lPesMan
		oPesoBal:SetFocus()
	Else
		If !_lPCPTKFT
			oBtnPeso:SetFocus()
		Endif
	EndIf
	Return
	******************************************************************************************************
Static Function bValPlaca()
	Local _lRet := .T.
	Local _I := 0
	cPlaca := Upper(cPlaca)
	If Len(AllTrim(cPlaca)) <= 0
		Return(_lRet)
	EndIf
	DA3->(dbSetOrder(3))
	If DA3->(dbSeek(xFilial()+SubStr(cPlaca,1,7)))
		SA4->(dbsetOrder(1))
		If SA4->(dbSeek(xFilial()+DA3->DA3_XCODTR))
			cTransp := SA4->A4_COD+"-"+SA4->A4_NOME
			oTransp:Refresh()
		Else
			MsgStop("Veículo sem transportadora amarrada.")
			_lRet := .F.
		EndIf
	Else
		MsgStop("Veículo não cadastrado.")
		_lRet := .F.
	EndIf
	Return(_lRet)
	******************************************************************************************************
Static Function bValMotor()
	Local _lRet := .T.
	DA4->(dbSetOrder(1))
	If DA4->(dbSeek(xFilial()+cMotor))
		cNmMotor := DA4->DA4_NOME
		oNmMotor:Refresh()
	Else
		MsgStop("Motorista Nao encontrado.")
		_lRet := .F.
	EndIf
Return(_lRet)

Static Function bIniPeso()
	nPesEnt := DAK->DAK_XPESEN
	nPesSai := DAK->DAK_XPESSA
	nPesCarga := IIf(nPesSai>0,DAK->DAK_XPESSA-DAK->DAK_XPESEN,0)

	nPesMerc := 0
	nPesEmb := 0
	nPesTot := 0

	nPesDif := 0
	nPerDif := 0
	bPesoMerc()
	Return
	******************************************************************************************************
Static Function bPeso()
	nPesoBal := 0
	oPesoBal:Refresh()
	bValPeso()
	Return
	******************************************************************************************************
Static Function bPesoMerc()
	Local _cQry := ""
	_cQry += " SELECT SUM(ZP1_PESO) PESOPROD, ROUND(SUM(ZP1_PESO*(CASE WHEN SB1.B1_XPESROM > 0 THEN B1_XPESROM ELSE 1 END-1)),2) PESOEMB"
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CARGA = '"+cCarga+"'"
	TcQuery _cQry New Alias "QRYP"
	If !QRYP->(EOF())
		nPesMerc := QRYP->PESOPROD
		nPesEmb := QRYP->PESOEMB
		nPesTot := nPesMerc+nPesEmb
	EndIf
	QRYP->(dbCloseArea())

	If nPesSai > 0
		nPesDif := nPesCarga-nPesTot
		nPerDif := Round(nPesDif/nPesCarga*100,2)
	EndIf
	Return
	******************************************************************************************************
Static Function bValPeso()
	Local _lRet := .T.
	nPesMerc := 0
	nPesEmb := 0
	nPesTot := 0

	nPesDif := 0
	nPerDif := 0
	If nPesoBal > 0
		If lEntrada
			cDtHrEnt := DToC(Date())+"-"+Time()
			cUserEnt := cUserName
			nPesEnt := nPesoBal
		Else
			cDtHrSai := DToC(Date())+"-"+Time()
			cUserSai := cUserName
			nPesSai := nPesoBal
			nPesCarga := nPesSai-nPesEnt
		EndIf
		bPesoMerc()
	ElseIf nPesoBal < 0
		MsgStop("O peso deve ser positivo")
	Else
		If lEntrada
			nPesEnt := 0
		Else
			nPesSai := 0
			nPesCarga := 0
		EndIf
	EndIf
	oPesEnt:Refresh()
	oPesSai:Refresh()
	oPesCarga:Refresh()
	oPesMerc:Refresh()
	oPesEmb:Refresh()
	oPesTot:Refresh()
	oPesDif:Refresh()
	oPerDif:Refresh()
	oDtHrEnt:Refresh()
	oUserEnt:Refresh()
	oDtHrSai:Refresh()
	oUserSai:Refresh()
	Return(_lRet)
	******************************************************************************************************
Static Function bImp()
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Ticket Pesagem"
	Local cPict          := ""
	Local titulo       := "Ticket Pesagem"
	Local nLin         := 80

	Local Cabec1       := "c1"
	Local Cabec2       := "c2"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := FunName()
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog

	Private cString := "DAK"

	dbSelectArea("DAK")
	dbSetOrder(1)
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return
	******************************************************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)


	SetRegua(RecCount())

	Cabec1       := "Carga: "+cCarga+" Veiculo: "+cPlaca+" Transportador: "+SubStr(cTransp,8,35)
	Cabec2       := "Motorista...: "+AllTrim(cNmMotor)

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	@nLin,00 PSAY "Exp. Abertura: "+DAK->DAK_XUSABE+" Exp. Fechamento: "+cExpedidor;nLin++
	@nLin,00 PSAY "Inicio: "+DToC(DAK->DAK_XDTABE)+" "+DAK->DAK_XHRABE+"     Final: "+DToC(DAK->DAK_XDTFEC)+" "+DAK->DAK_XHRFEC;nLin++
	@nLin,00 PSAY "Lacre:"+DAK->DAK_XLACRE;nLin++
	@nLin,00 PSAY "--------------------------------------------------------------------------------";nLin++
	@nLin,00 PSAY "Peso Bruto Exp.    Peso Liqu. Carga    Peso Venda Carga   Diferença  Autorizante";nLin++
	@nLin,00 PSAY "        "+Transform(nPesTot,"@E 999,999")+"             "+Transform(nPesCarga,"@E 999,999")+"             "+Transform(nPesMerc,"@E 999,999")+"     "+Transform(nPesDif,"@E 999,999");nLin+=2
	@nLin,00 PSAY "---------------------------------------+----------------------------------------";nLin++
	@nLin,00 PSAY "             Pesagem Entrada           |              Pesagem Saida";nLin++
	@nLin,00 PSAY "---------------------------------------+----------------------------------------";nLin++
	@nLin,00 PSAY " Data: "+SubStr(cDtHrEnt,1,10)+"                      | Data: "+SubStr(cDtHrSai,1,10);nLin++
	@nLin,00 PSAY " Hora: "+SubStr(cDtHrEnt,12,8)+"                        | Hora: "+SubStr(cDtHrSai,12,8);nLin++
	@nLin,00 PSAY " Usuário: "+Pad(SubStr(cUserEnt,1,28),28)+" | Usuário: "+Pad(SubStr(cUserSai,1,28),28);nLin++
	@nLin,00 PSAY " Peso: "+TransForm(nPesEnt, "@E 999,999")+" KG                      | Peso: "+TransForm(nPesSai, "@E 999,999")+" KG";nLin++
	@nLin,00 PSAY " Método: "+If(lPesMan,"Manual","Leitu.")+"                        | Método: "+If(lPesMan,"Manual","Leitu.");nLin+=6
	@nLin,00 PSAY ".                      ----------------------------------------";nLin++
	@nLin,00 PSAY ".                      "+cNmMotor;nLin++

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


/*
*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789
Carga: 999999 Veiculo: XXX9999 Trasportador: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Motorista...: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - RG: XXXXXXXXXXXXXXXXXXX
--------------------------------------------------------------------------------
Exp. Abertura: XXXXXXXXXXXXXXXXXXXXXXX Exp. Fechamento: XXXXXXXXXXXXXXXXXXXXXXX
Inicio: 99/99/9999 99:99:99     Final: 99/99/9999 99:99:99
Lacre:
--------------------------------------------------------------------------------
Peso Bruto Exp.    Peso Liqu. Carga    Peso Venda Carga   Diferença  Autorizante
999,999             999,999             999,999     999,999

---------------------------------------+----------------------------------------
.            Pesagem Entrada           |              Pesagem Saida
---------------------------------------+----------------------------------------
Data: 99/99/9999                      | Data: 99/99/9999
Hora: 99:99:99                        |
Usuário: XXXXXXXXXXXXXXXXXXXXXXXXXXXX | Usuário: XXXXXXXXXXXXXXXXXXXXXXXXXXXX
Peso: 999,999 KG                      | Peso: 999,999 KG
Método: Manual                        | Método: Manual





.                      ----------------------------------------
.                      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fRetTick() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Preenche dados dos campos com os dados do Ticket.			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
User Function fRetTick(_cTicket)

	Local lRet	:= .T.
	Local _cEmpPedBal	:= GetNewPar("MV_XEMPBAL","") //-> Filiais que utilizam o peso balancao
	ZPC->(dbSetOrder(1))
	If ZPC->(dbSeek(xFilial("ZPC") + _cTicket ))
		If cFilAnt $ _cEmpPedBal
			If ZPC->ZPC_CARGA <> cCarga
				Alert("Este Ticket nao pertence a esta carga")
				Return .F.
			Endif
		Endif
		cPlaca		:= ZPC->ZPC_CODVEI
		cUserEnt	:= U_RETUSDAT(1, ZPC->ZPC_USPES1, 1, 2) 
		cDtHrEnt	:= DTOC(ZPC->ZPC_DTAPG1)+"-"+ZPC->ZPC_HRAP1
		cUserSai	:= U_RETUSDAT(1, ZPC->ZPC_USPES2, 1, 2)
		cDtHrSai	:= DTOC(ZPC->ZPC_DTAPG2)+"-"+ZPC->ZPC_HRAP2
		nPesoBal	:= ZPC->ZPC_PESO2
		nPesEnt	:= ZPC->ZPC_PESO1
		nPesSai	:= ZPC->ZPC_PESO2
		nPesCarga	:= nPesSai-nPesEnt
		bPesoMerc()
	Else
		Alert("Ticket N‹o Encontrado.")
		lRet:=.F.
	Endif

Return(lRet)
