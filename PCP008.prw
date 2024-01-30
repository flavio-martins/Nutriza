#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#define DS_MODALFRAME   128
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP008() ºAutor  ³Infinit             º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Expedicao												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
2016 - Evandro Gomes -> Ajustadas não conformidades que estavam impedindo a expedicao
2016 - Evandro Gomes -> Inclus‹o de rotina sequencia de carga por pedido e por produto
2016 - Evandro Gomes -> Sequencia de expedicao por Carga
2016 - Evandro Gomes -> Sequencia de expedicao por Pedido
2016 - Evandro Gomes -> Inclusao de Rotina FIFO
2016 - Evandro Gomes -> Inclusao de rotina FIFO FIXO
2016 - Evandro Gomes -> Inclusao de registro de LOG
2016 - Evandro Gomes -> Inclusao de controle de transacao
2016 - Evandro Gomes -> Inclusao de rotina de tolerancia
2016 - Evandro Gomes -> Inclusao de rotina de tolerancia por cliente
2018 - Flávio Martins -> Alterações e mudanças drásticas em todo o projeto.
*/
User Function GTOPCP08()

	Private cPedido
	Private aItmCarreg	:= {}
	Private cCarga
	Private lAbreFecha 	:= .T.
	Private _cEtiq
	Private LVOLTACX 	:= .F.
	Private oLeituras
	Private oProds

	U_PCP008()

Return
/*
nOpc = 1 -> Manutencao
nOpc = 2 -> Visualizar
*/
User Function PCP008()

	Private cPedido
	Private cCarga
	Private oFolder1
	Private oCargas
	Private oPedidos
	Private oProds
	Private oItensPed
	Private oLeituras
	Private oDlgExp
	Private _cEtiq
	Private aItmCarreg	:= {}
	Private aCargas		:= {}
	Private aPedidos	:= {}
	Private aItensPed	:= {}
	Private aLeituras	:= {}
	Private _aDados		:= {}
	Private _cFiltro	:= ""
	Private _cNilAu		:= 8
	Private cUserDesm	:= GetNewPar("MV_USERDES","FLAVIO.MARTINS")
	Private _cLocDoc	:= GetNewPar("MV_XWMSLCD","40") //->Armazém para expedicao
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog		:= GetNewPar("MV_PCPTLOG",1)
	Private _cPCPAJPD	:= GetNewPar("MV_PCPAJPD","")
	Private lPedFifo	:= GetNewPar("MV_PCPPEDF",.T.) //-> Habilita fifo atraves de datas informadas no pedido
	Private cTipoExp	:= GetNewPar("MV_PCPTPEX",'P') //-> Tipo de Expedicao a se utilizada:'C'->Carga/'P'->Pedido
	Private cConcFifo	:= GetNewPar("MV_CONFIFO",'') //-> Familias que devem entrar em FIFO
	Private lSeqProd	:= GetNewPar("MV_XOMSSPR",.T.) //-> Sequencia de expedicao por Produto
	Private _lHabFeCx	:= GetNewPar("MV_XPCPHFC",.F.) //->Habilita Fechamento de Caixa por Armazem
	Private aPedFifo	:= {} //->Array para controle de vencimentos atraves do pedido
	Private nHRes		:= oMainWnd:nClientWidth*0.95	// Resolucao horizontal do monitor
	Private nVRes		:= oMainWnd:nClientHeight*0.90	// Resolucao vertical do monitor
	Private nVLim		:= (nVRes/2)-25
	Private lAbreFecha	:= .T.
	Private LVOLTACX	:= .F.


	//->Testa ambientes que podem ser usados

	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif
	//->Analiza se usuario pode acessar esta rotina
	If !U_APPFUN01("Z6_EXPEDIC")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	LjMsgRun( "Processando dados, aguarde...", "Expedição", {|| bDados() } )

	DEFINE MSDIALOG oDlgExp TITLE "Expedição" FROM 000, -30  TO nVRes,nHRes PIXEL COLORS 0, 16777215

	@ 000, 000 FOLDER oFolder1 SIZE 500, nVLim OF oDlgExp ITEMS "Cargas","Pedidos","Itens do Pedido","Leituras da Carga" COLORS 0, 16777215 PIXEL

	fCargas()

	@ nVLim+5, 055 BUTTON oFiltra PROMPT "Filtrar" SIZE 037, 012 OF oDlgExp ACTION bFiltrar() PIXEL
	If "PCP008" $ AllTrim(Upper(FunName()))
		@ nVLim+5, 005 BUTTON oBtnCarr PROMPT "Carregar" SIZE 037, 012 OF oDlgExp ACTION fInExp(1) PIXEL
		If cNivel >= _cNilAu
			@ nVLim+5, 105 BUTTON oBtnCarr PROMPT "Descarregar" SIZE 037, 012 OF oDlgExp ACTION bDescar() PIXEL
		EndIf
		@ nVLim+5, 155 BUTTON oBtnRecom PROMPT "Recompor" SIZE 037, 012 OF oDlgExp ACTION bRecomp() PIXEL
		@ nVLim+5, 205 BUTTON oBtnCarr PROMPT "Excluir" SIZE 037, 012 OF oDlgExp ACTION fInExp(3) PIXEL
		@ nVLim+5, 265 BUTTON oBtnCarr PROMPT "Sequencia" SIZE 037, 012 OF oDlgExp ACTION U_GTOOMS01(2, aCargas[oCargas:nAt,1]) PIXEL
	Else
		@ nVLim+5, 005 BUTTON oBtnCarr PROMPT "Visualizar" SIZE 037, 012 OF oDlgExp ACTION fInExp(2) PIXEL
		@ nVLim+5, 105 BUTTON oBtnCarr PROMPT "Sequencia" SIZE 037, 012 OF oDlgExp ACTION U_GTOOMS01(2, aCargas[oCargas:nAt,1]) PIXEL
	EndIf

	oFolder1:Align	:= CONTROL_ALIGN_TOP
	oCargas:Align	:= CONTROL_ALIGN_ALLCLIENT
	oItensPed:Align := CONTROL_ALIGN_ALLCLIENT
	oPedidos:Align	:= CONTROL_ALIGN_ALLCLIENT
	oLeituras:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgExp CENTERED

Return

/*
Funcao: fInExp()
Descricao: Inicia expedicao
*/
Static Function fInExp(nTipo)
	Private lVarejo	:= .F.

	//->Identificacao da carga se e varejo
	DAK->(dbSetOrder(1))
	If DAK->(dbSeek(xFilial()+aCargas[oCargas:nAt,1]))
		lVarejo:=IIf(DAK->DAK_OCORRE='09',.T.,.F.)
	Endif

	If lVarejo //->Carga de Varejo
		cTipoExp:='C'  //-> Tipo de Expedicao a se utilizada:'C'->Carga/'P'->Pedido
	Else
		cTipoExp:= GetNewPar("MV_PCPTPEX",'P') //-> Tipo de Expedicao a se utilizada:'C'->Carga/'P'->Pedido
	Endif

	If cTipoExp=='C' .Or. (cTipoExp=='P' .And. fCarQtd(aCargas[oCargas:nAt,1],"") > 0)
		cTipoExp:='C'
		If oFolder1:nOption==1
			bCarrega(Iif(nTipo = 2,"V",""),"",nTipo)
		Else
			Alert("Selecione a Carga na Aba de 'Cargas'.")
		Endif
	Elseif cTipoExp=='P' .And. fCarQtd(aCargas[oCargas:nAt,1],"")==0
		If oFolder1:nOption==2 //->Aba de pedidos
			If fPedExp('P',nTipo, aPedidos[oPedidos:nAt,1], aCargas[oCargas:nAt,1],"") //->Verifica Sequencia de Carga
				bCarrega(Iif((nTipo = 2),"V",""),aPedidos[oPedidos:nAt,1],nTipo)
			Endif
		Else
			Alert("Selecione o Pedido na Aba de 'Pedidos'.")
		Endif
	Else
		Alert("Tipo de operação nao identificada.")
	Endif
Return

Static Function fCargas()
	Local _I := 0

	aCargas := {}

	For _I := 1 To Len(_aDados)
		aAdd(aCargas,{;
		_aDados[_I,1],;
		DToC(SToD(_aDados[_I,2])),;
		_aDados[_I,3],;
		_aDados[_I,4],;
		_aDados[_I,5],;
		_aDados[_I,6],;
		_aDados[_I,7],;
		DToC(SToD(_aDados[_I,8]))+"/"+_aDados[_I,9],;
		_aDados[_I,10],;
		DToC(SToD(_aDados[_I,11]))+"/"+_aDados[_I,12];
		})
	Next _I

	If Len(aCargas) <= 0
		aAdd(aCargas,{"","","","","","","","","",""})
	EndIf

	If oCargas == Nil
		@ 000, 000 LISTBOX oCargas Fields HEADER "Carga","Data Carga","Placa","Motorista","Transportador","Status","Usuario Abertura","Data/Hora Abertura","Usuario Fechamento","Data/Hora Fechamento" SIZE 496, 261 OF oFolder1:aDialogs[1] PIXEL ColSizes 25,35,30,120,120,100,50,50,50,50,50,50
		oCargas:bLDblClick := {|| oCargas:DrawSelect()}
		oCargas:bChange := {|| fPedidos()}
	EndIf
	oCargas:SetArray(aCargas)
	oCargas:bLine := {|| {;
	aCargas[oCargas:nAt,1],;
	aCargas[oCargas:nAt,2],;
	aCargas[oCargas:nAt,3],;
	aCargas[oCargas:nAt,4],;
	aCargas[oCargas:nAt,5],;
	aCargas[oCargas:nAt,6],;
	aCargas[oCargas:nAt,7],;
	aCargas[oCargas:nAt,8],;
	aCargas[oCargas:nAt,9],;
	aCargas[oCargas:nAt,10];
	}}
	oCargas:Refresh()
	oCargas:nAt := 1
	fLeituras()
	fPedidos()
Return

Static Function fPedidos()
	Local _nPosCarga := aScan(_aDados,{|x| x[1] == aCargas[oCargas:nAt,1]})
	Local _aPeds := {}
	Local _I := 0

	aPedidos := {}

	If _nPosCarga > 0
		_aPeds := aClone(_aDados[_nPosCarga,Len(_aDados[_nPosCarga])])
		For _I := 1 To Len(_aPeds)
			aAdd(aPedidos,{;
			_aPeds[_I,1],;
			DToC(SToD(_aPeds[_I,2])),;
			_aDados[_nPosCarga,6],;
			_aPeds[_I,3],;
			_aPeds[_I,4],;
			_aPeds[_I,5];
			})
		Next _I
	EndIf

	If Len(aPedidos) <= 0
		aAdd(aPedidos,{"","","","","",""})
	EndIf

	If oPedidos == Nil
		@ 000, 000 LISTBOX oPedidos Fields HEADER "Pedido","Data Pedido","Status","Cliente","Vendedor","Observação" SIZE 496, 261 OF oFolder1:aDialogs[2] PIXEL ColSizes 25,35
		oPedidos:bLDblClick := {|| oPedidos:DrawSelect()}
		oPedidos:bChange := {|| fItensPed()}
	EndIf
	oPedidos:SetArray(aPedidos)
	oPedidos:bLine := {|| {;
	aPedidos[oPedidos:nAt,1],;
	aPedidos[oPedidos:nAt,2],;
	aPedidos[oPedidos:nAt,3],;
	aPedidos[oPedidos:nAt,4],;
	aPedidos[oPedidos:nAt,5],;
	aPedidos[oPedidos:nAt,6];
	}}
	oPedidos:Refresh()
	oPedidos:nAt := 1
	fItensPed()
	fLeituras()
Return

Static Function fItensPed()
	Local _nPosCarga := aScan(_aDados,{|x| x[1] == aCargas[oCargas:nAt,1]})
	Local _nPosPed   := 0
	Local _aPeds 	 := {}
	Local _aItens 	 := {}
	Local _I 		 := 0

	aItensPed := {}

	If _nPosCarga > 0
		_aPeds := aClone(_aDados[_nPosCarga,Len(_aDados[_nPosCarga])])
		If (_nPosPed := aScan(_aPeds,{|x| x[1] == aPedidos[oPedidos:nAt,1]})) > 0
			_aItens := aClone(_aPeds[_nPosPed,Len(_aPeds[_nPosPed])])
			For _I := 1 To Len(_aItens)
				aAdd(aItensPed,{_aItens[_I,1],_aItens[_I,2],Transform(_aItens[_I,3],PesqPict("SC9","C9_QTDLIB"))})
			Next _I
		EndIf
	EndIf

	If Len(aItensPed) <= 0
		aAdd(aItensPed,{"","",""})
	EndIf

	If oItensPed == Nil
		@ 000, 000 LISTBOX oItensPed Fields HEADER "Produto","Descricao","Quantidade" SIZE 496, 261 OF oFolder1:aDialogs[3] PIXEL ColSizes 30,200
		oItensPed:bLDblClick := {|| oItensPed:DrawSelect()}
	EndIf
	oItensPed:SetArray(aItensPed)
	oItensPed:bLine := {|| {;
	aItensPed[oItensPed:nAt,1],;
	aItensPed[oItensPed:nAt,2],;
	aItensPed[oItensPed:nAt,3];
	}}
	oItensPed:Refresh()


Return

Static Function fLeituras()
	Local _nPosCarga := aScan(_aDados,{|x| x[1] == aCargas[oCargas:nAt,1]})
	Local _aLeits := {}
	Local _I := 0

	aLeituras := {}

	If _nPosCarga > 0
		_aLeits := aClone(_aDados[_nPosCarga,Len(_aDados[_nPosCarga])-1])
		For _I := 1 To Len(_aLeits)
			aAdd(aLeituras,{;
			_aLeits[_I,1],;
			_aLeits[_I,2],;
			_aLeits[_I,3],;
			DToC(SToD(_aLeits[_I,4])),;
			TransForm(_aLeits[_I,5],PesqPict("ZP1","ZP1_PESO")),;
			DToC(SToD(_aLeits[_I,6]))+"/"+_aLeits[_I,7],;
			_aLeits[_I,8]})
		Next _I
	EndIf

	If Len(aLeituras) <= 0
		aAdd(aLeituras,{"","","","","","",""})
	EndIf

	If oLeituras == Nil
		@ 000, 000 LISTBOX oLeituras Fields HEADER "Identificação","Produto","Descricao","Data Producao","Peso","Data Carregamento","Pallet" SIZE 496, 261 OF oFolder1:aDialogs[4] PIXEL ColSizes 50,30,200,40,35,60
		oLeituras:bLDblClick := {|| oLeituras:DrawSelect()}
	EndIf
	oLeituras:SetArray(aLeituras)
	oLeituras:bLine := {|| {;
	aLeituras[oLeituras:nAt,1],;
	aLeituras[oLeituras:nAt,2],;
	aLeituras[oLeituras:nAt,3],;
	aLeituras[oLeituras:nAt,4],;
	aLeituras[oLeituras:nAt,5],;
	aLeituras[oLeituras:nAt,6],;
	aLeituras[oLeituras:nAt,7];
	}}
	oLeituras:Refresh()

Return


Static Function bDados
	Local _cQry := ""
	Local _aAuxPed := {}
	Local _aAuxItem := {}
	Local _aAuxLei := {}
	Local _cCargaAtu := ""
	Local _cPedAtu := ""
	Local _I := 0
	Local LF := chr(13)+chr(10)

	_aDados := {}
	_cQry += " SELECT" + LF
	_cQry += " DAK_COD, DAK_DATA, DA3.DA3_PLACA, DA4.DA4_NOME, ISNULL(SA4.A4_NOME,'') A4_NOME" + LF
	_cQry += " , CASE DAK_XSTEXP" + LF
	_cQry += " 	WHEN 'A' THEN 'Aguardando Carregamento'" + LF
	_cQry += " 	WHEN 'C' THEN 'Carregando'" + LF
	_cQry += " 	WHEN 'S' THEN 'Suspensa'" + LF
	_cQry += " 	WHEN 'F' THEN 'Finalizada'" + LF
	_cQry += " 	ELSE '' END DAK_XSTEXP" + LF
	_cQry += " , DAK_XUSABE, DAK_XDTABE, DAK_XHRABE, DAK_XUSFEC, DAK_XDTFEC, DAK_XHRFEC" + LF
	_cQry += " , SC5.C5_NUM, SC5.C5_EMISSAO, " + LF
	_cQry += " 	CASE C5_TIPO WHEN 'B' THEN SA2.A2_NOME ELSE SA1.A1_NOME END A1_NOME, " + LF
	_cQry += " 	SA3.A3_NOME, SC5.C5_XOBS " + LF
	_cQry += " , SC9.C9_PRODUTO, SB1.B1_DESC, SC9.C9_QTDLIB" + LF
	_cQry += " , DAI_SEQUEN" + LF
	_cQry += " FROM "+RetSQLName("DAK")+" DAK" + LF
	_cQry += " INNER JOIN "+RetSQLName("DA3")+" DA3 ON DA3.D_E_L_E_T_ = ' ' AND DA3.DA3_FILIAL = '"+xFilial("DA3")+"' AND DA3.DA3_COD = DAK.DAK_CAMINH" + LF
	_cQry += " INNER JOIN "+RetSQLName("DA4")+" DA4 ON DA4.D_E_L_E_T_ = ' ' AND DA4.DA4_FILIAL = '"+xFilial("DA4")+"' AND DA4.DA4_COD = DAK.DAK_MOTORI" + LF
	_cQry += " LEFT JOIN "+RetSQLName("SA4")+" SA4 ON SA4.D_E_L_E_T_ = ' ' AND SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND SA4.A4_COD = DA3.DA3_XCODTR" + LF
	_cQry += " INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI.D_E_L_E_T_ = ' ' AND DAI.DAI_FILIAL = DAK_FILIAL AND DAI.DAI_COD = DAK.DAK_COD" + LF
	_cQry += " INNER JOIN "+RetSQLName("SC5")+" SC5 ON SC5.D_E_L_E_T_ = ' ' AND SC5.C5_FILIAL = DAI.DAI_FILIAL AND SC5.C5_NUM = DAI.DAI_PEDIDO" + LF
	_cQry += " LEFT JOIN "+RetSQLName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI" + LF
	_cQry += " LEFT JOIN "+RetSQLName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.A2_COD = SC5.C5_CLIENTE AND SA2.A2_LOJA = SC5.C5_LOJACLI" + LF
	_cQry += " INNER JOIN "+RetSQLName("SA3")+" SA3 ON SA3.D_E_L_E_T_ = ' ' AND SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.A3_COD = SC5.C5_VEND1" + LF
	_cQry += " INNER JOIN "+RetSQLName("SC9")+" SC9 ON SC9.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = SC5.C5_FILIAL AND SC9.C9_PEDIDO = SC5.C5_NUM AND SC9.C9_BLCRED = ' '" + LF
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC9.C9_PRODUTO" + LF
	_cQry += " WHERE DAK.D_E_L_E_T_ = ' '" + LF
	_cQry += " AND DAK_FILIAL = '"+xFilial("DAK")+"'" + LF
	If (Len ( AllTrim(_cFiltro)) > 0)
		_cQry += "	AND ("+_cFiltro+")" + LF
	Else
		_cQry += " AND DAK.DAK_XBLQCP = '2'" + LF
		_cQry += " AND (DAK.DAK_XSTEXP = 'A' OR DAK.DAK_XSTEXP = 'S' OR DAK.DAK_XSTEXP = ' ')" + LF
	EndIf
	_cQry += " ORDER BY DAK.DAK_COD, DAI.DAI_PEDIDO" + LF
	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_A.SQL",_cQry)
	TcQuery _cQry New Alias "QRYDAD"
	While !QRYDAD->(EOF())
		_cCargaAtu := QRYDAD->DAK_COD
		aAdd(_aDados,{QRYDAD->DAK_COD, QRYDAD->DAK_DATA, QRYDAD->DA3_PLACA, QRYDAD->DA4_NOME, QRYDAD->A4_NOME, QRYDAD->DAK_XSTEXP, QRYDAD->DAK_XUSABE, QRYDAD->DAK_XDTABE, QRYDAD->DAK_XHRABE, QRYDAD->DAK_XUSFEC, QRYDAD->DAK_XDTFEC, QRYDAD->DAK_XHRFEC, {} , {}})
		_aAuxPed := {}
		While !QRYDAD->(EOF()) .AND. _cCargaAtu == QRYDAD->DAK_COD
			_cPedAtu := QRYDAD->C5_NUM
			aAdd(_aAuxPed, {QRYDAD->C5_NUM, QRYDAD->C5_EMISSAO, QRYDAD->A1_NOME, QRYDAD->A3_NOME, QRYDAD->C5_XOBS ,QRYDAD->DAI_SEQUEN,{}})
			_aAuxItem := {}
			While !QRYDAD->(EOF()) .AND. _cCargaAtu == QRYDAD->DAK_COD .AND. _cPedAtu == QRYDAD->C5_NUM
				aAdd(_aAuxItem,{QRYDAD->C9_PRODUTO, QRYDAD->B1_DESC, QRYDAD->C9_QTDLIB})
				QRYDAD->(dbSkip())
			EndDo
			_aAuxPed[Len(_aAuxPed),Len(_aAuxPed[Len(_aAuxPed)])] := aClone(_aAuxItem)
		EndDo
		//->Re-Indexa Pedidos
		aSort(_aAuxPed,,, { |x,y| x[6] < y[6] } )
		_aDados[Len(_aDados),Len(_aDados[Len(_aDados)])] := aClone(_aAuxPed)
	EndDo
	QRYDAD->(dbCloseArea())

	For _I := 1 To Len(_aDados)
		_cQry := " SELECT ZP1.ZP1_CODETI, ZP1.ZP1_CODPRO, SB1.B1_DESC, ZP1.ZP1_DTPROD, ZP1.ZP1_PESO, ZP1.ZP1_PALETE, ZP1.ZP1_DTCAR, ZP1.ZP1_HRCARE" + LF
		_cQry += " FROM "+RetSQLName("ZP1")+" ZP1" + LF
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = ZP1.ZP1_CODPRO" + LF
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '" + LF
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"' " + LF
		_cQry += " AND ZP1_CARGA = '"+_aDados[_I,1]+"' " + LF
		_cQry += " ORDER BY ZP1.ZP1_PALETE, ZP1.ZP1_CODETI" + LF
		MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_B.SQL",_cQry)
		TcQuery _cQry New Alias "QRYLEI"
		_aAuxLei := {}
		While !QRYLEI->(EOF())
			aAdd(_aAuxLei, {QRYLEI->ZP1_CODETI, QRYLEI->ZP1_CODPRO, QRYLEI->B1_DESC, QRYLEI->ZP1_DTPROD, QRYLEI->ZP1_PESO, QRYLEI->ZP1_DTCAR, QRYLEI->ZP1_HRCARE, QRYLEI->ZP1_PALETE})
			QRYLEI->(dbSkip())
		EndDo
		QRYLEI->(dbCloseArea())
		_aDados[_I,Len(_aDados[_I])-1] := aClone(_aAuxLei)
	Next _I

Return

/*
Funcao: bFiltrar()
Descricao: Filtra Cargas
*/
Static Function bFiltrar() 
	//DAK_XBLQCP  --> 0=Aberta;1=Bloqueada;2=Expedicao;3=Apta a Faturar;4=Faturada                                                                    
	_cFiltro := BuildExpr("DAK",,,.T.)
	IIf ((Len(AllTrim(_cFiltro)) > 0),_cFiltro += " AND DAK_XBLQCP IN ('2','3','4') ",_cFiltro += " DAK_XBLQCP IN ('2','3','4') ")
		LjMsgRun( "Processando dados, aguarde...", "Expedição", {|| bDados() } )
		fCargas()
Return

/*
Funcao: bRecomp()
Descricao: Recompor carga
*/
Static Function bRecomp()
	//Local cCarga := aCargas[oCargas:nAt,1]
	DAK->(dbSetOrder(1))
	If DAK->(dbSeek(xFilial()+cCarga)) .AND. DAK->DAK_XSTEXP == "C"
		If MsgYesNo("Deseja recompor a carga "+cCarga+" ?")
			RecLock("DAK",.F.)
			DAK->DAK_XSTEXP := "S"
			DAK->(MsUnLock())
			U_PCPRGLOG(_nTpLog,cCarga,"52","Carga:"+cCarga+" Status: Suspensa")
			If cTipoExp=='P'
				DAI->(dbSetOrder(1))
				DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
				While !DAI->(EOF()) .AND. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
					U_PCPRGLOG(_nTpLog,DAI->DAI_PEDIDO,"B2","Carga:"+cCarga+" Pedido:"+DAI->DAI_PEDIDO+" Status: Suspensa")
					DAI->(dbSkip())
				Enddo
			Endif
			LjMsgRun( "Prcessando dados, aguarde...", "Expedição", {|| bDados() } )
			fCargas()
		EndIf
	Else
		MsgStop("Carga não localizada ou status diferente de Carregando.")
		LjMsgRun( "Prcessando dados, aguarde...", "Expedição", {|| bDados() } )
		fCargas()
	EndIf
Return

/*
Funcao: bCarrega(_cOpc,_cPedido,nTipo)
Descricao: Inicia expedicao de uma carga
*/
Static Function bCarrega(_cOpc,_cPedido,nTipo)
	Private oAcao
	Private nAcao := 1
	Private oBtnFecha
	Private oBtnObs
	Private oBtnSusp
	Private oCarga
	//Private cCarga := aCargas[oCargas:nAt,1]
	Private oContador
	Private nContador := 0
	Private oDtCarga
	Private dDtCarga := CToD(aCargas[oCargas:nAt,2])
	Private oExpedi
	Private cExpedi := cUserName
	Private oIdEtiq
	Private cIdEtiq := Space(17)
	Private oLacre
	Private cLacre := Space(TamSX3("DAK_XLACRE")[1])
	Private oPlaca
	Private cPlaca := aCargas[oCargas:nAt,3]
	Private oStatusO
	Private oStatusE
	Private cStatus := ""
	Private oTransp
	Private cTransp := aCargas[oCargas:nAt,4]
	Private oZera
	//Private oProds
	Private aProds := {}
	Private oDlgReg
	Private _lFecha := .F.
	Private oTotCX
	Private nTotCX := 0
	Private oFont1 := TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private oFont2 := TFont():New("Tahoma",,044,,.T.,,,,,.F.,.F.)
	Private _lVisual := ValType(_cOpc) == "C" .AND. _cOpc == "V"
	lAbreFecha := .F.
	cCarga := aCargas[oCargas:nAt,1]
	cPedido:= Iif(cTipoExp=='P' .And. _cPedido <> Nil, _cPedido,"") //-> Em Caso de Expedicao por pedido

	DAK->(dbSetOrder(1))
	DAK->(dbSeek(xFilial()+cCarga))
	If SubStr(aCargas[oCargas:nAt,6],1,1) = "A"
		RecLock("DAK",.F.)
		DAK->DAK_XSTEXP := "C"
		DAK->DAK_XUSABE := cUserName
		DAK->DAK_XDTABE := Date()
		DAK->DAK_XHRABE := Time()
		DAK->DAK_XBLQCP	:= "2"
		DAK->DAK_XDTFEC := CToD("//")
		DAK->DAK_XHRFEC := ""
		DAK->DAK_XUSFEC := ""
		DAK->(MsUnLock())
	EndIF
	If !_lVisual

		DAK->(dbSetOrder(1))
		If !DAK->(dbSeek(xFilial()+cCarga)) .OR. DAK->DAK_FEZNF == "1"
			LjMsgRun( "Prcessando dados, aguarde...", "Expedicao", {|| bDados() } )
			fCargas()
			Return
		EndIf

		If lPedFifo //-> Habilita FIFO através dos pedidos
			aPedFifo:={}
			LjMsgRun( "Processando vencimentos, aguarde...", "Expedicao", {|| fPedFifo(cCarga,cPedido) } )
		Endif

		If DAK->DAK_FEZNF == "1"
			MsgStop("Carga ja faturada.")
			Return
		EndIf

		If DAK->DAK_XPESEN < 100
			MsgStop("Veiculo ainda não fez pesagem de entrada.")
			MsgStop("Veiculo ainda não fez pesagem de entrada.")
			Return
		EndIf

		If !(SubStr(aCargas[oCargas:nAt,6],1,1) $ "A|S|C") .AND. U_APPFUN01("Z6_PESROMA")=="S"
			If lAbreFecha := MsgYesNo("Carga ja fechada, deseja reabri-la?")
				// colocar a justificativa da reabertura.
				a:= 1 // para validar o IF! retirar quando fizer a justificativa;
				RecLock("DAK",.F.)
				DAK->DAK_XSTEXP := "C"
				DAK->DAK_XUSABE := cUserName
				DAK->DAK_XDTABE := Date()
				DAK->DAK_XHRABE := Time()
				DAK->DAK_XBLQCP	:= "2"
				DAK->DAK_XDTFEC := CToD("//")
				DAK->DAK_XHRFEC := ""
				DAK->DAK_XUSFEC := ""
				DAK->(MsUnLock())
				U_PCPRGLOG(_nTpLog,cCarga,"53","Carga:"+cCarga+" Status: Carregando")
				If cTipoExp=='P'
					U_PCPRGLOG(_nTpLog,cPedido,"B3","Carga:"+cCarga+" Status: Carregando")
				Endif
			EndIf
		ElseIf !(SubStr(aCargas[oCargas:nAt,6],1,1) $ "A|S|C") .AND. !(U_APPFUN01("Z6_PESROMA")=="S")
			MsgStop("Carga já fechada, solicite a alguém que possa abri-la.")
			Return
		EndIf
	EndIf
	LVOLTACX := .F.
	DEFINE MSDIALOG oDlgReg TITLE "Registro de Expedição" FROM 000, 000  TO 650, 1000 COLORS 0, 16777215 PIXEL

	@ 002, 002 SAY oSay1 PROMPT "Carga" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oCarga VAR cCarga SIZE 040, 010 OF oDlgReg COLORS 0, 16777215 READONLY PIXEL
	@ 002, 047 SAY oSay2 PROMPT "Data" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 010, 047 MSGET oDtCarga VAR dDtCarga SIZE 040, 010 OF oDlgReg COLORS 0, 16777215 READONLY PIXEL
	@ 002, 092 SAY oSay3 PROMPT "Expedidor" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 010, 092 MSGET oExpedi VAR cExpedi SIZE 060, 010 OF oDlgReg COLORS 0, 16777215 READONLY PIXEL
	@ 025, 002 SAY oSay4 PROMPT "Placa" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 032, 002 MSGET oPlaca VAR cPlaca SIZE 040, 010 OF oDlgReg COLORS 0, 16777215 READONLY PIXEL
	@ 025, 047 SAY oSay5 PROMPT "Transportador" SIZE 105, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 032, 047 MSGET oTransp VAR cTransp SIZE 105, 010 OF oDlgReg COLORS 0, 16777215 READONLY PIXEL

	If !_lVisual
		If nTipo==1
			nAcao:=1
		Else
			nAcao:=2
		Endif
		@ 010, 164 RADIO oAcao VAR nAcao ITEMS "Inclusão","Exclusão" SIZE 050, 030 OF oDlgReg COLOR 0, 16777215 MESSAGE "Leituras" WHEN .F. PIXEL
	EndIf

	If cTipoExp=='P' //-> Em caso de expedicao por pedidos
		@ 002, 230 SAY oSay8 PROMPT "Pedido" SIZE 050, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
		@ 010, 230 MSGET oPedido VAR cPedido SIZE 080, 018 OF oDlgReg COLORS 0, 16777215 FONT oFont1 Picture "@!" READONLY PIXEL
	Endif

	@ 002, 380 SAY oSay8 PROMPT "Total Caixas" SIZE 050, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 010, 380 MSGET oTotCX VAR nTotCX SIZE 080, 018 OF oDlgReg COLORS 0, 16777215 FONT oFont1 Picture "@E 999,999.99" READONLY PIXEL


	fProds() //-> Lista os produtos a serem carregados

	If !_lVisual
		@ 250, 002 SAY oSay6 PROMPT "Identificação" SIZE 050, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
		@ 257, 002 MSGET oIdEtiq VAR cIdEtiq SIZE 075, 010 OF oDlgReg VALID {|| iif(!Empty(AllTrim(cIdEtiq)),Eval({ || bValEtiq(cCarga, cPedido, cIdEtiq),oIdEtiq:SetFocus()}),.t.)} COLORS 0, 16777215 PIXEL

		@ 286, 001 SAY oSay7 PROMPT "Contador" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
		@ 272, 028 MSGET oContador VAR nContador SIZE 060, 033 OF oDlgReg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 281, 103 BUTTON oZera PROMPT "Zera" SIZE 020, 020 OF oDlgReg ACTION bZera() PIXEL

		@ 250, 160 BUTTON oBtnSusp PROMPT "Suspender Carga" SIZE 050, 012 OF oDlgReg ACTION bSusp() PIXEL
		@ 265, 160 BUTTON oBtnObs PROMPT "Obs.Carga" SIZE 050, 012 OF oDlgReg ACTION bObs() PIXEL
		@ 280, 160 BUTTON oBtnFecha PROMPT "Fecha Carga" SIZE 050, 012 OF oDlgReg ACTION bFecha() PIXEL
		@ 305, 160 BUTTON oBtnImp PROMPT "Importa Leituras" SIZE 050, 012 OF oDlgReg ACTION bImporta() PIXEL
	EndIf
	@ 310, 003 SAY oSay9 PROMPT "Lacre:" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 310, 022 MSGET oLacre VAR cLacre SIZE 125, 010 OF oDlgReg COLORS 0, 16777215 When !_lVisual PIXEL
	If !_lVisual
		oIdEtiq:SetFocus()
		oAcao:bChange := {|| oIdEtiq:SetFocus()}
	EndIf

	@ 250, 215 GET oStatusO VAR cStatus OF oDlgReg MULTILINE SIZE 282, 070 COLORS 0, 65280 FONT oFont1 READONLY HSCROLL PIXEL
	@ 250, 215 GET oStatusE VAR cStatus OF oDlgReg MULTILINE SIZE 282, 070 COLORS 0, 65280 FONT oFont1 READONLY HSCROLL PIXEL
	oStatusE:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oStatusO:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")

	oStatusO:Hide()
	oStatusE:Hide()

	ACTIVATE MSDIALOG oDlgReg CENTERED VALID bValFecha()

Return

/*
Funcao: fProds()
Descricao: Lista um produto de uma carga
*/
Static Function fProds()
	Local _cQry := ""

	If oProds == Nil  //-------> retirei para forçar ele ser refeito.
		aProds := {}
		nContador := 0
		nTotCX := 0

		_cQry += " SELECT C9_PRODUTO CODIGO, B1_DESC PRODUTO"
		_cQry += " , CAIXASPED, ISNULL(CAIXASEXP,0) CAIXASEXP, CAIXASPED - ISNULL(CAIXASEXP,0) CAXASDIF"
		_cQry += " , PESOPED, ISNULL(PESOEXP,0) PESOEXP"
		_cQry += " FROM ("
		_cQry += " 	SELECT DAK_FILIAL, DAK.DAK_COD, SC9.C9_PRODUTO, SB1.B1_DESC"
		_cQry += " 	, SUM(CASE "
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB/SB1.B1_CONV"
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB" //*SB1.B1_CONV
		_cQry += " 		ELSE 0 END) CAIXASPED"
		_cQry += " 	, SUM(CASE "
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' THEN SC9.C9_QTDLIB"
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' THEN SC9.C9_QTDLIB*SB1.B1_CONV"
		_cQry += " 		ELSE 0 END) PESOPED"
		//_cQry += " 	, SUM(SC9.C9_QTDLIB) PESOPED"
		_cQry += " 	FROM "+RetSQLName("DAK")+" DAK"
		_cQry += " 	INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI.D_E_L_E_T_ = ' ' AND DAI.DAI_FILIAL = DAK_FILIAL AND DAI.DAI_COD = DAK.DAK_COD"
		If cTipoExp=='P' //->Em caso de espedicao por pedido
			_cQry += " AND DAI.DAI_PEDIDO='"+cPedido+"' "
		Endif
		_cQry += " 	INNER JOIN "+RetSQLName("SC9")+" SC9 ON SC9.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = DAI.DAI_FILIAL AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' '"
		_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC9.C9_PRODUTO"
		_cQry += " 	WHERE DAK.D_E_L_E_T_ = ' '"
		_cQry += " 	GROUP BY DAK_FILIAL, DAK.DAK_COD, SC9.C9_PRODUTO, SB1.B1_DESC"
		_cQry += " ) A"
		_cQry += " LEFT JOIN ("
		_cQry += " 	SELECT ZP1.ZP1_FILIAL, ZP1.ZP1_CARGA, ZP1.ZP1_CODPRO"
		_cQry += " 	, SUM(CASE "
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN ZP1.ZP1_PESO/SB1.B1_CONV"
		_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN ZP1.ZP1_PESO/SB1.B1_CONV"
		_cQry += " 		ELSE 0 END) CAIXASEXP"
		_cQry += " 	, SUM(ZP1.ZP1_PESO) PESOEXP"
		_cQry += " 	FROM "+RetSQLName("ZP1")+" ZP1"
		_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = ZP1.ZP1_CODPRO"
		_cQry += " 	WHERE ZP1.D_E_L_E_T_ = ' '"
		If cTipoExp=='P' //->Em caso de espedicao por pedido
			_cQry += " AND ZP1.ZP1_PEDIDO='"+cPedido+"' "
		Endif
		_cQry += " 	GROUP BY ZP1.ZP1_FILIAL, ZP1.ZP1_CARGA, ZP1.ZP1_CODPRO"
		_cQry += " ) B ON B.ZP1_FILIAL = A.DAK_FILIAL AND B.ZP1_CARGA = A.DAK_COD AND B.ZP1_CODPRO = A.C9_PRODUTO"
		_cQry += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"'"
		_cQry += " AND DAK_COD = '"+cCarga+"'"
		_cQry += " ORDER BY 1"
		MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_C.SQL",_cQry)
		TcQuery _cQry New Alias "QRYPRD"

		While !QRYPRD->(EOF())
			aAdd(aProds,{;
			QRYPRD->CODIGO,;
			QRYPRD->PRODUTO,;
			Transform(QRYPRD->CAIXASPED,PesqPict("SC9","C9_QTDLIB")),;
			Transform(QRYPRD->CAIXASEXP,PesqPict("SC9","C9_QTDLIB")),;
			Transform(QRYPRD->CAXASDIF,PesqPict("SC9","C9_QTDLIB")),;
			Transform(QRYPRD->PESOPED,PesqPict("SC9","C9_QTDLIB")),;
			Transform(QRYPRD->PESOEXP,PesqPict("SC9","C9_QTDLIB"));
			})
			nContador += QRYPRD->CAIXASEXP
			nTotCX += QRYPRD->CAIXASPED
			QRYPRD->(dbSkip())
		EndDo
		QRYPRD->(dbCloseArea())

		If Len(aProds) <= 0
			aAdd(aProds,{"","","","","","",""})
		EndIF
		//TCBrowse():New( [ nRow ], [ nCol ], [ nWidth ], [ nHeight ], [ bLine ]                                                                                                                                     , [ aHeaders ]                                                                                      , [ aColSizes ]           , [ oWnd ], [ cField ]    , [ uValue1 ]    , [ uValue2 ]    , [ bChange ]    , [ bLDblClick ]           , [ bRClick ]    , [ oFont ]    , [ oCursor ]     , [ nClrFore ]    , [ nClrBack ]    , [ cMsg ]                                            , [ uParam20 ]    , [ cAlias ]    , [ lPixel ], [ bWhen ]       , [ uParam24 ]    , [ bValid ]   , [ lHScroll ], [ lVScroll ] )
		oProds := TCBrowse():New(048, 002, 495, 200,,{"Cód.","Produto","Emb. Pedidas","Emb. Expedidas","Diferença Emb.","Peso Pedido","Peso Expedido"},{25,200,45,45,45,45,45},oDlgReg,,,,,{||},,,,,,,,,.T.,,.F.,,, )
		//	oProds := TCBrowse():New( 048, 002, 495, 200, , {"","Cód.","Produto","Emb. Pedidas","Emb. Expedidas","Diferença Emb.","Peso Pedido","Peso Expedido"}, {20,25,200,45,45,45,45,45}, oDlgReg, /*[ cField ]*/, /*[ uValue1 ]*/, /*[ uValue2 ]*/, /*[ bChange ]*/, {|| oProds:DrawSelect()}, /*[ bRClick ]*/, /*[ oFont ]*/, /*[ oCursor ]*/, /*[ nClrFore ]*/, /*[ nClrBack ]*/, "Representação de como está sendo efetuada a carga.", /*[ uParam20 ]*/, /*[ cAlias ]*/, .T.       , /*[ bWhen ] */ , /*[ uParam24 ]*/, /*[ bValid ]*/, .t.         , .t.         )

		//	@ 048, 002 LISTBOX oProds Fields HEADER "Cód.","Produto","Emb. Pedidas","Emb. Expedidas","Diferença Emb.","Peso Pedido","Peso Expedido" SIZE 495, 200 OF oDlgReg PIXEL ColSizes 25,200,45,45,45,45,45
	EndIf
	oProds:SetArray(aProds)

	oProds:bLine := {|| {;
	aProds[oProds:nAt,1],;
	aProds[oProds:nAt,2],;
	aProds[oProds:nAt,3],;
	aProds[oProds:nAt,4],;
	aProds[oProds:nAt,5],;
	aProds[oProds:nAt,6],;
	aProds[oProds:nAt,7];
	}}
	oProds:bLDblClick := {|| oProds:DrawSelect()}

	oProds:Refresh()
	/*
	oContador
	oContador:Refresh()
	*/
Return

/*
Funcao: fPedExp()
Descricao: Verifica se sequencia de carga esta sendo seguida
_cOrig == 'P' -> Pedido
_cOrig == 'C' -> Pedido + Produto
*/
Static Function fPedExp(_cOrig, nTipo ,_cPedido ,_cCarga ,_cProduto)
	Local _cQry 	:= ""
	Local _lPedOk	:= .T.

	If EmpTy(AllTrim(_cPedido))
		Alert("Pedido Inválido.")
		Return .F.
	Endif
	_cQry += " SELECT "
	If lSeqProd //->Sequencia por produto
		_cQry += " TOP 1 DAI_PEDIDO, C9_XSEQUEN SEQ, C9_PRODUTO"
	Else
		_cQry += " TOP 1 DAI_PEDIDO, DAI_SEQUEN SEQ"
	Endif
	_cQry += " ,ROUND(CAIXASPED,0,1) CAIXASPED, ISNULL(ROUND(CAIXASEXP,0,1),0) CAIXASEXP"
	_cQry += " ,ROUND(CAIXASPED,0,1) - ISNULL(ROUND(CAIXASEXP,0,1),0) CAXASDIF"
	_cQry += " ,ROUND(PESOPED,2) PESOPED, ISNULL(ROUND(PESOEXP,2),0) PESOEXP"
	_cQry += " FROM ( "
	_cQry += " 	SELECT DAK_FILIAL, DAK.DAK_COD, DAI_PEDIDO, DAI_SEQUEN, SC9.C9_XSEQUEN, SC9.C9_PRODUTO, SB1.B1_DESC"
	_cQry += " 	, SUM(CASE "
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB/SB1.B1_CONV"
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB" //*SB1.B1_CONV
	_cQry += " 		ELSE 0 END) CAIXASPED"
	_cQry += " 	, SUM(CASE "
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' THEN SC9.C9_QTDLIB"
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' THEN SC9.C9_QTDLIB*SB1.B1_CONV"
	_cQry += " 		ELSE 0 END) PESOPED"
	_cQry += " 	FROM "+RetSQLName("DAK")+" DAK"
	_cQry += " 	INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI.D_E_L_E_T_ = ' ' AND DAI.DAI_FILIAL = DAK_FILIAL AND DAI.DAI_COD = DAK.DAK_COD"
	_cQry += " 	INNER JOIN "+RetSQLName("SC9")+" SC9 ON SC9.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = DAI.DAI_FILIAL AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO AND SC9.C9_BLCRED = ' ' "
	_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC9.C9_PRODUTO"
	_cQry += " 	WHERE DAK.D_E_L_E_T_ = ' '"
	_cQry += " 	GROUP BY DAK_FILIAL, DAK.DAK_COD, DAI_PEDIDO, DAI_SEQUEN, SC9.C9_XSEQUEN, SC9.C9_PRODUTO, SB1.B1_DESC"
	_cQry += " ) A"
	_cQry += " LEFT JOIN ("
	_cQry += " 	SELECT ZP1.ZP1_FILIAL, ZP1.ZP1_CARGA, ZP1.ZP1_PEDIDO, ZP1.ZP1_CODPRO"
	_cQry += " 	, SUM(CASE "
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN ZP1.ZP1_PESO/SB1.B1_CONV"
	_cQry += " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN ZP1.ZP1_PESO/SB1.B1_CONV"
	_cQry += " 		ELSE 0 END) CAIXASEXP"
	_cQry += " 	, SUM(ZP1.ZP1_PESO) PESOEXP"
	_cQry += " 	FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = ZP1.ZP1_CODPRO"
	_cQry += " 	WHERE ZP1.D_E_L_E_T_ = ' '"
	/*If lSeqProd .And. !_cProduto == Nil .And. !Empty(AllTrim(_cProduto)) //->Sequencia por produto
	//	_cQry += " 	AND ZP1.ZP1_CODPRO = '"+C9_PRODUTO+"'"
	//Endif*/
	_cQry += " 	GROUP BY ZP1.ZP1_FILIAL, ZP1.ZP1_CARGA, ZP1.ZP1_PEDIDO, ZP1.ZP1_CODPRO"
	_cQry += " ) B ON B.ZP1_FILIAL = A.DAK_FILIAL AND B.ZP1_CARGA = A.DAK_COD AND B.ZP1_CODPRO = A.C9_PRODUTO"
	If cTipoExp=='P' .And. !lSeqProd //->Em caso de espedicao por pedido
		_cQry += " AND B.ZP1_PEDIDO=A.DAI_PEDIDO "
	Endif
	_cQry += " WHERE DAK_FILIAL = '"+xFilial("DAK")+"'"
	_cQry += " AND DAK_COD = '"+_cCarga+"'"
	_cQry += " AND (ROUND(CAIXASPED,0,1) - ISNULL(ROUND(CAIXASEXP,0,1),0)) > 0 "
	If lSeqProd //->Sequencia por produto
		_cQry += " ORDER BY C9_XSEQUEN ASC "
	Else
		_cQry += " ORDER BY DAI_SEQUEN ASC "
	Endif
	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"fPedExp.sql",_cQry)

	TcQuery _cQry New Alias "QRYPRD"

	While !QRYPRD->(EOF())
		/* Sequencia por pedido */
		If QRYPRD->DAI_PEDIDO <> _cPedido .And. !lSeqProd
			_cMens:="SEQUENCIA POR PEDIDO"+chr(10)+chr(13)
			_cMens+="Origem: "+_cOrig+chr(10)+chr(13)
			_cMens+="Este pedido esta fora da sequencia de carregamento. "+chr(10)+chr(13)
			_cMens+="A sequencia de carregamento obedece a ordem de sequencia "+chr(10)+chr(13)
			_cMens+="de entrega da carga associado aos pedidos que ainda tem "+chr(10)+chr(13)
			_cMens+="caixas a serem expedidas. "+chr(10)+chr(13)
			_cMens+="Carga: ["+_cCarga+"] "+chr(10)+chr(13)
			_cMens+="Pedido Selecionado: ["+_cPedido+"] "+chr(10)+chr(13)
			_cMens+="Pedido na sequência: ["+QRYPRD->DAI_PEDIDO+"] "+chr(10)+chr(13)
			//_cMens+="Sequencia: ["+QRYPRD->DAI_SEQUEN+"]"+chr(10)+chr(13)
			If nTipo==3 //->Exclusao
				_cMens+="Deseja abrir mesmo assim?"
				If !MsgBox(_cMens,"Atencao","YESNO")
					_lPedOk:=.F.
				Endif
			Else
				Alert(_cMens)
				_lPedOk:=.F.
			Endif
		Elseif lSeqProd .And. _cOrig == 'P' //-> Sequencia por produto / Analisando o pedido
			If QRYPRD->DAI_PEDIDO <> _cPedido
				_cMens:="SEQUENCIA POR PRODUTO"+chr(10)+chr(13)
				_cMens+="Origem: "+_cOrig+chr(10)+chr(13)
				_cMens+="Este pedido esta fora da sequencia de carregamento. "+chr(10)+chr(13)
				_cMens+="A sequencia de carregamento obedece a ordem de sequencia "+chr(10)+chr(13)
				_cMens+="de entrega da carga associado aos pedidos que ainda tem "+chr(10)+chr(13)
				_cMens+="caixas a serem expedidas. "+chr(10)+chr(13)
				_cMens+="Carga: ["+_cCarga+"] "+chr(10)+chr(13)
				_cMens+="Pedido Selecionado: ["+_cPedido+"] "+chr(10)+chr(13)
				_cMens+="Pedido na sequência: ["+QRYPRD->DAI_PEDIDO+"] "+chr(10)+chr(13)
				If nTipo==3 //->Exlusao
					_cMens+="Deseja abrir mesmo assim?"
					If !MsgBox(_cMens,"Atencao","YESNO")
						_lPedOk:=.F.
					Endif
				Else
					Alert(_cMens)
					_lPedOk:=.F.
				Endif
			Endif
		Elseif lSeqProd .And. _cOrig == 'C' //-> Sequencia por produto / Analisando o pedido
			If QRYPRD->DAI_PEDIDO <> _cPedido .Or. QRYPRD->C9_PRODUTO <> _cProduto
				_cMens:="SEQUENCIA POR PRODUTO"+chr(10)+chr(13)
				_cMens+="Origem: "+_cOrig+chr(10)+chr(13)
				_cMens+="Este pedido ou produto esta fora da sequencia de carregamento. "+chr(10)+chr(13)
				_cMens+="A sequencia de carregamento obedece a ordem de sequencia "+chr(10)+chr(13)
				_cMens+="de entrega da carga associado aos pedidos que ainda tem "+chr(10)+chr(13)
				_cMens+="caixas a serem expedidas. "+chr(10)+chr(13)
				_cMens+="Carga: ["+_cCarga+"] "+chr(10)+chr(13)
				_cMens+="Pedido Selecionado: ["+_cPedido+"] "+chr(10)+chr(13)
				_cMens+="Pedido na sequência: ["+QRYPRD->DAI_PEDIDO+"] "+chr(10)+chr(13)
				_cMens+= Replicate("=",50) +chr(10)+chr(13)
				_cMens+="Produto da Sequência: ["+QRYPRD->C9_PRODUTO+"] "+chr(10)+chr(13)
				_cMens+="Descricao: ["+ AllTrim(Posicione("SB1",1,XFILIAL("SB1") + QRYPRD->C9_PRODUTO,"B1_DESC")) +"] "+chr(10)+chr(13)
				_cMens+="Sequência do Produto: ["+QRYPRD->SEQ+"]"+chr(10)+chr(13)
				If nTipo==3 //->Exlusao
					_cMens+="Deseja abrir mesmo assim?"
					If !MsgBox(_cMens,"Atenção","YESNO")
						_lPedOk:=.F.
					Endif
				Else
					Alert(_cMens)
					_lPedOk:=.F.
				Endif
			Endif
		Endif
		QRYPRD->(dbSkip())
	EndDo
	QRYPRD->(dbCloseArea())
Return(_lPedOk)

/*
Funcao: fCarQtd()
Descricao: Retorna quantidade de registros lidos
*/
Static Function fCarQtd(_cCarga,_cPedido)
	Local _cQry 	:= ""
	Local _nRet	:= 0
	_cQry += " SELECT COUNT(*) QTDREG "
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 "
	_cQry += " WHERE ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CARGA = '"+_cCarga+"' "
	_cQry += " AND ZP1_PEDIDO = '"+_cPedido+"' "
	_cQry += " AND D_E_L_E_T_ = ' ' "
	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_D.SQL",_cQry)
	TcQuery _cQry New Alias "QRYPRD"
	If !QRYPRD->(EOF())
		_nRet:=QRYPRD->QTDREG
	Endif
	QRYPRD->(dbCloseArea())
Return(_nRet)

/*
Funcao: bZera()
Descricao: Zera contador
*/
Static Function bZera()
	cIdEtiq := Space(17)
	oIdEtiq:Refresh()
	oIdEtiq:SetFocus()
	nContador := 0
	oContador:Refresh()
	oIdEtiq:SetFocus()
Return

Static Function bValFecha()
	If _lVisual
		_lFecha := .T.
	Else
		If _lFecha
			LjMsgRun( "Processando dados, aguarde...", "Expedição", {|| bDados() } )
			fCargas()
		EndIf
	EndIf
Return(_lFecha)

Static Function bSusp()
	cIdEtiq := Space(17)
	oIdEtiq:Refresh()
	RecLock("DAK",.F.)
	DAK->DAK_XSTEXP := "S"
	DAK->(MsUnLock())
	U_PCPRGLOG(_nTpLog,cCarga,"52","Carga:"+cCarga+" Status: Suspensa")
	If cTipoExp=='P'
		DAI->(dbSetOrder(1))
		DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
		While !DAI->(EOF()) .AND. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
			U_PCPRGLOG(_nTpLog,DAI->DAI_PEDIDO,"B2","Status Carga: Suspensa")
			DAI->(dbSkip())
		Enddo
	Endif

	_lFecha := .T.
	oDlgReg:End()
Return

Static Function bFecha()
	Local _cQry := ""
	Local _aProds := {}
	Local _nPos := 0
	Local _nCaixas := 0
	Local _nPeso := 0
	Local _cFATPBPC	:= GetNewPar("MV_FATPBPC","B1_PESBRU") //-> Campo de media para peso Bruto

	If Len(AllTrim(cLacre)) <= 0
		MsgStop("Preencha o lacre.")
		Return
	EndIf

	_cQry += " SELECT ZP1_CODPRO, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+DAK->DAK_FILIAL+"' "
	_cQry += " AND ZP1_CARGA = '"+DAK->DAK_COD+"' "
	_cQry += " GROUP BY ZP1_CODPRO"
	_cQry += " ORDER BY ZP1_CODPRO"
	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_F.SQL",_cQry)
	If Select("QRYF") > 0
		QRYF->(dbCloseArea())
	Endif
	TcQuery _cQry New Alias "QRYF"
	While !QRYF->(EOF())
		aAdd(_aProds,{QRYF->ZP1_CODPRO,QRYF->QTDCAIXA,QRYF->PESO})
		QRYF->(dbSkip())
	EndDo
	QRYF->(dbCloseArea())

	If MsgYesNo("Confirma o fechamento da carga?")
		Begin Transaction
			//TCCommit(1) // Inicia a Transação
			RecLock("DAK",.F.)
			DAK->DAK_XBLQCP	:= "3"
			DAK->DAK_VALOR 	:= 0
			DAK->DAK_PESO 	:= 0
			DAK->DAK_XLACRE := cLacre
			DAK->DAK_XUSFEC := cUserName
			DAK->DAK_XDTFEC := Date()
			DAK->DAK_XHRFEC := Time()
			DAI->(dbSetOrder(1))
			DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
			While !DAI->(EOF()) .AND. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
				If _cPCPAJPD == "PCP"
					SC5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial()+DAI->DAI_PEDIDO))
						RecLock("SC5",.F.)
						SC5->C5_VOLUME1	:= 0
						SC5->C5_PBRUTO	:= 0
						SC5->C5_PESOL	:= 0

						SC6->(dbSetOrder(1))
						SC9->(dbSetOrder(1))
						SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
						While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
							_nCaixas := 0
							_nPeso := 0
							If (_nPos := aScan(_aProds,{|x| x[1] = SC6->C6_PRODUTO})) > 0 .AND. _aProds[_nPos,2] > 0
								SB1->(dbSeek(xFilial()+SC6->C6_PRODUTO))
								If _aProds[_nPos,3] >= SC6->C6_QTDVEN
									_nPeso := SC6->C6_QTDVEN
								Else
									_nPeso := _aProds[_nPos,3]
								EndIf
								_nCaixas := ConvUM(SB1->B1_COD, _nPeso, 0, 2)
								_aProds[_nPos,2] -= _nCaixas
								_aProds[_nPos,3] -= _nPeso

								RecLock("SC6",.F.)
								SC6->C6_QTDVEN 	:= _nPeso
								SC6->C6_UNSVEN 	:= _nCaixas
								SC6->C6_VALOR 	:= _nPeso*SC6->C6_PRCVEN
								SC6->(MsUnLock())
								//SC6->(TCCommit())
								//Totaliza valor e peso da carga
								DAK->DAK_VALOR 	+= SC6->C6_VALOR
								DAK->DAK_PESO 	+= _nPeso

								//Totaliza volumes e pesos no cabecalho do pedido
								SC5->C5_VOLUME1	+= _nCaixas
								SC5->C5_PBRUTO	+= _nPeso*SB1->&_cFATPBPC
								SC5->C5_PESOL		+= _nPeso
							EndIf
							If SC9->(dbSeek(xFilial()+SC6->(C6_NUM+C6_ITEM)))
								RecLock("SC9",.F.)
								If _nPeso > 0
									SC9->C9_QTDLIB := _nPeso
								Else
									SC9->(dbDelete())
								EndIf
								SC9->(MsUnLock())
								//SC9->(TCCommit())
							EndIf
							SC6->(dbSkip())
						EndDo
						SC5->(MsUnLock())
						//SC5->(TCCommit())
					EndIf
				Else
					SC5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial()+DAI->DAI_PEDIDO))
						SC6->(dbSetOrder(1))
						SC6->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))
						While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM)
							SB1->(dbSeek(xFilial()+SC6->C6_PRODUTO))
							_nPeso		:= SC6->C6_QTDVEN
							_nCaixas 	:= ConvUM(SB1->B1_COD, _nPeso, 0, 2)
							DAK->DAK_VALOR 	+= SC6->C6_VALOR
							DAK->DAK_PESO 	+= _nPeso
							SC6->(dbSkip())
						EndDo
					Endif
				Endif
				DAI->(dbSkip())
			EndDo
			DAK->(MsUnLock())
		End Transaction

		U_PCPRGLOG(_nTpLog,cCarga,"54","Status Apta a Faturar / Lacre: "+DAK->DAK_XLACRE)
		If cTipoExp=='P'
			DAI->(dbSetOrder(1))
			DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
			While !DAI->(EOF()) .AND. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
				U_PCPRGLOG(_nTpLog,DAI->DAI_PEDIDO,"B2","Status Apta a Faturar / Lacre: "+DAK->DAK_XLACRE)
				DAI->(dbSkip())
			Enddo
		Endif
		//If lAbreFecha
		RecLock("DAK",.F.)
		DAK->DAK_XSTEXP := "F"
		DAK->DAK_XBLQCP := "3"
		DAK->(MsUnLock())
		U_PCPRGLOG(_nTpLog,cCarga,"55","Status Carga: Finalizada")

		If cTipoExp=='P'
			DAI->(dbSetOrder(1))
			DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
			While !DAI->(EOF()) .AND. DAI->(DAI_FILIAL+DAI_COD) == DAK->(DAK_FILIAL+DAK_COD)
				U_PCPRGLOG(_nTpLog,DAI->DAI_PEDIDO,"B5","Status Carga: Finalizada")
				DAI->(dbSkip())
			Enddo
		Endif
		//EndIf
		_lFecha := .T.
		oDlgReg:End()
	EndIf

Return

/*
Funcao: bValEtiq()
Descricao: Valida Etiqueta Lida
*/
Static Function bValEtiq(cCarga, cPedido, cIdEtiq)
	Local _lRet 	:= .T.
	Local _nPos 	:= 0
	Local _aPalete  := {}
	Local _lPalete  := .F.
	Local _I 		:= 0
	Local cCodLog	:=""
	Local _lachou 	:= .F.
	Local lPula 	:= .T.
	Local __lpal 	:= .f.
	Local xAliasTMP	:= GetNextAlias()
	LVOLTACX		:= .F.
	cStatus 		:= ""

	_cEtiq 	:= Upper(SubStr(cIdEtiq,1,16))

	If Len(AllTrim(_cEtiq)) <= 0
		Return .t.
	EndIf

	/*
	//->Valida Enderecamento
	If !U_GTOWMSVEE(_cEtiq)
	cStatus := "Etiqueta enderecada, impossivel movimentacoes."
	bMsgStat()
	Return(.F.)
	Endif
	*/
	If SubStr(_cEtiq,1,2) == "90"
		ZP4->(dbSetOrder(1))
		ZP4->(dbSeek(xFilial()+_cEtiq))
		__lpal := .T.
	Else
		ZP1->(dbsetorder(1))
		ZP1->(dbSeek(xFilial()+_cEtiq))
		__lpal := .F.
	EndIF
	If __lpal ///// se pallet
		if ZP4->ZP4_STATUS # "F" .AND. nAcao == 1 //ZP4_STATUS --> M=Montando;S=Suspenso;F=Fechado;C=Carregado;E=Expedido
			cStatus := "Pallet não permitido!"+chr(13)+chr(10)+;
			"Status: ["+ZP4->ZP4_STATUS+" - "+iif(ZP4->ZP4_STATUS = "M","Montando",;
			iif(ZP4->ZP4_STATUS = "S","Suspenso",;
			iif(ZP4->ZP4_STATUS = "F","Fechado",;
			iif(ZP4->ZP4_STATUS = "C","Carregado",;
			iif(ZP4->ZP4_STATUS = "E","Expedido",;
			" -- X -- " )))))+"]"+chr(13)+chr(10)
		EndIF

		if (AllTrim(ZP4->ZP4_ENDWMS) # '' .and. ZP4->ZP4_STATUS = 'F') .AND. nAcao == 1
			cStatus := "Pallet não permitido!"+chr(13)+chr(10)+;
			"Ainda contém endereço"+chr(13)+chr(10)+;
			"Endereço: "+ZP4->ZP4_ENDWMS+chr(13)+chr(10)+;
			"Status: "+ZP4->ZP4_STATUS+chr(13)+chr(10)
		EndIF

		if (AllTrim(ZP4->ZP4_CARGA) # '' .and. ZP4->ZP4_STATUS = 'F') .AND. nAcao == 1
			cStatus := "Pallet não permitido!"+chr(13)+chr(10)+;
			"Já foi carregado"+chr(13)+chr(10)+;
			"Nº da Carga: "+ZP4->ZP4_CARGA+chr(13)+chr(10)+;
			"Status: "+ZP4->ZP4_STATUS+chr(13)+chr(10)
		EndIF

		if AllTrim(ZP4->ZP4_CARGA) = ''  .AND. nAcao == 2
			cStatus := "Pallet não permitido!"+chr(13)+chr(10)+;
			"Já foi excluído da carga/ou não tem carga relacionada."
		EndIF
		If (aScan(aProds,{|x| x[1] = ZP4->ZP4_PRODUT})) <= 0
			cStatus := "Pallet não permitido!"+chr(13)+chr(10)+;
			"Produto não está na carga."
		EndIf

	EndIF
	If !(__lpal) ///// se CAIXA
		if AllTrim(ZP1->ZP1_CARGA) # ''  .AND. nAcao == 1
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Já existe carga --> ["+AllTrim(ZP1->ZP1_CARGA)+"]"
		EndIf
		if AllTrim(ZP1->ZP1_CARGA) = ''  .AND. nAcao == 2
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Já foi excluída da carga/ou não tem carga relacionada."
		EndIf
		If AllTrim(ZP1->ZP1_PEDIDO) # ''  .AND. nAcao == 1
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Já existe pedido --> ["+AllTrim(ZP1->ZP1_PEDIDO)+"]"
		EndIF
		if ZP1->ZP1_STATUS # '2'  .AND. nAcao == 1
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Seu Status não é 2 --> ["+AllTrim(ZP1->ZP1_STATUS)+"]"+chr(13)+chr(10)+;
			IIf(AllTrim(ZP1->ZP1_STATUS) =='3',"Já foi carregada na carga --> ["+AllTrim(ZP1->ZP1_CARGA)+"]",;
			iif(AllTrim(ZP1->ZP1_STATUS) =='9',"Caixa Suspensa",;
			iif(AllTrim(ZP1->ZP1_STATUS) =='5',"Etiqueta Baixada em Estoque","")))
		EndIF
		if	ZP1->ZP1_LOCAL # '10'  .AND. nAcao == 1
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Seu armazém não é o 10 --> ["+AllTrim(ZP1->ZP1_LOCAL)+"]"
		EndIF
		if AllTrim(ZP1->ZP1_ENDWMS) # '' .AND. nAcao == 1
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Está endereçado. --> ["+AllTrim(ZP1->ZP1_ENDWMS)+"]"
		EndIF
		If (aScan(aProds,{|x| x[1] = ZP1->ZP1_CODPRO})) <= 0
			cStatus := "Caixa não permitida!"+chr(13)+chr(10)+;
			"Produto não está na carga."
		EndIf

	EndIf
	If Empty(cStatus) .and. !(Empty(AllTrim(_cEtiq)))
		Begin Transaction
			If SubStr(_cEtiq,1,2) == "90" //-> Palete
				_lPalete := .T.
				ZP4->(dbSetOrder(1))
				If (_lachou := ZP4->(dbSeek(xFilial()+_cEtiq)))
					_nPos := aScan(aProds, {|x| x[1] == ZP4->ZP4_PRODUT})
					If nAcao == 1 .AND. ZP4->ZP4_CARGA == cCarga
						cStatus := "Pallet já lido nesta carga"
					ElseIf nAcao == 2 .AND. ZP4->ZP4_CARGA <> cCarga
						cStatus := "Pallet não pertence a esta carga - a2"
					ElseIf nAcao == 1 .AND. Len(AllTrim(ZP4->ZP4_CARGA)) > 0
						cStatus := "Pallet já está em outra carga ["+ZP4->ZP4_CARGA+"]"
					ElseIf nAcao == 1 .AND. _nPos > 0 .AND. (bStrToVal(aProds[_nPos,5]) - ZP4->ZP4_CONTAD) < 0
						cStatus := "A quantidade de caixas deste pallet ultrapassa a quantidade da carga"
					ElseIf !(EMPTY(ZP4->ZP4_ENDWMS))
						cStatus := "Este pallet não foi desendereçado."
						_lachou := .f.
					EndIf
				Else
					cStatus := "Etiqueta Invalida"
				EndIf
				cPalet := ZP4->ZP4_PALETE
			Else
				_lPalete := .F.
				lPula := .T.
				ZP1->(dbsetorder(1))
				_lachou := ZP1->(dbSeek(xFilial()+_cEtiq))
				cPalet := ZP1->ZP1_PALETE
				If nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga
					cStatus := "Esta caixa não consta nesta carga - a   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"] - b2"
					lPula := .F.
				EndIf
				IF nAcao == 2 .AND. AllTrim(ZP1->ZP1_CARGA) = cCarga  .and. (SubStr(aCargas[oCargas:nAt,6],1,1) $ "F|S")
					fVoltaCxa(_cEtiq)
					cIdEtiq := Space(17)
					oIdEtiq:Refresh()
					oIdEtiq:SetFocus()
					cStatus := "Caixa Excluída"
					bMsgStat()
					cIdEtiq := Space(17)
					oIdEtiq:Refresh()
					oIdEtiq:SetFocus()
					oLeituras:Refresh()
					lPula := .F.
					_lachou := .F.
					LVOLTACX := .T.
				EndIF
				If lPula
					ZP4->(dbsetorder(1))
					_OldPall := ZP1->ZP1_PALETE
					If (_lachou := ZP4->(dbSeek(xFilial()+ZP1->ZP1_PALETE)).and. ZP4->ZP4_STATUS = 'F' )
						If nAcao == 1 .AND. ZP1->ZP1_CARGA = cCarga  .and. lAbreFecha
							cStatus := "Esta caixa já foi lida anteriormente para esta carga-a"
						ElseIf nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga  .and. lAbreFecha
							cStatus := "Esta caixa não consta nesta carga - b   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"]"
						ElseIf nAcao == 1 .AND. Len(AllTrim(ZP1->ZP1_CARGA)) > 0  .and. lAbreFecha
							cStatus := "Esta caixa já esta em outra carga ["+ZP1->ZP1_CARGA+"]"
						ElseIf !(EMPTY(ZP1->ZP1_ENDWMS))  .and. lAbreFecha
							cStatus := "Esta caixa não foi desendereçada."
							_lachou := .f.
						ElseIf nAcao == 1 .AND. ZP1->ZP1_STATUS # '2'
							cStatus := "Esta caixa, não está com o Status 'em carregamento.'."
						EndIf
						If Len(cStatus) <= 0 .and. nAcao == 1
							iif(Empty(Alltrim(cPedido)),cPedido := aPedidos[oPedidos:nAt,1],cPedido := cPedido)
							Reclock("ZP4",.F.)
							ZP4_CONTAD := (ZP4->ZP4_CONTAD-1)
							ZP4_CODEST := (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
							/*
							ZP4_USFECH 	:= cUserName
							ZP4_DTFECH 	:= DATE()
							ZP4_HRFECH 	:= TIME()
							*/
							MsUnLock()
							If ZP4->ZP4_CONTAD == 0
								Reclock("ZP4",.F.)
								ZP4->(DbDelete())
								MsUnLock()
							EndIf
							ZP1->(dbSetOrder(1))
							If ZP1->(dbseek(xfilial()+_cEtiq))
								_nPos := aScan(aProds,{|x| x[1] = ZP1->ZP1_CODPRO})
								Reclock("ZP1",.F.)
								ZP1->ZP1_PALETE := ""
								ZP1->ZP1_STATUS := "3"
								ZP1->ZP1_CARGA  := cCarga
								ZP1->ZP1_PEDIDO := cPedido := pedido(cCarga, ZP1->ZP1_CODPRO, cPedido)
								ZP1->ZP1_DTCAR	:= Date()
								ZP1->ZP1_HRCARE	:= Time()
								MsUnlock()
								//msgalert("Gravando com numero de pedido --> ["+cPedido+"]","UIA!")
								u_PCPRGLOG(2,cIdEtiq,"29","Retirada do Pallet ["+_OldPall+"] e colocada na carga ["+cCarga+"].")
								u_PCPRGLOG(2,cIdEtiq,"22","Expedida na carga ["+cCarga+"].")
								LVOLTACX := .T.
								cStatus := "OK - Etiqueta EXCLUÍDA do pallet e INCLUÍDA na carga."
								nContador++
								oContador:Refresh()
								aProds[_nPos,4] := TransForm(bStrToVal(aProds[_nPos,4])+1,PesqPict("ZP1","ZP1_PESO"))
								aProds[_nPos,5] := TransForm(bStrToVal(aProds[_nPos,5])-1,PesqPict("ZP1","ZP1_PESO"))
								fProds()
								oStatusO:Show()
								oStatusE:Hide()
								oStatusO:Refresh()
								oStatusE:Refresh()
								oContador:Refresh()
								oProds:Refresh()
								oProds:Refresh()
								oProds:Refresh()
								cIdEtiq := Space(17)
								oIdEtiq:Refresh()
								oIdEtiq:SetFocus()
							Else
								cStatus := "A caixa ["+_cEtiq+"], não foi encontrada."
							EndIF
							fProds()
							oProds:Refresh()
							/*
							ElseIf !(_lachou) .and. (SubStr(aCargas[oCargas:nAt,6],1,1) $ "S|F")
							fVoltaCxa(_cEtiq)
							_lachou 	:= .f.
							Return
							*/
						EndIf
						fProds()
						oProds:Refresh()
						/*
						Else
						cStatus := "Você não possui autorização para abrir um pallet com status FECHADO."
						_lachou := .F.
						_lPalete:= .T.
						*/
					EndIf
					fProds()
					oProds:Refresh()
				EndIf
				fProds()
				oProds:Refresh()
			Endif
			fProds()
			oProds:Refresh()
			If  _lachou // .and. Empty(AllTrim(cStatus))//SubStr(_cEtiq,1,1) $ "9|0" .and.
				If SubStr(_cEtiq,1,2) == "90"
					ZP4->(dbSetOrder(1))
					ZP4->(dbSeek(xFilial()+_cEtiq))
					ZP1->(DBGOTOP())
					ZP1->(dbSetOrder(2))
					ZP1->(dbSeek(xFilial()+_cEtiq))
					__while := "(!ZP1->(EOF()) .AND. ZP1->ZP1_FILIAL == xFilial('ZP1') .AND. ZP1->ZP1_PALETE == cPalet)"
				Else
					ZP1->(dbSetOrder(1))
					ZP1->(dbSeek(xFilial()+_cEtiq))
					__while := "(ZP1->ZP1_CODETI = _cEtiq .AND. ZP1->ZP1_PALETE == cPalet)"
				EndIF

				While &__while //valida se as ZP1 estão aptas a entrar na carga.
					/*
					cStatus := bValVencto()
					If !(Empty(	cStatus))
					DisarmTransaction()
					oContador:Refresh()
					bMsgStat()
					cIdEtiq := Space(17)
					oIdEtiq:Refresh()
					oIdEtiq:SetFocus()
					Return(.F.)
					Endif
					*/
					If ZP1->ZP1_STATUS = '3' .AND. ZP1->ZP1_PEDIDO = aPedidos[oPedidos:nAt,1] .AND. nAcao == 1 //-> Valida Status da etiqueta de caixa
						cStatus := "Etiqueta: "+ZP1->ZP1_CODETI+", já encontra-se carregada na carga ["+aCargas[oCargas:nAt,1]+"]."
						DisarmTransaction()
						oContador:Refresh()
						bMsgStat()
						cIdEtiq := Space(17)
						oIdEtiq:Refresh()
						oIdEtiq:SetFocus()
						Return(.F.)
					Endif

					If !(ZP1->ZP1_STATUS = '2') .AND. nAcao == 1 //-> Valida Status da etiqueta de caixa
						cStatus := "Etiqueta: "+ZP1->ZP1_CODETI+" do Pallet: "+cPalet+" encontra-se com status diferente de (2) - EM CARREGAMENTO."
						DisarmTransaction()
						oContador:Refresh()
						bMsgStat()
						cIdEtiq := Space(17)
						oIdEtiq:Refresh()
						oIdEtiq:SetFocus()
						Return(.F.)
					Endif

					If !(ZP1->ZP1_LOCAL $ '10') .AND. nAcao == 1 //-> Valida Local de expedicao
						cStatus := "Etiqueta: "+ZP1->ZP1_CODETI+" do Pallet: "+cPalet+" encontra-se em armazém diferente do permitido."
						DisarmTransaction()
						oContador:Refresh()
						bMsgStat()
						cIdEtiq := Space(17)
						oIdEtiq:Refresh()
						oIdEtiq:SetFocus()
						Return(.F.)
					Endif

					If lSeqProd .And. nAcao == 1 //->Expedicao por Produto
						If !fPedExp('C', nAcao, cPedido, cCarga, ZP1->ZP1_CODPRO) //->Verifica Sequencia de Carga
							cStatus := "Sequencia de expedicao quebrada."
							DisarmTransaction()
							oContador:Refresh()
							bMsgStat()
							cIdEtiq := Space(17)
							oIdEtiq:Refresh()
							oIdEtiq:SetFocus()
							Return(.F.)
						Endif
					Endif
					/*
					If nAcao == 2 .And. cTipoExp=='P' .and. !(LVOLTACX) //->Exclusao de Expedicao Por Pedido
					///		msgalert("a - " +ZP1->ZP1_PEDIDO+" -----> "+cPedido+" DAI:"+DAI->DAI_PEDIDO+"do brow:"+aPedidos[oPedidos:nAt,1])
					If ZP1->ZP1_PEDIDO <> cPedido
					cStatus := "Existem etiquetas que não pertencem a este pedido."
					DisarmTransaction()
					oContador:Refresh()
					bMsgStat()
					cIdEtiq := Space(17)
					oIdEtiq:Refresh()
					oIdEtiq:SetFocus()
					Return(.F.)
					Endif
					Endif
					*/
					If ZP1->ZP1_STATUS $ "7/9"
						_aPalete:={}
						DisarmTransaction()
						cStatus := "Existem etiquetas suspensas ou sequestradas no Pallet, Etiqueta Suspensa: "+ZP1->ZP1_CODETI
						bMsgStat()
						cIdEtiq := Space(17)
						oIdEtiq:Refresh()
						oIdEtiq:SetFocus()
						Return .F.
					Endif

					aAdd(_aPalete, ZP1->ZP1_CODETI )
					ZP1->(dbSkip())
				EndDo
				cCodLog:="21"
				/*
				Else
				DisarmTransaction()
				oContador:Refresh()
				bMsgStat()
				cIdEtiq := Space(17)
				oIdEtiq:Refresh()
				oIdEtiq:SetFocus()
				Return(.F.)
				*/
			EndIf

			If !(_lPalete) .and. !(LVOLTACX)
				_aPalete:={}
				If bVerEtiq(_cEtiq,cCarga, cPedido) //->Valida Etiqueta Normal
					_aPalete := {_cEtiq}
					cCodLog:="22"
				EndIf
			EndIf
			fProds()
			/*
			Salva expedicao de etiqueta
			*/
			If nAcao == 1
				If aProds[_nPosi := aScan(aProds, {|x| x[1] == (iif(SubStr(_cEtiq,1,2) == "90",;
				ZP4->ZP4_PRODUT,ZP1->ZP1_CODPRO))})][1] = (iif(SubStr(_cEtiq,1,2) == "90",ZP4->ZP4_PRODUT,ZP1->ZP1_CODPRO))
					if !(bStrToVal(aProds[_nPosi,5]) >= 0)
						cStatus := "Excedida a quantidade deste produto para este pedido."
						DisarmTransaction()
						oContador:Refresh()
						bMsgStat()
						cIdEtiq := Space(17)
						oIdEtiq:Refresh()
						oIdEtiq:SetFocus()
						Return(.F.)
					EndIF
				EndIf
			EndIF
			cIdEtiqBox := cIdEtiq
			//msgAlert("troquei!!"+cIdEtiqBox)
			If Len(AllTrim(cStatus)) <= 0 .and. !(LVOLTACX)
				If Len(_aPalete) > 0
					For _I := 1 To Len(_aPalete)
						If Len(AllTrim(cStatus)) <= 0
							cIdEtiq := _aPalete[_I]
							ZP1->(dbSetOrder(1))
							If ZP1->(dbSeek(xFilial()+cIdEtiq))
								/* Sequencia por produto */
								cxSeq:=""
								If lSeqProd
									SC9->(dbOrderNickName("GTOFILSC91"))
									If SC9->(dbSeek(xFilial("SC9") + cPedido + ZP1->ZP1_CODPRO))
										cxSeq:=SC9->C9_XSEQUEN
									Else
										cStatus := "Pedido x Produto nao encontrado na SC9."
										DisarmTransaction()
										oContador:Refresh()
										bMsgStat()
										cIdEtiq := Space(17)
										oIdEtiq:Refresh()
										oIdEtiq:SetFocus()
										Return(.F.)
									Endif
								Endif

								If nAcao == 2 .And. cTipoExp=='P' .and. !(LVOLTACX) //->Exclusao de Expedicao Por Pedido
									///					msgalert("b - "+ZP1->ZP1_PEDIDO+" -----> "+cPedido)
									If AllTrim(ZP1->ZP1_PEDIDO) <> AllTrim(cPedido)//aPedidos[oPedidos:nAt,1]
										cStatus := "Existem etiquetas que não pertencem a este pedido."
										DisarmTransaction()
										oContador:Refresh()
										bMsgStat()
										cIdEtiq := Space(17)
										oIdEtiq:Refresh()
										oIdEtiq:SetFocus()
										Return(.F.)
									Endif
								Endif

								If ZP1->ZP1_STATUS $ "7/9"
									DisarmTransaction()
									cStatus := "Etiqueta Suspensa: "+ZP1->ZP1_CODETI
									oContador:Refresh()
									bMsgStat()
									cIdEtiq := Space(17)
									oIdEtiq:Refresh()
									oIdEtiq:SetFocus()
									Return(.F.)
								Endif

								//->Validacoes de etiquetas
								/*
								Esta rotina esta sendo executada 2 vezes
								Esta sendo executada acima antes de entrar no loop do array _aPaletes.
								*/
								If !(nAcao == 2)
									If !bVerEtiq(ZP1->ZP1_CODETI,cCarga, cPedido)
										DisarmTransaction()
										cIdEtiq := Space(17)
										oIdEtiq:Refresh()
										oIdEtiq:SetFocus()
										Return(.F.)
									Endif
								EndIF

								iif(Empty(Alltrim(cPedido)),cPedido := aPedidos[oPedidos:nAt,1],cPedido := cPedido)
								_nPos := aScan(aProds, {|x| x[1] == ZP1->ZP1_CODPRO})
								If nAcao == 1
									If bStrToVal(aProds[_nPos,5]) > 0
										RecLock("ZP1",.F.)
										ZP1->ZP1_CARGA	:= cCarga
										ZP1->ZP1_PEDIDO	:= cPedido := pedido(cCarga, ZP1->ZP1_CODPRO, cPedido)
										If lSeqProd //->Sequencia por produto
											ZP1->ZP1_XROTEI	:= cxSeq
										Endif
										ZP1->ZP1_DTCAR	:= Date()
										ZP1->ZP1_HRCARE	:= Time()
										ZP1->ZP1_CODZPE	:= cCodLog
										ZP1->ZP1_STATUS := "3"
										ZP1->(MsUnLock())
										//msgalert("Gravado com numero de pedido --> ["+cPedido+"]","UIA!")								
										If lPedFifo .And. Len(aPedFifo) > 0 //-> Habilita FIFO atraves dos pedidos
											aSort( aPedFifo,,, { |x,y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2]) } )
											nPos:=aScan(aPedFifo,{|x| AllTrim(x[1]) == AllTrim(ZP1->ZP1_CODPRO) .And. x[2] >= ZP1->ZP1_DTPROD .And. x[3] > 0 })
											If nPos > 0
												aPedFifo[nPos,3]-=ZP1->ZP1_PESO
											Endif
										Endif
										fProds()
										//->Log de Registro
										U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,cCodLog,"Pallet: "+ZP1->ZP1_PALETE+"/Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))

										aProds[_nPos,4] := TransForm(bStrToVal(aProds[_nPos,4])+1,PesqPict("ZP1","ZP1_PESO"))
										aProds[_nPos,5] := TransForm(bStrToVal(aProds[_nPos,5])-1,PesqPict("ZP1","ZP1_PESO"))
										aProds[_nPos,7] := Transform(bStrToVal(aProds[_nPos,7])+ZP1->ZP1_PESO,PesqPict("SC9","C9_QTDLIB"))
										nContador++
									Else
										cStatus := "A quantidade de etiquetas lidas é maior que a carga"
									EndIf
								Else
									_cCarga:=ZP1->ZP1_CARGA
									RecLock("ZP1",.F.)
									ZP1->ZP1_CARGA := ""
									ZP1->ZP1_PEDIDO:= ""
									ZP1->ZP1_DTCAR := CToD("//")
									ZP1->ZP1_HRCARE:= ""
									ZP1->ZP1_STATUS := "2"
									ZP1->ZP1_CODZPE	:= "24"
									If lSeqProd //->Sequencia por produto
										ZP1->ZP1_XROTEI	:= ""
									Endif
									ZP1->(MsUnLock())
									msgalert("Gravando com numero de pedido --> []","UIA!")
									If lPedFifo .And. Len(aPedFifo) > 0 //-> Habilita FIFO atraves dos pedidos
										aSort( aPedFifo,,, { |x,y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2]) } )
										nPos:=aScan(aPedFifo,{|x| AllTrim(x[1]) == AllTrim(ZP1->ZP1_CODPRO) .And. x[2] >= ZP1->ZP1_DTPROD .And. x[3] > 0 })
										If nPos > 0
											aPedFifo[nPos,3]+=ZP1->ZP1_PESO
										Endif
									Endif
									fProds()
									//->Log de Registro
									U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"24","Carga: "+_cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))

									aProds[_nPos,4] := TransForm(bStrToVal(aProds[_nPos,4])+1,PesqPict("ZP1","ZP1_PESO"))
									aProds[_nPos,5] := TransForm(bStrToVal(aProds[_nPos,5])-1,PesqPict("ZP1","ZP1_PESO"))
									aProds[_nPos,7] := Transform(bStrToVal(aProds[_nPos,7])-ZP1->ZP1_PESO,PesqPict("SC9","C9_QTDLIB"))
									nContador--
								EndIf
								fProds()
							Else
								cStatus := "Etiqueta Invalida"
							EndIf
							fProds()
						EndIf
					Next _I
				Endif
			Endif
			If !LVOLTACX .and. SubStr(_cEtiq,1,2) == "90"
				ZP4->(dbSetOrder(1))
				ZP4->(dbSeek(xFilial()+_cEtiq))
				If !(_lRet := Len(AllTrim(cStatus)) <= 0)
					DisarmTransaction()
					oContador:Refresh()
					bMsgStat()
					cIdEtiq := Space(17)
					oIdEtiq:SetFocus()
					Return(_lRet)
				ElseIf _lPalete
					If nAcao == 1
						RecLock("ZP4",.F.)
						ZP4_CODEST := iif(ZP4->ZP4_CONTAD == POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"), "1","2")
						ZP4->ZP4_STATUS = "F"
						ZP4->ZP4_CARGA := cCarga
						ZP4->(MsUnLock())
						//->Log de Registro
						U_PCPRGLOG(_nTpLog,ZP4->ZP4_PALETE,"27","Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
					Else
						RecLock("ZP4",.F.)
						ZP4->ZP4_CARGA := ""
						If ZP4->ZP4_CODEST 	# "2"
							ZP4->ZP4_STATUS = "F"
						EndIF
						ZP4->(MsUnLock())
						//->Log de Registro
						U_PCPRGLOG(_nTpLog,ZP4->ZP4_PALETE,"28","Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
					EndIf
				EndIf
			EndIF
			//MsgAlert("fechando a transação!","U I A !!! ;)")
		End Transaction

	EndIf

	fProds()
	oLeituras:Refresh()
	oLeituras:Refresh()
	oLeituras:Refresh()
	oLeituras:Refresh()
	oContador:Refresh()
	oProds:Refresh()
	If !LVOLTACX
		bMsgStat()
	EndIF
	//cIdEtiq := Space(17)
	//oIdEtiq:Refresh()
	//oIdEtiq:SetFocus()
Return(_lRet)

/*
Funcao: bVerEtiq
Descricao: Verifica se a Etiqueta caixa e valida
*/
Static Function bVerEtiq(_cEtiq,cCarga, cPedido)
	Local _lRet 		:= .T.
	Local cPalete 		:= ""
	Local _lTolVen		:= GetNewPar("MV_PCPTOL",.F.)
	Local _aAreaZP1		:={}

	cStatus:=""

	//->Valida Enderecamento
	If !U_GTOWMSVEE(_cEtiq)
		cStatus := "Etiqueta enderecada, impossivel movimentações. Inclusa no Pallet"
		bMsgStat()
		cIdEtiq := Space(17)
		oIdEtiq:Refresh()
		oIdEtiq:SetFocus()
		Return(.F.)
	Endif

	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial()+_cEtiq))

		If ZP1->ZP1_LOCAL # '10' //-> Valida Local de expedicao
			cStatus := "Etiqueta: "+ZP1->ZP1_CODETI+" do Pallet: "+_cEtiq+" encontra-se armazenda em um local diferente do local de expedição."
			DisarmTransaction()
			oContador:Refresh()
			bMsgStat()
			cIdEtiq := Space(17)
			oIdEtiq:Refresh()
			oIdEtiq:SetFocus()
			Return(.F.)
		Endif

		If lSeqProd .And. nAcao == 1 //->Expedicao por Produto
			If !fPedExp('C', nAcao, cPedido, cCarga, ZP1->ZP1_CODPRO) //->Verifica Sequencia de Carga
				cStatus := "Sequencia de expedicao quebrada."
				_lRet := Len(AllTrim(cStatus))
				DisarmTransaction()
				oContador:Refresh()
				bMsgStat()
				cIdEtiq := Space(17)
				oIdEtiq:Refresh()
				oIdEtiq:SetFocus()
				Return(.F.)
			Endif
		Endif

		If SubStr(_cEtiq,1,2) # "90"
			If nAcao == 1 .AND. ZP1->ZP1_CARGA = cCarga
				cStatus := "Esta caixa já foi lida anteriormente para esta carga-b  --  zp1 ["+ZP1->ZP1_CARGA+"]   var ["+cCarga+"]"
				/*
				ElseIf nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga
				cStatus := "Esta caixa não consta nesta carga - c   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"]"
				*/
			ElseIf nAcao == 1 .AND. Len(AllTrim(ZP1->ZP1_CARGA)) > 0
				cStatus := "Esta caixa já esta em outra carga ["+ZP1->ZP1_CARGA+"]"

				_lachou := .f.
			EndIf
		EndIf

		If nAcao == 1 .AND. ZP1->ZP1_CARGA = cCarga  .and. lAbreFecha
			cStatus := "Esta caixa já foi lida anteriormente para esta carga-c"
		ElseIf nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga  .and. lAbreFecha
			cStatus := "Esta caixa não consta nesta carga - d   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"]"
		ElseIf nAcao == 1 .AND. Len(AllTrim(ZP1->ZP1_CARGA)) > 0  .and. lAbreFecha
			cStatus := "Esta caixa já esta em outra carga ["+ZP1->ZP1_CARGA+"]"


			_lZP1STATUS := iif(nAcao = 1,"2","3")
			If ZP1->ZP1_STATUS <> _lZP1STATUS .AND. ZP1->ZP1_CARGA <> cCarga
				cStatus := "Status deve estar em carregamento, para efetuar a carga."
			ElseIf nAcao == 1 .AND. ZP1->ZP1_CARGA = cCarga
				cStatus := "Esta caixa já foi lida anteriormente para esta carga-d"
			ElseIf nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga
				cStatus := "Esta caixa não consta nesta carga - e   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"]"
			ElseIf nAcao == 1 .AND. Len(AllTrim(ZP1->ZP1_CARGA)) > 0
				cStatus := "Esta caixa já esta em outra carga ["+ZP1->ZP1_CARGA+"]"
			ElseIf aScan(aProds, {|x| x[1] == ZP1->ZP1_CODPRO}) <= 0
				cStatus := "O produto desta etiqueta não consta na carga."
			ElseIf !(EMPTY(ZP1->ZP1_ENDWMS))
				cStatus := "Esta caixa não foi desendereçada."
			ElseIf ZP1->ZP1_STATUS $ "7/9"
				cStatus := "Etiqueta Suspensa ou sequestrada."
			EndIf

			_lachou := .f.
		EndIf

		_lZP1STATUS := iif(nAcao = 1,"2","3")
		If ZP1->ZP1_STATUS <> _lZP1STATUS .AND. ZP1->ZP1_CARGA <> cCarga  .AND. nAcao = 1  .and. lAbreFecha
			cStatus := "Esta caixa não esta ativa"
		ElseIf nAcao == 1 .AND. ZP1->ZP1_CARGA = cCarga  .and. lAbreFecha
			cStatus := "Esta caixa já foi lida anteriormente para esta carga-e"
		ElseIf nAcao == 2 .AND. ZP1->ZP1_CARGA <> cCarga  .and. lAbreFecha
			cStatus := "Esta caixa não consta nesta carga - f   ["+ZP1->ZP1_CARGA+"]  -x-  ["+cCarga+"]"
		ElseIf nAcao == 1 .AND. Len(AllTrim(ZP1->ZP1_CARGA)) > 0  .and. lAbreFecha
			cStatus := "Esta caixa já esta em outra carga ["+ZP1->ZP1_CARGA+"]"
		ElseIf aScan(aProds, {|x| x[1] == ZP1->ZP1_CODPRO}) <= 0  .and. lAbreFecha
			cStatus := "O produto desta etiqueta não consta na carga."
		ElseIf !(EMPTY(ZP1->ZP1_ENDWMS))  .and. lAbreFecha
			cStatus := "Esta caixa não foi desendereçada."
		ElseIf ZP1->ZP1_STATUS $ "7/9" .and. lAbreFecha
			cStatus := "Etiqueta Suspensa ou sequestrada."

			//ElseIF nAcao == 2 .AND.  Len(AllTrim(ZP1->ZP1_CARGA)) > 0  .and. !(lAbreFecha)
			//fVoltaCxa(_cEtiq)
			//return
		EndIf
	EndIf

	If nAcao == 1 .AND. Len(AllTrim(cStatus)) <= 0
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+_cEtiq))
			cStatus := bValVencto()
		Else
			cStatus := "Etiqueta nao encontrada.["+_cEtiq+"]"
		Endif
	Endif

	_lRet := Len(AllTrim(cStatus)) <= 0
Return(_lRet)

/*
Funcao: bAbrePal(cPalete)
Descricao: Descarrega carga expedida.
*/
Static Function bAbrePal(cPalete)
	Local _lRet	:= .F.
	Local aEti		:= {}
	Local cSql		:= ""

	Begin Transaction
		cStatus:=""

		//->Valida Enderecamento
		If !U_GTOWMSVEE(cPalete)
			cStatus := "Etiqueta enderecada, impossível movimentações."
			bMsgStat()
			cIdEtiq := Space(17)
			oIdEtiq:Refresh()
			oIdEtiq:SetFocus()
			Return(.F.)
		Endif

		If MsgYesNo("Deseja abrir o pallet "+cPalete+"?","Atencão")
			_lRet := .T.
			aEti:={}

			//->Abre o palete.
			ZP1->(dbSetOrder(2))
			If ZP1->(dbSeek(xFilial()+cPalete))
				While !ZP1->(EOF()) .AND. ZP1->ZP1_FILIAL == xFilial() .AND. ZP1->ZP1_PALETE == cPalete
					If ZP1->ZP1_STATUS $ "7/9"
						DisarmTransaction()
						cStatus := "Pallet com etiqueta suspensa ou sequestrada."
						Return(.F.)
					Endif

					RecLock("ZP1",.F.)
					ZP1->ZP1_PALETE:= ""
					ZP1->(MsUnLock())

					AADD(aEti,{ZP1->ZP1_CODETI,ZP1->ZP1_CARGA,ZP1->ZP1_PEDIDO})//->Log de Registro
					ZP1->(dbSkip())
				EndDo
			Endif

			cSql:="UPDATE "+RETSQLNAME("ZP1")+" SET ZP1_PALETE='', ZP1_CODZPE = '29' "
			cSql+="WHERE ZP1_PALETE='"+cPalete+"' AND D_E_L_E_T_ <> '*' "
			//	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_H.SQL",cSQL)
			If TCSQLExec(cSql) < 0
				DisarmTransaction()
				cStatus := "1-Falha no Processo de abertura do pallet número: "+cPalete
				Return .F.
			EndIf

			//->Log de Registro
			For x:=1 To Len(aEti)
				U_PCPRGLOG(_nTpLog,aEti[x,1],"29","Pallet: "+cPalete+"/Carga:"+aEti[x,2]+Iif(cTipoExp=='P',"/Pedido:"+aEti[x,3],""))
			Next x

			ZP1->(dbSetOrder(2))
			If ZP1->(dbSeek(xFilial()+cPalete))
				DisarmTransaction()
				cStatus := "2-Falha no Processo de abertura de pallet número: "+cPalete
				Return .F.
			Endif
			If Len(aEti) <= 0
				ZP4->(dbSetOrder(1))
				If ZP4->(dbSeek(xFilial()+cPalete)) .AND. ZP4->ZP4_CONTAD <= 0
					_cCarga:=ZP4->ZP4_CARGA
					RecLock("ZP4",.F.)
					ZP4->(dbDelete())
					ZP4->(MsUnLock())
					//->Log de Registro
					U_PCPRGLOG(_nTpLog,ZP4->ZP4_PALETE,"30","Carga:"+_cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
				ElseIF (posicione("SB1",1,"XFILIAL('SB1')+ZP4->ZP4_CODPRO","B1_XQTDPAL")) = ZP4->ZP4_CONTAD
					RecLock("ZP4",.F.)
					ZP4->ZP4_CODEST := '1'
					ZP4->(MsUnLock())
				Else
					RecLock("ZP4",.F.)
					ZP4->ZP4_CODEST := '2'
					ZP4->(MsUnLock())
				EndIf
			EndIF
		EndIf
	End Transaction
Return(_lRet)

/*
Funcao: bStrToVal
Descricao: Limpa o caracter "." e troca "," por "."
para converter valores strings em Float.
*/
Static Function bStrToVal(_cPar)
	Local _nRet := 0
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
	_nRet := Val(_cPar)
Return(_nRet)

/*
Funcao: bDescar()
Descricao: Descarrega carga expedida.
*/
Static Function bDescar()
	Local _cEtiqs := ""
	//Local cCarga := aCargas[oCargas:nAt,1]
	Local _cArq := ""
	Local _lPalete := .F.
	Local _cPalete := ""
	//Local cPedido  := ""   // Alterado por Wendel 23/10/2018.
	cCarga := aCargas[oCargas:nAt,1]

	If !(SubStr(aCargas[oCargas:nAt,6],1,1) $ "SF")
		MsgStop("Somente cargas com Status Fechada ou Suspensa podem ser descarregadas")
		Return
	EndIf

	If !MsgYesNo("Confirma o descarregamento da carga?")
		Return
	EndIf

	_lPalete := MsgYesNo("Carga Paletizada?")

	DAK->(dbSetOrder(1))
	If DAK->(dbSeek(xFilial()+cCarga))

		Begin Transaction
			ZP1->(dbSetOrder(3))
			While ZP1->(dbSeek(xFilial()+cCarga))
				If !_lPalete
					_cEtiqs += ZP1->ZP1_CODETI+";"
				EndIf
				_cPalete := ZP1->ZP1_PALETE
				RecLock("ZP1",.F.)
				ZP1->ZP1_CARGA 	:= ""
				ZP1->ZP1_DTCAR	:= CToD("//")
				ZP1->ZP1_HRCARE	:= ""
				ZP1->ZP1_PEDIDO := ""
				ZP1->ZP1_STATUS := "2"
				ZP1->ZP1_CODZPE	:= IIF(!_lPalete,"35","31")
				If !_lPalete
					ZP1->ZP1_PALETE := ""
				EndIf
				If lSeqProd //->Sequencia por produto
					ZP1->ZP1_XROTEI	:= ""
				Endif
				ZP1->(MsUnLock())
				msgalert("Gravando com numero de pedido --> []","UIA!")
				//->Log de Registro
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"31","Pallet: "+ZP1->ZP1_PALETE+"/Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
				If !_lPalete
					U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"35","Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
				EndIf

				If Len(AllTrim(_cPalete)) > 0
					ZP4->(dbSetOrder(1))
					If ZP4->(dbSeek(xFilial()+_cPalete))
						RecLock("ZP4",.F.)
						If _lPalete
							ZP4->ZP4_CARGA := ""
						Else
							ZP4->(dbDelete())
						EndIf
						ZP4->(MsUnLock())

						//->Log de resgistro
						If _lPalete //->Paletizada
							U_PCPRGLOG(_nTpLog,_cPalete,"36","Pallet: "+ZP1->ZP1_PALETE+"/Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
						Else
							U_PCPRGLOG(_nTpLog,_cPalete,"37","Pallet: "+ZP1->ZP1_PALETE+"/Carga: "+cCarga+Iif(cTipoExp=='P',"/Pedido:"+cPedido,""))
						EndIf

					EndIf
					If _lPalete
						_cEtiqs += ZP1->ZP1_PALETE+";"
					EndIf
				ElseIf _lPalete
					_cEtiqs += ZP1->ZP1_CODETI+";"
				EndIf
				ZP1->(dbSkip())
			EndDo

			RecLock("DAK",.F.)
			DAK->DAK_XSTEXP := "A"
			DAK->DAK_XBLQCP := "2"
			DAK->DAK_XUSABE := ""
			DAK->DAK_XDTABE := CToD("//")
			DAK->DAK_XHRABE := ""
			DAK->DAK_XLACRE := ""
			DAK->DAK_XUSFEC := ""
			DAK->DAK_XDTFEC := CToD("//")
			DAK->DAK_XHRFEC := ""
			DAK->(MsUnLock())

			U_PCPRGLOG(_nTpLog,cCarga,"56","Status Carga: Aguardando Carregamento")
			U_PCPRGLOG(_nTpLog,cCarga,"57","Status Bloqueio: Expedicao")

			If cTipoExp=='P'
				U_PCPRGLOG(_nTpLog,cPedido,"B6","Status Carga: Aguardando Carregamento")
				U_PCPRGLOG(_nTpLog,cPedido,"B7","Status Bloqueio: Expedicao")
			Endif

			If Len(AllTrim(_cEtiqs)) > 0
				While Len(AllTrim(_cArq)) <= 0
					_cArq := cGetFile('Arquivo *|*.*','Onde deseja salvar as leituras ?',0,'C:\Temp\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
				EndDo
				_cArq += cCarga+"_"+DToS(Date())+"_"+StrTran(Time(),":","")+".TXT"
				MemoWrite(_cArq,_cEtiqs)
				MsgInfo("Foi gerado o arquivo "+_cArq)
			EndIf

		End Transaction
	EndIf
	LjMsgRun( "Processando dados, aguarde...", "Expedição", {|| bDados() } )
	fCargas()
Return

/*
Funcao: bImporta()
Descricao: Importa arquivo de texto.
*/
Static Function bImporta()
	Local cFile := cGetFile('Arquivo TXT|*.txt','Disquete e Drives Locais',0,'C:\Temp\',.T.,GETF_LOCALHARD,.F.)
	Local _aEtiqs := {}
	Local _I := 0
	If File(cFile)
		_aEtiqs := StrTokArr2( MemoRead(cFile), ";")
		For _I := 1 To Len(_aEtiqs)
			cIdEtiq := _aEtiqs[_I]
			bValEtiq()
		Next _I
	Else
		MsgStop("Arquivo invalido.")
	EndIf
Return

/*
Funcao: bValVencto()
Descricao: Trata vencimento dos produtos
*/
Static Function bValVencto()
	Local _cRet 		:= ""
	//Local cCarga 		:= aCargas[oCargas:nAt,1]
	Local _cCliente 	:= ""
	Local _cLoja 		:= ""
	Local _cQry 		:= ""
	Local _lPrdCli	:= .F.
	Local _cForFifo	:= "N" //->Fifo para caixas em qualquer status
	Local _lTolVen	:= GetNewPar("MV_PCPTOL",.F.) //->Toler‰ncia
	Local _lForFifo	:= GetNewPar("MV_PCPFORF",.F.)
	Local nPos			:= 0
	Local _cXGP1		:= ""
	Local _lFifFix	:= .F. //->GetNewPar("MV_XPCPFFX",.T.) //-> Fifo Fixo

	/*
	Houve uma mudanca na variavel _lFifFix.
	seu conteœdo sera atualizado pelo campo:
	*/

	DAK->(dbSetOrder(1))
	DAI->(dbSetOrder(1)) //-> DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
	SA1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	ZP5->(dbSetOrder(1))

	//->Informacoes da Carga
	If DAK->(dbSeek(xFilial()+cCarga))
		If cTipoExp=='C' .Or. (cTipoExp=='P' .And. fCarQtd(aCargas[oCargas:nAt,1],"") > 0) //->Expedicao por Carga
			If DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
				_cCliente	:= DAI->DAI_CLIENT
				_cLoja		:= DAI->DAI_LOJA
				If _lForFifo //->Tratamento de FIFO
					_cForFifo:= DAK->DAK_FORFIF
				Endif
			Else
				_cRet := "Carga nao encontrada na DAI: "+DAK->DAK_COD
				Return _cRet
			EndIf
		Elseif cTipoExp=='P' .And. fCarQtd(aCargas[oCargas:nAt,1],"")==0 //->Expedicao por pedido
			DAI->(dbSetOrder(4)) //-> DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
			If DAI->(dbSeek(DAK->DAK_FILIAL+aPedidos[oPedidos:nAt,1]+DAK->DAK_COD))
				_cCliente	:= DAI->DAI_CLIENT
				_cLoja		:= DAI->DAI_LOJA
				If _lForFifo //->Tratamento de FIFO
					_cForFifo:= DAK->DAK_FORFIF
				Endif
			Else
				_cRet := "Pedido "+aCargas[oCargas:nAt,1]+" da carga: "+DAK->DAK_COD+" n‹o encontrado na DAI."
				Return _cRet
			EndIf
		Else
			_cRet := "Carga nao encontrada na DAI: "+DAK->DAK_COD
			Return _cRet
		Endif
	Else
		_cRet := "Tipo de operacao nao identificado. Carga ou Pedido."
		Return _cRet
	EndIf

	//->Valida do produto informado na etiqueta do Produto
	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+ZP1->ZP1_CODPRO))
		_cRet := "Produto nao encontrado: ["+ZP1->ZP1_CODPRO+"] Etiqueta: ["+ZP1->ZP1_CODETI+"]"
		Return _cRet
	Else
		_cXGP1:= SB1->B1_XGP1 //->Conservacao
		dbSelectArea("SB1")
		If FieldPos(AllTrim("B1_XFIFFX")) > 0 //-> Fifo Fixo Por produto
			_lFifFix:=SB1->B1_XFIFFX=="S"
		Endif
	Endif

	//-> Trata rotina de vencimentos apontados no pedido de venda
	If lPedFifo .And. Len(aPedFifo) > 0 //-> Habilita FIFO atraves dos pedidos
		aSort( aPedFifo,,, { |x,y| x[1]+DTOS(x[2]) < y[1]+DTOS(y[2]) } )
		nPos:=aScan(aPedFifo,{|x| AllTrim(x[1]) == AllTrim(ZP1->ZP1_CODPRO) .And. x[2] < ZP1->ZP1_DTPROD .And. x[3] > 0})
		If nPos > 0
			_cRet := "EXPEDICAO POR FIFO NO PEDIDO - Este produto reque expedicao com data de producao menor que ou igual a : "+DToC(aPedFifo[nPos,2])+" / Produto: "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)
			Return _cRet
		Endif
	Endif

	//-> Fifo Obrigatório por Família
	If Len(AllTrim(cConcFifo)) > 0 .Or. _lFifFix //-> Fifo Fixo por Produto
		If AllTrim(_cXGP1) $  cConcFifo .Or. _lFifFix //-> Fifo Fixo por Produto
			_cQry := " SELECT COUNT(*) QTDT"
			_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK)"
			_cQry += " WHERE "
			_cQry += " ZP1_FILIAL = '"+ZP1->ZP1_FILIAL+"'"
			_cQry += " AND ZP1_CODETI <> '"+ZP1->ZP1_CODETI+"'"
			_cQry += " AND ZP1_STATUS IN ('1','2') "
			_cQry += " AND ZP1_CARGA = '' "
			_cQry += " AND ZP1_CODPRO = '"+ZP1->ZP1_CODPRO+"'"
			_cQry += " AND ZP1_DTPROD < '"+DToS(ZP1->ZP1_DTPROD)+"' "
			_cQry += " AND ZP1.D_E_L_E_T_ = ' '"
			//		MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_I.SQL",_cQry)
			TcQuery _cQry New Alias "QRYV"
			If !QRYV->(EOF())
				If QRYV->QTDT > 0
					_cRet := "FIFO OBRIGATORIO POR CONSERVAÇÃO: Existem data de producao anteriores ao desta etiqueta para este produto."
					QRYV->(dbCloseArea())
					Return _cRet
				EndIf
			EndIf
			QRYV->(dbCloseArea())
		Endif
	Endif

	//->Tolerancia de fabricacao informada no cadastro de produtos para todos os produtos
	If _lTolVen
		_cRet :=""
		If Date()-ZP1->ZP1_DTPROD > SB1->B1_XTOLVEN
			_cRet := "Esta Etiqueta ultrapassa a tolerancia. Fabricacao: "+DToC(ZP1->ZP1_DTPROD)+" / Tolerancia: "+cValToChar(SB1->B1_XTOLVEN)
		EndIf

		If Len(AllTrim(_cRet)) > 0
			Return _cRet
		Endif
	EndIf

	//->Tolerancia por cliente
	If !Empty(AllTrim(_cCliente))

		ZP5->(dbSetOrder(1))
		If ZP5->(dbSeek(xFilial("ZP5") + _cCliente + _cLoja + ZP1->ZP1_CODPRO)) .AND. ZP5->ZP5_DIAS > 0
			If Date()-ZP1->ZP1_DTPROD > ZP5->ZP5_DIAS
				_cRet := "TOLERANCIA POR CLIENTE: Esta Etiqueta ultrapassa a tolerancia. Fabricacao: "+DToC(ZP1->ZP1_DTPROD)+" / Tolerancia: "+cValToChar(SB1->B1_XTOLVEN)
			EndIf
		EndIf

		If Len(AllTrim(_cRet)) > 0
			Return _cRet
		Endif

		If SA1->(dbSeek(xFilial("SA1") + _cCliente + _cLoja )) .AND. SA1->A1_XMAXDVE > 0
			_cQry := " SELECT COUNT(DISTINCT ZP1_DTVALI) QTDT"
			_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK)"
			_cQry += " WHERE "
			_cQry += " AND ZP1_FILIAL = '"+ZP1->ZP1_FILIAL+"'"
			_cQry += " AND ZP1_CODETI <> '"+ZP1->ZP1_CODETI+"'"
			_cQry += " AND ZP1_STATUS = '2'"
			_cQry += " AND ZP1_CARGA = '"+cCarga+"'"
			_cQry += " AND ZP1_CODPRO = '"+ZP1->ZP1_CODPRO+"'"
			_cQry += " AND ZP1_DTVALI <> '"+DToS(ZP1->ZP1_DTVALI)+"'"
			_cQry += " ZP1.D_E_L_E_T_ = ' '"
			//		MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_J.SQL",_cQry)
			TcQuery _cQry New Alias "QRYV"
			If !QRYV->(EOF())
				If QRYV->QTDT+1 > SA1->A1_XMAXDVE
					_cRet := "MçXIMO DE VENCIMENTO POR CLIENTE: Numero maximo de vencimentos por produto excedido. Cliente: ["+_cCliente+"/"+_cLoja+"]-"+POSICIONE("SA1",1,XFILIAL("SA1")+_cCliente + _cLoja,"A1_NOME")
				EndIf
			EndIf
			QRYV->(dbCloseArea())

			If Len(AllTrim(_cRet)) > 0
				Return _cRet
			Endif

		EndIf
	ENdif


	/*
	FIFO:
	O Fifo deve ser considerado dentro da tolerãnia
	Para obrigatoriedade do FIFO e utilizada a seguinte fórmula:
	1-Mesmo produto com data de produçãoo menor que a etiqueta que está tentando-se expedir
	2-Data de produção menor que a data atual-dias de tolerancia do produto.
	*/
	If SB1->B1_XTOLVEN <= 0
		_cRet := "Telerancia do produto "+ZP1->ZP1_CODPRO+" zerada."
		Return(_cRet)
	Endif

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+ZP1->ZP1_CODPRO))
		_cRet :=""
		_cQry := " SELECT ZP1_DTPROD, ZP1_STATUS, ISNULL(MIN(ZP1_DTVALI),'') ZP1_DTVALI "
		_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK)"
		_cQry += " WHERE "
		_cQry += " ZP1_CODETI <> '"+ZP1->ZP1_CODETI+"' "
		If _cForFifo=="S" .And. _lForFifo
			_cQry += " AND ZP1_STATUS IN ('1','9','7','2') "
		Else
			_cQry += " AND ZP1_STATUS = '2' "
		Endif
		_cQry += " AND ZP1_CARGA = '' "
		_cQry += " AND ZP1_CODPRO = '"+ZP1->ZP1_CODPRO+"' "
		_cQry += " AND ZP1_DTPROD < '"+DToS(Date()-SB1->B1_XTOLVEN)+"' "
		_cQry += " AND ZP1_DTPROD < '"+DToS(ZP1->ZP1_DTPROD)+"' "
		_cQry += " AND ZP1.D_E_L_E_T_ <> '*' "
		_cQry += " GROUP BY ZP1_DTPROD, ZP1_STATUS "
		_cQry += " ORDER BY 3 "
		//	MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_K.SQL",_cQry)
		TcQuery _cQry New Alias "QRYV"
		If !QRYV->(EOF())
			_cRet := "No estoque ha etiqueta com data de Fabricacao anterior. Dt. Prod.:"+DToC(SToD(QRYV->ZP1_DTPROD))+"."
			_cRet += " Cliente: ["+_cCliente +"/"+ _cLoja+"] - "+SubStr(Posicione("SA1",1,xFilial("SA1") + _cCliente + _cLoja ,"A1_NOME"),1,25)
			_cRet += " Status: "+Iif(QRYV->ZP1_STATUS=="2","Carregando",Iif(QRYV->ZP1_STATUS=="9","Sequestrada","Suspensa"))+" "+Iif(_cForFifo=="S"," ATENÇÃO: FIFO FORÇADO ATIVADO","")
		EndIf
		QRYV->(dbCloseArea())

		If Len(AllTrim(_cRet)) > 0
			Return _cRet
		Endif

	Else
		_cRet := "Produto nao encontrado: "+ZP1->ZP1_CODPRO+"."
		Return(_cRet)
	EndIf
Return(_cRet)

/*
Função: bMsgStat()
Descrição: Quadro de Mesnagem
*/
Static Function bMsgStat()
	If Len(AllTrim(cStatus)) > 0
		oStatusO:Hide()
		oStatusE:Show()
		Tone()
		Tone()
		Tone()
	Else
		cStatus := "Etiqueta OK"
		oStatusO:Show()
		oStatusE:Hide()
	EndIf
	oStatusO:Refresh()
	oStatusE:Refresh()
Return


/*
Função: fPedFifo()
Descrição: Cria uma matriz para acompanhamento dos pedidos em que foram apontados vencimentos específicos.
*/
Static Function fPedFifo(_cCarga, _cPedido)
	Local nPos	:=0

	If cTipoExp=='P' //->Expedição Por Pedido
		//->Localiza Produtos com data de vencimento específica
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+_cPedido))
			While !SC6->(Eof()) .And. SC6->(xFilial("SC6")+DAI->DAI_PEDIDO)==xFilial("SC6")+_cPedido
				If Len(Alltrim(DTOS(SC6->C6_DTVALID))) >0
					SC9->(dbSetOrder(1))
					If SC9->(dbSeek(xFilial()+SC6->(C6_NUM+C6_ITEM)))
						nPos:=aScan(aPedFifo,{|x| AllTrim(x[1])==AllTrim(SC6->C6_PRODUTO)})
						If nPos==0
							AADD(aPedFifo,{SC6->C6_PRODUTO,;
							SC6->C6_DTVALID,;
							SC9->C9_QTDLIB})
						Else
							aPedFifo[nPos,3]+= SC9->C9_QTDLIB
						Endif
					Endif
				Endif
				SC6->(dbSkip())
			Enddo
		Endif
	Else
		//->Localiza Produtos com data de vencimento espec’fica
		If DAK->(dbSeek(xFilial()+cCarga))
			If DAI->(dbSeek(DAK->(DAK_FILIAL+DAK_COD)))
				While !DAI->(Eof()) .And. DAI->(DAI_FILIAL+DAI_COD)==DAK->(DAK_FILIAL+DAK_COD)
					SC6->(dbSetOrder(1))
					If SC6->(dbSeek(xFilial("SC6")+DAI->DAI_PEDIDO))
						While !SC6->(Eof()) .And. SC6->(xFilial("SC6")+DAI->DAI_PEDIDO)==xFilial("SC6")+DAI->DAI_PEDIDO
							If Len(Alltrim(DTOS(SC6->C6_DTVALID))) >0
								SC9->(dbSetOrder(1))
								If SC9->(dbSeek(xFilial()+SC6->(C6_NUM+C6_ITEM)))
									nPos:=aScan(aPedFifo,{|x| AllTrim(x[1])==AllTrim(SC6->C6_PRODUTO)})
									If nPos==0
										AADD(aPedFifo,{SC6->C6_PRODUTO,;
										SC6->C6_DTVALID,;
										SC9->C9_QTDLIB})
									Else
										aPedFifo[nPos,3]+= SC9->C9_QTDLIB
									Endif
								Endif
							Endif
							SC6->(dbSkip())
						Enddo
					Endif
					DAI->(dbSkip())
				Enddo
			EndIf
		EndIf
	Endif

	//->Verifica o que já foi carregado
	_cQry := " SELECT ZP1_CODPRO, SUM(ZP1_PESO) PESO "
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 "
	_cQry += " WHERE "
	_cQry += " ZP1_CARGA = '"+_cCarga+"' "
	If cTipoExp=='P' //->Expedição Por Pedido
		_cQry += " AND ZP1_PEDIDO = '"+_cPedido+"' "
	Endif
	_cQry += " AND ZP1.D_E_L_E_T_ <> '*' "
	_cQry += " GROUP BY ZP1_CODPRO"
	//MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_L.SQL",_cQry)
	TcQuery _cQry New Alias "QRYP"
	While !QRYP->(EOF())
		nPos:=aScan(aPedFifo,{|x| AllTrim(x[1]) == AllTrim(QRYP->ZP1_CODPRO) .And. x[3] > 0 })
		If nPos>0
			aPedFifo[nPos,3]-= QRYP->PESO
		Endif
		QRYP->(dbSkip())
	Enddo
	QRYP->(dbCloseArea())
Return

Static Function fVoltaCxa(_cEtiq)

	TCCommit(1)
	ZP1->(dbsetorder(1))
	IF	ZP1->(dbSeek(xFilial("ZP1")+_cEtiq))
		_nPos := aScan(aProds,{|x| x[1] = ZP1->ZP1_CODPRO})
		_CPAL := ZP1->ZP1_PALETE
		RecLock("ZP1",.F.)
		ZP1_PALETE	:= ""
		ZP1_STATUS  := "2"
		ZP1_CARGA	:= ""
		ZP1_PEDIDO	:= ""
		ZP1_NF		:= ""
		ZP1_SERIE	:= ""
		ZP1_ENDWMS	:= ""
		ZP1_DTCAR	:= CTOD("  /  /  ")
		ZP1_HRCARE	:= ""
		ZP1_CODZPE  := '24'
		MsUnLock()
		ZP1->(dbCommit())
		u_PCPRGLOG(2,cIdEtiq,"31","Exclusão de caixa da carga ["+aCargas[oCargas:nAt,1]+"], realizada")
		msgalert("Gravando com numero de pedido --> []","UIA!")
	endif
	ZP4->(dbsetorder(1))
	if (ZP4->(DBSEEK(XFILIAL("ZP4")+_CPAL)))
		RecLock("ZP4",.F.)
		ZP4_CONTAD	:= ZP4->ZP4_CONTAD-1
		ZP4_CODEST	:= "2"
		MsUnlock()
		ZP4->(dbCommit())
		u_PCPRGLOG(2,cIdEtiq,"19","Exclusão de caixa do pallet ["+_CPAL+"] e atualização de quantidade ["+AllTrim(Str(ZP4_CONTAD))+"], realizada")
	EndIF
	TCCommit(2)
	TCCommit(4)
	LVOLTACX := .T.
	nContador--


	/*
	Else
	PCPRGLOG(1,cIdEtiq,"08","")
	*/
	aProds[_nPos,4] := TransForm(bStrToVal(aProds[_nPos,4])+1,PesqPict("ZP1","ZP1_PESO"))
	aProds[_nPos,5] := TransForm(bStrToVal(aProds[_nPos,5])-1,PesqPict("ZP1","ZP1_PESO"))
	fProds()
	cIdEtiq := Space(17)
	oIdEtiq:refresh()
	oDlgReg:refresh()
	oContador:refresh()
	oIdEtiq:SetFocus()
Return

Static Function pedido(cCarga, cProduto, cPedido)

	cRet := cPedido

	If DAK->DAK_OCORRE = '09'
		_cQry := " SELECT DAI_COD, DAI_PEDIDO, C6_NUM, C6_ITEM, "
		_cQry += " 		C6_PRODUTO, C6_DESCRI, (C6_QTDVEN / B1_CONV) AS QTDVEN, "
		_cQry += " 		C6_QTDVEN AS KG, COUNT(ZP1.ZP1_CODPRO) AS QTD "
		_cQry += " FROM "+RetSQLName("DAI")
		_cQry += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON C6_NUM = DAI_PEDIDO "
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD = C6_PRODUTO "
		_cQry += " LEFT  JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1_CARGA = '"+cCarga+"' AND ZP1_CODPRO = '"+cProduto+"' AND ZP1_PEDIDO = C6_NUM		
		_cQry += " WHERE DAI_COD = '"+cCarga+"' "
		_cQry += " AND C6_PRODUTO = '"+cProduto+"' "
		_cQry += " GROUP BY DAI_COD, DAI_PEDIDO, C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, B1_CONV "		
		_cQry += " ORDER BY DAI_PEDIDO, C6_ITEM "
		If Select("QRYF") > 0
			QRYF->(dbCloseArea())
		Endif		
		TcQuery _cQry New Alias "QRYF"

		Do While !QRYF->(EOF()) 
			If QRYF->QTDVEN > QRYF->QTD
				cRet := QRYF->C6_NUM
				Exit
			Else
				QRYF->(dbSkip())
				If QRYF->QTDVEN > QRYF->QTD
					cRet := QRYF->C6_NUM
					Exit
				EndIF
			EndIF
		EndDo	
	EndIf


Return cRet

/*
If DAK->DAK_OCORRE = '09'

TCSqlExec( "UPDATE "+RetSQLName("ZP1")+" SET ZP1_PEDIDO = '' WHERE ZP1_CARGA = '"+DAK->DAK_COD+"' " )     

_cQry := " SELECT DAI_COD, DAI_PEDIDO, C6_NUM, C6_ITEM, "
_cQry += " 		C6_PRODUTO, C6_DESCRI, (C6_QTDVEN / B1_CONV) AS QTDVEN, C6_QTDVEN AS KG "
_cQry += " FROM "+RetSQLName("DAI")
_cQry += " INNER JOIN "+RetSQLName("SC6")+" ON C6_NUM = DAI_PEDIDO "
_cQry += " INNER JOIN "+RetSQLName("SB1")+" ON B1_COD = C6_PRODUTO "
_cQry += " WHERE DAI_COD = '"+DAK->DAK_COD+"' "
_cQry += " ORDER BY DAI_PEDIDO, C6_ITEM "

//MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_TMP.SQL",_cQry)
TcQuery _cQry New Alias "QRYF"
While !QRYF->(EOF())		
If Select("QRYETF") > 0
QRYETF->(dbCloseArea())
Endif
_cQry := " SELECT TOP "+AllTrim(Str(QRYF->QTDVEN))+" ZP1_CODETI "
_cQry += " FROM "+RetSQLName("ZP1")
_cQry += " WHERE ZP1_CARGA = '"+DAK->DAK_COD+"' "
_cQry += " AND ZP1_CODPROD = '"+QRYF->C6_PRODUTO+"' "
_cQry += " AND ZP1_PEDIDO  = '' "

//MemoWrite("C:\TEMP\"+Upper(AllTrim(Funname()))+"_TMP.SQL",_cQry)
TcQuery _cQry New Alias "QRYETF"
While !QRYETF->(EOF())
ZP1->(dbSetOrder(1))
ZP1->(dbSeek(XFILIAL("ZP1")+QRYETF->ZP1_CODETI))
Reclock("ZP1",.F.)
ZP1->ZP1_PEDIDO := QRYF->DAI_PEDIDO
MsUnlock()
QRYETF->(DBSKIP())
EndDo
EndDo	
EndIF
*/