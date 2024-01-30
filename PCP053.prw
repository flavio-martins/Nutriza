#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH
#INCLUDE "apvt100.ch"
#INCLUDE 'PARMTYPE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP053   ºAutor  ³Evandro Gomes     º Data ³ 02/05/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fluxo de caixas por ArmazŽm 								    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA - PCP 													 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP053()
	Private cPerg	:= Padr("PCP053",10)
	Private ODLGF53
	Private _cFunMrk	:= ""
	//->Browse de ZPEs
	Private oWBrwF53
	Private aWBrwF53 	:= {}
	Private cStatus	:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros	:= {}
	Private _cLocDoc	:= GetNewPar("MV_XWMSLCD","94") //->Armazéns das docas

	//->Par‰metros para interface
	Private _aButts		:= {}
	Private _cTitulo		:= "Faturamento Por Carga"
	Private _aCabec		:= {}
	Private _aButts		:= {}
	Private aObjects		:= {}
	Private _nTpLog		:= GetNewPar("MV_PCPTLOG",1)
	Private oOk 			:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 			:= LoadBitmap( GetResources(), "LBNO")
	Private _oNo			:= LoadBitmap( GetResources(), "disable" )
	Private _oOk 			:= LoadBitmap( GetResources(), "enable")
	Private oFntSt 		:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private  _cFunAx		:= ""
	Private aCores		:= {}
	Private _cLocDoc		:= GetNewPar("MV_XWMSLCD","10") //->ArmazŽns das docas
	Private _lHabFeCx		:= GetNewPar("MV_XPCPHFC",.T.) //->Habilita Fechamento de Caixa por ArmazŽm

	If !_lHabFeCx
		Alert("Rotina desabilitada.")
		Return .F.
	Endif

	PCP053Z(cPerg)
	Pergunte(cPerg,.T.)

	aCores := 	{ 	{"BR_VERDE"	, "Aberto"},;
	{"BR_AMARELO"	, "Suspenso"},;
	{"BR_VERMELHO", "Fechado"}}

	AADD(_aButts,{"", { || ExecBlock("PCP053A",.F.,.F.,{1,cPerg,.T.,.T.}) },"Filtrar", "Filtrar"})    			
	AADD(_aButts,{"", { || ExecBlock("PCP053D",.F.,.F.,{3,cPerg,aWBrwF53[oWBrwF53:nAt][3], aWBrwF53[oWBrwF53:nAt][9]}) },"Abrir", "Abrir"})
	/*
	AADD(_aButts,{"", { || ExecBlock("PCP053A",.F.,.F.,{3,cPerg,aWBrwF53[oWBrwF53:nAt][3], aWBrwF53[oWBrwF53:nAt][9]}) },"Fechar", "Fechar"})
	AADD(_aButts,{"", { || ExecBlock("PCP053A",.F.,.F.,{3,cPerg,aWBrwF53[oWBrwF53:nAt][3], aWBrwF53[oWBrwF53:nAt][9]}) },"Imprimir", "Imprimir"})
	*/
	_aCabec:={"","Codigo","Data","Local","Dta. Abre","Hr. Abre","Dta. Fecha","Hr. Fechar","RECNO"}
	ExecBlock("PCP053A",.F.,.F.,{1,cPerg,.F.,.F.})
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrwF53, @oDlgF53, @oWBrwF53, .F., .F., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F., , , ,aCores)
Return

/* Regua de Processamento */
User Function PCP053A()
	Local _lRet 	:= .T.
	Local nOpc		:= PARAMIXB[1]
	Local _cPerg	:= PARAMIXB[2]
	Local _lRefx	:= PARAMIXB[3]
	Local _lPerg	:= PARAMIXB[4]
	Private oProcess

	If nOpc==1 //->Lista Agendas
		oProcess:=MsNewProcess():New( { || PCP053B(_lPerg,_cPerg) } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If _lRefx
			U_OHFUNA21(@oDlgF53, @oWBrwF53, _aCabec, @aWBrwF53, _cFunMrk)
			oWBrwF53:Refresh()
		Endif
	Endif

Return(_lRet)

/*
Lista Cargas
*/
Static Function PCP053B(_lPerg,_cPerg)
	Local lContinua 	:= .T.
	Local cQryZPS		:= ""
	Local _cStatus	:= ""
	Local _cSituac	:= ""
	Local _CALIASZPS	:= GetNextAlias()

	Pergunte(_cPerg,_lPerg)

	aWBrwF53:={}

	cQryZPS := " SELECT * "
	cQryZPS += " FROM "+RETSQLNAME("ZPS")+" ZPS WITH(NOLOCK) "
	cQryZPS += " WHERE "
	cQryZPS += " ZPS.ZPS_FILIAL='"+xFilial("ZPS")+"'"
	cQryZPS += " AND ZPS_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	cQryZPS += " AND ZPS_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

	If ( MV_PAR05 == 1 ) //-> Aberto
		cQryZPS += " AND ZPS_STATUS='A'"
	ElseIf ( MV_PAR05 == 2 ) //-> Fechado
		cQryZPS += " AND ZPS_STATUS='F'"
	EndIf

	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZPS.SQL", cQryZPS )
	dbUseArea(.T.,"TopConn",TCGenQry(,,cQryZPS),_cAliasZPS,.F.,.T.)
	(_cAliasZPS)->(dbGoBottom())
	oProcess:SetRegua1(2)
	oProcess:SetRegua2((_cAliasZPS)->(LastRec()))
	oProcess:IncRegua1("Selecionando....")
	(_cAliasZPS)->(dbGoTop())
	While !(_cAliasZPS)->(EOF())
		oProcess:IncRegua2("Carga: "+(_cAliasZPS)->ZPS_COD)
		aAdd(aWBrwF53,{.T.,;
		IIF((_cAliasZPS)->ZPS_STATUS=="A","BR_VERDE",IIF((_cAliasZPS)->ZPS_STATUS=="F","BR_VERMELHO","BR_AMARELO")),;
		(_cAliasZPS)->ZPS_CODCXA,;
		DTOC(STOD((_cAliasZPS)->ZPS_DATA)),;
		(_cAliasZPS)->ZPS_LOCAL,;
		DTOC(STOD((_cAliasZPS)->ZPS_DTABRE)),;
		(_cAliasZPS)->ZPS_HRABRE,;
		DTOC(STOD((_cAliasZPS)->ZPS_DTFECH)),;
		(_cAliasZPS)->ZPS_HRFECH,;
		cvaltochar((_cAliasZPS)->R_E_C_N_O_) })
		(_cAliasZPS)->(dbSkip())
	EndDo
	(_cAliasZPS)->(dbCloseArea())
	If File(_cAliasZPS+GetdbExtension());FErase(_cAliasZPS+GetDbExtension());Endif
	If File(_cAliasZPS+OrdBagExt());FErase(_cAliasZPS + OrdBagExt());Endif
	If Len(aWBrwF53) <= 0
		aAdd(aWBrwF53,{"BR_VERMELHO","","  /  /    ","","  /  /    ","  :  :  ","  /  /    ","  :  :  ","0"})
	EndIf
Return

/* Ações no Grid */
Static Function PCP053C(_nTipo)
	Local _lRet 	:= .T.
	Local cMarca  := ThisMark()
	Local aErros	:= {}
Return

/* Abrir Caixa */
User Function PCP053D()
	Local _lRet 		:= .T.
	Local _aCmpVis	:={"ZPS_DATA","ZPS_LOCAL","ZPS_USER","ZPS_DTABRE","ZPS_HRABRE"}
	Local _aCmpEdt	:={"ZPS_DATA","ZPS_LOCAL"}
	PRIVATE cCadastro	:= "Manutencao de Registro"

	If PARAMIXB[1] == 3 //->Incluir
		//->Valisa se J‡ existe Caixa Aberto
		nOpcao := AxInclui('ZPS', 0, PARAMIXB[1],_aCmpVis,"U_PCP053D1()",_aCmpEdt,"U_PCP053D2()",,,,,,,,,,,,,)
		ExecBlock("PCP053A",.F.,.F.,{1,cPerg,.T.,.F.})
	Endif
Return(_lRet)

/* Antes de Entrada na Tela */
User Function PCP053D1()
	M->ZPS_USER	:= UsrRetName(RetCodUsr())
	M->ZPS_STATUS	:= "A"
	M->ZPS_DTABRE	:= Date()
	M->ZPS_HRABRE	:= Time()
Return

/* Tudo Ok */
User Function PCP053D2()
	Local _aRet	:= U_PCP053W(1, M->ZPS_LOCAL)
	Local _lRet	:= .T.

	//-> Valida se existe caixa aberto
	If Len(AllTrim(_aRet[1])) <> 0
		MsgStop("Imposs’vel abre caixa, j‡ existe um caixa aberto para este local.","Atencao")
		Return .F.
	Endif

Return(_lRet)

/*
Fechar/Suspender Caixa
nTipo==1 -> Fechar Caixa
nTipo==2 -> Visualiza
*/
Static Function PCP053E(nTipo, _cCodCxa,_dData, _cLocal, _aErros)
	Local _lRet 		:= .T.
	Local _cQry		:= ""
	Local _cAliasZP1	:= GetNextAlias()
	Local _cAliasZPS	:= GetNextAlias()
	Local _cAliasZPU	:= GetNextAlias()
	Local _aFecha		:= {}
	Local _nErr		:= 0
	Local _nSldAnt	:= 0
	Local _nEntrada	:= 0
	Local _nSaida		:= 0
	Local _nSldAtu	:= 0
	Local _aSldAnal	:= {} //-> Anal’tico
	Local _aSldSint	:= {0,0,0,0} //-> SintŽtico


	ZPS->(dbSetOrder(1))
	If ZPS->(dbSeek(xFilial("ZPS") + _cCodCxa))

		If ZPS->ZPS_STATUS== "F" .And. nTipo ==1 //-> Tentativa de fechar caixa
			AADD(_aErros,{"IMPOSSIVEI FECHAR CAIXA, O CAIXA Jç ESTç FECHADO","ERRO"})
			Return(.F.)
		Endif

		ZPT->(dbSetOrder(1)) //->Se j‡ existe caixa fechado.
		If ZPT->(dbSeek(xFilial("ZPS") + _cCodCxa))
			oProcess:SetRegua1(3)
			oProcess:SetRegua2(100)
			While !ZPT->(Eof())
				oProcess:IncRegua1("Sld. Anterior/Entrada/Saida/Sld. Atual...")
				AADD(_aSldAnal,{;
				ZPT->ZPT_CODPRO,;
				ZPT->ZPT_SLDANT,;
				ZPT->ZPT_ENTRAD,;
				ZPT->ZPT_SAIDA,;
				ZPT->ZPT_SLDATU})
				ZPT->(dbSkip())
			Enddo
		Else	
			oProcess:SetRegua1(4)
			oProcess:IncRegua1("Saldo anterior...")

			//->Saldo Anterior
			PCP053F(ZPS->ZPS_CODCXA, ZPS->ZPS_DATA, ZPS->ZPS_LOCAL, @_aSldAnal)

			oProcess:IncRegua1("Entrada/Saida...")
			oProcess:SetRegua2(Len(_aSldAnal))

			For x:=1 To Len(_aSldAnal)
				oProcess:IncRegua2("Produto: "+_aSldAnal[x][1])
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1") + _aSldAnal[x][1]))
					_nSldAnt	:= _aSldAnal[x][2]
					_nEntrada	:= 0
					_nSaida	:= 0
					_nSldAtu	:= 0

					//->Entradas/Sa’da
					_cQry:=" SELECT ZPU_TIPO, SUM(ZPU_PESO) PESO, SUM(ZPU_QTDCX) QTDCX "
					_cQry+=" FROM "+RETSQLNAME("ZPU")+" ZPU "
					_cQry+=" WHERE "
					_cQry+=" WHERE ZPU_CODCXA = '"+_cCodCxa+"' "
					_cQry+=" AND ZPU_LOCAL= '"+_cLocal+"'"
					_cQry+=" AND ZPU_CODPRO= '"+_aSldAnal[x][1]+"'"
					_cQry+=" AND ZPU.D_E_L_E_T_=''"
					_cQry+=" GROUP BY ZPU_TIPO"
					_cQry+=" ORDER BY ZPU_TIPO"
					dbUseArea(.F.,"TOPCONN",TcGenQry(,,_cQry),_cAliasZPU,.T.,.F.)
					While !(_cAliasZPU)->(Eof())
						If (_cAliasZPU)->ZPU_TIPO == "E"
							_nEntrada	+= (_cAliasZPU)->ZPU_PESO
						Else
							_nSaida	+= (_cAliasZPU)->ZPU_PESO
						Endif
						(_cAliasZPU)->(dbSkip())
					Enddo
					(_cAliasZPU)->(dbCloseArea())
					If File(_cAliasZPU+GetDBExtension());fErase(_cAliasZPU+GetDBExtension());Endif
					If File(_cAliasZPU+OrdBagExt());fErase(_cAliasZPU+OrdBagext());Endif

					_nSldAtu:=_nSldAnt
					_nSldAtu+=_nEntrada
					_nSldAtu-=_nSaida

					_aSldAnal[x][3]:=_nEntrada
					_aSldAnal[x][4]:=_nSaida
					_aSldAnal[x][5]:=_nSldAtu
				Else
					_nErr++
					AADD(_aErros,{"NAO SERA POSSIVEL "+Iif(nTipo==1,"Fechamento","Visualizar")+" PRODUTO "+(_cAliasZP1)->ZP1_CODPRO+" NAO ENCONTRADO.","ERRO"})
				Endif
			Next x
		Endif

		oProcess:IncRegua1("Salvado Registro...")
		oProcess:SetRegua2(Len(_aSldAnal))
		For x:=1 To Len(_aSldAnal)
			If nTipo == 1 //-> Fechar
				oProcess:IncRegua2("Produto: "+_aSldAnal[x][1])
				RecLock("ZPT",.T.)
				ZPT->ZPT_FILIAL	:= xFilial("ZPT")
				ZPT->ZPT_CODCXA	:= _cCodCxa
				ZPT->ZPT_DATA		:= _dData
				ZPT->ZPT_LOCAL	:= _cLocal
				ZPT->ZPT_CODPRO	:= _aSldAnal[x][1]
				ZPT->ZPT_SLDANT	:= _aSldAnal[x][2]
				ZPT->ZPT_ENTRAD	:= _aSldAnal[x][3]
				ZPT->ZPT_SAIDA	:= _aSldAnal[x][4]
				ZPT->ZPT_SLDATU	:= _aSldAnal[x][5]
				ZPT->(MsUnLock())
				_aSldSint[1][1]+=_aSldAnal[x][2]
				_aSldSint[1][2]+=_aSldAnal[x][3]
				_aSldSint[1][3]+=_aSldAnal[x][4]
				_aSldSint[1][4]+=_aSldAnal[x][5]
			Endif
		Next x

		oProcess:IncRegua1("Salvado Registro...")

		If nTipo == 1 //-> Fechar
			RecLock("ZPS",.F.)
			ZPS->ZPS_DTFECH	:= Date()
			ZPS->ZPS_HRFECH	:= Time()
			ZPS->(MsUnLock())
		ENdif

		//->Imprimir
		If Len(_aSldAnal) > 0
			PCP053G(_cCodCxa, _dData, _cLocal,_aSldAnal) //->Imprimir
		Else
			_nErr++
			AADD(_aErros,{"NAO FOI POSSIVEL IMPRIMIR: DADOS NAO ENCONTRADOS.","ERRO"})
		Endif
	Endif		
Return(_lRet)

/*
Saldo Anterior
*/
Static Function PCP053F(_cCodCxa, _dData, _cLocal,_aSldAnal)
	Local _nRet		:= 0
	Local _cSql		:= ""
	Local _cAliasZPTx	:= GetNextAlias()
	_cSql:="SELECT  "
	_cSql+=" * "
	_cSql+=" FROM "+RETSQLNAME("ZPT")+" ZPT "
	_cSql+=" WHERE ZPT_CODCXA = '"+_cCodCxa+"' "
	_cSql+=" AND ZPT_DATA = '"+DTOS(_dData)+"' "
	_cSql+=" AND ZPT_LOCAL= '"+_cLocal+"'"
	_cSql+=" AND ZPT.D_E_L_E_T_=''"
	_cSql+=" ORDER BY ZPT_CODPRO "
	dbUseArea(.F.,"TOPCONN",TcGenQry(,,_cSql),_cAliasZPTx,.T.,.F.)
	(_cAliasZPTx)->(dbGoBottom())
	oProcess:SetRegua2((_cAliasZPTx)->(LastRec()))
	(_cAliasZPTx)->(dbGoTop())
	While !(_cAliasZPTx)->(Eof())
		oProcess:IncRegua("Produto: "+(_cAliasZPTx)->ZPT_CODPRO)	
		AADD(_aSldAnal,{;
		(_cAliasZPTx)->ZPT_CODPRO,;
		(_cAliasZPTx)->ZPT_SLDATU,;
		0,;
		0,;
		(_cAliasZPTx)->ZPT_SLDATU;
		})

		(_cAliasZPTx)->(dbSkip())
	Enddo
	(_cAliasZPTx)->(dbCloseArea())
	If File(_cAliasZPTx+GetDBExtension());fErase(_cAliasZPTx+GetDBExtension());Endif
	If File(_cAliasZPTx+OrdBagExt());fErase(_cAliasZPTx+OrdBagext());Endif
Return(_nRet)

/*
Imprime um Fechamento
*/
Static Function PCP053G(_cCodCxa, _dData, _cLocal,_aSldAnal)
	Local oReport
	oReport:=TReport():New(cPerg, cTitulo,cPerg, {|oReport| PCP053H(oReport, _cCodCxa, _dData, _cLocal,_aSldAnal)},"Fechaneto de Caixa")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return

/*
Assistente de impress‹o
*/
Static Function PCP053H(oReport, _cCodCxa, _dData, _cLocal,_aSldAnal)
	Local cAliasPrt	:= "ZPS"
	Local oSection1
	Local oSection2

	oSection1:=TRSection():New(oReport,"Fechamento de armazem: "+DTOC(_dData),{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()

	TRCell():New(oSection1,"A1",cAliasPrt,OemToAnsi("Data"),PesqPict('ZPT',"ZPT_DATA"),TamSX3("ZPT_DATA")[1]+1)			
	TRCell():New(oSection1,"A2",cAliasPrt,OemToAnsi("Codigo"),PesqPict('ZPS',"ZPS_CODCXA"),TamSX3("ZPS_CODCXA")[1]+1)
	TRCell():New(oSection1,"A3",cAliasPrt,OemToAnsi("Local"),PesqPict('ZPS',"ZPS_LOCAL"),TamSX3("ZPS_LOCAL")[1]+1)
	TRCell():New(oSection1,"A4",cAliasPrt,OemToAnsi("Descricao"),PesqPict('NNR',"NNR_DESCRI"),TamSX3("NNR_DESCRI")[1]+1)
	TRCell():New(oSection1,"A5",cAliasPrt,OemToAnsi("Status"),PesqPict('ZPS',"ZPS_STATUS"),TamSX3("ZPS_STATUS")[1]+1)

	TRCell():New(oSection2,"A1",cAliasPrt,OemToAnsi("Codigo"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
	TRCell():New(oSection2,"A2",cAliasPrt,OemToAnsi("Descricao"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
	TRCell():New(oSection2,"A3",cAliasPrt,OemToAnsi("Sld. Ant."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"A4",cAliasPrt,OemToAnsi("Entrada"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"A5",cAliasPrt,OemToAnsi("Saida"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"A6",cAliasPrt,OemToAnsi("Sld. Atu."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)

	ZPS->(dbSetOrder(1))
	If ZPS->(dbSeek(xFilial("ZPS") + _cCodCxa))
		NNR->(dbSetOrder(1))
		If NNR->(dbSeek(xFilial("NNR") + ZPS->ZPS_LOCAL)) 
			oSection1:Init()
			oSection2:Init()
			oReport:SetMeter(Len(_aSldAnal))

			oSection1:Cell("A1"):SetValue(ZPS->ZPS_DATA)
			oSection1:Cell("A2"):SetValue(ZPS->ZPS_CODCXA)
			oSection1:Cell("A3"):SetValue(ZPS->ZPS_LOCAL)
			oSection1:Cell("A4"):SetValue(NNR->NNR_DESCRI)
			oSection1:Cell("A5"):SetValue(ZPS->ZPS_STATUS)
			oSection1:Printline()

			For x:=1 To Len(_aSldAnal)

				If oReport:Cancel() //->Cancelar
					Exit
				EndIf
				oReport:IncMeter()

				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1") + _aSldAnal[x][1]))
					oSection2:Cell("A1"):SetValue(_aSldAnal[x][1])
					oSection2:Cell("A2"):SetValue(SB1->B1_DESC)
					oSection2:Cell("A3"):SetValue(_aSldAnal[x][2])
					oSection2:Cell("A4"):SetValue(_aSldAnal[x][3])
					oSection2:Cell("A5"):SetValue(_aSldAnal[x][4])
					oSection2:Cell("A6"):SetValue(_aSldAnal[x][5])
					oSection2:Printline()
				Endif
			Next x

			oSection2:Finish()
			oSection1:Finish()
		Endif
	Endif
Return(oReport)


/*
Retorna Dados de Caixa
Opções:
_nTipo=1 -> Retorn o codigo do caixa aberto
*/
User Function PCP053W(_nTipo, _cLocal)
	Local cCodCxa	:= "" //->C—digo do Caixa em aberto
	Local _cMens	:= "CA nao encontrado." //->Mensagem de retorno
	If _nTipo == 1 //-> Retorna o œltimo Caixa Aberto
		ZPS->(dbSetOrder(1))
		If ZPS->(dbSeek(xFilial("ZPS") + _cLocal + "A"))
			If Date() - ZPS->ZPS_DATA > 2
				_cMens	:= "CA Acima da tolerancia."
			Else
				_cCodCxa:=ZPS->ZPS_CODCXA
			Endif
		Endif
	Endif
Return({cCodCxa,_cMens})

/*
Inclui movimentações na Tabela de movimentações
*/
User Function PCP053W(_cTipo, _cCodCxa, _cLocal, _dData, _cCodPro, _nPeso)
	Local _lRet	:= .T.
	Local _cMenRet:= ""
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("ZPU") + _cCodPro))
		If SB1->B1_CONV > 0
			RecLock("ZPU",.T.)
			Replace ZPU_FILIAL 	With XFILIAL("ZPU")
			Replace ZPU_CODCXA 	With _cCodCxa
			Replace ZPU_LOCAL 	With _cLocal
			Replace ZPU_CODPRO 	With _cCodPro
			Replace ZPU_TIPO		With _cTipo
			Replace ZPU_STATUS 	With "A"
			Replace ZPU_DATA 		With _dData
			Replace ZPU_PESO 		With _nPeso
			Replace ZPU_QTDCXA 	With _nPeso / SB1->B1_CONV
			ZPU->(MsUnLock())
		Else
			_lRet		:= .F.
			_cMenRet	:= "Prod. sem conversao."
		Endif
	Else
		_lRet		:= .F.
		_cMenRet	:= "Prod. nao encontrado."
	Endif
Return(_lRet)

/*
Função: PCP053
Data: 29/02/16
Por: Evandor Gomes
Descrição: Perguntas
*/
Static Function PCP053Z(cPerg)
	Local aPrgBlq	:= {}
	U_OHFUNAP3(cPerg,"01","Data de?			",".","."       	,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data Ate?		",".","."       	,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Local de?		",".","."       	,"mv_ch3","C",02,0,0,"G","","NNR","","","mv_par03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Local Ate?		",".","."       	,"mv_ch4","C",02,0,0,"G","","NNR","","","mv_par04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Status?			","",""			,"mv_ch5","N",01,0,1,"C","","","","","MV_PAR05","Aberto","","","","Fechado","","","Suspenso","","","","","","","","","","","")
Return

