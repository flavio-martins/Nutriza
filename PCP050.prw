#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP050() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13 	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Agendamento de produção						 		  		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP050()
	Private cPerg		:= Padr("PCP050",10)
	Private ODLG050
	Private _cFunMrk	:= ""
	//->Browse de ZPEs
	Private oWBrw050
	Private aWBrw050 	:= {}
	Private cStatus	:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros	:= {}

	//->Par‰metros para interface
	Private _aButts		:= {}
	Private _cTitulo		:= "Agendamento de Producao"
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
	Private _dDtIni		:= CTOD("01/01/2001")
	Private _dDtFim		:= CTOD("01/01/2020")
	Private _nStatus		:= 3		

	If !U_APPFUN01("Z6_IMPPROD")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	AADD(_aButts,{"", { || ExecBlock("PCP050G",.F.,.F.,{2,aWBrw050[oWBrw050:nAt][5]}) },"Visualizar", "Visualizar"})
	AADD(_aButts,{"", { || ExecBlock("PCP050G",.F.,.F.,{3}) },"Incluir", "Incluir"})
	AADD(_aButts,{"", { || ExecBlock("PCP050G",.F.,.F.,{4,aWBrw050[oWBrw050:nAt][5]}) },"Alterar", "Alterar"})
	AADD(_aButts,{"", { || ExecBlock("PCP050G",.F.,.F.,{5,aWBrw050[oWBrw050:nAt][5]}) },"Exluir", "Excluir"})
	AADD(_aButts,{"", { || ExecBlock("PCP050F",.F.,.F.,{cPerg,.T.,.T.}) },"Filtrar", "Filtrar"})

	_aCabec:={"","Dta. Agenda","Dta. Producao","Status","RECNO"}
	ExecBlock("PCP050F",.F.,.F.,{cPerg,.T.,.F.})
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrw050, @oDlg050, @oWBrw050, .F., .T., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F. )
Return

/*
Regua de Processamento
*/
User Function PCP050A()
	Local _lRet 	:= .T.
	Local nOpc		:= PARAMIXB[1]
	Private oProcess
	If nOpc==1 //->Lista Agendas
		oProcess:=MsNewProcess():New( { || PCP050B() } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If ParamIXB[2]
			U_OHFUNA21(@oDlg050, @oWBrw050, _aCabec, @aWBrw050, _cFunMrk)
			oWBrw050:Refresh()
		Endif
	Endif
Return(_lRet)

/*
Lista Produção
*/
Static Function PCP050B()
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx		:= 0
	Local cAliasSD3	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _nRep 		:= 0
	Local _nRepCx		:= 0

	aAnal	:= {}
	aWBrw050 := {}

	_cQry := " SELECT "
	_cQry += " * "
	_cQry += " FROM "+RetSQLName("ZPR")+" ZPR"
	_cQry += " WHERE ZPR.D_E_L_E_T_ = ' '"
	_cQry += " AND ZPR_FILIAL = '"+xFilial("ZPR")+"'"
	If _nStatus <> 3
		_cQry += " AND ZPR_STATUS = '"+Iif(_nStatus==1,"F","A")+"'"
	Endif
	_cQry += " AND ZPR_DTASCH BETWEEN '"+DTOS(_dDtIni)+"' AND '"+DTOS(_dDtFim)+"' "
	_cQry += " ORDER BY ZPR_DTASCH "
	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZPR.SQL", _cQry )
	TcQuery _cQry New Alias "QRYP"
	QRYP->(dbGoBottom())
	oProcess:SetRegua1(2)
	oProcess:SetRegua2(QRYP->(LastRec()))
	oProcess:IncRegua1("Selecionando....")
	QRYP->(dbGoTop())
	_aCodAnt:={}
	While !QRYP->(EOF())

		oProcess:IncRegua2("Prod.:" + SubStr(DTOC(STOD(QRYP->ZPR_DTASCH)),1,20))

		aAdd(aWBrw050,{IIF(QRYP->ZPR_STATUS=="F","BR_VERMELHO","BR_VERDE"),;
		DTOC(STOD(QRYP->ZPR_DTASCH)),;
		DTOC(STOD(QRYP->ZPR_DTAPRD)),;
		QRYP->ZPR_STATUS,;
		cvaltochar(QRYP->R_E_C_N_O_)})

		QRYP->(dbSkip())
	EndDo
	QRYP->(dbCloseArea())

	oProcess:SetRegua2(Len(aWBrw050))
	oProcess:IncRegua1("Validando Registros...")
	For x:=1 To Len(aWBrw050)
		oProcess:IncRegua2("Valida Dados...")
	Next x

	If Len(aWBrw050) <= 0
		aAdd(aWBrw050,{"BR_VERMELHO","","","","","","","","","",""})
	EndIf
Return

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Filtro
*/
User Function PCP050F()
	PCP050Z(PARAMIXB[1]) //->Cria Perguntas
	If PARAMIXB[2]
		If Pergunte(PARAMIXB[1],.T.)
			_dDtIni		:= MV_PAR01
			_dDtFim		:= MV_PAR02
			_nStatus	:= MV_PAR03
			ExecBlock("PCP050A",.F.,.F.,{1,PARAMIXB[3]})
		Else
			MV_PAR01:= _dDtIni 
			MV_PAR02:= _dDtFim
			MV_PAR03:= _nStatus
			ExecBlock("PCP050A",.F.,.F.,{1,PARAMIXB[3]})
		Endif
	Else
		MV_PAR01:= _dDtIni 
		MV_PAR02:= _dDtFim
		MV_PAR03:= _nStatus	
		ExecBlock("PCP050A",.F.,.F.,{1,PARAMIXB[3]})
	Endif
Return

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Manutenção de Agenda
*/
User Function PCP050G()
	Local aArea		:= GetArea()
	Local aAreaZPR	:= ZPR->(GetArea())
	Local nOpcao		:= 0
	PRIVATE cCadastro  	:= "Manutencao de Agenda"

	DbSelectArea('ZPR')
	ZPR->(DbSetOrder(1))
	ZPR->(DbGoTop())

	//Chama a inclus‹o
	If PARAMIXB[1] ==1 //->Pesquisar
	ElseIf PARAMIXB[1] == 2 //->Visualizar
		ZPR->(dbGoTo(Val(aWBrw050[oWBrw050:nAt][5])))
		If !ZPR->(Recno()) == Val(aWBrw050[oWBrw050:nAt][5])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			nOpcao := AxVisual('ZPR', Val(aWBrw050[oWBrw050:nAt][5]), PARAMIXB[1],{"ZPR_DTASCH","ZPR_DTAPROD","ZPR_STATUS"})
		Endif
	ElseIf PARAMIXB[1] == 3 //->Incluir
		nOpcao := AxInclui('ZPR', 0, PARAMIXB[1],{"ZPR_DTASCH","ZPR_DTAPROD"})
		ExecBlock("PCP050F",.F.,.F.,{cPerg,.F.,.T.})
	ElseIf PARAMIXB[1] == 4 //->Altera
		ZPR->(dbGoTo(Val(aWBrw050[oWBrw050:nAt][5])))
		If !ZPR->(Recno()) == Val(aWBrw050[oWBrw050:nAt][5])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			If ZPR->ZPR_STATUS=="F"
				MsgInfo("Agendamento ja executado.", "Alterando")
			Else
				nOpcao := AxAltera('ZPR', Val(aWBrw050[oWBrw050:nAt][5]), PARAMIXB[1],{"ZPR_DTASCH","ZPR_DTAPROD"})
				ExecBlock("PCP050F",.F.,.F.,{cPerg,.F.,.T.})
			Endif
		Endif
	ElseIf PARAMIXB[1] == 5 //->Exclui
		ZPR->(dbGoTo(Val(aWBrw050[oWBrw050:nAt][5])))
		If !ZPR->(Recno()) == Val(aWBrw050[oWBrw050:nAt][5])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			If ZPR->ZPR_STATUS=="F"
				MsgInfo("Agendamento ja executado.", "Excluindo")
			Else
				nOpcao := AxDeleta('ZPR', Val(aWBrw050[oWBrw050:nAt][5]), PARAMIXB[1],{"ZPR_DTASCH","ZPR_DTAPROD","ZPR_STATUS"})
				ExecBlock("PCP050F",.F.,.F.,{cPerg,.F.,.T.})
			Endif
		Endif
	Endif


	/*If nOpcao == 1
	MsgInfo("Agendamento incluido com sucesso.", "Atenção")
	EndIf*/

	RestArea(aAreaZPR)
	RestArea(aArea)

	//nOpcA:=AxInclui( "ZPR", ZP1->(Recno()), 3,,_cFunAx,,,,,aButtons ,,,.T.)
Return


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
Static Function PCP050Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Data De?"		,"","","mv_ch1","D",08,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data Ate?"		,"","","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Status?"			,'','',"mv_ch3","N",01,0,1,"C","","","","","MV_PAR03","Nao Executado","","","","Executado","","","Ambos","","","","","","","","","","","")
Return


