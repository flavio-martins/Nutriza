#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#define DS_MODALFRAME   128
#define CHR_LINE				'<hr>'
#define CHR_CENTER_OPEN		'<div align="center" >'
#define CHR_CENTER_CLOSE   	'</div>'
#define CHR_FONT_DET_OPEN	'<font face="Courier New" size="3">'
#define CHR_FONT_DET_CLOSE	'</font>'
#define CHR_FONT_VER_OPEN	'<font face="Verdana" size="3">'f
#define CHR_FONT_VER_CLOSE	'</font>'
#define CHR_ENTER				'<br>'
#define CHR_NEGRITO			'<b>'
#define CHR_NOTNEGRITO		'</b>'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP021() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Importar produção da paletização						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Em: 01/11/16													           ±±
±± Por: Evandro Gomes													   ±±
±± Descrição: Adaptado para dados do arquivo morto.				  		   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function PCP02199()
	Private _cNumOp
	Private _lGeraOPI 	:= GetMv('MV_GERAOPI')
	U_PCP021(2)
Return

User Function PCP021(_nOpc)
	Private _lGeraOPI 	:= GetMv('MV_GERAOPI')
	Private _cNumOp
	Private oBtnProc
	Private __nOpc		:= Iif(ValType(_nOpc)=="N", _nOpc, 1) //-> 1=Manual/2=Cronometrado
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
	Private _cProdIni	:=""
	Private _cProdFim	:=""
	Private oDlg021
	Private _cFunMrk
	Private _lFecEst
	Private dDataFec
	Private _cPCPAPP
	Private _lProduz
	Private _lQryEti	:= .F.
	Private _aFilesEr	:= {} 

	//->Browse de ZPEs
	Private oWBrw021
	Private aWBrw021 	:= {}
	Private cStatus		:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros		:= {}
	Private aQtdPrd		:= {}

	//->Parametros para interface
	Private _aButts		:= {}
	Private _cTitulo	:= IIf(__nOpc==1,"Producao Diaria Manual","Producao Diaria Automatica")
	Private _aCabec		:= {}
	Private _aButts		:= {}
	Private aObjects	:= {}

	Private sDtaProdIni	:= ""
	Private oDtaProdIni
	Private dDtaProdIni	:= CTOD("  /  /    ")
	Private sDtaProdFim	:= ""
	Private oDtaProdFim
	Private dDtaProdFim	:= CTOD("  /  /    ")
	Private cSqlQry		:= ""


	If !IsBlind()	//Acesso pelo menu
		_lQryEti	:= GetNewPar("MV_XHABQRE",.T.) //-> Habilita função para marcar OP nas caixas por query Update
		_lProduz	:= GetNewPar("MV_XHABPRD",.F.) //-> Habilita função de realizar produção
		cProdzp1	:= GetMv('MV_XPRDZP1')	//-> Produtos que nao serão importados = MV_XPRDZP1
		cMailImp	:= GetMV('MV_XIMPPCP')	//-> e-mail que sera avisado sobre falha na importação. 
		_lMkpZP1	:= GetNewPar("MV_MKOPZP1",.F.) //-> Grava rastreamento de caixas
		_cDirErr	:= GetNewPar("MV_XDIRERR",FunName()) //-> Pasta onde var ser gravado o error log
		cPerg		:= PadR(funname(),10)	
		dDtPrdIni	:= ctod("  /  /    ")
		dDtPrdFim	:= ctod("  /  /    ")
		_cFunMrk	:= "" //->"PCP021X"
		_lFecEst	:= GetNewPar("MV_XFEHPRD",.F.) //-> Se valida data de fechamento de estoque
		dDataFec 	:= GetMV("MV_ULMES") //-> Data do œltimo fechamento de estoque
		_cPCPAPP	:= GetNewPar("MV_XPCPAPP","10") //->ArmazŽm onde ser‹o alocadas as producoes
		_aFilesEr	:= {} 
		_nTpLog		:= GetNewPar("MV_PCPTLOG",1)
		oOk 		:= LoadBitmap( GetResources(), "LBOK")
		oNo 		:= LoadBitmap( GetResources(), "LBNO")
		oFntSt 		:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)

		If !U_APPFUN01("Z6_IMPPROD")=="S"
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return
		Endif

		If __nOpc == 1 //-> Manual
			AADD(_aButts,{"", { || ExecBlock("PCP021F",.F.,.F.,{cPerg,.T.,.T.,.T.}) },"Filtrar", "Filtrar"})
			AADD(_aButts,{"", { || ExecBlock("PCP021A",.F.,.F.,{3}) },"Inverte", "Inverte"})
			AADD(_aButts,{"", { || ExecBlock("PCP021A",.F.,.F.,{4}) },"Imprimir", "Imprimir"})
			If _lProduz
				AADD(_aButts,{"", { || ExecBlock("PCP021A",.F.,.F.,{2}) },"Produzir", "Produzir"})
			Endif
		Endif
		_aCabec:={"","Produto","Descricao","Cx. Nao Imp.","Peso Nao Imp","Cx. Importadas","Peso Importado","Cx. Ativadas","Peso Ativado","Cx. Repoc.","Peso Reproc","OP: KG ","OP: CX","KG:SD3XZP1","Cx:SD3XZP1"}
		If __nOpc == 1 //-> Manual
			ExecBlock("PCP021F",.F.,.F.,{cPerg,IIf(__nOpc==2,.F.,.T.),.F.,.F.})
		Else
			aWBrw021:={}
			aAdd(aWBrw021,{.F.,"","","","","","","","","","","","","",""})
		Endif
		U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrw021, @oDlg021, @oWBrw021, .T., .F., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F., IIf(__nOpc==2,"PCP021Y",""), IIf(__nOpc==2,60000,""),"PCP21GET" )
		A := 1
	Else //-> Via schedul
		//-> Carrega Par‰metros
		_lImpSch	:= .T.
		RpcSetType( 3 )				
		RpcSetEnv( '01', '0101' )	//Nutriza
		_cAliasZPRX:=GetNextAlias()
		cSql:="SELECT * FROM "+RETSQLNAME("ZPR")+" ZPR WHERE ZPR_FILIAL='"+XFILIAL("ZPR")+"' AND ZPR_DTASCH='"+DTOS(Date())+"' AND ZPR_STATUS='A' AND D_E_L_E_T_='' ORDER BY ZPR_DTAPRD"
		//cSql:=ChangeQuery(cSql)
		dbUseArea(.T.,"TopConn",TCGenQry(,,cSql),_cAliasZPRX,.F.,.T.)
		If !(_cAliasZPRX)->(EOF()) .And.  !(_cAliasZPRX)->(BOF()) 
			While !(_cAliasZPRX)->(EOF())
				aErros		:= {}
				aQtdPrd		:= {}
				dDtPrdIni 	:= STOD((_cAliasZPRX)->ZPR_DTAPRD)//-> Data de Produção
				dDtPrdFim 	:= STOD((_cAliasZPRX)->ZPR_DTAPRD)//-> Data de Produção
				_lQryEti	:= GetNewPar("MV_XHABQRE",.T.) //-> Habilita função para marcar OP nas caixas por query Update
				cProdzp1	:= GetMv('MV_XPRDZP1')	//-> Produtos que nao serão importados = MV_XPRDZP1
				cMailImp	:= GetMV('MV_XIMPPCP')	//-> e-mail que sera avisado sobre falha na importação. 
				_lMkpZP1	:= GetNewPar("MV_MKOPZP1",.F.) //-> Grava rastreamento de caixas
				_cDirErr	:= GetNewPar("MV_XDIRERR",FunName()) //-> Pasta onde var ser gravado o error log
				_cFunMrk	:= "PCP021X"
				_lFecEst	:= GetNewPar("MV_XFEHPRD",.F.) //-> Se valida data de fechamento de estoque
				dDataFec 	:= GetMV("MV_ULMES") //-> Data do œltimo fechamento de estoque
				_cPCPAPP	:= GetNewPar("MV_XPCPAPP","10") //->Armazem onde ser‹o alocadas as producoes
				_nTpLog		:= GetNewPar("MV_PCPTLOG",1)
				aWBrw021	:={} //->Limpa Array
				Conout('Início do processo de importação da produção : Data '+dtoc(dDtPrdIni)+' Hora : '+time())
				AADD(aErros,{"Carregando Parametros",""})
				AADD(aErros,{'Início do processo de importação da produção :',""})
				AADD(aErros,{'Data: '+dtoc(dDtPrdIni),""})
				AADD(aErros,{'Hora: '+time(),""})
				ExecBlock("PCP021A",.F.,.F.,{1,.F.})
				ExecBlock("PCP021A",.F.,.F.,{2,.F.})

				//->Atualiza Agendamento
				cSqlQry:= "UPDATE "+RetSqlName("ZPR")+" SET ZPR_STATUS='F' WHERE ZPR_DTASCH='"+DTOS(Date())+"' AND ZPR_DTAPRD='"+(_cAliasZPRX)->ZPR_DTAPRD+"' AND ZPR_STATUS='A' AND D_E_L_E_T_='' "
				If TCSqlExec(cSqlQry) < 0
					ZPR->(dbSetOrder(1))
					If ZPR->(dbSeek(xFilial("ZPR") + DTOS(Date()) + (_cAliasZPRX)->ZPR_DTAPRD))
						RecLock("ZPR",.T.)
						Replace ZPR_STATUS With "F"
						ZPR->(MsUnLock())
						AADD(aErros,{"Registro de Agendamento: '"+DTOC(dDtPrdIni)+"' atualizado com sucesso. [TENTATIVA 02]",""})
					Else
						ZPR->(dbGoTo((_cAliasZPRX)->R_E_C_N_O_))
						If ZPR->(Recno()) == (_cAliasZPRX)->R_E_C_N_O_
							RecLock("ZPR",.F.)
							Replace ZPR_STATUS With "F"
							ZPR->(MsUnLock())
							AADD(aErros,{"Registro de Agendamento: '"+DTOC(dDtPrdIni)+"' atualizado com sucesso [TENTATIVA 03].",""})
						Else
							AADD(aErros,{"Registro de Agendamento: '"+DTOC(dDtPrdIni)+"' não foi atualizado.",""})
						Endif
					Endif
				Else
					AADD(aErros,{"Registro de Agendamento: '"+DTOC(dDtPrdIni)+"' atualizado com sucesso. [TENTATIVA 01]",""})
				Endif

				AADD(aErros,{'Fim do processo de importação da produção:',""})
				AADD(aErros,{'Data: '+dtoc(dDtPrdIni),""})
				AADD(aErros,{'Hora: '+time(),""})
				Conout('Fim do processo de importação da produção : Data '+dtoc(dDtPrdIni)+' Hora : '+time())
				U_PCP021M("Status de Produção Paletizado","Status de Producao: "+dtoc(dDtPrdIni), {}, aErros, _aFilesEr)//->Envia Email

				(_cAliasZPRX)->(dbSkip())
			Enddo
		Else
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Processo de producao nao iniciado")
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Nao foram encontrados agendamentos")
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+'agenda de Processo de procucao nao encontrado',""})
			U_PCP021M("Status de Produção Paletizado","Status de Producao: AGENDAMENTO NAO ENCONTRADO.", {}, aErros, _aFilesEr)//->Envia Email
		Endif
		(_cAliasZPRX)->(dbCloseArea())
		If File(_cAliasZPRX+GetdbExtension())
			FErase(_cAliasZPRX+GetDbExtension())
		Endif
		If File(_cAliasZPRX+OrdBagExt())
			FErase(_cAliasZPRX+ OrdBagExt())
		Endif

		Conout("Agendando producao dia anterior")
		//->Agenda Dia Anterior
		ZPR->(dbSetOrder(1))
		If !ZPR->(dbSeek(xFilial("ZPR") + DTOS(Date()+1) + DTOS(Date())))
			RecLock("ZPR",.T.)
			Replace ZPR_FILIAL With xFilial("ZPR")
			Replace ZPR_DTASCH With Date()+1
			Replace ZPR_DTAPRD With Date()
			Replace ZPR_STATUS With "A"
			ZPR->(MsUnLock())
		Endif

		RpcClearEnv()
	Endif
	//   	PutMv ("MV_GERAOPI",_lGeraOPI)
Return

/*
Função: OHFAP2P1
Descrição: Ponto de entrada para adiconar Say e Get.
*/
//User Function OHFAP2P1
User Function PCP21GET
	U_OHFUNA22(@oDlg021,@sDtaProdIni,,"Data Producao:",50,10,,,038,007,,-15,.T.)
	U_OHFUNA23(@oDlg021,@oDtaProdIni, @dDtaProdIni,,80,10,"@D 99/99/9999",.F.,037,57,,-15,.F.,,{})
	U_OHFUNA22(@oDlg021,@sDtaProdFim,,"A:",50,10,,,038,145,,-15,.T.)
	U_OHFUNA23(@oDlg021,@oDtaProdFim, @dDtaProdFim,,80,10,"@D 99/99/9999",.F.,037,175,,-15,.F.,,{})
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
User Function PCP021A()
	Local _lRet 	:= .T.
	Local nOpc		:= PARAMIXB[1]
	Private oProcess
	If nOpc==1 //->Lista Producoes
		If _lImpSch //-> Via Schedule
			Conout('Executando Rotina: PCP021B - Producoes Pendentes' )
			AADD(aErros,{'Executando Rotina: PCP021B - Producoes Pendentes',""})
			PCP021B()
		Else
			oProcess:=MsNewProcess():New( { || PCP021B() } , "Gerando Dados..." , "Aguarde..." , .F. )
			oProcess:Activate()
			If ParamIXB[2]
				U_OHFUNA21(@oDlg021, @oWBrw021, _aCabec, @aWBrw021, _cFunMrk)
			Endif
		Endif
	ElseIf nOpc==2 //->Executa Producoes
		If _lImpSch //-> Via Schedule
			Conout('Executando Rotina: PCP021D - Producao' )
			AADD(aErros,{'Executando Rotina: PCP021D - Producao',""})
			PCP021D()
		Else
			oProcess:=MsNewProcess():New( { || PCP021D() } , "Gerando Dados..." , "Aguarde..." , .F. )
			oProcess:Activate()
			If !_lImpSch .And. __nOpc == 1 //-> Produção Manual
				ExecBlock("PCP021F",.F.,.F.,{cPerg,.T.,.T.,.T.})
			Endif
		Endif
	ElseIf nOpc==3 //->Inverte Selecao
		oProcess:=MsNewProcess():New( { || PCP021C() } , "Invertendo..." , "Aguarde..." , .F. )
		oProcess:Activate()
	ElseIf nOpc==4 //->Imprimir
		oProcess:=MsNewProcess():New( { || PCP021E() } , "Imprimir..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif

Return(_lRet)

/* Inverte seleção */
Static Function PCP021C()
	Local _I := 0
	If !_lImpSch
		oProcess:SetRegua1(1)
		oProcess:SetRegua2(Len(aWBrw021))
		oProcess:IncRegua1("Invertendo selecao")
	Endif
	For _I := 1 To Len(aWBrw021)
		If !_lImpSch
			oProcess:IncRegua2("Prod.:"+aWBrw021[_I,3])
		Endif
		aWBrw021[_I,1] := !aWBrw021[_I,1]
		oWBrw021:aArray[_I][1]:= !oWBrw021:aArray[_I][1]
	Next _I
	oWBrw021:GoTop()
	oWBrw021:Refresh()
	oDlg021:Refresh()
Return

/* Gera Ordens de Produção */
Static Function PCP021D()
	Local _I 			:= 0
	Local lerro			:= .f.
	Local aLog			:= {}
	Local aEtqPrd		:= {}
	Local aQryUpd		:= {}
	Local _lContPrd		:= .T.
	Local _cDocumento	:= "P" + DTOS(dDtPrdIni)
	Private _dBkDt 		:= Iif(_lImpSch,dDtPrdIni,dDataBase)


	_aFilesEr	:= {} //-> Arquivos de Erro
	aQtdPrd		:= {}

	If !_lImpSch //->Produção Manual
		aErros	:= {}
	Endif

	If dDtPrdIni <> dDtPrdFim
		If _lImpSch
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Data Inicial Difere da Data Final.")
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Data Inicial"+dtoc(dDtPrdIni))
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Data Final:"+dtoc(dDtPrdFim))
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data Inicial Difere da Data Final.",""})
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data Inicial"+dtoc(dDtPrdIni),""})
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data Final:"+dtoc(dDtPrdFim),""})
		Else
			Alert("Data Inicial Difere da Data Final.")
		Endif
		Return(.F.)
	Endif

	If !_lImpSch
		If __nOpc == 1
			Conout('Início do processo de importação da produção : Data '+dtoc(dDtPrdIni)+' Hora : '+time())
			AADD(aErros,{'Início do processo de importação da produção :',""})
			AADD(aErros,{'Data: '+dtoc(dDtPrdIni),""})
			AADD(aErros,{'Hora: '+time(),""})
			AADD(aErros,{'Tipo de Producao: Manual',""})
		Endif
	Endif

	If __nOpc == 1
		If dDataFec >= dDtPrdIni
			If _lImpSch
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Data dentro de um periodo fechado.")
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data dentro de um periodo fechado.",""})
			Else
				Help( " ", 1, "FECHTO" )
			Endif
			Return(.F.)
		Endif
	Else
		If dDataFec >= dDtPrdIni
			If _lImpSch
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Data dentro de um periodo fechado.")
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Data dentro de um periodo fechado.",""})
			Endif
			Return(.F.)
		Endif
	Endif

	If Len(aWBrw021) <= 0
		If _lImpSch
			Conout("["+DTOC(Date())+" - "+Time()+"]"+"Dados nao encontrados no array.")
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Dados nao encontrados no array.",""})
		Else
			MsgStop("["+DTOC(Date())+" - "+Time()+"]"+"Dados nao encontrados no array.")
		Endif
		Return(.F.)
	Endif

	If _lImpSch
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"Processo Iniciado")
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Processo Iniciado",""})
	Else
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Processo Iniciado",""})
		oProcess:SetRegua1(Len(aWBrw021))
	Endif

	For _I := 1 To Len(aWBrw021)
		IncProc()

		//->Em caso de produção marca todos
		If _lImpSch
			aWBrw021[_I,1]:=.T.
		Else
			AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2]+" Est‡: "+Iif(aWBrw021[_I,1],"MARCADO","DESMACADO"),""})
		Endif

		_lContPrd:=.T. //->Continua producao

		//->Erro de sincronia entre ZP1 X SD3 
		/*If bStrToVal(aWBrw021[_I,14]) > 0 .And. bStrToVal(aWBrw021[_I,14]) <> bStrToVal(aWBrw021[_I,11])
		If _lImpSch
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"ERRO: PRODUTO COM DIVERGENCIA ZP1 X SD3")
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2])
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"))
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"Divergencia KG: "+aWBrw021[_I,12])
		Conout("["+DTOC(Date())+" - "+Time()+"]"+"Divergencia Caixa: "+aWBrw021[_I,13])
		Conout("")
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO: PRODUTO COM DIVERGENCIA ZP1 X SD3"+_cNumOp,_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2],_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"),_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Divergencia KG: "+aWBrw021[_I,12],_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Divergencia caixa: "+aWBrw021[_I,13],_cNumOp})
		Else
		If __nOpc == 1 //-> Produção Manual
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO: PRODUTO COM DIVERGENCIA ZP1 X SD3"+_cNumOp,_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2],_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"),_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Divergencia KG: "+aWBrw021[_I,12],_cNumOp})
		AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Divergencia caixa: "+aWBrw021[_I,13],_cNumOp})
		Endif
		Endif
		_lContPrd:=.F.
		Endif*/

		If (__nOpc ==2 .Or. aWBrw021[_I,1]) .And. bStrToVal(aWBrw021[_I,5]) > 0 .And. !Empty(AllTrim(aWBrw021[_I,2])) .And. _lContPrd

			If !_lImpSch
				oProcess:IncRegua1("Prod: "+aWBrw021[_I,3])
				oProcess:SetRegua2(3)
				oProcess:IncRegua2("Abrindo OP")
			Endif

			_cNumOp := GetNumSc2()

			If _lImpSch
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Incluindo OP ")
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Ordem de Producao: "+_cNumOp)
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2])
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"))
				Conout("["+DTOC(Date())+" - "+Time()+"]"+"Qtd. a Ser Produzida: "+aWBrw021[_I,5])
				Conout("")
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Ordem de Producao: "+_cNumOp,_cNumOp})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2],_cNumOp})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"),_cNumOp})
				AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Qtd. a ser produzida: "+aWBrw021[_I,5],_cNumOp})
			Else
				If __nOpc == 1 //-> Produção Manual
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Ordem de Producao: "+_cNumOp,""})
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Produto: "+aWBrw021[_I,2],""})
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"),""})
				Endif
			Endif

			lerro			:= .F.
			lMsErroAuto		:= .F.
			lMsHelpAuto		:= .T. 
			lAutoErrNoFile 	:= .T.
			Begin Transaction

				If _lImpSch //-> Schedule
					Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Abrindo OP")
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Abrindo OP.",_cNumOp})
				Else
					If __nOpc == 1 //-> Produção Manual
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Abrindo Op.",""})
					Endif
				Endif

				//->Abre Ordem de Produção
				lMsErroAuto := .F.
				SG1->(dbSetOrder(1))
				_cAutExpl := IIF(SG1->(dbSeek(xFilial()+aWBrw021[_I,2])),"S","N")
				aRotAuto  := {;
				{"C2_FILIAL"	,xFilial("SC2")					,NIL},;
				{"C2_NUM"		,_cNumOp						,NIL},;
				{"C2_ITEM"		,"01"							,NIL},;
				{"C2_SEQUEN"	,"001"							,NIL},;
				{"C2_PRODUTO"	,aWBrw021[_I,2]					,NIL},;
				{"C2_LOCAL"	,_cPCPAPP							,NIL},;
				{"C2_QUANT"	,bStrToVal(aWBrw021[_I,5])			,NIL},;
				{"C2_DATPRI"	,dDtPrdIni						,NIL},;
				{"C2_DATPRF"	,dDtPrdIni						,NIL},;
				{"C2_OBS"		,"Executado Por: PCP021"		,NIL},;					
				{"AUTEXPLODE"	,_cAutExpl						,NIL}}
				dDataBase	:= dDtPrdIni
				CTPMT		:=""
				dDataBase 	:= Date()					
				MsExecAuto({|x,y| MATA650(x,y)},aRotAuto,3)
				If lMsErroAuto
					AutoGrLog("Arquivo de log ")
					AutoGrLog("Produto: "+aWBrw021[_I,2])
					AutoGrLog("Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"))
					AutoGrLog(Replicate("-", 20))
					DisarmTransaction()
					cLogFile := '\system\'+AllTrim(_cDirErr)+'\'+AllTrim(FunName())+'_MATA650_'+AllTrim(aWBrw021[_I,2])+'.txt'		//função que retorna as informacoes de erro ocorridos durante o processo da rotina automatica
					AADD(_aFilesEr,{cLogFile})
					aLog	:= GetAutoGRLog()
					PCP021W(cLogFile, aLog) //->Cria arquivo de Log
					If _lImpSch
						Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao abrir Ordem de Producao")
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro ao criar ordem de producao.(Ver Arquivo)",_cNumOp})
					Else
						If __nOpc == 1 //-> Produção Manual
							AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro ao criar ordem de producao.(Ver Arquivo)",cLogFile})
						Endif
					Endif
					lerro	:= .T.
				Else //->Continua com o apontamento de OP
					If _lImpSch
						Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] OP aberta com sucesso")
						Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Encerrando Ordem de Producao")
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"OP aberta com sucesso.",_cNumOp})
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Inciando apontamento de OP.",_cNumOp})
					Else
						oProcess:IncRegua2("Encerrando OP...")
						If __nOpc == 1 //-> Produção Manual
							AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"OP aberta com sucesso.",""})
							AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Inciando apontamento de OP.",""})
						Endif
					Endif

					//->Apnta e Encerra Ordem de Produção
					lMsErroAuto := .F.
					CriaSB2(aWBrw021[_I,2],_cPCPAPP)
					aItens     := {;
					{"D3_TM"		, "103"					,NIL},;
					{"D3_COD"		, aWBrw021[_I,2]		,NIL},;
					{"D3_QUANT"	, bStrToVal(aWBrw021[_I,5])	,Nil},;
					{"D3_OP"		, _cNumOp+"01"+"001"	,Nil},;
					{"D3_LOCAL"	, _cPCPAPP					,Nil},;
					{"D3_EMISSAO"	, dDtPrdIni				,NIL},;
					{"D3_FILIAL"	, xFilial("SD3")		,Nil};
					}
					CTPMT:=""
					MSExecAuto({|x,y| mata250(x,y)},aItens,3)
					If lMsErroAuto
						AutoGrLog("Arquivo de Log")
						AutoGrLog("Produto: "+aWBrw021[_I,2])
						AutoGrLog("Descricao: "+Posicione("SB1",1,xFilial("SB1") + aWBrw021[_I,2],"B1_DESC"))
						AutoGrLog(Replicate("-", 20))
						DisarmTransaction()
						cLogFile := '\system\'+AllTrim(_cDirErr)+'\'+AllTrim(FunName())+'_MATA250_'+AllTrim(aWBrw021[_I,2])+'.txt'		//função que retorna as informacoes de erro ocorridos durante o processo da rotina autom‡tica
						AADD(_aFilesEr,{cLogFile})
						aLog := GetAutoGRLog()
						PCP021W(cLogFile, aLog) //->Cria arquivo de Log
						If _lImpSch
							Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao Encerrar Ordem de Producao")
							AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro no apontamento da Orderm de Producao(Ver Arquivo).",_cNumOp})
						Else
							If __nOpc == 1 //-> Produção Manual
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro no apontamento da Orderm de Producao(Ver Arquivo).",cLogFile})
							Endif
						Endif
						lerro	:= .T.
					Else

						If !_lImpSch
							oProcess:IncRegua2("Analisando Caixas OP...")
						Endif

						/*
						Por: Evandro Gomes
						Descrição:	Registra Log de caixa e altera campos ZP1_OP
						para o nœmero da op de importação
						*/
						If _lImpSch //->Schecule
							If !lerro
								Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] OP Apontada com sucesso.")
								Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Iniciando apontamento de etiquetas caixa")
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"OP Apontada com sucesso.",_cNumOp})
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Iniciando apontamento de etiquetas caixa.",_cNumOp})
							Else
								Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Nao iniciado apontamento de etiquetas caixa")
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro no apontamento da OP.",_cNumOp})
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Abortado Proximo Passo: apontamento de etiquetas caixa.",""})
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"RollBack Iniciado...",_cNumOp})
							Endif
						Else
							If __nOpc == 1 //-> Produção Manual 
								If !lerro 
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"OP Apontada com sucesso.",_cNumOp})
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Iniciando apontamento de etiquetas caixa.",""})
								Else
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Erro no apontamento da OP.",_cNumOp})
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Abortado Proximo Passo: apontamento de etiquetas caixa.",""})
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"RollBack Iniciado...",_cNumOp})
								Endif
							Endif
						Endif

						//->Inicia apontamento de caixas
						If !lerro
							If _lImpSch
								Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Selecionando Etiquetas...")
								AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Selecionando Etiquetas....",_cNumOp})
							Else
								If __nOpc == 1 //-> Produção Manual
									AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"Selecionando Etiquetas....",_cNumOp})
								Endif
							Endif
							If !fAddEtq(_lQryEti,dDtPrdIni, aWBrw021[_I,2], bStrToVal(aWBrw021[_I,5]) ,bStrToVal(aWBrw021[_I,4]), @aErros, @aEtqPrd, @aQryUpd, _cNumOp)
								DisarmTransaction()
								lerro	:= .T.
							Else
								If _lQryEti //-> Altera as etiquetas por query update
									If Len(aQryUpd) > 0
										For x:=1 To Len(aQryUpd)
											If TCSQLExec(aQryUpd[x][2]) < 0
												DisarmTransaction()
												If _lImpSch
													Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao executar query de caixas:")
													Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] "+aQryUpd[x][2])
													Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro: "+TCSQLError())
													AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao executar query de caixas: "+aQryUpd[x][2],_cNumOp})
													AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro Retornado: "+TCSQLError(),_cNumOp})
												Else
													If __nOpc == 1 //-> Produção Manual
														AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao executar query de caixas: "+aQryUpd[x][2],_cNumOp})
														AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro Retornado: "+TCSQLError(),_cNumOp})
													Endif
												Endif
												lerro	:= .T.
											Else
												If _lImpSch
													Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Apontamento de etiqueta caixa realizado com sucesso.")
													Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Query: "+aQryUpd[x][2])
													AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Apontamento de etiqueta caixa realizado com sucesso.",_cNumOp})
													AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Query: "+aQryUpd[x][2],_cNumOp})
												Else
													If __nOpc == 1 //-> Produção Manual
														AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Apontamento de etiqueta caixa realizado com sucesso.",""})
														AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+aQryUpd[x][2],_cNumOp})
													Endif
												Endif
											EndIf
										Next x
									Else
										DisarmTransaction()
										If _lImpSch
											Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao apontar etiquetas de eaixas.")
											AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao apontar etiquetas de eaixas.",_cNumOp})
										Else
											If __nOpc == 1 //-> Produção Manual
												AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao apontar etiquetas de eaixas.",""})
											Endif
										Endif
										lerro	:= .T.
									Endif
								Else
									If !LogProd2(aWBrw021[_I,2], _cNumOp, aEtqPrd)
										DisarmTransaction()
										If _lImpSch
											Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao apontar etiquetas de eaixas.")
											AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao apontar etiquetas de eaixas.",_cNumOp})
										Else
											If __nOpc == 1 //-> Produção Manual
												AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao apontar etiquetas de eaixas.",""})
											Endif
										Endif
										lerro	:= .T.
									Else
										If _lImpSch
											Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Apontamento de etiqueta caixa realizado com sucesso.")
											AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Apontamento de etiqueta caixa realizado com sucesso.",_cNumOp})
										Else
											If __nOpc == 1 //-> Produção Manual
												AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Apontamento de etiqueta caixa realizado com sucesso.",""})
											Endif
										Endif
									Endif
								Endif
							Endif
						Endif
					EndIf
				EndIf
			End Transaction

			If _lImpSch
				If !lerro
					Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] OP encerrada sucesso")
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"OP com encerrada sucesso",_cNumOp})
				Else
					Conout("["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"] Erro ao encerrar OP")
					AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao encerrar OP.",_cNumOp})
				Endif
				Conout("")
				Conout("")
				Conout("")
			Else
				If __nOpc == 1  //-> Produção Manual
					If !lerro
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"OP com encerrada sucesso",""})
					Else
						AADD(aErros,{"["+DTOC(Date())+" - "+Time()+"]"+"["+_cNumOp+"]:"+"Erro ao encerrar OP.",""})
					Endif
				Endif
			Endif

		EndIf
	Next _I

	If _lImpSch
		AADD(aErros,{"",""})
	Else
		If __nOpc == 1
			AADD(aErros,{'Fim do processo de importação da produção:',""})
			AADD(aErros,{'Data: '+dtoc(dDtPrdIni),""})
			AADD(aErros,{'Hora: '+time(),""})
			Conout('Fim do processo de importação da produção : Data '+dtoc(dDtPrdIni)+' Hora : '+time())
		Endif
	Endif

	If !_lImpSch .And. __nOpc == 1 //-> Produção Manual
		If Len(aErros) > 0 // .And. MsgBox("Deseja ver o log de processamento?","Atencao!!!","YESNO")
			U_PCP021M("Status de Produção Paletizado","Status de Producao: "+dtoc(dDtPrdIni), {}, aErros, _aFilesEr)//->Envia Email
			U_MFATA07Z("Log de Processamento.",aErros)
		Endif
	Endif

	If !_lImpSch
		dDataBase := _dBkDt
	Endif
Return

/*
Valida data
*/
Static Function bValDtPrd()
	Local _lRet := .T.
	If Empty(DTOS(dDtPrdIni))
		Return .T.
	Endif
	ExecBlock("PCP021A",.F.,.F.,{1,.T.})
Return(_lRet)

/*
Lista Produção
*/
Static Function PCP021B()
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

	aWBrw021 := {}

	If !_lImpSch
		dDtPrdIni:=MV_PAR01
		dDtPrdFim:=MV_PAR02
		_cProdIni:=MV_PAR04
		_cProdFim:=MV_PAR05
	Endif

	If dDataFec >= dDtPrdIni .And. _lFecEst
		If __nOpc ==1 //-> Produção Normal
			If _lImpSch
				Conout("Data dentro de um periodo fechado.")
				AADD(aErros,{"Data dentro de um periodo fechado.",""})
			Else
				Help( " ", 1, "FECHTO" )
			Endif
		Endif
	Else
		_cQry := " SELECT "
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
		_cQry += " , COUNT(*) QTDCX, SUM(ZP1_PESO) PESO "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_OP = '' THEN 1 ELSE 0 END) QTDCX_NAO_PRODUZIDAS "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_OP = '' THEN ZP1_PESO ELSE 0 END) PESO_NAO_PRODUZIDO "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_OP <>'' THEN 1 ELSE 0 END) QTDCX_PRODUZIDAS "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_OP <> '' THEN ZP1_PESO ELSE 0 END) PESO_PRODUZIDO "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_STATUS IN ('1','2','3','7','9') THEN 1 ELSE 0 END) QTDCX_ATIVAS "
		_cQry += " ,SUM(CASE WHEN ZP1.ZP1_STATUS IN ('1','2','3','7','9') THEN ZP1_PESO ELSE 0 END) PESO_ATIVO "
		_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK)"
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
		_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_STATUS  IN ('1','2','3','7','9') "
		_cQry += " AND ZP1.ZP1_REPROC <> 'S'"
		_cQry += " AND (ZP1.ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
		_cQry += " AND ZP1_DTATIV BETWEEN '"+DToS(dDtPrdIni)+"' AND '"+DToS(dDtPrdFim)+"' "
		_cQry += " AND ZP1_HRATIV <> 'INVENTAR' "
		If !IsBlind()	//Acesso pelo menu
			_cQry += " AND ZP1_CODPRO BETWEEN '"+_cProdIni+"' AND '"+_cProdFim	+"' "
		Endif
		_cQry += " AND ZP1_CODPRO NOT IN ("+AllTrim(cProdZP1)+IIF(!Empty(AllTrim(MV_PAR06)),",","")+AllTrim(MV_PAR06)+")
		_cQry += " AND SB1.B1_TIPO <> 'ME' "	
		_cQry += " GROUP BY ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
		_cQry += " UNION ALL "
		_cQry += " SELECT "
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
		_cQry += " , COUNT(*) QTDCX,SUM(ZP1_MORTO.ZP1_PESO) PESO "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_OP = '' THEN 1 ELSE 0 END) QTDCX_NAO_PRODUZIDAS "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_OP = '' THEN ZP1_MORTO.ZP1_PESO ELSE 0 END) PESO_NAO_PRODUZIDO "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_OP <>'' THEN 1 ELSE 0 END) QTDCX_PRODUZIDAS "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_OP <> '' THEN ZP1_MORTO.ZP1_PESO ELSE 0 END) PESO_PRODUZIDO "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_STATUS IN ('1','2','3','7','9') THEN 1 ELSE 0 END) QTDCX_ATIVAS "
		_cQry += " ,SUM(CASE WHEN ZP1_MORTO.ZP1_STATUS IN ('1','2','3','7','9') THEN ZP1_MORTO.ZP1_PESO ELSE 0 END) PESO_ATIVO "
		_cQry += " FROM ZP1010_MORTO ZP1_MORTO WITH (NOLOCK)"
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
		_cQry += " WHERE ZP1_MORTO.D_E_L_E_T_ = ' '"
		_cQry += " AND ZP1_MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cQry += " AND ZP1_MORTO.ZP1_STATUS  IN ('1','2','3','7','9')"
		_cQry += " AND ZP1_MORTO.ZP1_REPROC <> 'S'"
		_cQry += " AND (ZP1_MORTO.ZP1_EDATA <> 'S' OR ZP1_MORTO.ZP1_OP = 'TUNEDATA' OR ZP1_MORTO.ZP1_OP = 'RETEDATA')"
		If !IsBlind()	//Acesso pelo menu
			_cQry += " AND ZP1_MORTO.ZP1_DTATIV BETWEEN '"+DToS(dDtPrdIni)+"' AND '"+DToS(dDtPrdFim)+"' "
		Endif
		_cQry += " AND ZP1_MORTO.ZP1_HRATIV <> 'INVENTAR'"
		_cQry += " AND ZP1_CODPRO BETWEEN '"+_cProdIni+"' AND '"+_cProdFim	+"' "
		_cQry += " AND ZP1_MORTO.ZP1_CODPRO NOT IN  ("+AllTrim(cProdZP1)+IIF(!Empty(AllTrim(MV_PAR06)),",","")+AllTrim(MV_PAR06)+")
		_cQry += " AND SB1.B1_TIPO <> 'ME' "	
		_cQry += " GROUP BY ZP1_MORTO.ZP1_FILIAL, ZP1_MORTO.ZP1_CODPRO, ZP1_MORTO.ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_MORTO.ZP1_REPROC"
		_cQry += " ORDER BY ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV "
		MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZP1.SQL", _cQry )
		TcQuery _cQry New Alias "QRYP"

		QRYP->(dbGoBottom())
		If !_lImpSch
			oProcess:SetRegua1(2)
			oProcess:SetRegua2(QRYP->(LastRec()))
			oProcess:IncRegua1("Selecionando....")
		Endif

		QRYP->(dbGoTop())
		_aCodAnt:={}
		While !QRYP->(EOF())

			If !_lImpSch
				oProcess:IncRegua2("Prod.:" + SubStr(QRYP->B1_DESC,1,20))
			Endif

			_nImp	:= 0
			_nImpCx	:= 0
			_nRep 	:= 0
			_nRepCx	:= 0
			_nOpSD3	:= ""	

			/*
			S— localiza as producoes efetuadas uma œnica vez
			*/
			_nPosAnt:= aScan(_aCodAnt,{|x| AllTrim(x[1]) == AllTrim(QRYP->ZP1_CODPRO) .And. AllTrim(x[10]) == AllTrim(QRYP->ZP1_DTATIV)})
			If _nPosAnt==0

				//->Pega as Producoes ja Efetuadas
				_cQry := " 	SELECT SUBSTRING(D3_OP,1,6) OP, SUM(D3_QUANT) QTD "
				_cQry += " 	FROM "+RetSQLName("SD3")
				_cQry += " 	WHERE D_E_L_E_T_ = ' '"
				_cQry += " 	AND D3_TM = '103'"
				_cQry += " 	AND D3_CF = 'PR0'"
				_cQry += " 	AND D3_ESTORNO = ''"
				_cQry += " 	AND D3_COD = '"+QRYP->ZP1_CODPRO+"'"
				_cQry += " 	AND D3_EMISSAO = '"+QRYP->ZP1_DTATIV+"' "
				_cQry += " 	GROUP BY SUBSTRING(D3_OP,1,6)"
				_cQry:=ChangeQuery(_cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSD3,.T.,.F.)
				(cAliasSD3)->(dbGoTop())
				While !(cAliasSD3)->(Eof())
					_nImp 	+= (cAliasSD3)->QTD
					_nImpCx+= (cAliasSD3)->QTD/QRYP->B1_CONV
					_nOpSD3:= (cAliasSD3)->OP
					(cAliasSD3)->(dbSkip())
				Enddo
				If Select(cAliasSD3) > 0
					(cAliasSD3)->(dbCloseArea())
					If File(cAliasSD3+GetDBExtension())
						fErase(cAliasSD3+GetDBExtension())
					Endif
				Endif

				AADD(_aCodAnt,{QRYP->ZP1_CODPRO,_nOpSD3,_nImp,_nImpCx,0,0,0,0,.F.,QRYP->ZP1_DTATIV,.F.})

				//->Reprocesso
				/*_cQry := "SELECT SUM(D3_QUANT) QTD "
				_cQry += "FROM "+RetSQLName("SD3")
				_cQry += "WHERE D_E_L_E_T_ = ' '"
				_cQry += "AND D3_COD = '"+QRYP->ZP1_CODPRO+"'"
				_cQry += "AND D3_EMISSAO ='"+DToS(dDtPrdIni)+"'"
				_cQry += "AND D3_TIPO='PA' "
				_cQry += "AND D3_TM='999' " 
				_cQry += "AND D3_CF='RE7' "
				_cQry:=ChangeQuery(_cQry)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSD3,.T.,.F.)
				If !(cAliasSD3)->(Eof()) .And. !(cAliasSD3)->(Bof())
				_nRep 	:= (cAliasSD3)->QTD
				_nRepCx:= (cAliasSD3)->QTD/QRYP->B1_CONV
				Endif
				If Select(cAliasSD3) > 0
				(cAliasSD3)->(dbCloseArea())
				If File(cAliasSD3+GetDBExtension())
				fErase(cAliasSD3+GetDBExtension())
				Endif
				Endif*/
				_cQry := " SELECT "	
				_cQry += " ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
				_cQry += " , COUNT(*) QTDCX, SUM(ZP1_PESO) PESO "
				_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK)"
				_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
				_cQry += " WHERE "
				_cQry += " ZP1_FILIAL = '"+xFilial("ZP1")+"'"
				_cQry += " AND ZP1_STATUS = '1'"
				_cQry += " AND ZP1.ZP1_REPROC = 'S'"
				_cQry += " AND ZP1.ZP1_CODPRO = '"+QRYP->ZP1_CODPRO+"'"
				_cQry += " AND (ZP1.ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
				_cQry += " AND ZP1_DTATIV = '"+QRYP->ZP1_DTATIV+"' "
				_cQry += " AND ZP1_HRATIV <> 'INVENTAR' "
				_cQry += " AND SB1.B1_TIPO <> 'ME' "	
				_cQry += " GROUP BY ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
				_cQry += " UNION ALL "
				_cQry += " SELECT "
				_cQry += " ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_REPROC "
				_cQry += " , COUNT(*) QTDCX,SUM(ZP1_MORTO.ZP1_PESO) PESO "
				_cQry += " FROM ZP1010_MORTO ZP1_MORTO WITH (NOLOCK)"
				_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
				_cQry += " WHERE "
				_cQry += " ZP1_MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'"
				_cQry += " AND ZP1_MORTO.ZP1_STATUS = '1'"
				_cQry += " AND ZP1_MORTO.ZP1_REPROC = 'S'"
				_cQry += " AND ZP1_MORTO.ZP1_CODPRO = '"+QRYP->ZP1_CODPRO+"'"
				_cQry += " AND (ZP1_MORTO.ZP1_EDATA <> 'S' OR ZP1_MORTO.ZP1_OP = 'TUNEDATA' OR ZP1_MORTO.ZP1_OP = 'RETEDATA')"
				_cQry += " AND ZP1_MORTO.ZP1_DTATIV = '"+QRYP->ZP1_DTATIV+"' "
				_cQry += " AND ZP1_MORTO.ZP1_HRATIV <> 'INVENTAR' "
				_cQry += " AND SB1.B1_TIPO <> 'ME' "	
				_cQry += " GROUP BY ZP1_MORTO.ZP1_FILIAL, ZP1_MORTO.ZP1_CODPRO, ZP1_MORTO.ZP1_DTATIV, B1_DESC, B1_CONV, ZP1_MORTO.ZP1_REPROC"
				_cQry += " ORDER BY ZP1_FILIAL, ZP1_CODPRO, ZP1_DTATIV "
				MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZP1_2.SQL", _cQry )
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasREP,.T.,.F.)
				While !(cAliasREP)->(Eof())
					_nRep 	+= (cAliasREP)->PESO
					_nRepCx+= (cAliasREP)->QTDCX
					(cAliasREP)->(dbSkip())
				Enddo
				If Select(cAliasREP) > 0
					(cAliasREP)->(dbCloseArea())
					If File(cAliasREP+GetDBExtension())
						fErase(cAliasREP+GetDBExtension())
					Endif
				Endif*
			Endif

			If !_lImpSch
				oProcess:IncRegua2("Gravando Registro na Array...")
			Endif


			/*
			Para Efeito de Caixas n‹o marcadas com Ordem de producao
			por algum motivo
			*/
			_nPosAnt:= aScan(_aCodAnt ,{|x| AllTrim(x[1])==Alltrim(QRYP->ZP1_CODPRO) .And. AllTrim(x[10]) == AllTrim(QRYP->ZP1_DTATIV)})
			If _nPosAnt > 0 .And. !_aCodAnt[_nPosAnt,11] 
				If QRYP->ZP1_DTATIV < '20170701'
					_aCodAnt[_nPosAnt,5] += QRYP->QTDCX
					_aCodAnt[_nPosAnt,6] += QRYP->PESO
					_aCodAnt[_nPosAnt,7] += QRYP->QTDCX
					_aCodAnt[_nPosAnt,8] += QRYP->PESO
				Else
					_aCodAnt[_nPosAnt,5] += QRYP->QTDCX_NAO_PRODUZIDAS
					_aCodAnt[_nPosAnt,6] += QRYP->PESO_NAO_PRODUZIDO
					_aCodAnt[_nPosAnt,7] += QRYP->QTDCX_PRODUZIDAS
					_aCodAnt[_nPosAnt,8] += QRYP->PESO_PRODUZIDO
					_aCodAnt[_nPosAnt,9] := .T.
				Endif
			Endif

			_nPos	:= aScan(aWBrw021,{|x| x[2] == QRYP->ZP1_CODPRO })
			If _nPos > 0
				If QRYP->ZP1_REPROC <> "S"
					If QRYP->ZP1_DTATIV < '20170701'
						aWBrw021[_nPos,4] += QRYP->QTDCX
						aWBrw021[_nPos,5] += QRYP->PESO
						aWBrw021[_nPos,8] += QRYP->QTDCX
						aWBrw021[_nPos,9] += QRYP->PESO
					Else
						_nCxAProd:=(QRYP->QTDCX_NAO_PRODUZIDAS + QRYP->QTDCX_PRODUZIDAS + _nRepCx) - Iif(_nPosAnt>0 .And. !_aCodAnt[_nPosAnt,11],_aCodAnt[_nPosAnt,4],0)
						_nKgAProd:=(QRYP->PESO_NAO_PRODUZIDO + QRYP->PESO_PRODUZIDO + _nRep) - Iif(_nPosAnt>0.And. !_aCodAnt[_nPosAnt,11],_aCodAnt[_nPosAnt,3],0)
						aWBrw021[_nPos,4] += _nCxAProd //QRYP->QTDCX_NAO_PRODUZIDAS
						aWBrw021[_nPos,5] += _nKgAProd //QRYP->PESO_NAO_PRODUZIDO
						aWBrw021[_nPos,8] += QRYP->QTDCX_PRODUZIDAS
						aWBrw021[_nPos,9] += QRYP->PESO_PRODUZIDO
						aWBrw021[_nPos,14] -= QRYP->QTDCX_PRODUZIDAS //->Diferenca ZP1XSD3
						aWBrw021[_nPos,15] -= QRYP->PESO_PRODUZIDO //->Diferenca ZP1XSD3
						If _nPosAnt > 0 .And. !_aCodAnt[_nPosAnt,11]
							aWBrw021[_nPos,12]+=_aCodAnt[_nPosAnt,4]
							aWBrw021[_nPos,13]+=_aCodAnt[_nPosAnt,3]
							_aCodAnt[_nPosAnt,11] := .T.
						Endif
					Endif
				Else
					If QRYP->ZP1_DTATIV < '20170701'
						aWBrw021[_nPos,10] += QRYP->QTDCX
						aWBrw021[_nPos,11] += QRYP->PESO
					Else
						aWBrw021[_nPos,10] += _nRepCx
						aWBrw021[_nPos,11] += _nRep
					ENdif
				Endif
			Else
				If QRYP->ZP1_DTATIV < '20170701'
					aAdd(aWBrw021,{.F.,QRYP->ZP1_CODPRO,QRYP->B1_DESC,;
					Iif(QRYP->ZP1_REPROC<>"S",QRYP->QTDCX-_nImpCx,0),;
					Iif(QRYP->ZP1_REPROC<>"S",QRYP->PESO-_nImp,0),;
					_nImpCx,;
					_nImp,;
					Iif(QRYP->ZP1_REPROC<>"S",QRYP->QTDCX,0),;
					Iif(QRYP->ZP1_REPROC<>"S",QRYP->PESO,0),;
					Iif(QRYP->ZP1_REPROC=="S",QRYP->QTDCX,0),;
					Iif(QRYP->ZP1_REPROC=="S",QRYP->PESO,0),;
					0,;
					0;
					})
				Else
					_nCxAProd:=(QRYP->QTDCX_NAO_PRODUZIDAS + QRYP->QTDCX_PRODUZIDAS + _nRepCx) - Iif(_nPosAnt>0 .And. !_aCodAnt[_nPosAnt,11],_aCodAnt[_nPosAnt,4],0)
					_nKgAProd:=(QRYP->PESO_NAO_PRODUZIDO + QRYP->PESO_PRODUZIDO + _nRep) - Iif(_nPosAnt>0 .And. !_aCodAnt[_nPosAnt,11],_aCodAnt[_nPosAnt,3],0)
					aAdd(aWBrw021,{.F.,;
					QRYP->ZP1_CODPRO,;
					QRYP->B1_DESC,;
					_nCxAProd,;
					_nKgAProd,;
					QRYP->QTDCX_PRODUZIDAS,;
					QRYP->PESO_PRODUZIDO,;
					QRYP->QTDCX_ATIVAS,;
					QRYP->PESO_ATIVO,;
					_nRepCx,;
					_nRep,;
					Iif(_nPosAnt>0,_aCodAnt[_nPosAnt,4],0),;
					Iif(_nPosAnt>0,_aCodAnt[_nPosAnt,3],0),;
					QRYP->QTDCX_NAO_PRODUZIDAS,;
					QRYP->PESO_NAO_PRODUZIDO;
					})

					If _nPosAnt > 0
						_aCodAnt[_nPosAnt,11] := .T.
					Endif
					/*
					Iif(_nPosAnt>0,_aCodAnt[_nPosAnt,4]-QRYP->QTDCX_PRODUZIDAS,0),;
					Iif(_nPosAnt>0,_aCodAnt[_nPosAnt,3]-QRYP->PESO_PRODUZIDO,0);
					*/
				Endif
			Endif

			QRYP->(dbSkip())
		EndDo
		QRYP->(dbCloseArea())

		If !_lImpSch
			oProcess:SetRegua2(Len(aWBrw021))
			oProcess:IncRegua1("Validando Registros...")
		Endif

		For x:=1 To Len(aWBrw021)
			If !_lImpSch
				oProcess:IncRegua2("Prod: "+aWBrw021[x,3])
			Endif
			aWBrw021[x,1]	:=.T.
			aWBrw021[x,4]	:= Transform(aWBrw021[x,4],"@E 999,999,999.99")
			aWBrw021[x,5]	:= Transform(aWBrw021[x,5],"@E 999,999,999.99")
			aWBrw021[x,6]	:= Transform(aWBrw021[x,6],"@E 999,999,999.99")
			aWBrw021[x,7]	:= Transform(aWBrw021[x,7],"@E 999,999,999.99")
			aWBrw021[x,8]	:= Transform(aWBrw021[x,8],"@E 999,999,999.99")
			aWBrw021[x,9]	:= Transform(aWBrw021[x,9],"@E 999,999,999.99")
			aWBrw021[x,10]	:= Transform(aWBrw021[x,10],"@E 999,999,999.99")
			aWBrw021[x,11]	:= Transform(aWBrw021[x,11],"@E 999,999,999.99")
			aWBrw021[x,12]	:= Transform(aWBrw021[x,12],"@E 999,999,999.99")
			aWBrw021[x,13]	:= Transform(aWBrw021[x,13],"@E 999,999,999.99")
			aWBrw021[x,14]	:= Transform(aWBrw021[x,14],"@E 999,999,999.99")
			aWBrw021[x,15]	:= Transform(aWBrw021[x,15],"@E 999,999,999.99")
		Next x
	Endif
	If Len(aWBrw021) <= 0
		aAdd(aWBrw021,{.F.,"","","","","","","","","","","","","",""})
	EndIf

	/*
	Verifica se houve divergencia de marcaÇÃo de caixas
	*/
	If !_lImpSch .And. MV_PAR03==1
		For _x:=1 To Len(_aCodAnt)
			If _aCodAnt[_x,9] //->Marcação de Caixas
				/*Em caso de ter havido produÇÃo e  haverem caixas sem marcaÇÃo de op */
				If _aCodAnt[_x,3] > 0 .And. _aCodAnt[_x,6] > 0
					_nCxProd:=_aCodAnt[_x,4] //-> Qtd. Caixas Produzidas no SD3
					_nCxProd-=_aCodAnt[_x,7] //-> Qtd. Caixas apontadas como produzidas
					If _nCxProd > 0
						_cQry:="SELECT TOP "+TRANSFORM(_nCxProd, "99999999999999")+" * FROM "+RETSQLNAME("ZP1")+" ZP1 "
						_cQry+="WHERE "
						_cQry+="ZP1_CODPRO='"+_aCodAnt[_x,1]+"' "
						_cQry+="AND ZP1_DTATIV='"+DToS(dDtPrdIni)+"' "
						_cQry+="AND ZP1_OP='' "
						_cQry+="AND ZP1.D_E_L_E_T_=' ' "
						MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZP1_2.SQL", _cQry )
						TcQuery _cQry New Alias "QRYP"
						QRYP->(dbGoBottom())
						oProcess:SetRegua2(QRYP->(LastRec()))
						oProcess:IncRegua1("Ajustando Caixas...")
						QRYP->(dbGoTop())
						While !QRYP->(EOF())
							oProcess:IncRegua2("Prod.:" + QRYP->ZP1_CODPRO)
							ZP1->(dbSetOrder(1))
							If ZP1->(dbSeek(xFilial("ZP1")+QRYP->ZP1_CODETI))
								RecLock("ZP1",.F.)
								ZP1->ZP1_OP := _cNumOp
								ZP1->(MsUnLock())
								U_PCPRGLOG(Iif(!IsBlind(),2,_nTpLog),QRYP->ZP1_CODETI,"58","OP: "+_aCodAnt[_x,2])
							Endif
							QRYP->(dbSkip())
						Enddo
						QRYP->(dbCloseArea())
					Endif
				Endif
			Endif
		Next _x
	Endif
Return

Static Function bStrToVal(_cPar)
	Local _nRet := 0
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
	_nRet := Val(_cPar)
Return(_nRet)

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Registro de Log na ZP1
*/
Static Function LogProd2(_cPrd, _cNumOp, aEtqPrd)
	Local _cSql	:= ""
	Local nret	:= 0
	Local lRet	:= .T.

	For x:=1 To Len(aEtqPrd)
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+aEtqPrd[x,3]))
			RecLock("ZP1",.F.)
			ZP1->ZP1_OP := _cNumOp
			ZP1->(MsUnLock())
			_cSql:="UPDATE ZP1010_MORTO SET ZP1_OP='"+_cNumOp+"' WHERE ZP1_FILIAL='"+xFilial("ZP1")+"' AND ZP1_CODETI='"+aEtqPrd[x,3]+"' "
			nRet := TCSQLExec(_cSql)
			U_PCPRGLOG(Iif(!IsBlind(),2,_nTpLog),aEtqPrd[x,3],"58","OP: "+_cNumOp)
		Else
			_cSql:="UPDATE ZP1010_MORTO SET ZP1_OP='"+_cNumOp+"' WHERE ZP1_FILIAL='"+xFilial("ZP1")+"' AND ZP1_CODETI='"+aEtqPrd[x,3]+"' "
			nRet := TCSQLExec(_cSql)
			If nRet >= 0
				U_PCPRGLOG(Iif(!IsBlind(),2,_nTpLog),aEtqPrd[x,3],"58","OP: "+_cNumOp)
			Endif
		Endif
	Next x

	//->Conferencia
	For x:=1 To Len(aEtqPrd)
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+aEtqPrd[x,3]))
			If ZP1->ZP1_OP <> _cNumOp
				Return(.F.)
			Endif
		Endif
	Next x
Return(.T.)

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Imprimir
*/
Static Function PCP021E()
	Local cTitulo		:= "Relatório Fechamento Producao"
	Local cPerg		:= ""
	Local oReport
	Private cAliasPrt	:= "XXXZZB"
	oReport:=FImp2(cPerg, cTitulo, cAliasPrt)
	oReport:PrintDialog()
Return(.T.)

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Filtro
{cPerg,.F.,.F.}
*/
User Function PCP021F()
	Local lPrw	:= PARAMIXB[3]
	PCP021Z(PARAMIXB[1]) //->Cria Perguntas
	If PARAMIXB[2]
		If Pergunte(PARAMIXB[1],.T.)
			dDtaProdIni	:= MV_PAR01
			dDtaProdFim	:= MV_PAR02
			dDtPrdIni	:= MV_PAR01
			dDtPrdFim	:= MV_PAR02
			_cProdIni	:= MV_PAR04
			_cProdFim	:= MV_PAR05
			PutMv ("MV_GERAOPI", iiF(MV_PAR07=1, .T., .F.))
			ExecBlock("PCP021A",.F.,.F.,{1,lPrw})
		Endif
	Else	
		MV_PAR01	:= dDtPrdIni
		MV_PAR02	:= dDtPrdFim 
		MV_PAR04	:= _cProdIni
		MV_PAR05	:= _cProdFim
		MV_PAR07	:= IIF(_lGeraOPI,1,2)
		ExecBlock("PCP021A",.F.,.F.,{1,lPrw})
	Endif
	If PARAMIXB[4]
		oDlg021:Refresh()
	Endif
Return

/*
Por: Evandro Gomes
Em: 21/08/16
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
Em: 21/08/16
Descrição: Imprimir
*/
Static Function FImp3(oReport, cPerg, cTitulo, cAliasPrt)
	Local oSection1
	oSection1:=TRSection():New(oReport,cTitulo+" Periodo: "+DTOC(dDtPrdIni)+" A "+DTOC(dDtPrdFim)+ "Auditoria(Data: "+DTOC(Date())+" Hora: " + Time()+")",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A1",cAliasPrt,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"A2",cAliasPrt,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"A3",cAliasPrt,OemToAnsi("Cx.N.Import."),"@E 99,999",6+1)
	TRCell():New(oSection1,"A4",cAliasPrt,OemToAnsi("Qt.N.Import."),"@E 999,999.999",11+1)
	TRCell():New(oSection1,"A5",cAliasPrt,OemToAnsi("Cx.Importada"),"@E 99,999",6+1)
	TRCell():New(oSection1,"A6",cAliasPrt,OemToAnsi("Qt.Importada"),"@E 999,999.999",11+1)
	TRCell():New(oSection1,"A7",cAliasPrt,OemToAnsi("Cx.Ativada"),"@E 99,999",6+1)
	TRCell():New(oSection1,"A8",cAliasPrt,OemToAnsi("Qt.Ativada"),"@E 999,999.999",11+1)
	TRCell():New(oSection1,"A9",cAliasPrt,OemToAnsi("Cx.Reproces."),"@E 99,999",6+1)
	TRCell():New(oSection1,"AA",cAliasPrt,OemToAnsi("Qt.Reproces."),"@E 999,999.999",11+1)
	TRCell():New(oSection1,"AB",cAliasPrt,OemToAnsi("Cx. PR0"),"@E 99,999",6+1)
	TRCell():New(oSection1,"AC",cAliasPrt,OemToAnsi("Qt. PR0"),"@E 999,999.999",11+1)
	TRCell():New(oSection1,"AD",cAliasPrt,OemToAnsi("Cx.ZP1XSD3"),"@E 99,999",6+1)
	TRCell():New(oSection1,"AE",cAliasPrt,OemToAnsi("Qt.ZP1XSD3"),"@E 999,999.999",11+1)

	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")
	TRFunction():New(oSection1:Cell("A3"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A4"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A5"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A6"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A7"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A8"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("A9"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("AA"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("AB"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("AC"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("AD"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("AE"),NIL,"SUM",,,,,.F.,.T.)
	oSection1:Init()

	oReport:SetMeter(Len(aWBrw021))
	oProcess:SetRegua1(1)
	oProcess:SetRegua2(Len(aWBrw021))
	oProcess:IncRegua1("Gerando Relatorio")

	For x:=1 To Len(aWBrw021)
		If oReport:Cancel() //->Cancelar
			Exit
		EndIf
		oReport:IncMeter()
		IncProc("Imprimindo Produto "+cValToChar(aWBrw021[x,3]))
		oProcess:IncRegua2("Prod: "+aWBrw021[x,3])
		oSection1:Cell("A1"):SetValue(aWBrw021[x,2])
		oSection1:Cell("A2"):SetValue(aWBrw021[x,3])
		oSection1:Cell("A3"):SetValue(bStrToVal(aWBrw021[x,4]))
		oSection1:Cell("A4"):SetValue(bStrToVal(aWBrw021[x,5]))
		oSection1:Cell("A5"):SetValue(bStrToVal(aWBrw021[x,6]))
		oSection1:Cell("A6"):SetValue(bStrToVal(aWBrw021[x,7]))
		oSection1:Cell("A7"):SetValue(bStrToVal(aWBrw021[x,8]))
		oSection1:Cell("A8"):SetValue(bStrToVal(aWBrw021[x,9]))
		oSection1:Cell("A9"):SetValue(bStrToVal(aWBrw021[x,10]))
		oSection1:Cell("AA"):SetValue(bStrToVal(aWBrw021[x,11]))
		oSection1:Cell("AB"):SetValue(bStrToVal(aWBrw021[x,12]))
		oSection1:Cell("AC"):SetValue(bStrToVal(aWBrw021[x,13]))
		oSection1:Cell("AD"):SetValue(bStrToVal(aWBrw021[x,14]))
		oSection1:Cell("AE"):SetValue(bStrToVal(aWBrw021[x,15]))
		oSection1:Printline()
	Next x

	oSection1:Finish()
Return(oReport)

/* Add etiquetas */
Static Function fAddEtq(_lxQryEti,_DtPrw, _cCodPro, _nQtd, _nQtdCx, _aErr, aEtqPrd, aQryUpd, _cNumOp)
	Local _lRet		:= .T.
	Local _nPeso	:= 0
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx	:= 0
	Local cAliasSD3	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _cUpd		:= ""
	Local lf 		:= chr(13)+chr(10)

	aEtqPrd	:= {}
	aQryUpd	:= {}

	If _lxQryEti //-> Altera as etiquetas por query update
		If !_lImpSch
			oProcess:SetRegua1(1)
			oProcess:SetRegua2(5)
			oProcess:IncRegua1("Sel. Etiquetas....")
		Endif
		_cUpd := " UPDATE "
		_cUpd += RetSQLName("ZP1")+" "
		_cUpd += " SET ZP1_OP='"+_cNumOp+"' "
		_cUpd += " WHERE D_E_L_E_T_ = ' '"
		_cUpd += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cUpd += " AND ZP1_STATUS IN ('1','2','3','7','9') "
		_cUpd += " AND ZP1_OP = '' "
		_cUpd += " AND ZP1_REPROC <> 'S'"
		_cUpd += " AND (ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
		_cUpd += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"
		_cUpd += " AND ZP1_HRATIV <> 'INVENTAR'"
		_cUpd += " AND ZP1_CODPRO='"+_cCodPro+"' "
		AADD(aQryUpd,{1,_cUpd})
		If !_lImpSch
			oProcess:IncRegua2("Query Update 01")
		Endif
		_cUpd := " UPDATE "
		_cUpd += RetSQLName("ZP1")+"_MORTO "
		_cUpd += " SET ZP1_OP='"+_cNumOp+"' "
		_cUpd += " WHERE D_E_L_E_T_ = ' '"
		_cUpd += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cUpd += " AND ZP1_STATUS IN ('1','2','3','7','9') "
		_cUpd += " AND ZP1_OP = '' "
		_cUpd += " AND ZP1_REPROC <> 'S'"
		_cUpd += " AND (ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
		_cUpd += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"
		_cUpd += " AND ZP1_HRATIV <> 'INVENTAR'"
		_cUpd += " AND ZP1_CODPRO='"+_cCodPro+"' "
		AADD(aQryUpd,{2,_cUpd})
		If !_lImpSch
			oProcess:IncRegua2("Query Update 02")
		Endif
		_cUpd := " UPDATE "
		_cUpd += RetSQLName("ZP1")+" "
		_cUpd += " SET ZP1_OP='"+_cNumOp+"' "
		_cUpd += " WHERE "
		_cUpd += " ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cUpd += " AND ZP1_STATUS IN ('1','2','3','7','9') "
		_cUpd += " AND ZP1_REPROC = 'S'"
		_cUpd += " AND ZP1_OP = '' "
		_cUpd += " AND (ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
		_cUpd += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"
		_cUpd += " AND ZP1_HRATIV <> 'INVENTAR'"
		_cUpd += " AND ZP1_CODPRO='"+_cCodPro+"' "
		AADD(aQryUpd,{3,_cUpd})
		If !_lImpSch
			oProcess:IncRegua2("Query Update 03")
		Endif
		_cUpd := " UPDATE "
		_cUpd += RetSQLName("ZP1")+"_MORTO "
		_cUpd += " SET ZP1_OP='"+_cNumOp+"' "
		_cUpd += " WHERE "
		_cUpd += " ZP1_FILIAL = '"+xFilial("ZP1")+"'"
		_cUpd += " AND ZP1_STATUS IN ('1','2','3','7','9') "
		_cUpd += " AND ZP1_REPROC = 'S'"
		_cUpd += " AND ZP1_OP = '' "
		_cUpd += " AND (ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
		_cUpd += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"
		_cUpd += " AND ZP1_HRATIV <> 'INVENTAR'"
		_cUpd += " AND ZP1_CODPRO='"+_cCodPro+"' "
		AADD(aQryUpd,{4,_cUpd})
		If !_lImpSch
			oProcess:IncRegua2("Query Update 04")
		Endif
	Endif
	If !_lImpSch
		oProcess:IncRegua2("Validando Peso Caixa x Producao...")
	Endif
	If _lxQryEti //-> Altera as etiquetas por query update
		_cQry := " SELECT SUM(QTD) AS QTDCX, SUM(ZP1PESO) AS PESO  "+lf
	Else
		_cQry := " SELECT TOP "+cValToChar(_nQtdCx)+" "+lf
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_DTATIV, ZP1_CODETI, ZP1_REPROC, ZP1_PESO "+lf
	Endif
	_cQry += " FROM "+lf
	_cQry += " (SELECT "+lf
	If _lxQryEti //-> Altera as etiquetas por query update
		_cQry += " COUNT(*) AS QTD, SUM(ZP1_PESO) ZP1PESO "+lf
	Else
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_DTATIV, ZP1_CODETI, ZP1_REPROC, ZP1_PESO "+lf
	Endif
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK) "+lf
	If !_lxQryEti //-> Altera as etiquetas por query update
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"+lf
		_cQry += " AND SB1.B1_TIPO <> 'ME' "+lf
	Endif
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"+lf
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"+lf
	_cQry += " AND ZP1_STATUS IN ('1','2','3','7','9') "+lf
	_cQry += " AND ZP1_OP = '' "+lf
	_cQry += " AND ZP1.ZP1_REPROC <> 'S'"+lf
	_cQry += " AND (ZP1.ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"+lf
	_cQry += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"+lf
	_cQry += " AND ZP1_HRATIV <> 'INVENTAR'"+lf
	_cQry += " AND ZP1_CODPRO='"+_cCodPro+"' "+lf

	_cQry += " UNION ALL "+lf

	_cQry += " SELECT "+lf
	If _lxQryEti //-> Altera as etiquetas por query update
		_cQry += " COUNT(*) AS QTD, SUM(ZP1_PESO) ZP1PESO "+lf
	Else
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_DTATIV, ZP1_CODETI, ZP1_REPROC, ZP1_PESO "+lf
	Endif
	_cQry += " FROM ZP1010_MORTO ZP1_MORTO WITH (NOLOCK) "+lf
	If !_lxQryEti //-> Altera as etiquetas por query update
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"+lf
		_cQry += " AND SB1.B1_TIPO <> 'ME' "+lf
	Endif
	_cQry += " WHERE ZP1_MORTO.D_E_L_E_T_ = ' '"+lf
	_cQry += " AND ZP1_MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'"+lf
	_cQry += " AND ZP1_MORTO.ZP1_STATUS IN ('1','2','3','7','9') "+lf
	_cQry += " AND ZP1_MORTO.ZP1_OP = '' "+lf
	_cQry += " AND ZP1_MORTO.ZP1_REPROC <> 'S'"+lf
	_cQry += " AND (ZP1_MORTO.ZP1_EDATA <> 'S' OR ZP1_MORTO.ZP1_OP = 'TUNEDATA' OR ZP1_MORTO.ZP1_OP = 'RETEDATA')"+lf
	_cQry += " AND ZP1_MORTO.ZP1_DTATIV = '"+DToS(_DtPrw)+"'"+lf
	_cQry += " AND ZP1_MORTO.ZP1_HRATIV <> 'INVENTAR'"+lf
	_cQry += " AND ZP1_MORTO.ZP1_CODPRO='"+_cCodPro+"' "+lf

	_cQry += " UNION ALL "+lf

	_cQry += " SELECT "+lf
	If _lxQryEti //-> Altera as etiquetas por query update
		_cQry += " COUNT(*) AS QTD, SUM(ZP1_PESO) ZP1PESO "+lf
	Else
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_DTATIV, ZP1_CODETI, ZP1_REPROC, ZP1_PESO "+lf
	Endif
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK) "+lf
	If !_lxQryEti //-> Altera as etiquetas por query update
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"+lf
		_cQry += " AND SB1.B1_TIPO <> 'ME' "+lf
	Endif
	_cQry += " WHERE "+lf
	_cQry += " ZP1_FILIAL = '"+xFilial("ZP1")+"'"+lf
	_cQry += " AND ZP1_STATUS IN ('1','2','3','7','9') "+lf
	//_cQry += " AND ZP1_OP = '' "
	_cQry += " AND ZP1.ZP1_REPROC = 'S'"+lf
	_cQry += " AND (ZP1.ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"+lf
	_cQry += " AND ZP1_DTATIV = '"+DToS(_DtPrw)+"'"+lf
	_cQry += " AND ZP1_HRATIV <> 'INVENTAR'"+lf
	_cQry += " AND ZP1_CODPRO='"+_cCodPro+"' "+lf
	_cQry += " AND ZP1.D_E_L_E_T_ = ' '"+lf		
	_cQry += " UNION ALL "+lf

	_cQry += " SELECT "+lf
	If _lxQryEti //-> Altera as etiquetas por query update
		_cQry += " COUNT(*) AS QTD, SUM(ZP1_PESO) ZP1PESO "+lf
	Else
		_cQry += " ZP1_FILIAL, ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_DTATIV, ZP1_CODETI, ZP1_REPROC, ZP1_PESO "+lf
	Endif
	_cQry += " FROM ZP1010_MORTO ZP1_MORTO WITH (NOLOCK) "+lf
	If !_lxQryEti //-> Altera as etiquetas por query update
		_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"+lf
		_cQry += " AND SB1.B1_TIPO <> 'ME'"+lf
	Endif
	_cQry += " WHERE "+lf
	_cQry += " ZP1_MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'"+lf
	_cQry += " AND ZP1_MORTO.ZP1_STATUS IN ('1','2','3','7','9') "+lf
	//_cQry += " AND ZP1_MORTO.ZP1_OP = '' "
	_cQry += " AND ZP1_MORTO.ZP1_REPROC = 'S'"+lf
	_cQry += " AND (ZP1_MORTO.ZP1_EDATA <> 'S' OR ZP1_MORTO.ZP1_OP = 'TUNEDATA' OR ZP1_MORTO.ZP1_OP = 'RETEDATA')"+lf
	_cQry += " AND ZP1_MORTO.ZP1_DTATIV = '"+DToS(_DtPrw)+"'"+lf
	_cQry += " AND ZP1_MORTO.ZP1_HRATIV <> 'INVENTAR'"+lf
	_cQry += " AND ZP1_MORTO.D_E_L_E_T_ = ' '"+lf
	_cQry += " AND ZP1_MORTO.ZP1_CODPRO='"+_cCodPro+"' ) AS SUBQRY "+lf

	MemoWrite("C:\TEMP\PCP021_CAIXAS_ZP1.SQL", _cQry )

	TcQuery _cQry New Alias "QRYP"

	QRYP->(dbGoBottom())
	If !_lImpSch
		oProcess:SetRegua1(1)
		oProcess:SetRegua2(QRYP->(LastRec()))
		oProcess:IncRegua1("Sel. Etiquetas....")
	Endif

	QRYP->(dbGoTop())
	_aCodAnt:={}

	If _lxQryEti //-> Altera as etiquetas por query update
		_nPeso+=QRYP->PESO
	Else
		While !QRYP->(EOF())

			If !_lImpSch
				oProcess:IncRegua2("Etiq.:" + SubStr(QRYP->ZP1_CODETI,1,20))
			Endif

			aAdd(aEtqPrd,{QRYP->ZP1_FILIAL,QRYP->ZP1_CODPRO,QRYP->ZP1_CODETI})
			_nPeso+=QRYP->ZP1_PESO

			QRYP->(dbSkip())
		EndDo
	Endif
	QRYP->(dbCloseArea())


	//->Valida Qtd. Produção X Qtd. Caixas
	If _nPeso <> _nQtd 
		If _lImpSch
			Conout("ERRO:")
			Conout("Apontamento Etiqueta")
			Conout("Divergencia entre Qtd. Producao x Qtd. Caixas")
			Conout("Qtd. Producao: " + Transform(_nQtd,"@E 999,999,999.99"))
			Conout("Qtd. Caixas: " + Transform(_nPeso,"@E 999,999,999.99"))
			Conout("")
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Divergencia entre Qtd. Producao x Qtd. Caixas","ERRO"})
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Peso da Ordem de Producao: " + Transform(_nQtd,"@E 999,999,999.99"),"ERRO"})
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Peso encontrado de Caixas: " + Transform(_nPeso,"@E 999,999,999.99"),"ERRO"})
		Else
			If __nOpc == 1 //-> Produção Manual
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Divergencia entre Qtd. Producao x Qtd. Caixas","ERRO"})
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Peso da Ordem de Producao: " + Transform(_nQtd,"@E 999,999,999.99"),"ERRO"})
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"ERRO 007: Peso encontrado de Caixas: " + Transform(_nPeso,"@E 999,999,999.99"),"ERRO"})
			Endif
			dDataBase := _dBkDt
		Endif
		Return(.F.)
	Else
		If _lImpSch
			Conout("Apontamento Etiqueta")
			Conout("Peso de Producao Encontrado: " + Transform(_nQtd,"@E 999,999,999.99"))
			Conout("Peso de Caixas Encontrado: " + Transform(_nPeso,"@E 999,999,999.99"))
			Conout("")
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Peso da Ordem de Producao: " + Transform(_nQtd,"@E 999,999,999.99"),""})
			AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Peso encontrado de Caixas: " + Transform(_nPeso,"@E 999,999,999.99"),""})
		Else
			If __nOpc == 1 //-> Produção Manual
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Peso da Ordem de Producao: " + Transform(_nQtd,"@E 999,999,999.99"),""})
				AADD(_aErr,{"["+DTOC(Date())+" - "+Time()+"]"+"Peso encontrado de Caixas: " + Transform(_nPeso,"@E 999,999,999.99"),""})
			Endif
			dDataBase := _dBkDt
		Endif
	Endif
Return(_lRet)


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
User Function PCP021M(_cSubObject,_cTitEmail, _aBody, _aDetal, _aFileMail,_cMails)

	local cPopAddr	:= GetMV("MV_WFPOPS")   // Endereco do servidor POP3
	local cSMTPAddr	:= GetMV("MV_WFSMTPS")  // Endereco do servidor SMTP
	local cPOPPort 	:= GetMV("MV_WFPRTPO")  // Porta do servidor POP
	local cSMTPPort	:= GetMV("MV_WFPRTSM")	// Porta do servidor SMTP
	local cUser    	:= GetMV("MV_WFMAIL")   // Usuario que ira realizar a autenticacao
	local cPass    	:= GetMV("MV_WFPASSW")  // Senha do usuario
	local oReqAut  	:= GetMV("MV_WFREQAU")  // Requer Autenticação
	local oReqSSL  	:= GETMV("MV_WFRESSL")  // Requer Autenticação  
	local nSMTPTime	:= 60
	Local aSe1		:= {}
	Local aSc6		:= {}
	Local nSp		:= 7
	Local _cAnexos	:= ""
	Local _lEnvMail	:= GetNewPar("MV_XEMFICS",.T.)
	Local cDestino	:= "ti@friato.com.br;" + IIF(Type("_cMails") <> "U", _cMails, IIF(Type("cMailImp") <> "U",cMailImp,"")) 
	Local	_cSmtpError	:= '',;
	_lOk		:= .f.,;
	_cTitulo 	:= OemToAnsi(_cSubObject),;
	_cTo		:= cDestino,;
	_cFrom		:= 'protheus@friato.com.br',; //->_cMailTec,;
	_cMensagem	:= '',;
	_lReturn	:= .f.

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
Static Function PCP021W(cLogFile, aLog)
	Local lRet := .F.
	If !File(cLogFile)			
		If (nHandle := MSFCreate(cLogFile,0)) <> -1	
			lRet := .T.	
		EndIf
	Else
		fErase(cLogFile)
		/*If (nHandle := FOpen(cLogFile,2)) <> -1
		FSeek(nHandle,0,2)
		lRet := .T.
		EndIf*/

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
Descricao: Produção Autom‡tica
*/
User Function PCP021Y()
	ExecBlock("PCP021F",.F.,.F.,{cPerg,.F.,.F.,.T.})
	ExecBlock("PCP021A",.F.,.F.,{3}) //-> Inverte seleção
	ExecBlock("PCP021A",.F.,.F.,{2}) //-> Produção
	aWBrw021:={}
	aAdd(aWBrw021,{.F.,"","","","","","","","","",""})
	U_OHFUNA21(@oDlg021, @oWBrw021, _aCabec, @aWBrw021, _cFunMrk)
Return(.T.)


/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Marca
*/
User Function PCP021X()
	oWBrw021:aArray[oWBrw021:nAt][1]:= !oWBrw021:aArray[oWBrw021:nAt][1]
	aWBrw021[oWBrw021:nAt][1]:=oWBrw021:aArray[oWBrw021:nAt][1]
	oWBrw021:DrawSelect()
	oWBrw021:Refresh()
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
Static Function PCP021Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Data de?"		,"","","mv_ch1","D",08,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data ate?"		,"","","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Ajusta Cx OP?"	,"","","mv_ch3","N",01,0,1,"C","","","","","MV_PAR03","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Produto de?"	    ,"","","mv_ch4","C",15,0,0,"G","","SB1","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Produto ate?"	,"","","mv_ch5","C",15,0,0,"G","","SB1","","","MV_PAR05","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Prod. Negada"	,"","","mv_ch6","C",100,0,0,"G","","SB1","","","MV_PAR06","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","MV_GERAOPI"  	,"","","mv_ch7","N",1,0,0,"C","","","","","MV_PAR07","Sim","","","","Nao","","","","","","","","","","","","","","")

	dbSelectArea("SX6")
	SX6->(dbSetOrder(1))
	If !SX6->(dbSeek(xFilial("SX6") + "MV_XPCPDTA" ))
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "MV_XPCPDTA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Dta. Fecha Producao"
		SX6->X6_CONTEUD := "20180101"
		SX6->X6_CONTSPA := "20180101"
		SX6->X6_CONTENG := "20180101"
		SX6->(MsUnlock())
	Endif
Return