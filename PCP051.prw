#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#define DS_MODALFRAME   128

#define CHR_LINE				'<hr>'
#define CHR_CENTER_OPEN		'<div align="center" >'
#define CHR_CENTER_CLOSE   	'</div>'
#define CHR_FONT_DET_OPEN	'<font face="Courier New" size="3">'
#define CHR_FONT_DET_CLOSE	'</font>'
#define CHR_FONT_VER_OPEN	'<font face="Verdana" size="3">'
#define CHR_FONT_VER_CLOSE	'</font>'
#define CHR_ENTER				'<br>'
#define CHR_NEGRITO			'<b>'
#define CHR_NOTNEGRITO		'</b>'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP051() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13 	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Encerramento de OP												º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Em: 01/11/16															         ±±
±± Por: Evandro Gomes															  ±±
±± Descricao: Adaptado para dados do arquivo morto.				  			  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function PCP05199()
	U_PCP051(2)
Return

User Function PCP051(_nOpc)
	Private oBtnProc
	Private __nOpc	:= Iif(ValType(_nOpc)=="N", _nOpc, 1) //-> 1=Manual/2=Cronometrado
	Private oOk 
	Private oNo 
	Private cProdzp1
	Private cMailImp 
	Private _nTpLog
	Private _lMkpZP1
	Private _cDirErr
	Private _lImpSch
	Private cPerg		
	Private dDtPrdIni
	Private dDtPrdFim
	Private oDlg051
	Private _cFunMrk
	Private _lFecEst
	Private dDataFec
	Private _cPCPAPP
	Private _lProduz
	Private _aFilesEr	:= {} 

	//->Browse de ZPEs
	Private oWBrw051
	Private aWBrw051 	:= {}
	Private cStatus	:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros	:= {}

	//->Par‰metros para interface
	Private _aButts		:= {}
	Private _cTitulo		:= IIf(__nOpc==1,"Encerramento de OP","Encerramento de OP")
	Private _aCabec		:= {}
	Private _aButts		:= {}
	Private aObjects		:= {}

	Private sDtaProdIni		:= ""
	Private oDtaProdIni
	Private dDtaProdIni		:= CTOD("  /  /    ")
	Private sDtaProdFim		:= ""
	Private oDtaProdFim
	Private dDtaProdFim		:= CTOD("  /  /    ")

	_lProduz	:= GetNewPar("MV_XHABPRD",.F.) //-> Habilita funcao de realizar producao
	cProdzp1	:= GetMv('MV_XPRDZP1')	//-> Produtos que nao serão importados = MV_XPRDZP1
	cMailImp	:= GetMV('MV_XIMPPCP')	//-> e-mail que sera avisado sobre falha na importação. 
	_lMkpZP1	:= GetNewPar("MV_MKOPZP1",.F.) //-> Grava rastreamento de caixas
	_cDirErr	:= GetNewPar("MV_XDIRERR",FunName()) //-> Pasta onde var ser gravado o error log
	cPerg		:= PadR(funname(),10)	
	dDtPrdIni	:= ctod("  /  /    ")
	dDtPrdFim	:= ctod("  /  /    ")
	_cFunMrk	:= "PCP051X"
	_lFecEst	:= GetNewPar("MV_XFEHPRD",.F.) //-> Se valida data de fechamento de estoque
	dDataFec 	:= GetMV("MV_ULMES") //-> Data do œltimo fechamento de estoque
	_cPCPAPP	:= GetNewPar("MV_XPCPAPP","10") //->Armazm onde ser‹o alocadas as producoes
	_aFilesEr	:= {} 
	_nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	oOk 		:= LoadBitmap( GetResources(), "LBOK")
	oNo 		:= LoadBitmap( GetResources(), "LBNO")
	oFntSt 	:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)

	If !U_APPFUN01("Z6_IMPPROD")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	AADD(_aButts,{"", { || ExecBlock("PCP051F",.F.,.F.,{cPerg,.T.,.T.,.T.}) },"Filtrar", "Filtrar"})
	AADD(_aButts,{"", { || ExecBlock("PCP051A",.F.,.F.,{3}) },"Inverte", "Inverte"})
	AADD(_aButts,{"", { || ExecBlock("PCP051A",.F.,.F.,{4}) },"Imprimir", "Imprimir"})
	AADD(_aButts,{"", { || ExecBlock("PCP051A",.F.,.F.,{2}) },"Encerrar", "Encerrar"})
	_aCabec:={"","","Produto","Descricao","OP","Item","Seq.","Local","Emissao","Status","RecnoSD3","Sit"}
	If __nOpc == 1 //-> Manual
		ExecBlock("PCP051F",.F.,.F.,{cPerg,.T.,.F.,.F.})
	Else
		aWBrw051:={}
		aAdd(aWBrw051,{.F.,"BR_AZUL","","","","","","","","","","","","",""})
	Endif
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrw051, @oDlg051, @oWBrw051, .T., .F., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F., IIf(__nOpc==2,"PCP051Y",""), IIf(__nOpc==2,60000,""), "PCP51GET" )

Return

/*
Funcao: OHFAP5P1
Descricao: Ponto de entrada para adiconar Say e Get.
*/
User Function PCP51GET
	U_OHFUNA22(@oDlg051,@sDtaProdIni,,"Data Producao:",50,10,,,038,007,,-15,.T.)
	U_OHFUNA23(@oDlg051,@oDtaProdIni, @dDtaProdIni,,80,10,"@D 99/99/9999",.T.,037,57,,-15,.F.,,{})
	U_OHFUNA22(@oDlg051,@sDtaProdFim,,"A:",50,10,,,038,145,,-15,.T.)
	U_OHFUNA23(@oDlg051,@oDtaProdFim, @dDtaProdFim,,80,10,"@D 99/99/9999",.T.,037,175,,-15,.F.,,{})
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Barra de Progresso

nOpc==1 //->Lista Producoes
nOpc==2 //->Executa Producoes
nOpc==3 //->Inverte Selecao
nOpc==4 //->Imprimir

*/
User Function PCP051A()
	Local _lRet 	:= .T.
	Local nOpc		:= PARAMIXB[1]
	Private oProcess
	If nOpc==1 //->Lista Producoes
		oProcess:=MsNewProcess():New( { || PCP051B() } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If ParamIXB[2]
			U_OHFUNA21(@oDlg051, @oWBrw051, _aCabec, @aWBrw051, _cFunMrk)
		Endif
	ElseIf nOpc==2 //->Executa Producoes
		oProcess:=MsNewProcess():New( { || PCP051D() } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
	ElseIf nOpc==3 //->Inverte Selecao
		oProcess:=MsNewProcess():New( { || PCP051C() } , "Invertendo..." , "Aguarde..." , .F. )
		oProcess:Activate()
	ElseIf nOpc==4 //->Imprimir
		oProcess:=MsNewProcess():New( { || PCP051E() } , "Imprimir..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif
Return(_lRet)

/*
Inverte selecao
*/
Static Function PCP051C()
	Local _I := 0
	If !_lImpSch
		oProcess:SetRegua1(1)
		oProcess:SetRegua2(Len(aWBrw051))
		oProcess:IncRegua1("Invertendo selecao")
	Endif
	For _I := 1 To Len(aWBrw051)
		If !_lImpSch
			oProcess:IncRegua2("Prod.:"+aWBrw051[_I,3])
		Endif
		aWBrw051[_I,1] := !aWBrw051[_I,1]
		oWBrw051:aArray[_I][1]:= !oWBrw051:aArray[_I][1]
	Next _I
	oWBrw051:GoTop()
	oWBrw051:Refresh()
	oDlg051:Refresh()
Return

/*
Gera Ordens de Producao
*/
Static Function PCP051D()
	Local _I 			:= 0
	Local lerro		:= .F.
	Local aLog			:= {}
	Local aEtqPrd		:= {}
	Local _lContPrd	:= .T.
	Private _dBkDt 	:= CTOD("  /  /    ")

	_aFilesEr	:= {} //-> Arquivos de Erro
	aErros		:= {}

	/*If dDataFec >= dDtPrdIni
	AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data dentro de um periodo fechado.",""})
	lerro:=.F.
	Endif*/

	If Len(aWBrw051) <= 0
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Dados nao encontrados no array.",""})
		lerro:=.T.
	Endif

	If !lerro
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Processo Iniciado",""})
		oProcess:SetRegua1(Len(aWBrw051))		
		For _I := 1 To Len(aWBrw051) 
			_cNumOp := aWBrw051[_I,5]
			oProcess:IncRegua1("Prod: "+aWBrw051[_I,3]+" OP: "+_cNumOp)
			_lContPrd:=.T. //->Continua producao
			If aWBrw051[_I,1] .And. aWBrw051[_I,12] == '3'
				AADD(aErros,{REPLICATE("=",190),""})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Ordem de Producao: "+_cNumOp,""})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw051[_I,3],""})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw051[_I,4],"B1_DESC"),""})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"R_E_C_N_O_: "+aWBrw051[_I,11],""})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Local: "+aWBrw051[_I,8],""})

				lerro				:= .F.
				lMsErroAuto		:= .F.
				lMsHelpAuto		:= .T. 
				lAutoErrNoFile 	:= .T.

				oProcess:SetRegua2(2)
				oProcess:IncRegua2("Encerrando OP...")
				Begin Transaction
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Iniciando encerramento da OP",""})
					If !EmpTy(AllTrim(aWBrw051[_I,11]))
						SD3->(dbGoto(Val(aWBrw051[_I,11])))
						If SD3->(Recno()) == Val(aWBrw051[_I,11])
							CriaSB2(aWBrw051[_I,3], aWBrw051[_I,8])
							If PCP051N("SD3",Val(aWBrw051[_I,11]),2,@aErros)
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"OP com encerrada sucesso",""})
							Endif
						Else
							AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Problemas ao ecerrar a OP: Registro nao encontrado na SD3",""})
						Endif
					Else
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Problemas ao ecerrar a OP: Nao existe PR0",""})
					Endif
				End Transaction
				oProcess:IncRegua2("Fim Encerrando OP...")
			EndIf
		Next _I
		AADD(aErros,{REPLICATE("=",190),""})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Processo Terminando",""})
	Endif
	PCP051M("Fim do Encerramento de OP: "+dtoc(dDtPrdIni), {}, aErros, _aFilesEr)//->Envia Email
	If Len(aErros) > 0
		U_MFATA07Z("Log de Processamento.",aErros)
	Endif
	ExecBlock("PCP051F",.F.,.F.,{cPerg,.T.,.T.,.T.})
Return

/*
Valida data
*/
Static Function bValDtPrd()
	Local _lRet := .T.
	If Empty(DTOS(dDtPrdIni))
		Return .T.
	Endif
	ExecBlock("PCP051A",.F.,.F.,{1,.T.})
Return(_lRet)

/*
Lista Producao
*/
Static Function PCP051B()
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx		:= 0
	Local cAliasSD3	:= GetNextAlias()
	Local cAliasZP1	:= GetNextAlias()
	Local cAliasREP	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _nRep 		:= 0
	Local _nRepCx		:= 0
	Local _nCxAProd	:= 0
	Local _nKgAProd	:= 0
	Local nRegSD3		:= 0
	Local nRegSH6		:= 0
	Local dEmissao	:= CTOD("  /  /     ")
	Local nLeg			:= 0
	Local nRecSD3		:= 0

	aWBrw051 := {}
	dDtPrdIni:=MV_PAR01
	dDtPrdFim:=MV_PAR02

	_cQry := " SELECT "
	_cQry += " * "
	_cQry += " FROM "+RetSQLName("SC2")+" SC2 WITH (NOLOCK)"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C2_PRODUTO"
	_cQry += " WHERE SC2.D_E_L_E_T_ = ' '"
	_cQry += " AND C2_PRODUTO BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' "
	_cQry += " AND C2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	_cQry += " AND C2_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	_cQry += " AND C2_ITEM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQry += " AND C2_SEQUEN BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQry += " AND C2_DATRF='' "
	_cQry += " ORDER BY C2_EMISSAO"

	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_SC2.SQL", _cQry )
	TcQuery _cQry New Alias "QRYP"
	QRYP->(dbGoBottom())
	oProcess:SetRegua1(2)
	oProcess:SetRegua2(QRYP->(LastRec()))
	oProcess:IncRegua1("Selecionando....")
	QRYP->(dbGoTop())
	_aCodAnt:={}
	While !QRYP->(EOF())

		oProcess:IncRegua2("Prod.:" + SubStr(QRYP->B1_DESC,1,20))

		_nImp		:= 0
		_nImpCx	:= 0
		_nRep 		:= 0
		_nRepCx	:= 0
		_nOpSD3	:= ""
		nRegSD3	:= 0

		cAliasTemp:= "SD3TMP"
		cQuery	:= " SELECT TOP 1 D3_EMISSAO, R_E_C_N_O_ "
		cQuery	+= " FROM " + RetSqlName('SD3') + " SD3 WITH (NOLOCK) "
		cQuery	+= " WHERE D3_FILIAL   = '" + xFilial('SD3')+ "'"
		cQuery	+= " AND D3_OP  = '" + QRYP->(C2_NUM+C2_ITEM+C2_SEQUEN) + "'" //->C2_ITEMGRD
		cQuery	+= " AND D3_ESTORNO <> 'S' "
		cQuery	+= " AND D_E_L_E_T_  = ' '"
		cQuery	+= " AND D3_CF  = 'PR0'"
		cQuery	+= " ORDER BY R_E_C_N_O_ DESC"
		dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)
		If !SD3TMP->(Eof())
			nRecSD3	:= SD3TMP->R_E_C_N_O_
			dEmissao 	:= STOD(SD3TMP->D3_EMISSAO)
			nRegSD3	:= 1
		Endif

		cAliasTemp:= "SH6TMP"
		cQuery	:= " SELECT COUNT(*) AS RegSH6 "
		cQuery	+= " FROM " + RetSqlName('SH6') +" SH6 WITH (NOLOCK) "
		cQuery	+= " WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
		cQuery	+= " AND H6_OP 	   = '" + QRYP->(C2_NUM+C2_ITEM+C2_SEQUEN) + "'" //->C2_ITEMGRD
		cQuery	+= " AND D_E_L_E_T_  = ' '"
		dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)
		If !SH6TMP->(Eof())
			nRegSH6 := SH6TMP->RegSH6
		EndIf

		SD3TMP->(DbCloseArea())
		SH6TMP->(DbCloseArea())


		If QRYP->C2_TPOP == "P" //Prevista
			_cCor:="BR_AMARELO"
			_cStatus:="1-Prevista"
			nLeg:=1
		Elseif QRYP->C2_TPOP == "F" .And. Empty(AllTrim(QRYP->C2_DATRF)) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - STOD(QRYP->C2_DATPRI),0) < If(QRYP->C2_DIASOCI==0,1,QRYP->C2_DIASOCI)) //Em aberto
			_cCor:="BR_VERDE"
			_cStatus:="2-Em Aberto"
			nLeg:=2
		Elseif QRYP->C2_TPOP == "F" .And. Empty(AllTrim(QRYP->C2_DATRF)) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((ddatabase - dEmissao),0) > If(QRYP->C2_DIASOCI >= 0,-1,QRYP->C2_DIASOCI)) //Iniciada
			_cCor:="BR_LARANJA"
			_cStatus:="3-Iniciada"
			nLeg:=3
		Elseif QRYP->C2_TPOP == "F" .And. Empty(AllTrim(QRYP->C2_DATRF)) .And. (Max((ddatabase - dEmissao),0) > QRYP->C2_DIASOCI .Or. Max((ddatabase - STOD(QRYP->C2_DATPRI)),0) >= QRYP->C2_DIASOCI)   //Ociosa
			_cCor:="BR_CINZA"
			_cStatus:="4-Ociosa"
			nLeg:=4
		Elseif QRYP->C2_TPOP == "F" .And. !Empty(AllTrim(QRYP->C2_DATRF)) .And. QRYP->(C2_QUJE < C2_QUANT)  //Enc.Parcialmente
			_cCor:="BR_AZUL"
			_cStatus:="5-Enc.Parcialmente"
			nLeg:=5
		Elseif QRYP->C2_TPOP == "F" .And. !Empty(AllTrim(QRYP->C2_DATRF)) .And. QRYP->(C2_QUJE >= C2_QUANT) //Enc.Totalmente
			_cCor:="BR_VERMELHO"
			_cStatus:="6-Enc.Totalmente"
			nLeg:=6
		Endif

		If nRegSD3 > 0
			aAdd(aWBrw051,{.F.,_cCor,;
			QRYP->C2_PRODUTO,;
			QRYP->B1_DESC,;
			QRYP->C2_NUM,;
			QRYP->C2_ITEM,;
			QRYP->C2_SEQUEN,;
			QRYP->C2_LOCAL,;
			DTOC(STOD(QRYP->C2_EMISSAO)),;
			_cStatus,;
			cValToChar(nRecSD3),;
			cValToChar(nLeg)})
		Endif 

		QRYP->(dbSkip())
	EndDo
	QRYP->(dbCloseArea())

	If Len(aWBrw051) <= 0
		aAdd(aWBrw051,{.F.,"BR_AZUL","","","","","","","","","","","","",""})
	EndIf

Return

Static Function bStrToVal(_cPar)
	Local _nRet := 0
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
	_nRet := Val(_cPar)
Return(_nRet)

/*
Por: Evandro Gomes
Em: 51/08/16
Descrição: Imprimir
*/
Static Function PCP051E()
	Local cTitulo		:= "Relat—rio Fechamento Producao"
	Local cPerg		:= ""
	Local oReport
	Private cAliasPrt	:= "XXXZZB"
	oReport:=FImp2(cPerg, cTitulo, cAliasPrt)
	oReport:PrintDialog()
Return(.T.)

/*
Por: Evandro Gomes
Em: 51/08/16
Descrição: Filtro
{cPerg,.F.,.F.}
{cPerg,.T.,.F.,.F.}
*/
User Function PCP051F()
	Local lPrw	:= PARAMIXB[3]
	PCP051Z(PARAMIXB[1]) //->Cria Perguntas
	If PARAMIXB[2]
		If Pergunte(PARAMIXB[1],.T.)
			dDtaProdIni:=MV_PAR01
			dDtaProdFim:=MV_PAR02
			ExecBlock("PCP051A",.F.,.F.,{1,lPrw})
		Endif
	Else	
		MV_PAR01:=dDtPrdIni 
		MV_PAR02:=dDtPrdFim 
		ExecBlock("PCP051A",.F.,.F.,{1,lPrw})
	Endif
	If PARAMIXB[4]
		oDlg051:Refresh()
	Endif
Return

/*
Por: Evandro Gomes
Em: 51/08/16
Descrição: Imprimir
*/
Static Function FImp2(cPerg, cTitulo, cAliasPrt)
	Local oReport
	oReport:=TReport():New(cPerg, cTitulo,cPerg, {|oReport| FImp3(oReport, cPerg, cTitulo, cAliasPrt)},cTitulo)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
Return(oReport)

/*
Por: Evandro Gomes
Em: 51/08/16
Descrição: Imprimir
*/
Static Function FImp3(oReport, cPerg, cTitulo, cAliasPrt)
	Local oSection1
	oSection1:=TRSection():New(oReport,cTitulo+" Periodo: "+DTOC(dDtPrdIni)+" A "+DTOC(dDtPrdFim)+ "Auditoria(Data: "+DTOC(Date())+" Hora: " + Time()+")",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A1",cAliasPrt,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"A2",cAliasPrt,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"A3",cAliasPrt,OemToAnsi("O.P."),PesqPict('SC2',"C2_NUM"),TamSX3("C2_NUM")[1]+1)
	TRCell():New(oSection1,"A4",cAliasPrt,OemToAnsi("Item"),PesqPict('SC2',"C2_ITEM"),TamSX3("C2_ITEM")[1]+1)
	TRCell():New(oSection1,"A5",cAliasPrt,OemToAnsi("Seq"),PesqPict('SC2',"C2_SEQUEN"),TamSX3("C2_SEQUEN")[1]+1)
	TRCell():New(oSection1,"A6",cAliasPrt,OemToAnsi("Local"),PesqPict('SC2',"C2_LOCAL"),TamSX3("C2_LOCAL")[1]+1)
	TRCell():New(oSection1,"A7",cAliasPrt,OemToAnsi("Emissao"),PesqPict('SC2',"C2_EMISSAO"),TamSX3("C2_EMISSAO")[1]+1)
	TRCell():New(oSection1,"A8",cAliasPrt,OemToAnsi("Status"),"@!",20+1)
	TRCell():New(oSection1,"A9",cAliasPrt,OemToAnsi("RecnoSD3"),"@!",10+1)
	TRCell():New(oSection1,"A10",cAliasPrt,OemToAnsi("Tipo"),"@!",5+1)

	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	oSection1:Init()

	oReport:SetMeter(Len(aWBrw051))
	oProcess:SetRegua1(1)
	oProcess:SetRegua2(Len(aWBrw051))
	oProcess:IncRegua1("Gerando Relatorio")

	For x:=1 To Len(aWBrw051)
		If oReport:Cancel() //->Cancelar
			Exit
		EndIf
		oReport:IncMeter()
		IncProc("Imprimindo Produto "+aWBrw051[x,2])
		oProcess:IncRegua2("Prod: "+aWBrw051[x,2])
		oSection1:Cell("A1"):SetValue(aWBrw051[x,2])
		oSection1:Cell("A2"):SetValue(aWBrw051[x,3])
		oSection1:Cell("A3"):SetValue(aWBrw051[x,4])
		oSection1:Cell("A4"):SetValue(aWBrw051[x,5])
		oSection1:Cell("A5"):SetValue(aWBrw051[x,6])
		oSection1:Cell("A6"):SetValue(aWBrw051[x,7])
		oSection1:Cell("A7"):SetValue(aWBrw051[x,8])
		oSection1:Cell("A8"):SetValue(aWBrw051[x,9])
		oSection1:Cell("A9"):SetValue(aWBrw051[x,10])
		oSection1:Cell("A10"):SetValue(aWBrw051[x,11])
		oSection1:Printline()
	Next x

	oSection1:Finish()
Return(oReport)




/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1M ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Envia Email														¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function PCP051M(_cTitEmail, _aBody, _aDetal, _aFileMail)
	local cPopAddr  := GetMV("MV_WFPOPS")   // Endereco do servidor POP3
	local cSMTPAddr := GetMV("MV_WFSMTPS")  // Endereco do servidor SMTP
	local cPOPPort  := GetMV("MV_WFPRTPO")  // Porta do servidor POP
	local cSMTPPort := GetMV("MV_WFPRTSM")	// Porta do servidor SMTP
	local cUser     := GetMV("MV_WFMAIL")   // Usuario que ira realizar a autenticacao
	local cPass     := GetMV("MV_WFPASSW")  // Senha do usuario
	local oReqAut   := GetMV("MV_WFREQAU")  // Requer Autenticação
	local oReqSSL   := GETMV("MV_WFRESSL")  // Requer Autenticação  
	local nSMTPTime := 60
	Local aSe1		:= {}
	Local aSc6		:= {}
	Local nSp		:= 7
	Local _cAnexos	:= ""
	Local _lEnvMail	:= GetNewPar("MV_XEMFICS",.T.) //-> Data de obrigatoriedade do FICS
	Local cDestino	:= "ti@friato.com.be;"+cMailImp 
	Local	_cSmtpError	:= '',;
	_lOk			:= .f.,;
	_cTitulo 		:= OemToAnsi("Status de Producao Paletizado"),;
	_cTo			:= cDestino,;
	_cFrom			:= 'protheus@friato.com.br',; //->_cMailTec,;
	_cMensagem		:= '',;
	_lReturn		:= .f.

	If !_lEnvMail //->Envio de email n‹o habilitado
		conout( "Envio de email nao habilitado: ERROR" )
		Return .F.
	Endif

	If !empty(cDestino) //-> Existem Contados

		//->Trata Anexos
		If Len(_aFileMail) > 0
			_cAnexos	:= ""
			For _x:=1 To Len(_aFileMail)
				If EmpTy(AllTrim(_cAnexos))
					_cAnexos+= _aFileMail[_x][1]
				Else
					_cAnexos+=";"+_aFileMail[_x][1]
				Endif
			Next
		Endif

		/* Conecta com o Servidor SMTP */
		CONNECT SMTP SERVER AllTrim(cSMTPAddr)+":"+Alltrim(cValtoChar(cSMTPPort)) ;
		ACCOUNT cUser PASSWORD cPass ;
		RESULT lOk

		If lOk
			conout( "Conexão: OK" )

			_cMensagem:= CHR_CENTER_OPEN + CHR_CENTER_CLOSE + CHR_ENTER
			_cMensagem	+= CHR_FONT_DET_OPEN
			_cMensagem	+= CHR_NEGRITO + OemToAnsi(_cTitEmail) + CHR_NOTNEGRITO +  CHR_ENTER + CHR_ENTER
			_cMensagem	+= CHR_NEGRITO + OemToAnsi('Empresa do Grupo: ') + CHR_NOTNEGRITO + SM0->M0_NOME + CHR_ENTER + CHR_ENTER
			_cMensagem	+= CHR_ENTER

			If Len(_aBody) > 0
				For x:=1 To Len(_aBody)
					_cMensagem	+= CHR_NEGRITO + OemToAnsi(_aBody[x,1]) + CHR_NOTNEGRITO + _aBody[x,2] + CHR_ENTER + CHR_ENTER
				Next x
			Endif

			_cMensagem	+= CHR_ENTER
			_cMensagem	+= CHR_NEGRITO + OemToAnsi('Detallhe........: ') + CHR_NOTNEGRITO + CHR_ENTER
			If Len(_aDetal) > 0
				_cMensagem	+= CHR_ENTER
				_cMensagem	+= "<TABLE BORDER=1>"
				_cMensagem	+= "<TR>" 
				_cMensagem	+= CHR_NEGRITO +"<TD ALIGN=MIDDLE WIDTH=500>"+ OemToAnsi('Descricao')+ "</TD>"
				_cMensagem	+= CHR_NEGRITO +"<TD ALIGN=MIDDLE WIDTH=200>"+ OemToAnsi('Status')+ "</TD>"
				_cMensagem	+= CHR_NEGRITO +"</TR>"
				For x:=1 To Len(_aDetal)
					_cMensagem	+= "<TR>"
					_cMensagem	+="<TD ALIGN=LEFT WIDTH=500>" +_aDetal[x,1] + "</TD>"
					_cMensagem	+="<TD ALIGN=MIDDLE WIDTH=200>"+_aDetal[x,2] + "</TD>"
					_cMensagem	+= "</TR>"
				Next xY
				_cMensagem	+= "</TABLE>"	
			Endif
			_cMensagem	+= CHR_ENTER
			_cMensagem	+= CHR_ENTER
			_cMensagem	+= CHR_NEGRITO + OemToAnsi('NUTRIZA S.A.') + CHR_NOTNEGRITO + CHR_ENTER
			_cMensagem	+= OemToAnsi('TECNOLOGIA DA INFORMAÇÃO') + CHR_NOTNEGRITO + CHR_ENTER
			_cMensagem	+= OemToAnsi('ATENCAO: NAO RESPONDER ESTE EMAIL')+ CHR_ENTER + CHR_FONT_VER_CLOSE
			_cMensagem	+= CHR_FONT_DET_CLOSE
			conout( "Composicao de mensagem: OK" )
			SEND MAIL FROM _cFrom ;
			TO _cTo ;
			SUBJECT _cTitulo ;
			BODY _cMensagem ;
			attachment _cAnexos ;
			RESULT lOk      
			If lOk
				conout( "Envio OK" )
			Else
				GET MAIL ERROR cSmtpError
				conout( "Erro de envio : " + cSmtpError)
			Endif

			// Desconecta do Servidor
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cSmtpError
			conout( "Erro de conexão : " + cSmtpError)
		Endif
	Endif
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCP051N  ³ Autor ³ Marcos Bregantim      ³ Data ³ 11/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Encerramento de Ops.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250Encer(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA250                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCP051N(cAlias,nReg,nOpc,_aErr)
	Local lDigAuto	:= .F.
	Local aAC 		 	:= {"Abandona","Confirma"}
	Local bCampo     	:= {|nCpo| Field(nCpo) }
	Local cMascara	:= GetMv("MV_MASCGRD")
	Local nProdProp  	:= GetMV("MV_PRODPR0",NIL,1)
	Local nTamRef	 	:= Val(Substr(cMascara,1,2))
	Local lMonta     	:= .F.
	Local lParcTot   	:= .F.
	Local lQuery	 	:= .F.
	Local lContinua	:= .T.
	Local cCodRef	 	:= ''
	Local cNumOP     	:= ''
	Local cSeqPai    	:= ''
	Local aAreaSD3   	:= ''
	Local cQuery	 	:= ''
	Local cAliasNew	:= ''
	Local nQuant     	:= 0
	Local nQuant2UM  	:= 0
	Local nPerda     	:= 0
	Local cOpOrig    	:= 0
	Local i          	:= 0
	Local aTam		 	:= {}
	Local aSize      	:= {}
	Local aObjects   	:= {}
	Local aInfo      	:= {}
	Local cOp, nRecSD3
	Local nOpca, oDlg
	Local cChavPesq 	:= SD3->(D3_OP+D3_COD)
	Local dDtUltPR0 	:= SD3->D3_EMISSAO
	Local lA250SPRC 	:= NIL
	Local lIntSFC		:= IntegraSFC() .And. !IsInCallStack("AUTO681")
	Local dDataBloq  	:= GetNewPar("MV_ATFBLQM",CTOD(""))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se devera' encerrar ou nao todos os itens da Grade     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lEncGrd   := If( mv_par09 == 1, .T., .F.)

	Private aTELA[0][0],aGETS[0]
	Private aNeed 		:= {}
	Private lDelOpSC := GetMV("MV_DELOPSC")== "S"
	Private aRotAuto    := Nil
	Private lPerdInf    := SuperGetMV("MV_PERDINF",.F.,.F.)
	Private nFCICalc    := SuperGetMV("MV_FCICALC",.F.,0)
	PRIVATE aCtbDia	    := {}                   

	Private lExistePM   := .F. //Indica se existe produção a maior para permitir requisitar quando o empenho estiver zerado

	Private lLoteACD := SuperGetMV("MV_INTACD",.F.,"0") == "1" .And.;
	IsInCallStack("ACDV020") .And. ;
	ValType(xRotAuto) == "A" .And. ;
	Len(xRotAuto) >= 8 .And.;
	aScan(xRotAuto[8],"D3_LOTECTL") > 0 .And. ;
	!Empty(xRotAuto[8,2])

	Private lProdAut := GetMv("MV_PRODAUT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas no Apontamento de Refugo por Motivo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lSavePerda	:= .F.
	Private lEnvCQProd 	:= .F.
	Private aPerda  	:= {}
	Private aHdPerda 	:= {}
	Private nPosQuant,nPosMot,nPosDesc,nPosTipo,nPosCod,nPosLoc,nPosLote

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega a variavel que identifica se o calculo do custo e' :    ³
	//³               O = On-Line                                    ³
	//³               M = Mensal                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCusMed 	:= GetMv("mv_CusMed")
	Private lDigAutoAux := lDigAuto
	Private l250Auto 	:= ( aRotAuto <> Nil )
	Private l240Auto 	:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variavel utilizada para Integracao com Quality - Processos  	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lIntQual	:=.F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On-Line               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCusMed == "O"

		Private nHdlPrv 			// Endereco do arquivo de contra prova dos lanctos cont.

		Private cLoteEst 			// Numero do lote para lancamentos do estoque

		Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX5")
		dbSeek(xFilial("SX5")+"09EST")
		cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")

		Private nTotal		:= 0	// Total dos lancamentos contabeis

		Private cArquivo			// Nome do arquivo contra prova

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Esta variavel indica se utiliza segunda unidade de medida    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lUsaSegUm

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estas variaveis indicam para as funcoes de validacao qual    ³
	//³ programa as esta' chamando                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private l240:=.F.,l250 :=.T.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.F.

	Private dDataFec:= MVUlmes()

	If Type("l250Auto") == "U"
		Private l250Auto := .F.
	EndIf

	If cAlias=="SD3"
		// Posiciona SB1 para referencia de validação de produto bloqueado.
		DbSelectArea("SB1")
		DbSetOrder(1)
		MsSeek(xFilial("SB1")+SD3->D3_COD)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario tem permissao de alteracao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lContinua := MaAvalPerm(1,{SD3->D3_COD,"MTA650",4})
	If !lContinua
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Sem permissao para prosseguir...",""})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica calendário contábil                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua 
		If lContinua := (CtbValiDt(Nil,SD3->D3_EMISSAO,,Nil ,Nil ,{"EST001"}))
			If !Empty(dDataBloq) .And. (SD3->D3_EMISSAO <= dDataBloq)
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Calendario contabil fechado...",""})
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	dbSelectArea(cAlias)
	If Subs(D3_CF,1,2) == "ER"
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Este e um movimento originado por um movimento",""})
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"de estorno de producao, portanto nao pode ser estornado",""})
		lContinua := .F.
	ElseIf Subs(D3_CF,1,2) != "PR"
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Este e um movimento nao e uma producao",""})
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"portanto nao pode ser acessado.",""})
		lContinua := .F.
	ElseIf D3_ESTORNO == "S"
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Esta producao ja foi estornada.",""})
		Help(" ",1,"A250ESTORN")
		lContinua := .F.
	EndIf

	//-- Tratamento de Encerramento de OP com separação WMS, somente permitirá caso seja estornado o Serviço no WMS
	If lContinua .And. IntDl() .And. !WmsEstOp()
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Esta ordem de produção possui empenhos em uma ordem de separação WMS. Exclua a ordem de separação para realizar esta operação..",""})
		lContinua := .F.
	EndIf             

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar data do ultimo fechamento em SX6.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*If lContinua .And. dDataFec >= dDataBase
	AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Estoque fechado.",""})
	lContinua := .F.
	EndIf*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida produtos bloqueados(Produtos Acabados)		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. SB1->B1_MSBLQL $ "1" 
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto bloqueado...",""})
		lContinua := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Ordem de Producao nao foi encerrada por outra estacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. SC2->(dbSeek(xFilial("SC2")+Alltrim(SD3->D3_OP))) .And. !Empty(SC2->C2_DATRF)
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Ordem de producao encerrada...",""})
		lContinua := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forca o posicionamento no ultimo apontamento de producao.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecSD3 := Recno()
	dbSetOrder(1)
	dbSeek(xFilial("SD3")+cChavPesq)
	While !EOF() .And. D3_FILIAL+D3_OP+D3_COD == xFilial("SD3")+cChavPesq
		If Substr(D3_CF,1,2) == "PR" .And. D3_ESTORNO # "S" .And. D3_EMISSAO > dDtUltPR0
			nRecSD3 := Recno()
			dDtUltPR0 := D3_EMISSAO
		EndIf
		dbSkip()
	End
	MsGoTo(nRecSD3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Ordem de Producao possui saldo em processo	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("A250SPRC")
		lA250SPRC := ExecBlock("A250SPRC",.F.,.F.,{D3_OP,D3_EMISSAO})
	EndIf
	If lContinua .And. If(ValType(lA250SPRC)#"L",A250VerReq(D3_OP,D3_EMISSAO),!lA250SPRC)
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"A Ordem de producao nao pode ser encerrada, ",""})
		AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"pois possue saldos de requisicoes em aberto. ",""})
		lContinua := .F.
	EndIf

	//-- Impede encerramento de OP integrada ao Chao de Fabrica
	If lContinua .And. lIntSFC
		CYQ->(dbSetOrder(1))
		lContinua := !CYQ->(dbSeek(xFilial("CYQ")+SD3->D3_OP))
		If !lContinua
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Esta OP é movimentada somente através do módulo Chão de Fábrica.",""})
		EndIf                               
	EndIf

	If lContinua
		aAreaSD3:= SD3->(GetArea())
		cNum 	:= SD3->D3_DOC
		cItemGrd:= Right(SD3->D3_OP,Len(SC2->C2_ITEMGRD))
		cNumOp  := Substr(SD3->D3_OP,1,Len(SD3->D3_OP)-Len(cItemGrd))
		cOpOrig := SD3->D3_OP
		cDoc    := SD3->D3_DOC
		cSeqPai := SC2->C2_SEQPAI

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for encerrar todos os itens da Grade,a Enchoice sera' mon-³
		//³ tada de acordo com as variaveis de memoria, caso contrario,  ³
		//³ sera' montada baseando-se no registro corrente no SD3        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEncGrd .And. !Empty(cItemGrd)
			lMonta := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva a integridade dos campos de Bancos de Dados            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i := 1 To FCount()
				M->&(EVAL(bCampo,i)) := FieldGet(i)
			Next i
			dbSetOrder(2)
			dbSeek(xFilial("SD3")+cDoc)
			aAreaSD3:=SD3->(GetArea())  
			lQuery := .T.
			cAliasNew := GetNextAlias()
			cQuery := " SELECT SUM(D3_QUANT) QTD, SUM(D3_QTSEGUM) QTSEGUM, SUM(D3_PERDA) PERDA FROM "+RetSqlName('SD3')
			cQuery += " WHERE "
			cQuery += " D3_FILIAL = '"+xFilial("SD3")+"' AND "
			cQuery += " D3_DOC = '"+cDoc+"' AND "
			cQuery += " D3_ESTORNO <> 'S' AND "
			cQuery += " D3_CF = 'PRO' AND "  
			cQuery += " D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
			aTam := TamSx3("D3_QUANT")
			TCSetField( cAliasNew, "QTD", "N",aTam[1] , aTam[2] )
			aTam := TamSx3("D3_QTSEGUM")
			TCSetField( cAliasNew, "QTSEGUM", "N",aTam[1] , aTam[2] )
			aTam := TamSx3("D3_PERDA")
			TCSetField( cAliasNew, "PERDA", "N",aTam[1] , aTam[2] )
			If lQuery
				nQuant 	:= (cAliasNew)->QTD
				nQuant2UM	:= (cAliasNew)->QTSEGUM 
				nPerda		:= (cAliasNew)->PERDA
				(cAliasNew)->(DbCloseArea())
				SD3->(RestArea(aAreaSD3))
			Else
				Do While ! Eof() .And. D3_FILIAL+SD3->D3_DOC == xFilial("SD3")+cDoc
					If D3_ESTORNO != "S" .And. D3_CF == "PR0"
						nQuant+= D3_QUANT
						nQuant2UM += D3_QTSEGUM
						nPerda+=D3_PERDA
					EndIf
					dbSkip()
				EndDo  
			EndIf

			If IsAtNewGrd()
				cCodRef		 := M->D3_COD
				MatGrdPrrf(@cCodRef,.T.)
				M->D3_COD    := cCodRef      
			Else
				M->D3_COD    := Substr(M->D3_COD,1,nTamRef)
			EndIf           

			M->D3_QUANT  := nQuant
			M->D3_QTSEGUM:= nQuant2UM
			M->D3_PERDA  := nPerda
			M->D3_LOTECTL:= ' '
			M->D3_OP     := Substr(M->D3_OP,1,Len(M->D3_OP)-Len(cItemGrd))
		EndIf

		nOpca:= 2 //->If( (!lIntQual) .Or. A250EndOk(), 2, 0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa funcao que encerra OP              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcA == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Quando utiliza proporcionalizacao tipo 3   ³
			//³ no recalculo do custo medio pergunta se    ³
			//³ altera tipo do apontamento                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nProdProp == 3
				lParcTot:= .F. //->Aviso(STR0035,STR0060,{STR0056,STR0057},,,1) == 1
			EndIf

			RestArea(aAreaSD3)

			While !Eof() .And. D3_FILIAL+D3_DOC == xFilial("SD3")+cDoc

				If !(D3_CF $ "PR0/PR1")
					dbSkip()
					loop
				EndIf
				If !lEncGrd .And. Right(SD3->D3_OP,Len(SC2->C2_ITEMGRD))!=cItemGrd
					dbSkip()
					loop
				EndIf
				If SC2->(dbSeek(xFilial("SC2")+SD3->D3_OP)) .And. Empty(SC2->C2_DATRF)
					If (SC2->C2_SEQPAI > cSeqPai .Or. (SC2->C2_SEQPAI == cSeqPai .And. SD3->D3_OP == cOpOrig))
						If lParcTot
							Reclock("SD3",.F.)
							Replace D3_PARCTOT With "T"
							MsUNlock()
						EndIf
						A250End(.T.)
					EndIf
				EndIf
				dbSelectArea("SD3")
				SD3->(dbSkip())
			EndDo
		EndIf
	EndIf
	dbSelectArea(cAlias)
Return(lContinua)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A250End   ³ Autor ³Rodrigo de A. Sartorio³ Data ³ 04/09/97  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encerra ordens de producao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A250End()      				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Function A250End(lEncerra)

Local aAreaAnt    := {}
Local aTravas     := {}
Local aLstOpDep   := {}
Local aOpsPis     := {}

Local lSD3250R    := ExistBlock("SD3250R")
Local lA250ENOP   := ExistBlock("A250ENOP")
Local lConsVenc   := GetMV('MV_LOTVENC')=='S'
Local lPergAtuEmp := SuperGetMV("MV_PATUEMP",,"S") =="S"

Local lAtuEmp     := .F.
Local lRetPE      := .F.
Local cSeek       := ''
Local nLoop       := Nil
Local nRecSD3
Local nEntregSC7  := 0
Local lExcluiAE := IIF(GetMv("MV_DELEAE")=="S",.T.,.F.)

Default lEncerra  := .F. 

If Type("lPerdInf") == "U" 
lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza arquivo de empenhos e B2_QEMP     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF5")
dbSeek(xFilial("SF5")+SD3->D3_TM)
If F5_ATUEMP == "N" .And. lPergAtuEmp .And. __cInternet#"AUTOMATICO"
lAtuEmp:=Aviso(OemToAnsi(STR0035),OemToAnsi(STR0061),{OemToAnsi(STR0056),OemToAnsi(STR0057)},,, 2) == 1
EndIf		

Begin Transaction	
If F5_ATUEMP == "S" .Or. (lAtuEmp)
dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial("SD4")+SD3->D3_OP)
While !EOF() .And. D4_FILIAL+D4_OP==xFilial("SD4")+SD3->D3_OP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza arq. de saldos  B2_QEMP                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GravaEmp(	SD4->D4_COD,;
SD4->D4_LOCAL,;
SD4->D4_QUANT,;
SD4->D4_QTSEGUM,;
SD4->D4_LOTECTL,;
SD4->D4_NUMLOTE,;
NIL,;
NIL,;
SD4->D4_OP,;
SD4->D4_TRT,;
NIL,;
NIL,;
"SC2",;
NIL,;
SD4->D4_DATA,;
@aTravas,;
.T.,;
NIL,;
.T.,;
.T.,;
lConsVenc,;
NIL,;
NIL,;
.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remove travas dos registros utilizados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaDesTrava(aTravas)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza quantidade do SD4                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SD4",.F.)
SD4->D4_SLDEMP	:= SD4->D4_QUANT
SD4->D4_SLDEMP2	:= SD4->D4_QTSEGUM
Replace D4_QUANT	With 0
Replace D4_QTSEGUM	With 0
MsUnlock()
dbSkip()
End
EndIf

If lDelOpSC

aAreaAnt := GetArea()
aOpsPis	 := A250OpsPis(SD3->D3_OP)

dbSelectArea('SC1')
dbSetOrder(4)

For nLoop := 1 to Len(aOpsPis)
dbSelectArea("SC1")
If dbSeek(cSeek := xFilial('SC1') + aOpsPis[nLoop], .F.)
Do While !Eof() .And. C1_FILIAL+C1_OP == cSeek
If SB2->(dbSeek(xFilial('SB2')+SC1->C1_PRODUTO+SC1->C1_LOCAL, .F.))
RecLock('SB2', .F.)
Replace B2_SALPEDI With B2_SALPEDI - (SC1->C1_QUANT-SC1->C1_QUJE)
MsUnLock()
EndIf          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se SC esta em cotacao. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC1->C1_COTACAO) .And.  SC1->C1_COTACAO <> Replicate("X",Len(SC1->C1_COTACAO)) .And. SC1->C1_IMPORT <> "S" .And. SC1->C1_QUJE == 0
Aviso(STR0035,STR0102+AllTrim(SC1->C1_NUM)+STR0103+AllTrim(SC1->C1_ITEM)+STR0104,{'Ok'}) //A solicitacao de compras numero ### item ### nao podera ser excluida pois se encontra em processo de cotacao! "
If Type("aRegsSC1") != "U"
AADD(aRegsSC1,SC1->(Recno())) 
EndIf
dbSkip()
Loop
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se existe SI vinculada a SC. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC1->C1_NUM_SI) 
Aviso(STR0035,STR0102+AllTrim(SC1->C1_NUM)+STR0103+AllTrim(SC1->C1_ITEM)+STR0105,{'Ok'}) //A solicitacao de compras numero ### item ### nao podera ser excluida pois se encontra em processo de importacao!
If Type("aRegsSC1") != "U"
AADD(aRegsSC1,SC1->(Recno()))
EndIf
SC1->(dbSkip())
Loop                        
Endif                						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso ja haja qtd no PC, iguala qtd na SC para encerra-la ³
//³ senao deleta											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC1->C1_QUJE > 0
RecLock('SC1', .F.)
Replace C1_QUANT With C1_QUJE
Replace C1_QTSEGUM With ConvUM(SB2->B2_COD, C1_QUJE, 0, 2)
MsUnlock()
Else
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerar Carta de Correcao do Pedido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock('SC1',.F.,.T.)
Replace C1_OBS With STR0044 //"CANCELADA PELO SISTEMA."
dbDelete()
MsUnLock()
EndIf
SC1->(dbSkip())
EndDo
EndIf
dbSelectArea('SC7')
dbSetOrder(8)
If dbSeek(cSeek := xFilial('SC7') + aOpsPis[nLoop])
Do While !Eof() .And. C7_FILIAL + C7_OP == cSeek
If C7_TIPO == 2
nEntregSC7 := SC7->C7_QUJE+SC7->C7_QTDACLA
If SB2->(dbSeek(xFilial("SB2")+SC7->(C7_PRODUTO+C7_LOCAL),.F.))
nEntregSC7:=SC7->C7_QUJE+SC7->C7_QTDACLA
GravaB2Pre("-",SC7->C7_QUANT - nEntregSC7)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerar Carta de Correcao do Pedido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nEntregSC7 > 0 .Or. lExcluiAE
dbSelectArea("SC3")
dbSetOrder(1)
If dbSeek(xFilial("SC3")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
RecLock("SC3",.F.)
Replace C3_QUJE With C3_QUJE - (SC7->C7_QUANT-nEntregSC7)
If C3_QUANT > C3_QUJE .And. C3_ENCER == "E"
Replace C3_ENCER 	With " "
Endif
MsUnlock()


EndIf
EndIf
dbSelectArea("SC7")
// Caso ja haja qtd ENTREGUE no PC
If nEntregSC7 > 0
RecLock("SC7",.F.)
Replace C7_QUANT With SC7->C7_QUJE+SC7->C7_QTDACLA
Replace C7_TOTAL With SC7->C7_QUANT * SC7->C7_PRECO
MsUnlock()
ElseIf lExcluiAE
// Apaga registro somente qdo nao tem quantidade entregue
RecLock("SC7",.F.,.T.)
Replace C7_OBS With STR0044 //"CANCELADA PELO SISTEMA."
dbDelete()
MsUnLock()
EndIf
EndIf
SC7->(dbSkip())
EndDo
EndIf
Next
RestArea(aAreaAnt)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo de OP's                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2")+SD3->D3_OP)
RecLock("SC2",.F.)
Replace C2_DATRF With SD3->D3_EMISSAO
dbSelectArea("SHD")
dbSeek(xFilial("SHD")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD)
While !Eof() .And. HD_OP == SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
RecLock("SHD",.F.)
Replace HD_DATRF With SD3->D3_EMISSAO
dbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o campo totalizador dos empenhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL)
If EOF()
CriaSB2(SC2->C2_PRODUTO,SC2->C2_LOCAL)
EndIf
If lEncerra
GravaB2Pre("-",(SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)),SC2->C2_TPOP)
EndIf
End Transaction

// --- Ponto de entrada para indicar se ao encerrar uma OP, encerrar as OPs intermediarias tambem.
If lA250ENOP
lRetPE := ExecBlock("A250ENOP",.F.,.F.)
lRetPE := If(ValType(lRetPE)=="L",lRetPE,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso use producao automatica, encerro      ³
//³ tambem as OPs intermediarias.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProdAut .Or. lRetPE
nRecSD3:= SD3->(RecNo())
cNumOp := SubStr(SD3->D3_OP,1,8)
cOp    := Alltrim(SD3->D3_OP)
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2")+cOp)
While !Eof() .And. SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM == xFilial("SC2")+cNumOp
If SC2->C2_GRADE == "S" .And. SC2->C2_ITEMGRD != Right(SD3->D3_OP,Len(SC2->C2_ITEMGRD))
dbSkip()
loop
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista das Ops que geram dependencia para op atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLstOpDep := A250LDepOp(SD3->D3_OP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Op possicionada esta na lista das  ³
//³ Ops que geram dependencia para op atual          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(AsCan(aLstOpDep,SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)))
dbSelectArea("SC2")
dbSkip()
Loop
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se OP esta encerrada                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
If !Empty(SC2->C2_DATRF)
dbSelectArea("SC2")
dbSkip()
Loop
EndIf

Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza arquivo de empenhos e B2_QEMP     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF5")
dbSeek(xFilial("SF5")+SD3->D3_TM)
If F5_ATUEMP == "S" .Or. lAtuEmp
dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD)
While !EOF() .And. D4_FILIAL+D4_OP==xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao baixa se quantidade empenhada estiver zerada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If D4_QUANT=0.Or.(SF5->F5_TRANMOD=="N".And.IsProdMod(D4_COD))
dbSkip()
Loop
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o campo totalizador dos empenhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL)
If EOF()
CriaSB2(SD4->D4_COD,SD4->D4_LOCAL)
EndIf
RecLock("SB2",.F.)
If SD4->D4_QUANT > 0
Replace B2_QEMP  With B2_QEMP  - SD4->D4_QUANT
Replace B2_QEMP2 With B2_QEMP2 - SD4->D4_QTSEGUM
Else
Replace B2_SALPEDI With B2_SALPEDI - ABS(SD4->D4_QUANT)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza quantidade do SD4                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD4")
RecLock("SD4",.F.)
SD4->D4_SLDEMP	:= SD4->D4_QUANT
SD4->D4_SLDEMP2	:= SD4->D4_QTSEGUM
Replace D4_QUANT	With 0
Replace D4_QTSEGUM	With 0
dbSkip()

D4_QUANT>0


End
EndIf
RecLock("SC2",.F.)
Replace C2_DATRF With SD3->D3_EMISSAO
dbSelectArea("SHD")
dbSeek(xFilial("SHD")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD)
While !Eof() .And. HD_FILIAL+HD_OP == xFilial("SHD")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
RecLock("SHD",.F.)
Replace HD_DATRF With SD3->D3_EMISSAO
dbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o campo totalizador dos empenhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB2")
dbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL)
If EOF()
CriaSB2(SC2->C2_PRODUTO,SC2->C2_LOCAL)
EndIf
If lEncerra
GravaB2Pre("-",(SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)),SC2->C2_TPOP)
EndIf
End Transaction
dbSelectArea("SC2")
dbSkip()
End
dbSelectArea("SD3")
MsGoTo(nRecSD3)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada ao final do encerramento da producao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSD3250R
ExecBlock("SD3250R",.F.,.F.)
EndIf
Return
*/


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1W ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cria arquivo de log												¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function PCP051W(cLogFile, aLog)
	Local lRet := .F.
	If !File(cLogFile)			
		If (nHandle := MSFCreate(cLogFile,0)) <> -1	
			lRet := .T.	
		EndIf
	Else
		fErase(cLogFile)
		If (nHandle := MSFCreate(cLogFile,0)) <> -1	
			lRet := .T.	
		EndIf
	EndIf
	If	lRet //grava as informacoes de log no arquivo especificado
		For nX := 1 To Len(aLog)
			FWrite(nHandle,aLog[nX]+CHR(13)+CHR(10))
		Next nX
		FClose(nHandle)
	EndIf
Return



/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Marca
*/
User Function PCP051X()
	oWBrw051:aArray[oWBrw051:nAt][1]:= !oWBrw051:aArray[oWBrw051:nAt][1]
	aWBrw051[oWBrw051:nAt][1]:=oWBrw051:aArray[oWBrw051:nAt][1]
	oWBrw051:DrawSelect()
	oWBrw051:Refresh()
Return(.T.)


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1Z ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ajusta SX1 Perguntas										  	¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function PCP051Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Data de?"		,"","","mv_ch1","D",08,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data ate?"		,"","","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Local de?"		,"","","mv_ch3","C",TAMSX3("C2_LOCAL")[1],0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Local ate?"		,"","","mv_ch4","C",TAMSX3("C2_LOCAL")[1],0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Item de?"		,"","","mv_ch5","C",TAMSX3("C2_ITEM")[1],0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Item ate?"		,"","","mv_ch6","C",TAMSX3("C2_ITEM")[1],0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","Seq de?"			,"","","mv_ch7","C",TAMSX3("C2_SEQUEN")[1],0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"08","Seq ate?"		,"","","mv_ch8","C",TAMSX3("C2_SEQUEN")[1],0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"09","Encerra Grade?"	,"","","mv_ch9","N",1,0,1,"C","","","","","MV_PAR09","Sim","","","","N‹o","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"10","Codigo PA?"		,"","","mv_chA","C",TAMSX3("B1_COD")[1],0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"11","Codigo PA?"		,"","","mv_chB","C",TAMSX3("B1_COD")[1],0,0,"G","","","","","MV_PAR12","","","","","","","","","","","","","","","","")
Return