#include 'totvs.ch'
#include 'topconn.ch'
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)


User Function PCP023()


	Local _I
	Local _nCol := 0
	Private nHRes	:= oMainWnd:nClientWidth*0.88	// Resolucao horizontal do monitor
	Private nVRes	:= oMainWnd:nClientHeight*0.80	// Resolucao vertical do monitor
	Private nVLim := (nVRes/2)-25
	Private oFolder
	Private oDlgInv
	Private oIvents
	Private aIvents := {}
	Private cFiltro := ""
	Private cFiltroIt := ""
	Private cFiltroL := ""
	Private oItensInv
	Private aItensInv := {}
	Private cDocAnt := ""
	Private oLeituras
	Private aLeituras	:= {}
	Private aDadosLei	:= {}
	Private lCHK_NO 	:= .T.
	Private lCHK_NA 	:= .T.
	Private lCHK_NL 	:= .F.
	Private oCHK_NO
	Private oCHK_NA
	Private oCHK_NL
	Private _lEntrada	:= .T.
	Private _nNumSeq 	:= GetNewPar("MV_PCP7NUM",0) //-> 0=Sequencial Direta / 1=Sequencial com semaforo
	Private _nPCPEMB 	:= GetNewPar("MV_PCPEMBE","") //-> Separado por "/"= P=Paletizacao/E=Expedicao/W=WMS/I=Inventario
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _aRotUsa	:={.F.,.F.,.F.,.F.,.F.} //->1=Novo/2=Excluir/3=Fechar

	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		//Return .F.
	Endif

	If U_APPFUN01("Z6_IMPPROD")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		_aRotUsa[1]:=.T.
		_aRotUsa[2]:=.T.
		_aRotUsa[3]:=.T.
	Endif

	DEFINE MSDIALOG oDlgInv TITLE "Inventario" FROM 000, 000  TO nVRes,nHRes PIXEL COLORS 0, 16777215

	@ 000, 000 FOLDER oFolder SIZE 400, nVLim OF oDlgInv ITEMS "Inventarios","Itens do Inventario","Leituras do Inventario" COLORS 0, 16777215 PIXEL
	oFolder:bSetOption := {|| bMudaFolder() }
	fIvents()
	fItensInv(.T.)
	fLeituras()

	_nCol := 5
	@ 002, _nCol CHECKBOX oCHK_NO VAR lCHK_NO PROMPT "Etiqueta Normal" SIZE 075, 008 OF oFolder:aDialogs[3] COLORS 0, 16777215 ON CHANGE bChgLeitu(.F.) PIXEL
	_nCol += 82
	@ 002, _nCol CHECKBOX oCHK_NA VAR lCHK_NA PROMPT "Etiqueta nao Ativada" SIZE 075, 008 OF oFolder:aDialogs[3] COLORS 0, 16777215 ON CHANGE bChgLeitu(.F.) PIXEL
	_nCol += 82
	@ 002, _nCol CHECKBOX oCHK_NL VAR lCHK_NL PROMPT "Etiqueta nao Lida" SIZE 075, 008 OF oFolder:aDialogs[3] COLORS 0, 16777215 ON CHANGE bChgLeitu(.T.) PIXEL

	@ nVLim+5, 005 BUTTON oBtn1 PROMPT "Novo" SIZE 040, 012 OF oDlgInv ACTION Iif(_aRotUsa[1],bNewInv(),Alert("Usuario sem acesso.")) When oFolder:nOption == 1  PIXEL
	@ nVLim+5, 065 BUTTON oBtn2 PROMPT "Registrar" SIZE 040, 012 OF oDlgInv ACTION bRegInv() When oFolder:nOption == 1 PIXEL
	@ nVLim+5, 125 BUTTON oBtn3 PROMPT "Excluir" SIZE 040, 012 OF oDlgInv ACTION Iif(_aRotUsa[2],bExcluir(),Alert("Usuario sem acesso.")) PIXEL
	@ nVLim+5, 185 BUTTON oBtn4 PROMPT "Fechar" SIZE 040, 012 OF oDlgInv ACTION Iif(_aRotUsa[3],bFechar(),Alert("Usuario sem acesso.")) When oFolder:nOption == 1 PIXEL
	@ nVLim+5, 245 BUTTON oBtn6 PROMPT "Filtrar" SIZE 040, 012 OF oDlgInv ACTION bFiltrar() PIXEL
	@ nVLim+5, 305 BUTTON oBtn5 PROMPT "Totais" SIZE 040, 012 OF oDlgInv ACTION bTotais() When oFolder:nOption == 3 PIXEL

	oFolder:Align := CONTROL_ALIGN_TOP
	oIvents:Align := CONTROL_ALIGN_ALLCLIENT
	oItensInv:Align := CONTROL_ALIGN_ALLCLIENT
	oLeituras:Align := CONTROL_ALIGN_BOTTOM
	ACTIVATE MSDIALOG oDlgInv CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bTotais()	 บAutor  ณInfinit     บ Data ณ 02/05/13   	    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma totais do Inventrio										บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bTotais()
	Local oTotais
	Local aTotais := {}
	Local oDlgTot
	Local _I := 0
	Local _nPos := 0
	Local _nTotPes := 0
	Local _nTotCx := 0

	For _I := 1 To Len(aDadosLei)
		If (_nPos := aScan(aTotais, {|x| x[1] == aDadosLei[_I,1] })) > 0
			aTotais[_nPos,2] += bStrToVal(aDadosLei[_I,5])
			aTotais[_nPos,3]++
		Else
			aAdd(aTotais,{aDadosLei[_I,1],bStrToVal(aDadosLei[_I,5]),1})
		EndIf
		_nTotPes += bStrToVal(aDadosLei[_I,5])
		_nTotCx++
	Next _I

	aAdd(aTotais,{"TOTAL------->",_nTotPes,_nTotCx})


	DEFINE MSDIALOG oDlgTot TITLE "Totais por Status" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL
	@ 000, 000 LISTBOX oTotais Fields HEADER "Status","Peso","Caixas" SIZE 250, 150 OF oDlgTot PIXEL ColSizes 50,50
	oTotais:SetArray(aTotais)
	oTotais:bLine := {|| {;
	aTotais[oTotais:nAt,1],;
	Transform(aTotais[oTotais:nAt,2],"@E 999,999,999.99"),;
	Transform(aTotais[oTotais:nAt,3],"@E 999,999,999.99");
	}}
	oTotais:bLDblClick := {|| oTotais:DrawSelect()}
	oTotais:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgTot CENTERED

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bFechar()	 บAutor  ณEvandro Gomes     บ Data ณ 02/05/13   	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicia fechamento do Inventrios								บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bFechar()
	Local _I
	Local _cEtiq := ""
	Private oProcess

	If SubStr(aIvents[oIvents:nAt,5],1,1) <> "A"
		MsgStop("Somente ้ possivel fechar um inventario com o status Aberto.")
		Return
	EndIf

	If !MsgYesNo("Confirma o fechamento do inventario?")
		Return
	EndIf
	oProcess:=MsNewProcess():New( { || bProcFec() } , "Processando fechamento do inventario." , "Aguarde..." , .F. )
	oProcess:Activate()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bProcFec	 บAutor  ณEvandro Gomes     บ Data ณ 02/05/13   	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Processa fechamento do inventrio						    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bProcFec()

	Local _nTotReg := 0
	Local _nRegAtu := 0
	Local _aRegFile:= {}
	Local _aErrFile:= {}
	Local _cArqInv
	Local nHandle 
	Local _cLinWrt

	Begin Transaction

		oProcess:SetRegua1(10)

		ZP7->(dbSetOrder(1))
		If !ZP7->(dbSeek(xFilial()+aIvents[oIvents:nAt,1]))
			MsgStop("Falha na integridade. Inventario "+aIvents[oIvents:nAt,1]+" nao localizado na base.")
			DisarmTransaction()
			Return
		EndIf

		//Atualiza Itens
		oProcess:IncRegua1("Atualiza Itens...")
		oProcess:SetRegua2(1)
		oProcess:IncRegua2("Atualizando...")
		fItensInv(.F.)

		_nTotReg := Len(aItensInv)
		oProcess:IncRegua1("Estoque Por Data...")

		_cQry := " SELECT " 
		_cQry += "BM.BM_GRUPO BM_GRUPO, BM.BM_DESC AS BM_DESC, B1.B1_COD AS B1_COD, B1.B1_DESC AS B1_DESC "
		_cQry += ", COUNT(ZP1.ZP1_CODETI) AS CAIXAS, SUM(ZP1.ZP1_PESO) AS PESO  "
		_cQry += " FROM "+RetSQLName("SBM")+" BM "
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" B1 "
		_cQry += " ON BM.BM_GRUPO = B1.B1_GRUPO "
		_cQry += " INNER JOIN "+RetSQLName("ZP1")+" ZP1 "
		_cQry += " ON ZP1.ZP1_CODPRO = B1.B1_COD "
		_cQry += " AND ZP1.ZP1_STATUS IN ('1','9','7') "
		_cQry += " AND ZP1.ZP1_CARGA = '' "
		_cQry += " AND ZP1.D_E_L_E_T_ = '' "
		_cQry += " WHERE "
		_cQry += " BM.D_E_L_E_T_ = '' "
		_cQry += " AND BM.BM_FILIAL = '0101' "
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT = B1_COD)"
		_cQry += " GROUP BY BM.BM_GRUPO,  BM.BM_DESC, B1.B1_COD , B1.B1_DESC "
		_cQry += " ORDER BY BM.BM_DESC, B1.B1_COD , B1.B1_DESC "
		_cQry:=ChangeQuery(_cQry)

		TcQuery _cQry New Alias "QRYUP"

		_nTotRe:=Contar("QRYUP","!EOF()")
		oProcess:SetRegua2(_nTotReg)

		QRYUP->(dbGoTop())
		While !QRYUP->(EOF())
			oProcess:IncRegua2("Palete: "+QRYUP->B1_DESC)
			nPos:=AScan(aItensInv,{|x| AllTrim(x[1])==AllTrim(QRYUP->B1_COD)})
			AADD(_aRegFile,{"A",QRYUP->B1_COD,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),Transform(QRYUP->PESO,"@E 999,999,999.99"),Transform(QRYUP->CAIXAS,"@E 999,999,999.99"), "", "", "", ""})
			AADD(_aRegFile,{"C",QRYUP->B1_COD,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),Transform(QRYUP->PESO,"@E 999,999,999.99"),Transform(QRYUP->CAIXAS,"@E 999,999,999.99"),Transform(IIF(nPos>0,aItensInv[nPos,5],0),"@E 999,999,999.99"),Transform(IIF(nPos>0,aItensInv[nPos,6],0),"@E 999,999,999.99"),Transform(QRYUP->PESO-IIF(nPos>0,aItensInv[nPos,5],0),"@E 999,999,999.99"),Transform(QRYUP->CAIXAS - IIF(nPos>0,aItensInv[nPos,6],0),"@E 999,999,999.99")})
			QRYUP->(dbSkip())
		EndDo
		QRYUP->(dbGoTop())
		QRYUP->(dbCloseArea())

		//->Paletes nao lidos
		oProcess:IncRegua1("Paletes nao lidos...")
		_cQry := " SELECT ZP1_PALETE, ZP1_CODPRO, ZP1_ENDWMS "
		_cQry += " , 'UPDATE ZP4010 SET D_E_L_E_T_=''*'' WHERE ZP4_FILIAL = ''0101'' 
		_cQry += " AND ZP4_PALETE = '''+ZP1_PALETE+''' "
		_cQry += " AND NOT EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = '' ''"
		_cQry += " 	AND ZP9_FILIAL = ''"+xFilial("ZP9")+"'' "
		_cQry += " 	AND ZP9_DOC = ''"+ZP7->ZP7_DOC+"'' "
		_cQry += " 	AND ZP9_ETIQ = '''+ZP1_PALETE+''');' UPD"
		_cQry += " , 'UPDATE ZP4010 SET D_E_L_E_T_='' '' WHERE ZP4_FILIAL = ''0101'' 
		_cQry += " AND ZP4_PALETE = '''+ZP1_PALETE+''';' UPD_ROLLBACK "
		_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS = '1'"
		_cQry += " AND ZP1_CARGA = ''"
		_cQry += " AND ZP1_PALETE <> ''
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT = ZP1_CODPRO"
		_cQry += " )
		_cQry += " AND NOT EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		_cQry += " GROUP BY  ZP1_PALETE, ZP1_CODPRO, ZP1_ENDWMS "
		TcQuery _cQry New Alias "QRYUP"
		_nTotRe:=Contar("QRYUP","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUP->(dbGoTop())
		While !QRYUP->(EOF())
			oProcess:IncRegua2("Palete: "+QRYUP->ZP1_PALETE)
			AADD(_aRegFile,{"D",QRYUP->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUP->ZP1_PALETE,QRYUP->ZP1_ENDWMS, QRYUP->UPD, QRYUP->UPD_ROLLBACK, "U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUP->ZP1_PALETE+"','C4','Inventario: "+ZP7->ZP7_DOC+"')", "U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUP->ZP1_PALETE+"','D0','Inventario: "+ZP7->ZP7_DOC+"')"})
			QRYUP->(dbSkip())
		EndDo
		QRYUP->(dbGoTop())
		QRYUP->(dbCloseArea())

		//->Caixas nao Lidas
		oProcess:IncRegua1("Caixas nao Lidas...")
		_cQry := " SELECT ZP1_CODETI, ZP1_CODPRO, ZP1_ENDWMS "
		_cQry += " ,'UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS=''5'', ZP1_PALETE = '''' "
		_cQry += " WHERE D_E_L_E_T_ = '' '' AND ZP1_FILIAL = ''0101'' AND ZP1_CODETI = '''+ZP1_CODETI+''' "
		_cQry += " AND NOT EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ''''"
		_cQry += " 	AND ZP9_FILIAL = ''"+xFilial("ZP9")+"'' "
		_cQry += " 	AND ZP9_DOC = ''"+ZP7->ZP7_DOC+"'' "
		_cQry += " 	AND ZP9_ETIQ = '''+ZP1_CODETI+''');' UPD"
		_cQry += " ,'UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS='''+ZP1_STATUS+''', ZP1_PALETE = '''+ZP1_PALETE+''' "
		_cQry += " WHERE D_E_L_E_T_ = '''' AND ZP1_FILIAL = ''0101'' AND ZP1_CODETI = '''+ZP1_CODETI+''';' UPD_ROOLBACK"
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS = '1'"
		_cQry += " AND ZP1_CARGA = ''"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT ='"+ ZP1_CODPRO + "''
		_cQry += " )"
		_cQry += " AND NOT EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		TcQuery _cQry New Alias "QRYUE"
		_nTotReg:=Contar("QRYUE","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUE->(dbGoTop())

		While !QRYUE->(EOF())		
			oProcess:IncRegua2("Caixa: "+QRYUE->ZP1_CODETI)
			AADD(_aRegFile,{"E",QRYUE->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUE->ZP1_CODETI,QRYUE->ZP1_ENDWMS,QRYUE->UPD,QRYUE->UPD_ROOLBACK,"U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUE->ZP1_CODETI+"','C3','Inventario: "+ZP7->ZP7_DOC+"')","U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUE->ZP1_CODETI+"','C9','Inventario: "+ZP7->ZP7_DOC+"')"})
			QRYUE->(dbSkip())
		EndDo

		QRYUE->(dbGoTop())
		QRYUE->(dbCloseArea())

		//->Ajusta Caixas
		oProcess:IncRegua1("Ajusta Caixas...")
		//_cUpd := " UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS = '1', ZP1_DTATIV ='"+DToS(DATE())+"', ZP1_HRATIV = 'INVENTAR'"
		_cQry := " SELECT ZP1_CODETI, ZP1_CODPRO, ZP1_ENDWMS " 
		_cQry += " ,'UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS = ''1'' WHERE ZP1_CODETI='''+ZP1_CODETI+''';' UPD "
		_cQry += " ,'UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS = '''+ZP1_STATUS+''' WHERE ZP1_CODETI='''+ZP1_CODETI+''';' UPD_ROLLBACK "
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ"
		_cQry += " 	FROM "+RetSQLName("ZP9")+" ZP9"
		_cQry += " 	WHERE ZP9.D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_STATUS = 'NA'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		TcQuery _cQry New Alias "QRYUT"
		_nTotReg:=Contar("QRYUT","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUT->(dbGoTop())
		While !QRYUT->(EOF())
			oProcess:IncRegua2("Caixa: "+QRYUT->ZP1_CODETI)
			AADD(_aRegFile,{"F",QRYUT->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUT->ZP1_CODETI,QRYUT->ZP1_ENDWMS, QRYUT->UPD, QRYUT->UPD_ROLLBACK,"U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUT->ZP1_CODETI+"','D1','Inventario: "+ZP7->ZP7_DOC+"')","U_PCPRGLOG("+cValToChar(_nTpLog)+",'"+QRYUT->ZP1_CODETI+"','D2','Inventario: "+ZP7->ZP7_DOC+"')"})
			QRYUT->(dbSkip())
		EndDo
		QRYUT->(dbGoTop())
		QRYUT->(dbCloseArea())
		oProcess:IncRegua1("Ajusta Ativadas...")
		//_cUpd := " UPDATE "+RetSQLName("ZP1")+" SET ZP1_STATUS = '1', ZP1_DTATIV ='"+DToS(DATE())+"', ZP1_HRATIV = 'INVENTAR'"
		_cQry := " SELECT ZP1_CODETI, ZP1_CODPRO, ZP1_ENDWMS " 
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ"
		_cQry += " 	FROM "+RetSQLName("ZP9")+" ZP9"
		_cQry += " 	WHERE ZP9.D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_STATUS <> 'NA'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		_cQry +=" AND (SELECT TOP 1 ZPE_DATA FROM  "+RETSQLNAME("ZPE")+ " ZPE "
		_cQry +=" WHERE ZPE_CODETI=ZP1_CODETI "
		_cQry +=" AND ZPE_CODIGO='03' "
		_cQry +=" AND ZPE.D_E_L_E_T_ <>'*' "
		_cQry +=" ORDER BY ZPE_DATA) BETWEEN '"+Dtos(ZP7->ZP7_DATA)+"' AND '"+Dtos(Date())+"' "
		TcQuery _cQry New Alias "QRYUT"
		_nTotReg:=Contar("QRYUT","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUT->(dbGoTop())
		While !QRYUT->(EOF())
			oProcess:IncRegua2("Caixa: "+QRYUT->ZP1_CODETI)
			AADD(_aRegFile,{"F",QRYUT->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUT->ZP1_CODETI,QRYUT->ZP1_ENDWMS, "", "","",""})
			QRYUT->(dbSkip())
		EndDo
		QRYUT->(dbGoTop())
		QRYUT->(dbCloseArea())

		//->Inventario x Endereco
		oProcess:IncRegua1("Inventario x Endereco...")
		_cQry := " SELECT ZP1_CODPRO "
		_cQry += " , SUM(ZP1_PESO) INVENTARIO "
		_cQry += " , SUM(CASE WHEN ZP1_ENDWMS<>'' THEN ZP1_PESO ELSE 0 END) ENDERECADO "
		_cQry += " , SUM(CASE WHEN ZP1_ENDWMS='' THEN ZP1_PESO ELSE 0 END) NAO_ENDERECADO "
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS = '1'"
		_cQry += " AND ZP1_CARGA = ''"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT = ZP1_CODPRO"
		_cQry += " )"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		_cQry += " GROUP BY ZP1_CODPRO"
		TcQuery _cQry New Alias "QRYUE"
		_nTotReg:=Contar("QRYUE","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUE->(dbGoTop())
		While !QRYUE->(EOF())		
			oProcess:IncRegua2("Produto: "+QRYUE->ZP1_CODPRO)
			AADD(_aRegFile,{"G",QRYUE->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),Transform(INVENTARIO,"@E 999,999,999.99"),Transform(QRYUE->ENDERECADO,"@E 999,999,999.99"),Transform(QRYUE->NAO_ENDERECADO,"@E 999,999,999.99"),"","",""})
			QRYUE->(dbSkip())
		EndDo
		QRYUE->(dbGoTop())
		QRYUE->(dbCloseArea())

		oProcess:IncRegua1("Inventario x Endereco Analitico...")
		_cQry := " SELECT ZP1_CODPRO, ZP1_PALETE, ZP1_ENDWMS, COUNT(*)"
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS = '1'"
		_cQry += " AND ZP1_CARGA = ''"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT = ZP1_CODPRO"
		_cQry += " )"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		_cQry += " GROUP BY ZP1_CODPRO, ZP1_PALETE, ZP1_ENDWMS "
		TcQuery _cQry New Alias "QRYUE"
		_nTotReg:=Contar("QRYUE","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUE->(dbGoTop())
		While !QRYUE->(EOF())		
			oProcess:IncRegua2("Produto: "+QRYUE->ZP1_CODPRO)
			AADD(_aRegFile,{"H",QRYUE->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUE->ZP1_PALETE,QRYUE->ZP1_ENDWMS,"","","",""})
			QRYUE->(dbSkip())
		EndDo
		QRYUE->(dbGoTop())
		QRYUE->(dbCloseArea())

		oProcess:IncRegua1("Leituras de inventario Analitivo...")
		_cQry := " SELECT ZP1_CODPRO, ZP1_CODETI, ZP1_PALETE, ZP1_ENDWMS "
		_cQry += " FROM ZP1010 ZP1"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS = '1'"
		_cQry += " AND ZP1_CARGA = ''"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " 	AND ZP8_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP8_PRODUT = ZP1_CODPRO"
		_cQry += " )"
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " 	AND ZP9_DOC = '"+ZP7->ZP7_DOC+"'"
		_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
		_cQry += " )"
		TcQuery _cQry New Alias "QRYUE"
		_nTotReg:=Contar("QRYUE","!EOF()")
		oProcess:SetRegua2(_nTotReg)
		QRYUE->(dbGoTop())
		While !QRYUE->(EOF())		
			oProcess:IncRegua2("Produto: "+QRYUE->ZP1_CODPRO)
			AADD(_aRegFile,{"I",QRYUE->ZP1_CODPRO,ZP7->ZP7_LOCAL,ZP7->ZP7_DOC,DTOC(ZP7->ZP7_DATA),DTOC(ZP7->ZP7_DTLIM),QRYUE->ZP1_CODETI,QRYUE->ZP1_PALETE,QRYUE->ZP1_ENDWMS,"","",""})
			QRYUE->(dbSkip())
		EndDo
		QRYUE->(dbGoTop())
		QRYUE->(dbCloseArea())


		oProcess:IncRegua1("Gera Arquivo de Inventario...")
		_cArqInv:=GetSrvProfString( "StartPath", "" )+"InvProd\INV"+DTOS(DATE()) + SubStr(Time(),1,2)+ SubStr(Time(),4,2) + ".CSV "
		nHandle := FCreate(_cArqInv)
		_cLinWrt:=""
		If nHandle < 0
			MsgAlert("Erro durante criacao do arquivo.")
			DisarmTransaction()
			Return .F.
		Else
			oProcess:SetRegua2(Len(_aRegFile))
			//->Bloco A
			For _I := 1 To Len(_aRegFile)
				oProcess:IncRegua2("Bloco "+_aRegFile[_I,1]+" Id.:"+_aRegFile[_I,2])
				If AllTrim(_aRegFile[_I,1]) == "A"
					If SB1->(dbSeek(xFilial()+_aRegFile[_I,2]))
						_cLinWrt:=_aRegFile[_I,1]+"|"+_aRegFile[_I,2]+"|"+_aRegFile[_I,3]
						_cLinWrt+="|"+_aRegFile[_I,4]+"|"+_aRegFile[_I,5]+"|"+_aRegFile[_I,6]
						_cLinWrt+="|"+_aRegFile[_I,7]+"|"+_aRegFile[_I,8]+"|"+_aRegFile[_I,9]
						_cLinWrt+="|"+_aRegFile[_I,10]
						_cLinWrt+="|"+_aRegFile[_I,11]
						_cLinWrt+="|"+_aRegFile[_I,12]
						FWrite(nHandle,  _cLinWrt + CRLF)
					Else
						//->Bloco de erros
						AADD(_aErrFile,{"Z",_aRegFile[_I,2],_aRegFile[_I,3],_aRegFile[_I,4],_aRegFile[_I,5],_aRegFile[_I,6],_aRegFile[_I,7],_aRegFile[_I,8],_aRegFile[_I,9],_aRegFile[_I,10],_aRegFile[_I,11],_aRegFile[_I,12]})
					Endif
				Endif
			Next _I

			//->Bloco B
			For _I := 1 To Len(aItensInv)
				oProcess:IncRegua2("Bloco A Id.:"+aItensInv[_I,2])
				_cLinWrt:="B|"+aItensInv[_I,1]+"|"+ZP7->ZP7_LOCAL+"|"+ZP7->ZP7_DOC+"|"+DTOC(ZP7->ZP7_DATA)+"|"+DTOC(ZP7->ZP7_DTLIM)+"|"+aItensInv[_I,3]+"|"+aItensInv[_I,4]+"|"+""+"|"+""+"|"+""+"|"+""
				FWrite(nHandle,  _cLinWrt + CRLF)
			Next _I

			//->Bloco C
			For _I := 1 To Len(_aRegFile)
				oProcess:IncRegua2("Bloco "+_aRegFile[_I,1]+" Id.:"+_aRegFile[_I,2])
				If AllTrim(_aRegFile[_I,1]) == "C"
					If SB1->(dbSeek(xFilial()+_aRegFile[_I,2]))
						_cLinWrt:=_aRegFile[_I,1]+"|"+_aRegFile[_I,2]+"|"+_aRegFile[_I,3]
						_cLinWrt+="|"+_aRegFile[_I,4]+"|"+_aRegFile[_I,5]+"|"+_aRegFile[_I,6]
						_cLinWrt+="|"+_aRegFile[_I,7]+"|"+_aRegFile[_I,8]+"|"+_aRegFile[_I,9]
						_cLinWrt+="|"+_aRegFile[_I,10]
						_cLinWrt+="|"+_aRegFile[_I,11]
						_cLinWrt+="|"+_aRegFile[_I,12]
						FWrite(nHandle,  _cLinWrt + CRLF)
					Else
						//->Bloco de erros
						AADD(_aErrFile,{"Z",_aRegFile[_I,2],_aRegFile[_I,3],_aRegFile[_I,4],_aRegFile[_I,5],_aRegFile[_I,6],_aRegFile[_I,7],_aRegFile[_I,8],_aRegFile[_I,9],_aRegFile[_I,10],_aRegFile[_I,11],_aRegFile[_I,12]})
					Endif
				Endif
			Next _I

			//->Bloco D/E/F
			For _I := 1 To Len(_aRegFile)
				oProcess:IncRegua2("Bloco "+_aRegFile[_I,1]+" Id.:"+_aRegFile[_I,2])
				If AllTrim(_aRegFile[_I,1]) $ "D/E/F/G/H/I"
					If SB1->(dbSeek(xFilial()+_aRegFile[_I,2]))
						_cLinWrt:=_aRegFile[_I,1]+"|"+_aRegFile[_I,2]+"|"+_aRegFile[_I,3]
						_cLinWrt+="|"+_aRegFile[_I,4]+"|"+_aRegFile[_I,5]+"|"+_aRegFile[_I,6]
						_cLinWrt+="|"+_aRegFile[_I,7]+"|"+_aRegFile[_I,8]+"|"+_aRegFile[_I,9]
						_cLinWrt+="|"+_aRegFile[_I,10]
						_cLinWrt+="|"+_aRegFile[_I,11]
						_cLinWrt+="|"+_aRegFile[_I,12]
						FWrite(nHandle,  _cLinWrt + CRLF)
					Else
						//->Bloco de erros
						AADD(_aErrFile,{"Z",_aRegFile[_I,2],_aRegFile[_I,3],_aRegFile[_I,4],_aRegFile[_I,5],_aRegFile[_I,6],_aRegFile[_I,7],_aRegFile[_I,8],_aRegFile[_I,9],_aRegFile[_I,10],_aRegFile[_I,11],_aRegFile[_I,12]})
					Endif
				Endif
			Next _I

			//->Bloco Z - Erros
			oProcess:IncRegua1("Gera Registro de Erros...")
			oProcess:SetRegua2(Len(_aErrFile))
			For _I := 1 To Len(_aErrFile)
				oProcess:IncRegua2("Bloco "+_aErrFile[_I,1]+" Id.:"+_aErrFile[_I,2])
				_cLinWrt:=_aErrFile[_I,1]+"|"+_aErrFile[_I,2]+"|"+_aErrFile[_I,3]+"|"+_aErrFile[_I,4]+"|"+_aErrFile[_I,5]+"|"+_aErrFile[_I,6]+"|"+_aErrFile[_I,7]+"|"+_aErrFile[_I,8]+"|"+_aErrFile[_I,9]+"|"+_aErrFile[_I,10]+"|"+_aErrFile[_I,11]+"|"+_aErrFile[_I,12]
				FWrite(nHandle,  _cLinWrt + CRLF)
			Next _I
		Endif
		FClose(nHandle)
		Alert("Arquivo: "+_cArqInv+ " Gerado com sucesso.")

		/*
		//->Gera Registros Na SB7
		oProcess:IncRegua1("Gera Registros Na SB7...")
		oProcess:SetRegua2(Len(aItensInv))
		SB1->(dbSetOrder(1))
		For _I := 1 To Len(aItensInv)
		_nRegAtu++
		oProcess:IncRegua2("Registro "+AllTrim(StrZero(_nRegAtu,8))+"/"+AllTrim(StrZero(_nTotReg,8)))
		If SB1->(dbSeek(xFilial()+aItensInv[_I,1]))
		RecLock("SB7",.T.)
		SB7->B7_FILIAL	:= xFilial("SB7")
		SB7->B7_COD		:= SB1->B1_COD
		SB7->B7_LOCAL		:= ZP7->ZP7_LOCAL
		SB7->B7_TIPO		:= SB1->B1_TIPO
		SB7->B7_DOC		:= ZP7->ZP7_DOC
		SB7->B7_QUANT		:= bStrToVal(aItensInv[_I,3])
		SB7->B7_QTSEGUM	:= bStrToVal(aItensInv[_I,4])
		SB7->B7_DATA		:= ZP7->ZP7_DATA
		SB7->B7_DTVALID	:= ZP7->ZP7_DTLIM
		SB7->B7_STATUS	:= "1"
		SB7->B7_ORIGEM	:= "PCP023"
		SB7->(MsUnLock())
		Else
		If (TCSQLExec(_cUpd) < 0)
		MsgStop("Falha na integridade. Produto "+aItensInv[_I,1]+" nao localizado")
		DisarmTransaction()
		Return
		EndIf
		EndIf
		Next
		*/

		//Marca inventario como fechado
		oProcess:IncRegua1("Marca inventario como fechado...")
		oProcess:SetRegua2(1)
		oProcess:IncRegua2("Fechando...")
		RecLock("ZP7",.F.)
		ZP7->ZP7_STATUS := "F"
		ZP7->ZP7_USUFEC := cUserName
		ZP7->ZP7_DTFEC  := Date()
		ZP7->ZP7_HRFECH := Time()
		ZP7->(MsUnLock())

		//->Liberando produtos para movimentacoes
		oProcess:IncRegua1("Liberado Produtos...")
		For _I := 1 To Len(aItensInv)
			oProcess:IncRegua2("Liberando:"+aItensInv[_I,1])
			SB2->(dbSetorder(1))
			If SB2->(dbSeek(xFilial("SB2")+Padr(aItensInv[_I,1],TamSx3("B2_COD")[1])+ZP7->ZP7_LOCAL))
				RecLock("SB2",.F.)
				SB2->B2_DINVENT	:= ctod("  /  /    ")
				SB2->B2_DINVFIM	:= ctod("  /  /    ")
				SB2->(MsUnLock())
			Endif
		Next _I

	End Transaction
	oProcess:IncRegua1("Atualizando Exibicoes...")
	oProcess:SetRegua2(4)
	oProcess:IncRegua2("Consulta Itens...")
	fIvents()
	oProcess:IncRegua2("Consulta Inventario...")
	fItensInv(.T.)
	oProcess:IncRegua2("Desabilita Inventario...")
	lCHK_NL := .F.
	oProcess:IncRegua2("Consulta Leituras...")
	fLeituras()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bExcluir()	 บAutor  ณInfinit     บ Data ณ 02/05/13   	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Exclui Inventrios												 บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bExcluir()
	If SubStr(aIvents[oIvents:nAt,5],1,1) <> "A"
		MsgStop("Somente ้ possivel excluir um inventario com o status Aberto.")
		Return
	EndIf
	If oFolder:nOption == 1
		If Aviso("Aten็ao","Confirma a exclusao do inventแrio?",{"Nao","Sim"},1) == 2
			ZP7->(dbSetOrder(1))
			ZP8->(dbSetOrder(1))
			ZP9->(dbSetOrder(1))
			If ZP7->(dbSeek(xFilial()+aIvents[oIvents:nAt,1]))
				Begin Transaction
					RecLock("ZP7",.F.)
					ZP7->(dbDelete())
					ZP7->(MsUnLock())

					ZP8->(dbSeek(xFilial()+aIvents[oIvents:nAt,1]))
					While !ZP8->(EOF()) .AND. ZP8->ZP8_FILIAL == xFilial("ZP8") .AND. ZP8->ZP8_DOC ==aIvents[oIvents:nAt,1]
						RecLock("ZP8",.F.)
						ZP8->(dbDelete())
						ZP8->(MsUnLock())
						ZP8->(dbSkip())
					EndDo

					ZP9->(dbSeek(xFilial()+aIvents[oIvents:nAt,1]))
					While !ZP9->(EOF()) .AND. ZP9->ZP9_FILIAL == xFilial("ZP9") .AND. ZP9->ZP9_DOC ==aIvents[oIvents:nAt,1]
						RecLock("ZP9",.F.)
						ZP9->(dbDelete())
						ZP9->(MsUnLock())
						ZP9->(dbSkip())
						//->Log
						If SubStr(ZP9->ZP9_ETIQ,1,2)="90"
							U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"73","Inventario: "+ZP9->ZP9_DOC)
						Else
							U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"74","Inventario: "+ZP9->ZP9_DOC)
						Endif
					EndDo
				End Transaction
				fIvents()
				cDocAnt := ""
			EndIf
		EndIf
	ElseIf oFolder:nOption == 2
		If Aviso("Aten็ao","Confirma a exclusao do produto "+AllTrim(aItensInv[oItensInv:nAt,2])+" deste inventแrio?"+CHR(10)+"Todas as etiquetas ja lidas deste produtos tamb้m serao excluidas.",{"Nao","Sim"},2) == 2
			ZP8->(dbSetOrder(1))
			If ZP8->(dbSeek(xFilial()+aIvents[oIvents:nAt,1]+aItensInv[oItensInv:nAt,1]))
				Begin Transaction
					RecLock("ZP8",.F.)
					ZP8->(dbDelete())
					ZP8->(MsUnLock())

					//->Tabela de trabalho
					_cQry := " SELECT ZP9_ETIQ
					_cQry += " FROM "+RetSQLName("ZP9")+" ZP9"
					_cQry += " INNER JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_CODETI = ZP9_ETIQ"
					_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '"
					_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
					_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
					_cQry += " AND ZP1_CODPRO = '"+aItensInv[oItensInv:nAt,1]+"'"
					_cQry += " UNION ALL"
					_cQry += " SELECT ZP9_ETIQ"
					_cQry += " FROM "+RetSQLName("ZP9")+" ZP9"
					_cQry += " INNER JOIN "+RetSQLName("ZP4")+" ZP4 ON ZP4.D_E_L_E_T_ = ' ' AND ZP4_FILIAL = ZP9_FILIAL AND ZP4_PALETE = ZP9_ETIQ"
					_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '"
					_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
					_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
					_cQry += " AND ZP4_PRODUT = '"+aItensInv[oItensInv:nAt,1]+"'"
					TcQuery _cQry New Alias "QRYE"
					ZP9->(dbSetOrder(1))
					While !QRYE->(EOF())
						If ZP9->(dbseek(xFilial()+aIvents[oIvents:nAt,1]+QRYE->ZP9_ETIQ))
							RecLock("ZP9",.F.)
							ZP9->(dbDelete())
							ZP9->(MsUnLock())
							If SubStr(ZP9->ZP9_ETIQ,1,2)="90"
								U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"73","Inventario: "+ZP9->ZP9_DOC)
							Else
								U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"74","Inventario: "+ZP9->ZP9_DOC)
							Endif
						EndIf
						QRYE->(dbSkip())
					EndDo
					QRYE->(dbCloseArea())

					//->Arquivo Morto
					_cQry := " SELECT ZP9_ETIQ
					_cQry += " FROM "+RetSQLName("ZP9")+" ZP9"
					_cQry += " INNER JOIN ZP1010_MORTO ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_CODETI = ZP9_ETIQ"
					_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '"
					_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
					_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
					_cQry += " AND ZP1_CODPRO = '"+aItensInv[oItensInv:nAt,1]+"'"
					_cQry += " UNION ALL"
					_cQry += " SELECT ZP9_ETIQ"
					_cQry += " FROM "+RetSQLName("ZP9")+" ZP9"
					_cQry += " INNER JOIN "+RetSQLName("ZP4")+" ZP4 ON ZP4.D_E_L_E_T_ = ' ' AND ZP4_FILIAL = ZP9_FILIAL AND ZP4_PALETE = ZP9_ETIQ"
					_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '"
					_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
					_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
					_cQry += " AND ZP4_PRODUT = '"+aItensInv[oItensInv:nAt,1]+"'"
					TcQuery _cQry New Alias "QRYE"
					ZP9->(dbSetOrder(1))
					While !QRYE->(EOF())
						If ZP9->(dbseek(xFilial()+aIvents[oIvents:nAt,1]+QRYE->ZP9_ETIQ))
							RecLock("ZP9",.F.)
							ZP9->(dbDelete())
							ZP9->(MsUnLock())
							If SubStr(ZP9->ZP9_ETIQ,1,2)="90"
								U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"73","Inventario: "+ZP9->ZP9_DOC)
							Else
								U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"74","Inventario: "+ZP9->ZP9_DOC)
							Endif
						EndIf
						QRYE->(dbSkip())
					EndDo
					QRYE->(dbCloseArea())
				End Transaction
				MsgRun("Atualizando Itens...",,{|| fItensInv(.T.)})
				MsgRun("Atualizando Leituras...",,{|| fLeituras()()})
			EndIf
		EndIf
	Else
		If Aviso("Aten็ao","Confirma a exclusao da etiqueta "+aLeituras[oLeituras:nAt,2]+" deste inventแrio?",{"Nao","Sim"},1) == 2
			ZP9->(dbSetOrder(1))
			ZP1->(dbSetOrder(1))
			ZP4->(dbSetOrder(1))
			_lApaga := .F.
			If ZP9->(dbseek(xFilial()+aIvents[oIvents:nAt,1]+aLeituras[oLeituras:nAt,2]))
				If SubStr(ZP9->ZP9_ETIQ,2) == "90"
					_lApaga := .T.
				ElseIf ZP1->(dbSeek(xFilial()+ZP9->ZP9_ETIQ))
					If Len(AllTrim(ZP1->ZP1_PALETE)) > 0
						If ZP9->(dbseek(xFilial()+aIvents[oIvents:nAt,1]+ZP1->ZP1_PALETE))
							_lApaga := .T.
						EndIf
					Else
						_lApaga := .T.
					EndIf
				Else
					_lApaga := .T.
				EndIf
			ElseIf ZP1->(dbSeek(xFilial()+aLeituras[oLeituras:nAt,2]))
				If ZP9->(dbseek(xFilial()+aIvents[oIvents:nAt,1]+ZP1->ZP1_PALETE))
					_lApaga := .T.
				EndIf
			EndIf
			If _lApaga
				RecLock("ZP9",.F.)
				ZP9->(dbDelete())
				ZP9->(MsUnLock())
				If SubStr(ZP9->ZP9_ETIQ,1,2)="90"
					U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"73","Inventario: "+ZP9->ZP9_DOC)
				Else
					U_PCPRGLOG(_nTpLog,ZP9->ZP9_ETIQ,"74","Inventario: "+ZP9->ZP9_DOC)
				Endif
				MsgRun("Atualizando Itens...",,{|| fItensInv(.T.)})
				MsgRun("Atualizando Leituras...",,{|| fLeituras()()})
			EndIf
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bChgLeitu()	 บAutor  ณInfinit     บ Data ณ 02/05/13   	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Atualiza Leituras												 บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bChgLeitu(_lNL)
	Local _nTamV := ((oFolder:aDialogs[3]:nClientHeight)/2)-15
	Local _lEntra := .T.
	Local _I
	Private _lChgLei := .T.
	_lNL := IIf(_lNL==Nil,.F.,_lNL)

	aLeituras := {}
	If _lNL .AND. lCHK_NL .AND. MsgYesNo("Processa nao lidas? ")
		MsgRun("Atualizando Leituras...",,{|| fLeituras()()})
	EndIf

	For _I:= 1 To Len(aDadosLei)
		_lEntra := .T.
		If SubStr(aDadosLei[_I,1],1,2) == "NO" .AND. !lCHK_NO
			_lEntra := .F.
		ElseIf SubStr(aDadosLei[_I,1],1,2) == "NA" .AND. !lCHK_NA
			_lEntra := .F.
		ElseIf SubStr(aDadosLei[_I,1],1,2) == "NL" .AND. !lCHK_NL
			_lEntra := .F.
		EndIf
		If _lEntra
			aAdd(aLeituras,aClone(aDadosLei[_I]))
		EndIf
	Next _I

	If Len(aLeituras) <= 0
		aAdd(aLeituras,{"","","","","","","",""})
	EndIf

	If oLeituras == Nil
		@ 027, 000 LISTBOX oLeituras Fields HEADER "Status","Etiqueta","Produto","Descricao","Peso","Usuario Leitura","Data Leitura","Hora Leitura" SIZE 396, _nTamV OF oFolder:aDialogs[3] PIXEL //ColSizes 50,50
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
	aLeituras[oLeituras:nAt,7],;
	aLeituras[oLeituras:nAt,8];
	}}
	oLeituras:Refresh()
	If oCHK_NO <> Nil
		oCHK_NO:Refresh()
		oCHK_NA:Refresh()
		oCHK_NL:Refresh()
	EndIf

Return

Static Function fLeituras()
	Local _cQry := ""
	If !_lEntrada
		_cQry += " SELECT * FROM ("
		_cQry += " SELECT"
		_cQry += " CASE ZP9_STATUS"
		_cQry += " 	WHEN 'NO' THEN 'NO-Etiqueta Normal'"
		_cQry += " 	WHEN 'PN' THEN 'NO-Etiqueta Normal'"
		_cQry += " 	WHEN 'NA' THEN 'NA-Etiqueta nao Ativada'"
		_cQry += " 	WHEN 'CA' THEN 'CA-Etiqueta Carregada'"
		_cQry += " 	WHEN 'PC' THEN 'CA-Etiqueta Carregada'"
		_cQry += " 	WHEN 'IN' THEN 'IN-Etiqueta Inexistente'"
		_cQry += " 	WHEN 'PI' THEN 'IN-Etiqueta Inexistente'"
		_cQry += " 	WHEN 'NL' THEN 'NL-Etiqueta nao Lida'"
		_cQry += " 	WHEN 'RP' THEN 'RP-Etiqueta repetida'"
		_cQry += " ELSE ZP9_STATUS END STATUS"
		_cQry += " , ZP9_ETIQ, ISNULL(ZP1_CODPRO,'') ZP9_PRODUT, ISNULL(B1_DESC,'') ZP9_DESCRI"
		_cQry += " , ISNULL(ZP1_PESO,0) ZP9_PESO  , ZP9_USER, ZP9_DATA, ZP9_HORA"
		_cQry += " FROM "+RetSQLName("ZP9")+" ZP9"
		_cQry += " LEFT JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_CODETI = ZP9_ETIQ"
		_cQry += " LEFT JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
		_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
		_cQry += " AND SUBSTRING(ZP9_ETIQ,1,2) <> '90'"
		_cQry += " AND ZP9_STATUS <> 'PA'"

		_cQry += " UNION ALL

		_cQry += " SELECT
		_cQry += " CASE ZP9_STATUS
		_cQry += " 	WHEN 'NO' THEN 'NO-Etiqueta Normal'
		_cQry += " 	WHEN 'PN' THEN 'NO-Etiqueta Normal'
		_cQry += " 	WHEN 'NA' THEN 'NA-Etiqueta nao Ativada'
		_cQry += " 	WHEN 'CA' THEN 'CA-Etiqueta Carregada'
		_cQry += " 	WHEN 'PC' THEN 'CA-Etiqueta Carregada'
		_cQry += " 	WHEN 'IN' THEN 'IN-Etiqueta Inexistente'
		_cQry += " 	WHEN 'PI' THEN 'IN-Etiqueta Inexistente'
		_cQry += " 	WHEN 'NL' THEN 'NL-Etiqueta nao Lida'
		_cQry += " 	WHEN 'RP' THEN 'RP-Etiqueta repetida'
		_cQry += " ELSE ZP9_STATUS END STATUS
		_cQry += " , ISNULL(ZP1_CODETI,ZP9_ETIQ), ISNULL(ZP1_CODPRO,'') PRODUTO, ISNULL(B1_DESC,'') DESCRI
		_cQry += " , ISNULL(ZP1_PESO,0) PESO, ZP9_USER, ZP9_DATA, ZP9_HORA
		_cQry += " FROM "+RetSQLName("ZP9")+" ZP9
		_cQry += " LEFT JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_PALETE = ZP9_ETIQ
		_cQry += " LEFT JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO
		_cQry += " WHERE ZP9.D_E_L_E_T_ = ' '
		_cQry += " AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
		_cQry += " AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
		_cQry += " AND SUBSTRING(ZP9_ETIQ,1,2) = '90'
		_cQry += " AND ZP9_STATUS <> 'PA'"
		If lCHK_NL
			_cQry += " UNION ALL"

			_cQry += " SELECT 'NL-Etiqueta nao Lida' STATUS, ZP1_CODETI, ISNULL(ZP1_CODPRO,'') PRODUTO, ISNULL(B1_DESC,'') DESCRI"
			_cQry += " , ISNULL(ZP1_PESO,0) PESO, '' ZP9_USER, '' ZP9_DATA,  '' ZP9_HORA"
			_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
			_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
			_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
			_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
			_cQry += " AND ZP1_STATUS = '1'"
			_cQry += " AND ZP1_CARGA = ''"
			_cQry += " AND EXISTS ("
			_cQry += " 	SELECT ZP8_PRODUT FROM "+RetSQLName("ZP8")
			_cQry += " 	WHERE D_E_L_E_T_ = ' '"
			_cQry += " 	AND ZP8_FILIAL = '"+xFilial("ZP8")+"'"
			_cQry += " 	AND ZP8_DOC = '"+aIvents[oIvents:nAt,1]+"'"
			_cQry += " 	AND ZP8_PRODUT = ZP1_CODPRO"
			_cQry += " )"
			_cQry += " AND NOT EXISTS ("
			_cQry += " 	SELECT ZP9_ETIQ FROM "+RetSQLName("ZP9")
			_cQry += " 	WHERE D_E_L_E_T_ = ' '"
			_cQry += " 	AND ZP9_FILIAL = '"+xFilial("ZP9")+"'"
			_cQry += " 	AND ZP9_DOC = '"+aIvents[oIvents:nAt,1]+"'"
			_cQry += " 	AND ZP9_ETIQ = ZP1_CODETI"
			_cQry += " )"
		EndIf
		_cQry += " )A"
		If Len(AllTrim(cFiltroL)) > 0
			_cQry += "	WHERE ("+cFiltroL+")"
		EndIf
		_cQry += " ORDER BY 2,1"
		Tcquery _cQry New Alias "QRYL"
		aDadosLei := {}
		While !QRYL->(EOF())
			aAdd(aDadosLei,{QRYL->STATUS,QRYL->ZP9_ETIQ,QRYL->ZP9_PRODUT,QRYL->ZP9_DESCRI,Transform(QRYL->ZP9_PESO,"@E 999,999,999.99"),QRYL->ZP9_USER,IIF(Len(AllTrim(QRYL->ZP9_DATA))>0,DToC(SToD(QRYL->ZP9_DATA)),""),QRYL->ZP9_HORA})
			QRYL->(dbSkip())
		EndDo
		QRYL->(dbCloseArea())
	Else
		_lEntrada := .F.
	EndIf
	If Type("_lChgLei") <> "L"
		bChgLeitu()
	EndIf
Return

Static Function bFiltrar()
	If oFolder:nOption == 1
		cFiltro := BuildExpr("ZP7")
		LjMsgRun( "Processando filtro, aguarde...", "Inventแrio", {|| fIvents() } )
	ElseIf oFolder:nOption == 2
		cFiltroIt := BuildExpr("ZP8",,,.T.)
		LjMsgRun( "Processando filtro, aguarde...", "Itens Inventแrio", {|| fItensInv(.T.) } )
	ElseIf oFolder:nOption == 3
		cFiltroL := BuildExpr("ZP9",,,.T.)
		LjMsgRun( "Processando filtro, aguarde...", "Leituras Inventแrio", {|| fLeituras() } )
	EndIf
Return

/*
Registra etiquetas
*/
Static Function bRegInv()
	Private _cDoc		:= aIvents[oIvents:nAt,1]
	Private oBtnZera
	Private oContad
	Private nContad	:= 0
	Private oEtiq
	Private cEtiq 	:= Space(17)
	Private oFont 	:= TFont():New("Tahoma",,028,,.T.,,,,,.F.,.F.)
	Private oFont1 	:= TFont():New("Tahoma",,024,,.T.,,,,,.F.,.F.)
	Private oLeituras
	Private cLeituras	:= ""
	Private oDlgReg
	Private cStatus	:= ""
	Private oStatusOK
	Private oStatusER

	If SubStr(aIvents[oIvents:nAt,5],1,1) <> "A"
		MsgStop("Somente ้ possivel lan็ar registro de etiquetas em inventarios abertos.")
		Return
	EndIf

	DEFINE MSDIALOG oDlgReg TITLE "Registro de Inventario" FROM 000, 000  TO 600, 320 COLORS 0, 16777215 PIXEL

	@ 005, 005 MSGET oEtiq VAR cEtiq SIZE 150, 020 OF oDlgReg VALID bValEtiq() COLORS 0, 16777215 FONT oFont PIXEL
	@ 032, 005 SAY oSay1 PROMPT "Contador" SIZE 025, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 040, 005 MSGET oContad VAR nContad SIZE 040, 020 OF oDlgReg COLORS 0, 16777215 FONT oFont PIXEL
	@ 040, 050 BUTTON oBtnZera PROMPT "Zerar" SIZE 037, 020 OF oDlgReg ACTION bZerar() PIXEL
	@ 065, 005 SAY oSay2 PROMPT "Leituras Contador" SIZE 075, 007 OF oDlgReg COLORS 0, 16777215 PIXEL
	@ 072, 005 GET oLeituras VAR cLeituras OF oDlgReg MULTILINE SIZE 150, 150 COLORS 0, 16777215 READONLY HSCROLL PIXEL

	@ 225, 005 GET oStatusOk VAR cStatus OF oDlgReg MULTILINE SIZE 150, 070 COLORS 0, 16777215 FONT oFont1 READONLY HSCROLL PIXEL
	@ 225, 005 GET oStatusER VAR cStatus OF oDlgReg MULTILINE SIZE 150, 070 COLORS 0, 16777215 FONT oFont1 READONLY HSCROLL PIXEL
	oStatusER:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oStatusOK:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")
	oStatusOK:Hide()
	oStatusER:Hide()
	ACTIVATE MSDIALOG oDlgReg CENTERED
Return

Static Function bMsgStat()
	Local cTp := ""
	If cStatus == "NO"
		cStatus := "Etiqueta Normal"
	ElseIf cStatus == "NA"
		cTp := "E"
		cStatus := "Etiqueta nao ativada"
	ElseIf cStatus == "CA"
		cTp := "E"
		cStatus := "Etiqueta ja expedida"
	ElseIf cStatus == "IN"
		cTp := "E"
		cStatus := "Etiqueta inexistente"
	ElseIf cStatus == "PN"
		cStatus := "Etiqueta de palete normal"
	ElseIf cStatus == "PI"
		cTp := "E"
		cStatus := "Etiqueta de palete inexistente"
	ElseIf cStatus == "PC"
		cTp := "E"
		cStatus := "Etiqueta de palete ja expedida"
	ElseIf cStatus == "RP"
		cTp := "E"
		cStatus := "Etiqueta com leitura repetida"
	Else
		cTp := "E"
	EndIf

	If cTp == "E"
		oStatusOK:Hide()
		oStatusER:Show()
		Tone()
	Else
		oStatusOK:Show()
		oStatusER:Hide()
	EndIf
	oStatusOK:Refresh()
	oStatusER:Refresh()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bValEtiq()	 บAutor  ณEvandro Gomes   บ Data ณ 02/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Incluso de Etiquetas									บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NUTRIZA							                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function bValEtiq()
	Local _nSoma := 1
	If Len(AllTrim(cEtiq)) > 16
		U_PCPRGLOG(_nTpLog,SubStr(cEtiq,1,16),"87","Inv.:"+_cDoc+"-"+SubStr(cEtiq,1,16)+"("+SubStr(cEtiq,17,1)+")")
		cStatus := "Etiqueta com mais de 16 d’gidos"
	Else
		cEtiq := AllTrim(Upper(cEtiq))
		If Len(allTrim(cEtiq)) == 16
			ZP9->(dbSetOrder(1))
			ZP8->(dbSetOrder(1))
			If !ZP9->(dbSeek(xFilial("ZP9")+_cDoc+cEtiq))
				If SubStr(cEtiq,1,2) <> "90" //Etiqueta Caixa
					ZP1->(dbSetOrder(1))
					If ZP1->(dbSeek(xFilial()+cEtiq))
						If ZP1->ZP1_STATUS=="9"
							cStatus := "Etiqueta suspensa"
							Return(.F.)
						ElseIf !EmpTy(AllTrim(ZP1->ZP1_ENDWMS))
							cStatus := "Etiqueta Enderecada"
							Return(.F.) 
						Endif
						If ZP8->(dbSeek(xFilial()+_cDoc+ZP1->ZP1_CODPRO))
							If Len(AllTrim(ZP1->ZP1_PALETE)) > 0
								If ZP9->(dbSeek(xFilial()+_cDoc+ZP1->ZP1_PALETE))
									If Len(AllTrim(ZP1->ZP1_CARGA)) > 0
										If SubStr(cEtiq,1,2)="90"
											U_PCPRGLOG(_nTpLog,cEtiq,"76","Inventario: "+_cDoc)
										Else
											U_PCPRGLOG(_nTpLog,cEtiq,"75","Inventario: "+_cDoc)
										Endif
										cStatus := "Etiqueta ja Carregada"
									Else
										If Aviso("Aten็ao","Esta etiqueta esta no palete "+ZP1->ZP1_PALETE+". O mesmo ja foi invetariado. Deseja abrir o palete?",{"Nao","Sim"},2) == 2
											cStatus := bAbrePal(ZP1->ZP1_PALETE,cEtiq,.T.)
										Else
											If SubStr(cEtiq,1,2)="90"
												U_PCPRGLOG(_nTpLog,cEtiq,"77","Inventario: "+_cDoc)
											Else
												U_PCPRGLOG(_nTpLog,cEtiq,"78","Inventario: "+_cDoc)
											Endif
											cStatus := "Etiqueta ja se encontra em palete inventariado"
										EndIf
									EndIf
								Else
									Aviso("Aten็ao","Esta etiqueta esta no palete "+ZP1->ZP1_PALETE+". O mesmo sera aberto.",{"OK"},2)
									If SubStr(cEtiq,1,2)="90"
										U_PCPRGLOG(_nTpLog,cEtiq,"91","Inventario: "+_cDoc)
									Else
										U_PCPRGLOG(_nTpLog,cEtiq,"92","Inventario: "+_cDoc)
									Endif
									bAbrePal(ZP1->ZP1_PALETE,,.F.)
									cStatus := "NO"
								EndIf
							Else
								If ZP1->ZP1_STATUS == "1"
									If Len(AllTrim(ZP1->ZP1_CARGA)) > 0
										If SubStr(cEtiq,1,2)="90"
											U_PCPRGLOG(_nTpLog,cEtiq,"76","Inventario: "+_cDoc)
										Else
											U_PCPRGLOG(_nTpLog,cEtiq,"75","Inventario: "+_cDoc)
										Endif
										cStatus := "Etiqueta ja Carregada"
									Else
										If SubStr(cEtiq,1,2)="90"
											U_PCPRGLOG(_nTpLog,cEtiq,"91","Inventario: "+_cDoc)
										Else
											U_PCPRGLOG(_nTpLog,cEtiq,"92","Inventario: "+_cDoc)
										Endif
										cStatus := "NO" //Etiqueta Normal
									EndIf
								Else
									If SubStr(cEtiq,1,2)="90"
										U_PCPRGLOG(_nTpLog,cEtiq,"89","Inventario: "+_cDoc)
									Else
										U_PCPRGLOG(_nTpLog,cEtiq,"90","Inventario: "+_cDoc)
									Endif
									cStatus := "NA" //Etiqueta Nao Ativada
								EndIf
							EndIf
						Else
							If SubStr(cEtiq,1,2)="90"
								U_PCPRGLOG(_nTpLog,cEtiq,"79","Inventario: "+_cDoc)
							Else
								U_PCPRGLOG(_nTpLog,cEtiq,"80","Inventario: "+_cDoc)
							Endif
							cStatus := "O produto desta etiqueta nao consta neste inventario"
						EndIf
					Else
						If SubStr(cEtiq,1,2)="90"
							U_PCPRGLOG(_nTpLog,cEtiq,"81","Inventario: "+_cDoc)
						Else
							U_PCPRGLOG(_nTpLog,cEtiq,"82","Inventario: "+_cDoc)
						Endif
						cStatus := "Etiqueta Inexistente"
					EndIf
				Else //Etiqueta Palete
					ZP4->(dbSetOrder(1))
					If ZP4->(dbSeek(xFilial()+cEtiq))

						If !EmpTy(AllTrim(ZP4->ZP4_ENDWMS))
							cStatus := "Etiqueta Enderecada"
							Return(.F.)
						Endif

						If ZP8->(dbSeek(xFilial()+_cDoc+ZP4->ZP4_PRODUT))
							If Len(AllTrim(ZP4->ZP4_CARGA)) > 0
								If SubStr(cEtiq,1,2)="90"
									U_PCPRGLOG(_nTpLog,cEtiq,"76","Inventario: "+_cDoc)
								Else
									U_PCPRGLOG(_nTpLog,cEtiq,"75","Inventario: "+_cDoc)
								Endif
								cStatus := "Palete ja Carregado"
							Else
								If SubStr(cEtiq,1,2)="90"
									U_PCPRGLOG(_nTpLog,cEtiq,"91","Inventario: "+_cDoc)
								Else
									U_PCPRGLOG(_nTpLog,cEtiq,"92","Inventario: "+_cDoc)
								Endif
								cStatus := "PN" //Etiqueta Palete Normal
							EndIf
							_nSoma:= ZP4->ZP4_CONTAD
						Else
							If SubStr(cEtiq,1,2)="90"
								U_PCPRGLOG(_nTpLog,cEtiq,"79","Inventario: "+_cDoc)
							Else
								U_PCPRGLOG(_nTpLog,cEtiq,"80","Inventario: "+_cDoc)
							Endif
							cStatus := "O produto desta etiqueta nao consta neste inventario"
						EndIf
					Else
						If SubStr(cEtiq,1,2)="90"
							U_PCPRGLOG(_nTpLog,cEtiq,"81","Inventario: "+_cDoc)
						Else
							U_PCPRGLOG(_nTpLog,cEtiq,"82","Inventario: "+_cDoc)
						Endif
						cStatus := "Etiqueta Palente Inexistente"
						_nSoma:=0
					EndIf
				EndIf
			Else
				If SubStr(cEtiq,1,2)="90"
					U_PCPRGLOG(_nTpLog,cEtiq,"77","Inventario: "+_cDoc)
				Else
					U_PCPRGLOG(_nTpLog,cEtiq,"78","Inventario: "+_cDoc)
				Endif
				If SubStr(cEtiq,1,2) <> "90" //Etiqueta Caixa
					cStatus := "Etiqueta com leitura repetida"
				Else
					cStatus := "Palete ja lido anteriormente"
				EndIf
			EndIf

			//->Etiqueta Vlida para Incluso
			If Len(AllTrim(cStatus)) == 2
				RecLock("ZP9",.T.)
				ZP9->ZP9_FILIAL := xFilial("ZP9")
				ZP9->ZP9_DOC    := _cDoc
				ZP9->ZP9_ETIQ   := cEtiq
				ZP9->ZP9_USER   := cUserName
				ZP9->ZP9_DATA   := Date()
				ZP9->ZP9_HORA   := Time()
				ZP9->ZP9_STATUS := cStatus
				ZP9->(MsUnLock())
				If SubStr(cEtiq,1,2) == "90" //->Em caso de etiqueta palete
					bGrvEtiPa(cEtiq)
				EndIf
				nContad+=_nSoma
				If _nSoma > 0
					cLeituras := cEtiq+CHR(13)+CHR(10)+cLeituras
					oLeituras:Refresh()
					oContad:Refresh()
				EndIf
				_nSoma := 1
				//->Log
				If SubStr(cEtiq,1,2)="90"
					U_PCPRGLOG(_nTpLog,cEtiq,"71","Inventrio: "+AllTrim(_cDoc)+"/"+cStatus)
				Else
					U_PCPRGLOG(_nTpLog,cEtiq,"72","Inventrio: "+AllTrim(_cDoc)+"/"+cStatus)
				Endif
			EndIf
			bMsgStat()
			cEtiq := Space(17)
			oEtiq:Refresh()
			oEtiq:SetFocus()
		ElseIf Len(allTrim(cEtiq)) > 0 .AND. Len(allTrim(cEtiq)) <> 16
			If SubStr(cEtiq,1,2)="90"
				U_PCPRGLOG(_nTpLog,cEtiq,"81","Inventario: "+_cDoc)
			Else
				U_PCPRGLOG(_nTpLog,cEtiq,"82","Inventario: "+_cDoc)
			Endif
			cStatus := "Etiqueta invแlida"
			bMsgStat()
			cEtiq := Space(17)
			oEtiq:Refresh()
			oEtiq:SetFocus()
		EndIf
	Endif
Return(.T.)


Static Function bZerar()
	cLeituras := ""
	nContad := 0
	oLeituras:Refresh()
	oContad:Refresh()
	cEtiq := Space(17)
	oEtiq:Refresh()
	oEtiq:SetFocus()
Return

Static Function fItensInv(lFiltro)
	Local _cQry := ""
	If !_lEntrada
		_cQry += " SELECT ZP8_PRODUT, B1_DESC, SUM(ISNULL(ZP8_PESO,0)) ZP8_PESO, SUM(ISNULL(ZP8_CAIXAS,0)) ZP8_CAIXAS"
		_cQry += " FROM ("
		_cQry += " 	SELECT ZP8_FILIAL, ZP8_DOC, ZP8_PRODUT, B1_DESC, ZP9.ZP8_CAIXAS, ZP9.ZP8_PESO"
		_cQry += " 	FROM "+RetSQLName("ZP8")+" ZP8"
		_cQry += " 	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP8.ZP8_PRODUT"
		_cQry += " 		LEFT JOIN ("
		_cQry += " 		SELECT ZP9_FILIAL, ZP9_DOC, ZP1_CODPRO, SUM(ZP1_PESO) ZP8_PESO, COUNT(DISTINCT ZP1_CODETI) ZP8_CAIXAS"
		_cQry += " 		FROM "+RetSQLName("ZP9")+" ZP9"
		_cQry += " 		INNER JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_CODETI = ZP9_ETIQ"
		_cQry += " 		WHERE ZP9.D_E_L_E_T_ = ' '"
		_cQry += " 		AND (ZP9_STATUS = 'NO' OR ZP9_STATUS = 'NA' OR ZP9_STATUS = 'CA')"
		_cQry += " 		GROUP BY ZP9_FILIAL, ZP9_DOC, ZP1_CODPRO"
		_cQry += " 	) ZP9 ON ZP9_FILIAL = ZP8_FILIAL AND  ZP9_DOC = ZP8_DOC AND ZP1_CODPRO = ZP8_PRODUT"
		_cQry += " 	WHERE ZP8.D_E_L_E_T_ = ' '"
		_cQry += " 	UNION ALL"
		_cQry += " 	SELECT ZP8_FILIAL, ZP8_DOC, ZP8_PRODUT, B1_DESC, ZP9.ZP8_CAIXAS, ZP9.ZP8_PESO"
		_cQry += " 	FROM "+RetSQLName("ZP8")+" ZP8"
		_cQry += " 	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP8.ZP8_PRODUT"
		_cQry += " 		LEFT JOIN ("
		_cQry += " 		SELECT ZP9_FILIAL, ZP9_DOC, ZP1_CODPRO, SUM(ZP1_PESO) ZP8_PESO, COUNT(DISTINCT ZP1_CODETI) ZP8_CAIXAS"
		_cQry += " 		FROM "+RetSQLName("ZP9")+" ZP9"
		_cQry += " 		INNER JOIN "+RetSQLName("ZP1")+" ZP1 ON ZP1.D_E_L_E_T_ = ' ' AND ZP1_FILIAL = ZP9_FILIAL AND ZP1_PALETE = ZP9_ETIQ"
		_cQry += " 		WHERE ZP9.D_E_L_E_T_ = ' '"
		_cQry += " 		AND (ZP9_STATUS = 'PN' OR ZP9_STATUS = 'PC')"
		_cQry += " 		GROUP BY ZP9_FILIAL, ZP9_DOC, ZP1_CODPRO"
		_cQry += " 	) ZP9 ON ZP9_FILIAL = ZP8_FILIAL AND  ZP9_DOC = ZP8_DOC AND ZP1_CODPRO = ZP8_PRODUT"
		_cQry += " 	WHERE ZP8.D_E_L_E_T_ = ' '"
		_cQry += " ) A"
		_cQry += " WHERE ZP8_FILIAL = '"+xFilial("ZP8")+"'"
		_cQry += " AND ZP8_DOC = '"+aIvents[oIvents:nAt,1]+"'"
		If Len(AllTrim(cFiltroIt)) > 0 .And. lFiltro
			_cQry += "	AND ("+cFiltroIt+")"
		EndIf
		_cQry += " GROUP BY ZP8_PRODUT, B1_DESC"
		_cQry += " ORDER BY 1"
		TcQuery _cQry New Alias "QRYIT"
		aItensInv := {}
		While !QRYIT->(EOF())
			aAdd(aItensInv,{ZP8_PRODUT,B1_DESC,Transform(ZP8_PESO,"@E 999,999,999.99"),Transform(ZP8_CAIXAS,"@E 999,999,999.99"),ZP8_PESO,ZP8_CAIXAS})
			QRYIT->(dbSkip())
		EndDo
		QRYIT->(dbCloseArea())
	EndIf
	If Len(aItensInv) <= 0
		aAdd(aItensInv,{"",""," ",""})
	EndIf

	If oItensInv == Nil
		@ 000, 000 LISTBOX oItensInv Fields HEADER "Produto","Descricao","Peso","Caixas " SIZE 396, 205 OF oFolder:aDialogs[2] PIXEL //ColSizes 50,50
		oItensInv:bLDblClick := {|| oItensInv:DrawSelect()}
	EndIf
	oItensInv:SetArray(aItensInv)
	oItensInv:bLine := {|| {;
	aItensInv[oItensInv:nAt,1],;
	aItensInv[oItensInv:nAt,2],;
	aItensInv[oItensInv:nAt,3],;
	aItensInv[oItensInv:nAt,4];
	}}
	oItensInv:Refresh()
Return

Static Function bMudaFolder()
	If oFolder:nOption == 1
		If cDocAnt <> aIvents[oIvents:nAt,1]
			cDocAnt := aIvents[oIvents:nAt,1]
			cFiltroIt:=""
			cFiltroL:=""
		EndIf
		MsgRun("Atualizando Itens...",,{|| fItensInv(.T.)})
		MsgRun("Atualizando Leituras...",,{|| fLeituras()()})
	EndIf
Return

Static Function bNewInv()
	Private nOpc := 0
	Private oBtnGera
	Private oBtnProc
	Private oDocument
	Private cDocument := bGetNxtInv()
	Private oDtInv
	Private dDtInv := Date()
	Private oDtLim
	Private dDtLim := Date()
	Private oPrdDe
	Private cPrdDe := Space(15)
	Private oPrdAte
	Private cPrdAte := Replicate("Z",15)
	Private oGrpDe
	Private cGrpDe := Space(4)
	Private oGrpAte
	Private cGrpAte := Replicate("Z",4)
	Private oLocal
	Private cLocal := Space(2)
	Private oOk := LoadBitmap( GetResources(), "LBOK")
	Private oNo := LoadBitmap( GetResources(), "LBNO")
	Private oProds
	Private aProds := {}
	Private oDlgNInv

	DEFINE MSDIALOG oDlgNInv TITLE "Novo Inventแrio" FROM 000, 000  TO 600, 560 COLORS 0, 16777215 PIXEL
	@ 002, 002 SAY oSay1 PROMPT "Documento" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oDocument VAR cDocument SIZE 050, 010 OF oDlgNInv COLORS 0, 16777215 READONLY PIXEL
	@ 002, 060 SAY oSay2 PROMPT "Data Inventแrio" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 010, 060 MSGET oDtInv VAR dDtInv SIZE 050, 010 OF oDlgNInv COLORS 0, 16777215 HASBUTTON PIXEL
	@ 002, 115 SAY oSay3 PROMPT "Data Limite" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 010, 115 MSGET oDtLim VAR dDtLim SIZE 050, 010 OF oDlgNInv COLORS 0, 16777215 HASBUTTON PIXEL
	@ 002, 175 SAY oSay4 PROMPT "Armazem" SIZE 025, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 010, 175 MSGET oLocal VAR cLocal SIZE 030, 010 OF oDlgNInv COLORS 0, 16777215 F3 "NNR" HASBUTTON PIXEL
	@ 025, 002 SAY oSay5 PROMPT "Produto De" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 032, 002 MSGET oPrdDe VAR cPrdDe SIZE 050, 010 OF oDlgNInv COLORS 0, 16777215 F3 "SB1" HASBUTTON PIXEL
	@ 025, 059 SAY oSay6 PROMPT "Produto Ate" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 032, 059 MSGET oPrdAte VAR cPrdAte SIZE 050, 010 OF oDlgNInv COLORS 0, 16777215 F3 "SB1" HASBUTTON PIXEL
	@ 025, 115 SAY oSay7 PROMPT "Grupo De" SIZE 040, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 032, 115 MSGET oGrpDe VAR cGrpDe SIZE 040, 010 OF oDlgNInv COLORS 0, 16777215 F3 "SBM" HASBUTTON PIXEL
	@ 025, 159 SAY oSay8 PROMPT "Grupo Ate" SIZE 050, 007 OF oDlgNInv COLORS 0, 16777215 PIXEL
	@ 032, 159 MSGET oGrpAte VAR cGrpAte SIZE 040, 010 OF oDlgNInv COLORS 0, 16777215 F3 "SBM" HASBUTTON PIXEL
	@ 017, 222 BUTTON oBtnProc PROMPT "Processar" SIZE 050, 025 OF oDlgNInv ACTION fProds() PIXEL
	fProds()
	@ 280, 110 BUTTON oBtnGera PROMPT "Gera Inventแrio" SIZE 050, 012 OF oDlgNInv ACTION (nOpc := 1 ,oDlgNInv:End()) PIXEL

	ACTIVATE MSDIALOG oDlgNInv CENTERED VALID bValFrm()
	If nOpc == 1
		Begin Transaction
			RecLock("ZP7",.T.)
			ZP7->ZP7_FILIAL := xFilial("ZP7")
			ZP7->ZP7_STATUS := "A"
			ZP7->ZP7_DOC    := cDocument
			ZP7->ZP7_DATA   := dDtInv
			ZP7->ZP7_DTLIM  := dDtLim
			ZP7->ZP7_USUABE := cUserName
			ZP7->ZP7_DTABE  := Date()
			ZP7->ZP7_HRABE  := Time()
			ZP7->ZP7_LOCAL  := cLocal
			ZP7->(MsUnLock())
			For _I := 1 To Len(aProds)
				If aProds[_I,1] .AND. Len(AllTrim(aProds[_I,2])) >= 0
					SB2->(dbSetorder(1))
					If SB2->(dbSeek(xFilial("SB2")+Padr(aProds[_I,2],TamSx3("B2_COD")[1])+cLocal))

						RecLock("SB2",.F.)
						SB2->B2_DINVENT	:= Date()
						SB2->B2_DINVFIM	:= Date()+2
						SB2->(MsUnLock())

						RecLock("ZP8",.T.)
						ZP8->ZP8_FILIAL := xFilial("ZP8")
						ZP8->ZP8_DOC    := cDocument
						ZP8->ZP8_PRODUT := aProds[_I,2]
						ZP8->(MsUnLock())
					Else
						Alert("Armazem : "+cLocal+" Nao encontrado para produto: "+aProds[_I,2])
						DisarmTransaction()
						Return .F.
					Endif
				EndIf
			Next _I
		End Transaction
		fIvents()
	EndIf
Return

Static Function bValFrm()
	Local _lRet := .T.
	Local _I := 0
	Local _nHasProd := .F.
	If nOpc == 1
		If Empty(dDtInv)
			MsgStop("Informe a data do inventแrio")
			Return(.F.)
		EndIf
		If Empty(dDtLim)
			MsgStop("Informe a data limite do inventแrio")
			Return(.F.)
		EndIf
		If Len(AllTrim(cLocal)) <= 0
			MsgStop("Informe o armazem")
			Return(.F.)
		EndIf
		For _I := 1 To Len(aProds)
			If aProds[_I,1] .AND. Len(AllTrim(aProds[_I,2])) >= 0
				_nHasProd := .T.
			EndIf
		Next _I
		If !_nHasProd
			MsgStop("Selecione pelo menos um produto.")
			Return(.F.)
		EndIf
	EndIf
Return(_lRet)

Static Function fProds()
	Local _cQry := ""

	If Len(AllTrim(cLocal)) > 0
		_cQry += " SELECT B1_COD, B1_DESC"
		_cQry += " FROM "+RetSQLName("SB1")+" SB1 "
		_cQry += " INNER JOIN "+RetSQLName("SB2")+" SB2
		_cQry += " ON B2_COD = B1_COD "
		_cQry += " AND B2_LOCAL = '"+cLocal+"' "
		_cQry += " AND SB2.D_E_L_E_T_ <> '*' "
		_cQry += " WHERE SB1.D_E_L_E_T_ = ' '"
		_cQry += " AND B1_FILIAL = '"+xFilial("SB1")+"'"
		_cQry += " AND B1_COD BETWEEN '"+cPrdDe+"' AND '"+cPrdAte+"'"
		_cQry += " AND B1_GRUPO BETWEEN '"+cGrpDe+"' AND '"+cGrpAte+"'"
		_cQry += " AND B1_TIPO IN ('PA','ME')"
		_cQry += " ORDER BY B1_DESC"
		TcQuery _cQry New Alias "QRYINV"
		aProds := {}
		While !QRYINV->(EOF())
			aAdd(aProds,{.F.,B1_COD,B1_DESC})
			QRYINV->(dbSkip())
		EndDo
		QRYINV->(dbCloseArea())
	Endif
	If Len(aProds) <= 0
		aAdd(aProds,{.F.,"",""})
	EndIf

	If oProds == Nil
		@ 050, 002 LISTBOX oProds Fields HEADER "","Produto","Descricao" SIZE 275, 225 OF oDlgNInv PIXEL //ColSizes 30,150
		oProds:bLDblClick := {|| aProds[oProds:nAt,1] := !aProds[oProds:nAt,1],oProds:DrawSelect()}
		oProds:bHeaderClick := {|| bInvert()}
	EndIf
	oProds:SetArray(aProds)
	oProds:bLine := {|| {;
	If(aProds[oProds:nAT,1],oOk,oNo),;
	aProds[oProds:nAt,2],;
	aProds[oProds:nAt,3];
	}}
	oProds:Refresh()

Return

Static Function bInvert()
	Local _I := 0
	For _I := 1 To Len(aProds)
		aProds[_I,1] := !aProds[_I,1]
	Next _I
	oProds:SetArray(aProds)
	oProds:bLine := {|| {;
	If(aProds[oProds:nAT,1],oOk,oNo),;
	aProds[oProds:nAt,2],;
	aProds[oProds:nAt,3];
	}}
	oProds:Refresh()
Return

Static Function fIvents()
	aIvents := {}
	ZP7->(dbSetOrder(1))
	ZP7->(dbSeek(xFilial()))
	While !ZP7->(EOF()) .AND. ZP7->ZP7_FILIAL == xFilial("ZP7")
		If Len(AllTrim(cFiltro)) > 0 .AND. !(&cFiltro)
			ZP7->(dbSkip())
			Loop
		EndIf
		aAdd(aIvents,{ZP7->ZP7_DOC,ZP7->ZP7_DATA,ZP7->ZP7_DTLIM,ZP7->ZP7_LOCAL,bStatInv(ZP7->ZP7_STATUS),ZP7->ZP7_USUABE,DToC(ZP7->ZP7_DTABE)+"/"+ZP7->ZP7_HRABE,ZP7->ZP7_USUFEC,DToC(ZP7->ZP7_DTFEC)+"/"+ZP7->ZP7_HRFECH})
		ZP7->(dbSkip())
	EndDo

	If Len(aIvents) <= 0
		aAdd(aIvents,{"","","","","","","","",""})
	EndIf

	If oIvents == Nil
		@ 000, 000 LISTBOX oIvents Fields HEADER "Documento","Data Inventแrio","Data Limite","Armazem","Status","Usuario Abertura","Data/Hora Abertura","Usuario Fechamento","Data/Hora Fechamento" SIZE 396, 082 OF oFolder:aDialogs[1] PIXEL ColSizes 50,50
		oIvents:bLDblClick := {|| oIvents:DrawSelect()}
	EndIf
	oIvents:SetArray(aIvents)
	oIvents:bLine := {|| {;
	aIvents[oIvents:nAt,1],;
	aIvents[oIvents:nAt,2],;
	aIvents[oIvents:nAt,3],;
	aIvents[oIvents:nAt,4],;
	aIvents[oIvents:nAt,5],;
	aIvents[oIvents:nAt,6],;
	aIvents[oIvents:nAt,7],;
	aIvents[oIvents:nAt,8],;
	aIvents[oIvents:nAt,9];
	}}
	oIvents:Refresh()
Return

Static Function bStatInv(_cRet)
	If _cRet == "A"
		_cRet := "Aberto"
	ElseIf _cRet == "B"
		_cRet := "Bloqueado"
	ElseIf _cRet == "F"
		_cRet := "Fechado"
	ElseIf _cRet == "P"
		_cRet := "Processado"
	EndIf
Return(_cRet)

Static Function bGetNxtInv
	Local _cQry := "SELECT MAX(ZP7_DOC) ZP7_DOC FROM "+RetSqlName("ZP7")+" WHERE ZP7_FILIAL = '"+xFilial("ZP7")+"'"
	Local _cRet := "000000000"
	TcQuery _cQry New Alias "QRYSEQ"
	If !QRYSEQ->(EOF())
		_cRet := QRYSEQ->ZP7_DOC
	EndIf
	QRYSEQ->(dbCloseArea())
	_cRet := Soma1(_cRet)
Return(_cRet)

Static Function bStrToVal(_cPar)
	Local _nRet := 0
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
	_nRet := Val(_cPar)
Return(_nRet)

Static Function bAbrePal(cPalete,_cEtiq,_lZP9)
	Local _lRet := .F.
	Local _aAreaZP1 := ZP1->(GetArea())
	Local _cRet := "NO"
	Local _cStEti := ""
	ZP1->(dbSetOrder(2))

	If ZP4->(dbSeek(xFilial()+cPalete))
		_cStEti := ZP4->ZP4_STATUS
		RecLock("ZP4",.F.)
		ZP4->(dbDelete())
		ZP4->(MsUnLock())
		If SubStr(cPalete,1,2)="90"
			U_PCPRGLOG(_nTpLog,cPalete,"83","Inventario: "+_cDoc)
		Else
			U_PCPRGLOG(_nTpLog,cPalete,"84","Inventario: "+_cDoc)
		Endif
	EndIf

	If Len(AllTrim(_cStEti))>0
		_cRet := "NA"
	EndIf

	While ZP1->(dbSeek(xFilial()+cPalete))
		If _lZP9
			RecLock("ZP9",.T.)
			ZP9->ZP9_FILIAL := xFilial("ZP9")
			ZP9->ZP9_DOC    := _cDoc
			ZP9->ZP9_ETIQ   := ZP1->ZP1_CODETI
			ZP9->ZP9_USER   := cUserName
			ZP9->ZP9_DATA   := Date()
			ZP9->ZP9_HORA   := Time()
			ZP9->ZP9_STATUS := IIf(Len(AllTrim(_cStEti))>0,"NA","NO")
			ZP9->(MsUnLock())
			If SubStr(ZP1->ZP1_CODETI,1,2)="90"
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"71","Inventario: "+_cDoc+"/"+IIf(Len(AllTrim(_cStEti))>0,"NA","NO"))
			Else
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"72","Inventario: "+_cDoc+"/"+IIf(Len(AllTrim(_cStEti))>0,"NA","NO"))
			Endif
		EndIf

		If _lZP9 .AND. ZP1->ZP1_CODETI == _cEtiq
			If SubStr(cEtiq,1,2)="90"
				U_PCPRGLOG(_nTpLog,cEtiq,"77","Inventario: "+_cDoc)
			Else
				U_PCPRGLOG(_nTpLog,cEtiq,"78","Inventario: "+_cDoc)
			Endif
			_cRet := "Etiqueta com leitura repetida"
		EndIf

		RecLock("ZP1",.F.)
		ZP1->ZP1_PALETE:= ""
		ZP1->(MsUnLock())
		ZP1->(dbSkip())
		If SubStr(ZP1->ZP1_CODETI,1,2)="90"
			U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"83","Inventario: "+_cDoc)
		Else
			U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"84","Inventario: "+_cDoc)
		Endif
	EndDo
	If _lZP9
		ZP9->(dbSetOrder(1))
		If ZP9->(dbSeek(xFilial()+_cDoc+cPalete))
			RecLock("ZP9",.F.)
			ZP9->(dbDelete())
			ZP9->(MsUnLock())
			If SubStr(cPalete,1,2)="90"
				U_PCPRGLOG(_nTpLog,cPalete,"85","Inventario: "+_cDoc+"/Palete: "+cPalete)
			Else
				U_PCPRGLOG(_nTpLog,cPalete,"86","Inventario: "+_cDoc+"/Palete: "+cPalete)
			Endif
		EndIf
	EndIf
	RestArea(_aAreaZP1)
Return(_cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ bGrvEtiPa()	 บAutor  ณInfinit     บ Data ณ 02/05/13   	บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclui etiqueta caixa no inventrio							บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NUTRIZA							                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function bGrvEtiPa(cPalete)
	ZP1->(dbSetOrder(2))
	ZP1->(dbSeek(xFilial()+cPalete))
	While !ZP1->(EOF()) .AND. ZP1->ZP1_FILIAL == xFilial("ZP1") .AND. ZP1->ZP1_PALETE == cPalete
		RecLock("ZP9",.T.)
		ZP9->ZP9_FILIAL := xFilial("ZP9")
		ZP9->ZP9_DOC    := _cDoc
		ZP9->ZP9_ETIQ   := ZP1->ZP1_CODETI
		ZP9->ZP9_USER   := cUserName
		ZP9->ZP9_DATA   := Date()
		ZP9->ZP9_HORA   := Time()
		ZP9->ZP9_STATUS := "PA"
		ZP9->ZP9_PALETE := cPalete
		ZP9->(MsUnLock())
		//->Log
		If SubStr(ZP1->ZP1_CODETI,1,2)="90"
			U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"71","Inventario: "+_cDoc+"/Palete: "+cPalete+"/PA")
		Else
			U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"72","Inventario: "+_cDoc+"/Palete: "+cPalete+"/PA")
		Endif
		ZP1->(dbSkip())
	EndDo
Return

