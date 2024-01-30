#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "TopConn.ch"
#include "apwizard.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP046    ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Inventario-Ajusta Saldos de Estoque de acordo com o PCP	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descrição
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

*/
User Function PCP046()
	Local _aSay			:= {}
	Local _aButton		:= {}
	Local _xCabec			:= {}
	Private cPerg			:= PADR("PCP046",10)
	Private cTitulo		:= OemtoAnsi("Ajusta arquivo estoque via PCP")
	Private _nOpca		:= 0
	Private oProcess
	Private aErros		:= {} 
	PRIVATE cCusMed 		:= GetMv("MV_CUSMED") // Pega a variavel que identifica se o calculo do custo e: O = On-Line / M = Mensal 
	PRIVATE cCadastro		:= "Atualiza Estoque" 
	PRIVATE aRegSD3 		:= {} 
	PRIVATE _nTpLog		:= GetNewPar("MV_PCPTLOG",1)
	Private lMsErroAuto	:= .F.
	Private lUsaRot		:= GetNewPar("MV_XCPRRCM",.F.) //->Parametro para habilitar uso da rotina.

	If !lUsaRot
		Alert("Rotina desabilitada.")
		Return .F.
	Endif

	PCP046C(cPerg)
	Pergunte(cPerg,.T.)

	Aadd(_aSay, OemToAnsi('Este programa tem a finalidade de: ') )
	Aadd(_aSay, OemToAnsi('Ajusta o estoque de acordo com o relatorio Estoque por data.') )
	Aadd(_aSay, OemToAnsi('Antes de executar este procedimento, realize. as operação de ') )
	Aadd(_aSay, OemToAnsi('importar produção e refazer saldo.') )
	Aadd(_aSay, OemToAnsi('*** Este programa trata somente produtos acabados. ****') )

	AADD(_aButton, { 1,.T.,{|o| _nOpca:= 1,o:oWnd:End()}} )
	AADD(_aButton, { 2,.T.,{|o| o:oWnd:End() }} )
	Aadd(_aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)} } )

	FormBatch(cTitulo, _aSay, _aButton,,, 428)
	If _nOpca == 1
		oProcess := MsNewProcess():New( { || PCP046A() } , "Ajustando Estoque..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif
Return

/*
Ajusta estoque
*/
Static Function PCP046A()
	Local _cQry
	Local nDiff		:= 0
	Local cTipo		:= 'S'
	Local _nConv 		:= 0
	Local _nTConv 	:= 0
	Local _cDocumento	:= ""
	Local _cSerie		:= ""
	Local _cNumSeq	:= ""
	Local _cAliasSD3	:= "SD3TMP"
	Local _nQtd		:= 0
	Local _nQtd2		:= 0 
	Local cCounter	:=	StrZero(0,TamSx3('DB_ITEM')[1])
	Local cSql			:= ""
	Local lContinua	:= .T.
	Local aMovEst		:= {}
	Local aLocais		:= {}
	Local aProdutos	:= {}

	oProcess:SetRegua1(2)
	oProcess:IncRegua1("Atualizando estoque...")

	oProcess:SetRegua2(1)
	oProcess:IncRegua2("Executando Query...")

	_cQry := " SELECT ZP1_CODPRO COD, CASE WHEN SUBSTRING(ZP1_ENDWMS,1,2)='' THEN '10' ELSE SUBSTRING(ZP1_ENDWMS,1,2) END LOCAL"
	_cQry += " ,COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO "
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1"
	_cQry += " ON B1_COD=ZP1_CODPRO "
	_cQry += " AND B1_TIPO='PA' "
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQry += " AND ZP1_STATUS = '1' "
	_cQry += " AND ZP1_CARGA = '' "
	_cQry += " AND ZP1_OP <> '' " 
	_cQry += " GROUP BY ZP1_CODPRO, CASE WHEN SUBSTRING(ZP1_ENDWMS,1,2)='' THEN '10' ELSE SUBSTRING(ZP1_ENDWMS,1,2) END "
	_cQry += " ORDER BY 1,2"
	TcQuery _cQry New Alias "QRY"
	oProcess:SetRegua2(QRY->(LastRec()))
	QRY->(dbGoTop())
	While !QRY->(EOF())

		oProcess:IncRegua2("Produto: "+AllTrim(QRY->COD)+"-"+SubStr(POSICIONE("SB1",1,XFILIAL("SB1")+QRY->COD,"B1_DESC"),1,15))
		_nConv	:= POSICIONE('SB1', 1, xFilial('SB1') + QRY->COD, 'B1_CONV')
		_nTConv:= POSICIONE('SB1', 1, xFilial('SB1') + QRY->COD, 'B1_TIPCONV')
		_cDocumento:=AllTrim(QRY->COD)+DTOC(dDataBase)
		AADD(aProdutos,{QRY->COD,0})

		If aScan(aLocais,{|x| AllTrim(x[1]) == QRY->LOCAL}) == 0
			AADD(aLocais,{QRY->LOCAL,0})
		Endif

		AADD(aErros,{REPLICATE("=",200),""})
		AADD(aErros,{"Produto: " + AllTrim(QRY->COD),""})
		AADD(aErros,{"Descricao: " + POSICIONE("SB1",1,XFILIAL("SB1")+QRY->COD,"B1_DESC"),""})
		AADD(aErros,{"Armazem: " + QRY->LOCAL,""})
		AADD(aErros,{"Tipo de conversao: " + _nTConv,""})
		AADD(aErros,{"Conversor: " + Transform(_nConv,PesqPict("SB1","B1_CONV")),""})

		//->Segunda Unidade de Medida
		If _nTConv=='D' //->Divisor
			_nresto	:= mod(_nQtd, _nConv)
			_nQtd2:=_nQtd/_nConv
		Elseif _nTConv=='M' //->Multiplicador
			_nresto:=_nQtd * _nConv
			_nresto:= mod(_nresto, _nConv)
			_nQtd2:=_nQtd/_nConv
		Else
			AADD(aErros,{"PROBLEMA 01: UNIDADE DE CONVERSAO NAO ENCONTRADA.",""})
			AADD(aErros,{REPLICATE("=",200),""})
			QRY->(dbSkip())
			Loop
		Endif

		AADD(aErros,{"Estoque Camara Unidade de medida 1: " + Transform(QRY->PESO,PesqPict("SB2","B2_QATU")),""})
		AADD(aErros,{"Estoque Camara Unidade de medida 2: " + Transform(_nQtd2,PesqPict("SB2","B2_QATU")),""})

		//->Localiza o Produto em Estoque
		SB2->(dbSetorder(1))
		If SB2->(dbSeek(xFilial("SB2")+QRY->COD+QRY->LOCAL))
			_nQtd:=SB2->B2_QATU-QRY->PESO
			If _nQtd < 0
				_nQtd:=_nQtd * -1
				cTipo:='E'
			Else
				cTipo:='S'
			Endif

			AADD(aErros,{"Estoque Atual: " + Transform(SB2->B2_QATU,PesqPict("SB2","B2_QATU")),""})
			AADD(aErros,{"Estoque Diferenca: " + Transform(_nQtd,PesqPict("SB2","B2_QATU")),""})
			AADD(aErros,{"Movimento: " + cTipo,""})
		Else
			_nQtd:=QRY->PESO
			cTipo:='E'
			AADD(aErros,{"Estoque Atual: " + Transform(0,PesqPict("SB2","B2_QATU")),""})
			AADD(aErros,{"Estoque Diferenca: " + Transform(_nQtd,PesqPict("SB2","B2_QATU")),""})
			AADD(aErros,{"Movimento: " + cTipo,""})
		Endif

		//->Em caso de n‹o haver diferenças
		If _nQtd == 0
			AADD(aErros,{"PROBLEMA 01: SEM QUANTIDADE A SER MOVIMENTADA.",""})
			AADD(aErros,{"PROBLEMA 02: NAO EXISTE AJUSTE A SER MOVIMENTADO.",""})
			AADD(aErros,{REPLICATE("=",200),""})
			QRY->(dbSkip())
			Loop
		Endif

		Begin Transaction
			If _nQtd > 0
				aMovEst:={}
				_cNumSeq	:= "" 
				_cSerie	:= ""
				_cNumSeq	:= ""
				_cSerie 	:= 'J' + cTipo + DTOS(dDataBase) + Replace(Time(),":","")
				_cUM		:= POSICIONE('SB1', 1, xFilial('SB1') + QRY->COD, 'B1_UM')

				If cTipo == "E"
					_cTpMov := "001"
				Else
					_cTpMov := "501"
				EndIf

				aadd( aMovEst, { "D3_TM"     	, _cTpMov				, NIL } )				
				aadd( aMovEst, { "D3_COD"    	, QRY->COD				, NIL } )
				aadd( aMovEst, { "D3_UM"     	, _cUM					, NIL } )
				aadd( aMovEst, { "D3_QUANT"  	, _nQtd				, NIL } )
				aadd( aMovEst, { "D3_LOCAL"  	, QRY->LOCAL			, NIL } )
				aadd( aMovEst, { "D3_EMISSAO"	, dDataBase			, NIL } )
				lMsErroAuto :=.F.

				MSExecAuto( { |x,y| MATA240( x , y ) }, aMovEst, 3 )
				If lMsErroAuto
					MostraErro()
					DisarmTransaction()
					AADD(aErros,{"PROBLEMA 01: NAO FOI POSSIVEL REALIZAR A MOVIMENTACAO INTERNA.",""})
					AADD(aErros,{REPLICATE("=",200),""})
					Break
				Else
					AADD(aErros,{"SUCESSO 01: REALIZADA A MOVIMENTACAO INTERNA.",""})
					AADD(aErros,{"Data de Emissao:"+DTOC(dDataBase),""})
					AADD(aErros,{"Tipo de movimento:"+_cTpMov,""})
					AADD(aErros,{REPLICATE("=",200),""})
				Endif
			Endif
		End Transaction 
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

	oProcess:SetRegua2(1)
	oProcess:IncRegua2("Executando Query...")
	_cQry := " SELECT B2_COD, B2_LOCAL, B2_QATU "
	_cQry += " FROM "+RetSQLName("SB2")+" SB2"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1"
	_cQry += " ON B1_COD=B2_COD "
	_cQry += " AND B1_TIPO='PA' "
	_cQry += " WHERE SB2.D_E_L_E_T_ = ' '"
	_cQry += " AND B2_LOCAL='10' "
	_cQry += " AND NOT EXISTS(SELECT ZP1_CODPRO "
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_STATUS = '1' "
	_cQry += " AND ZP1_CARGA = '' "
	_cQry += " AND ZP1_OP <> '' "
	_cQry += " AND ZP1_CODPRO = B2_COD) "
	_cQry += " ORDER BY B2_COD"
	TcQuery _cQry New Alias "QRY"
	oProcess:SetRegua2(QRY->(LastRec()))
	QRY->(dbGoTop())
	While !QRY->(EOF())
		oProcess:IncRegua2("Produto: "+AllTrim(QRY->B2_COD)+"-"+SubStr(POSICIONE("SB1",1,XFILIAL("SB1")+QRY->B2_COD,"B1_DESC"),1,15))
		AADD(aErros,{REPLICATE("=",200),""})
		AADD(aErros,{"ZERA PRODUTO",""})
		AADD(aErros,{"Produto: " + AllTrim(QRY->B2_COD),""})
		AADD(aErros,{"Descricao: " + POSICIONE("SB1",1,XFILIAL("SB1")+QRY->B2_COD,"B1_DESC"),""})
		AADD(aErros,{"Armazem: " + QRY->B2_LOCAL,""})
		_nQtd:=QRY->B2_QATU
		If _nQtd < 0
			_nQtd:=_nQtd * -1
			cTipo:='E'
		Else
			cTipo:='S'
		Endif
		AADD(aErros,{"Estoque Atual: " + Transform(_nQtd,PesqPict("SB2","B2_QATU")),""})
		AADD(aErros,{"Estoque a Ajustar: " + Transform(_nQtd,PesqPict("SB2","B2_QATU")),""})
		AADD(aErros,{"Movimento: " + cTipo,""})

		Begin Transaction
			If _nQtd > 0
				aMovEst:={}
				_cNumSeq	:= "" 
				_cSerie	:= ""
				_cNumSeq	:= ""
				_cSerie 	:= 'J' + cTipo + DTOS(dDataBase) + Replace(Time(),":","")
				_cUM		:= POSICIONE('SB1', 1, xFilial('SB1') + QRY->B2_COD, 'B1_UM')

				If cTipo == "E"
					_cTpMov := "001"
				Else
					_cTpMov := "501"
				EndIf

				aadd( aMovEst, { "D3_TM"     	, _cTpMov				, NIL } )				
				aadd( aMovEst, { "D3_COD"    	, QRY->B2_COD				, NIL } )
				aadd( aMovEst, { "D3_UM"     	, _cUM					, NIL } )
				aadd( aMovEst, { "D3_QUANT"  	, _nQtd				, NIL } )
				aadd( aMovEst, { "D3_LOCAL"  	, QRY->B2_LOCAL			, NIL } )
				aadd( aMovEst, { "D3_EMISSAO"	, dDataBase			, NIL } )
				lMsErroAuto :=.F.

				MSExecAuto( { |x,y| MATA240( x , y ) }, aMovEst, 3 )
				If lMsErroAuto
					MostraErro()
					DisarmTransaction()
					AADD(aErros,{"PROBLEMA 01: NAO FOI POSSIVEL REALIZAR A MOVIMENTACAO INTERNA.",""})
					AADD(aErros,{REPLICATE("=",200),""})
					Break
				Else
					AADD(aErros,{"SUCESSO 01: REALIZADA A MOVIMENTACAO INTERNA.",""})
					AADD(aErros,{"Data de Emissao:"+DTOC(dDataBase),""})
					AADD(aErros,{"Tipo de movimento:"+_cTpMov,""})
					AADD(aErros,{REPLICATE("=",200),""})
				Endif
			Endif
		End Transaction
		AADD(aErros,{REPLICATE("=",200),""})

		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

	//->Recalcula saldos
	oProcess:SetRegua1(Len(aLocais))
	For x:=1 To Len(aLocais)
		oProcess:IncRegua1("Recalc. Local: "+aLocais[x,1])
		If aLocais[x,1] $ "95/96/97/98"
			PCP046B(aLocais[x,1])
		Endif
	Next x

	U_MFATA07Z("Log de Refaz Saldo",aErros)
Return

/*
Função: PCP046B
Data: 29/02/16
Por: Evandor Gomes
Descrição: Recalcula Saldo
*/
Static Function PCP046B(_cLocal)
	Local aScr
	Local cSql			:=""
	Local _cAliasEnd	:= GetNextAlias()
	Local _cAliasZP4	:= GetNextAlias()
	Local nQtdEnd		:= 0
	Local nLin			:= 0
	Local _cCodEti 
	Local nOcup		:= 0

	cSql:= "Select * "
	cSql+= "From "+RetSqlName("SBE")+" SBE "
	cSql+= "Where "
	cSql+= "	BE_LOCAL='"+_cLocal+"' "
	cSql+= "	AND SBE.D_E_L_E_T_ <> '*' "
	cSql:=ChangeQuery(cSql)
	dbUseArea(.T.,"TopConn",TCGenQry(,,cSql),_cAliasEnd,.F.,.T.)
	oProcess:SetRegua2((_cAliasEnd)->(LastRec()))
	(_cAliasEnd)->(dbGoTop())
	While !(_cAliasEnd)->(Eof())

		oProcess:IncRegua2("Endereco: "+(_cAliasEnd)->BE_LOCALIZ)		

		//->Etiquetas alocadas no Endereo
		nQtdEnd:=0
		BeginSql ALIAS _cAliasZP4
			SELECT
			COUNT(*) QTD
			FROM 
			%Table:ZP4% ZP4
			WHERE
			ZP4_ENDWMS=%Exp:(_cAliasEnd)->BE_LOCAL+(_cAliasEnd)->BE_LOCALIZ%
			AND %NotDel%
		EndSql
		If !(_cAliasZP4)->(Eof())
			nQtdEnd:=(_cAliasZP4)->QTD
		Endif
		(_cAliasZP4)->(dbCloseArea())
		If File(_cAliasZP4+GetDBExtension())
			fErase(_cAliasZP4+GetDBExtension())
		Endif

		//->Cria controle de estoque se n‹o existir
		U_VTFUNCSE((_cAliasEnd)->BE_LOCAL, (_cAliasEnd)->BE_LOCALIZ, (_cAliasEnd)->BE_CODPRO, (_cAliasEnd)->BE_ESTFIS, 0 )
		U_VTFUNMSE(5 ,(_cAliasEnd)->BE_LOCAL, (_cAliasEnd)->BE_LOCALIZ, nQtdEnd)

		(_cAliasEnd)->(dbSkip())
	Enddo
	(_cAliasEnd)->(dbCloseArea())
	If File(_cAliasEnd+GetDBExtension())
		fErase(_cAliasEnd+GetDBExtension())
	Endif
Return


/*
Função: PCP046C
Data: 29/02/16
Por: Evandor Gomes
Descrição: Perguntas
*/
Static Function PCP046C(cPerg)
	PUTSX1(cPerg,"01","Produto de          ?","","","MV_CH1","C",15,00,00,"G","","SB1","","S",MV_PAR01)
	PUTSX1(cPerg,"02","Produto Ate         ?","","","MV_CH2","C",15,00,00,"G","","SB1","","S",MV_PAR02)
Return


