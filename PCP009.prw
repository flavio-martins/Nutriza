#INCLUDE "rwmake.ch"

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#define DS_MODALFRAME   128
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP009 ()       ³ Autor ³ Evandro Gomes          ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Dias Vencto Cli. X Prod.												 ³±±
±±³          ³			                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Nutriza											      	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
DESCONTINUADO
User Function PCP009
Local cVldAlt := ".T." 
Local cVldExc := ".T." 
Private cString := "ZP5"
Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
//->Testa ambientes que podem ser usados
If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
Alert("Ambiente nao homologado para o uso desta rotina!!!")
Return .F.
Endif

dbSelectArea("ZP5")
dbSetOrder(1)

AxCadastro(cString,"Dias Vencto Cli. X Prod.",cVldExc,cVldAlt)

Return
*/
User Function PCP009()
	Private cPerg1	:= Padr("PCP009A",10)
	Private cPerg2	:= Padr("PCP009B",10)
	Private ODLG009
	Private _cFunMrk	:= ""
	//->Browse de ZPEs
	Private oWBrw009
	Private aWBrw009 	:= {}
	Private cStatus	:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros	:= {}

	//->Par‰metros para interface
	Private _aButts		:= {}
	Private _cTitulo		:= "Tolerancia Cliente X Loja X Produto"
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
	Private _cCliente		:= ""
	Private _cLoja		:= ""
	Private _cNomCli		:= ""
	Private _cPrdIni		:= ""
	Private _cPrdFim		:= Replicate("Z",15)
	Private _nStatus		:= 3
	Private _oCliente
	Private _oLoja
	Private _oNomCli
	Private _oPrdIni
	Private _oPrdFim

	If !U_APPFUN01("Z6_IMPPROD")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	AADD(_aButts,{"", { || ExecBlock("PCP009G",.F.,.F.,{2,aWBrw009[oWBrw009:nAt][5]}) },"Visualizar", "Visualizar"})
	AADD(_aButts,{"", { || ExecBlock("PCP009G",.F.,.F.,{3}) },"Incluir", "Incluir"})
	AADD(_aButts,{"", { || ExecBlock("PCP009G",.F.,.F.,{4,aWBrw009[oWBrw009:nAt][5]}) },"Alterar", "Alterar"})
	AADD(_aButts,{"", { || ExecBlock("PCP009G",.F.,.F.,{5,aWBrw009[oWBrw009:nAt][5]}) },"Exluir", "Excluir"})
	AADD(_aButts,{"", { || ExecBlock("PCP009F",.F.,.F.,{cPerg1,.T.,.T.}) },"Filtrar", "Filtrar"})
	AADD(_aButts,{"", { || ExecBlock("PCP009A",.F.,.F.,{2,.T.}) },"Importar", "Importar"})
	AADD(_aButts,{"", { || ExecBlock("PCP009A",.F.,.F.,{6,.T.}) },"Inverte Selecao", "Inverte Selecao"})
	AADD(_aButts,{"", { || ExecBlock("PCP009A",.F.,.F.,{7,.T.}) },"Apaga Marcados", "Apaga Marcados"})


	_aCabec:={"","Codigo","Descricao","Tol. Prod.?","Toleracia","RECNO"}
	ExecBlock("PCP009F",.F.,.F.,{cPerg1,.T.,.F.})
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrw009, @oDlg009, @oWBrw009, .T., .F., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F.,,,"PCP09GET" )
Return


/*
Função: PCP09GET
Descrição: Ponto de entrada para adiconar Say e Get.
*/
User Function PCP09GET
	U_OHFUNA22(@oDlg009,@_oCliente,,"Cliente:",50,10,,,033,007,,-15,.T.)
	U_OHFUNA23(@oDlg009,@_oCliente, @_cCliente,,30,10,"@!",.T.,040,007,,-15,.F.,,{})
	U_OHFUNA23(@oDlg009,@_oLoja, @_cLoja,,20,10,"@!",.T.,040,045,,-15,.F.,,{})
	U_OHFUNA23(@oDlg009,@_oNomCli, @_cNomCli,,100,10,"@!",.T.,040,70,,-15,.F.,,{})
Return

/*
Regua de Processamento
*/
User Function PCP009A()
	Local _lRet 	:= .T.
	Local nOpc		:= PARAMIXB[1]
	Private oProcess
	If nOpc==1 //->Lista Agendas
		oProcess:=MsNewProcess():New( { || PCP009B() } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If ParamIXB[2]
			U_OHFUNA21(@oDlg009, @oWBrw009, _aCabec, @aWBrw009, _cFunMrk)
			oWBrw009:Refresh()
		Endif
	ElseIf nOpc==2 //->Importa
		oProcess:=MsNewProcess():New( { || PCP009H() } , "Importa dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		ExecBlock("PCP009F",.F.,.F.,{cPerg1,.F.,.T.})
	ElseIf nOpc==6 .Or. nOpc==7 //->Marca Todos ou Exclui Marcados
		oProcess:=MsNewProcess():New( { || ExecBlock("PCP009G",.F.,.F.,{nOpc}) } , "Importa dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If nOpc == 7
			ExecBlock("PCP009F",.F.,.F.,{cPerg1,.F.,.T.})
		Endif
	ENdif
Return(_lRet)

/*
Lista Cliente e Produtos
*/
Static Function PCP009B()
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx		:= 0
	Local _cAliasZP5	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _nRep 		:= 0
	Local _nRepCx		:= 0

	aAnal	:= {}
	aWBrw009 := {}

	_cQry := " SELECT "
	_cQry += " * "
	_cQry += " FROM "+RetSQLName("ZP5")+" ZP5"
	_cQry += " WHERE ZP5.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP5_FILIAL = '"+xFilial("ZP5")+"'"
	If _nStatus <> 3
		_cQry += " AND ZP5_TOLSB1 = '"+Iif(_nStatus==1,"S","N")+"'"
	Endif
	_cQry += " AND ZP5_CLIENT='"+_cCliente+"' "
	_cQry += " AND ZP5_LOJA='"+_cLoja+"' "
	_cQry += " AND ZP5_PRODUT BETWEEN '"+_cPrdIni+"' AND '"+_cPrdFim+"'"
	_cQry += " ORDER BY ZP5_PRODUT "
	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZP5.SQL", _cQry )
	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),_cAliasZP5,.F.,.T.)
	(_cAliasZP5)->(dbGoBottom())
	oProcess:SetRegua1(2)
	oProcess:SetRegua2((_cAliasZP5)->(LastRec()))
	oProcess:IncRegua1("Selecionando....")
	(_cAliasZP5)->(dbGoTop())
	_aCodAnt:={}
	While !(_cAliasZP5)->(EOF())

		oProcess:IncRegua2("Prod.:" + SubStr((_cAliasZP5)->ZP5_PRODUT,1,20))

		aAdd(aWBrw009,{.F.,;
		(_cAliasZP5)->ZP5_PRODUT,;
		POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP5)->ZP5_PRODUT,"B1_DESC"),;
		(_cAliasZP5)->ZP5_TOLSB1,;
		cvaltochar((_cAliasZP5)->ZP5_DIAS),;
		cvaltochar((_cAliasZP5)->R_E_C_N_O_)})

		(_cAliasZP5)->(dbSkip())
	EndDo
	(_cAliasZP5)->(dbCloseArea())
	If File(_cAliasZP5+GetdbExtension())
		FErase(_cAliasZP5+GetDbExtension())
	Endif
	If File(_cAliasZP5+OrdBagExt())
		FErase(_cAliasZP5+ OrdBagExt())
	Endif

	If Len(aWBrw009) <= 0
		aAdd(aWBrw009,{.F.,"","","","0","0"})
	EndIf
Return

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Filtro
*/
User Function PCP009F()
	PCP009Z(1,PARAMIXB[1]) //->Cria Perguntas
	If PARAMIXB[2]
		If Pergunte(PARAMIXB[1],.T.)
			_cCliente		:= MV_PAR01
			_cLoja			:= MV_PAR02
			_cPrdIni		:= MV_PAR03
			_cPrdFim		:= MV_PAR04
			_cNomCli		:= POSICIONE("SA1", 1, XFILIAL("SA1")+_cCliente+_cLoja,"A1_NOME")
			_nStatus		:= MV_PAR05
			ExecBlock("PCP009A",.F.,.F.,{1,PARAMIXB[3]})
		Else
			MV_PAR01:= _cCliente 
			MV_PAR02:= _cLoja	 
			MV_PAR03:= _cPrdIni 
			MV_PAR04:= _cPrdFim 
			MV_PAR05:= _nStatus 
			ExecBlock("PCP009A",.F.,.F.,{1,PARAMIXB[3]})
		Endif
	Else
		MV_PAR01:= _cCliente 
		MV_PAR02:= _cLoja	 
		MV_PAR03:= _cPrdIni 
		MV_PAR04:= _cPrdFim 
		MV_PAR05:= _nStatus	
		ExecBlock("PCP009A",.F.,.F.,{1,PARAMIXB[3]})
	Endif
Return

/*
Por: Evandro Gomes
Em: 21/08/16
Descrição: Manutenção
*/
User Function PCP009G()
	Local aArea		:= GetArea()
	Local aAreaZP5	:= ZP5->(GetArea())
	Local nOpcao		:= 0
	Local nPosRec		:= 6
	PRIVATE cCadastro  	:= "Manutencao de Registro"

	DbSelectArea('ZP5')
	ZP5->(DbSetOrder(1))
	ZP5->(DbGoTop())

	//Chama a inclus‹o
	If PARAMIXB[1] ==1 //->Pesquisar
	ElseIf PARAMIXB[1] == 2 //->Visualizar
		ZP5->(dbGoTo(Val(aWBrw009[oWBrw009:nAt][nPosRec])))
		If !ZP5->(Recno()) == Val(aWBrw009[oWBrw009:nAt][nPosRec])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			nOpcao := AxVisual('ZP5', Val(aWBrw009[oWBrw009:nAt][nPosRec]), PARAMIXB[1],{"ZP5_CLIENT","ZP5_LOJA","ZP5_PRODUT","ZP5_TOLSB1","ZP5_DIAS"})
		Endif
	ElseIf PARAMIXB[1] == 3 //->Incluir
		nOpcao := AxInclui('ZP5', 0, PARAMIXB[1],{"ZP5_CLIENT","ZP5_LOJA","ZP5_PRODUT","ZP5_TOLSB1","ZP5_DIAS"})
		ExecBlock("PCP009F",.F.,.F.,{cPerg1,.F.,.T.})
	ElseIf PARAMIXB[1] == 4 //->Altera
		ZP5->(dbGoTo(Val(aWBrw009[oWBrw009:nAt][nPosRec])))
		If !ZP5->(Recno()) == Val(aWBrw009[oWBrw009:nAt][nPosRec])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			nOpcao := AxAltera('ZP5', Val(aWBrw009[oWBrw009:nAt][nPosRec]), PARAMIXB[1],{"ZP5_TOLSB1","ZP5_DIAS"})
			ExecBlock("PCP009F",.F.,.F.,{cPerg1,.F.,.T.})    		
		Endif
	ElseIf PARAMIXB[1] == 5 //->Exclui
		ZP5->(dbGoTo(Val(aWBrw009[oWBrw009:nAt][nPosRec])))
		If !ZP5->(Recno()) == Val(aWBrw009[oWBrw009:nAt][nPosRec])
			MsgInfo("Registro nao encontrado","Visualizar")
		Else
			nOpcao := AxDeleta('ZP5', Val(aWBrw009[oWBrw009:nAt][nPosRec]), PARAMIXB[1],{"ZP5_CLIENT","ZP5_LOJA","ZP5_PRODUT","ZP5_TOLSB1","ZP5_DIAS"})
			ExecBlock("PCP009F",.F.,.F.,{cPerg1,.F.,.T.})
		Endif
	ElseIf PARAMIXB[1] == 6 //->Marca Todos
		oProcess:SetRegua1(Len(aWBrw009))
		oProcess:SetRegua2(Len(aWBrw009))
		For i:=1 To Len(aWBrw009)
			oProcess:IncRegua1("Marcando...")
			oProcess:IncRegua2(_cCliente +"/"+  _cLoja +"/"+ aWBrw009[i][2])
			oWBrw009:aArray[i][1]:= !oWBrw009:aArray[i][1]
			aWBrw009[i][1]:=oWBrw009:aArray[i][1]
			oWBrw009:DrawSelect()
		Next i
		oWBrw009:Refresh()
		oWBrw009:GoTop()
	ElseIf PARAMIXB[1] == 7 //->Apaga Marcados
		oProcess:SetRegua1(Len(aWBrw009))
		oProcess:SetRegua2(Len(aWBrw009))
		For i:=1 To Len(aWBrw009)
			oProcess:IncRegua1("Marcando...")
			oProcess:IncRegua2(_cCliente +"/"+  _cLoja +"/"+ aWBrw009[i][2])
			If aWBrw009[i][1]
				ZP5->(dbSetOrder(1))
				If ZP5->(dbSeek(xFilial("SB5") + _cCliente +  _cLoja + aWBrw009[i][2]))
					RecLock("ZP5",.F.)
					ZP5->(dbDelete())
					ZP5->(MsUnLock())
				Endif
			Endif
		Next i
	Endif
	RestArea(aAreaZP5)
	RestArea(aArea)

	//nOpcA:=AxInclui( "ZP5", ZP1->(Recno()), 3,,_cFunAx,,,,,aButtons ,,,.T.)
Return


/*
Importa Produtos x Cliente x Loja
*/
Static Function PCP009H()
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx		:= 0
	Local _cAliasSA1	:= GetNextAlias()
	Local _cAliasSB1	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _nRep 		:= 0
	Local _nRepCx		:= 0

	PCP009Z(2,cPerg2)
	If !Pergunte(cPerg2,.T.)
		Alert("Operação Cancelada...")
		Return .F.
	Endif

	_cQry := " SELECT "
	_cQry += " * "
	_cQry += " FROM "+RetSQLName("SA1")+" SA1"
	_cQry += " WHERE SA1.D_E_L_E_T_ = ' '"
	_cQry += " AND A1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"' "
	_cQry += " AND A1_LOJA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"' "
	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_SA1.SQL", _cQry )
	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),_cAliasSA1,.F.,.T.)
	(_cAliasSA1)->(dbGoBottom())
	oProcess:SetRegua1((_cAliasSA1)->(LastRec()))
	(_cAliasSA1)->(dbGoTop())
	While !(_cAliasSA1)->(EOF())

		oProcess:IncRegua1("Prod.:" + (_cAliasSA1)->(A1_COD+"/"+A1_LOJA+"/"+SubStr(A1_NOME,1,15)))

		_cQry := " SELECT "
		_cQry += " * "
		_cQry += " FROM "+RetSQLName("SB1")+" SB1"
		_cQry += " WHERE SB1.D_E_L_E_T_ = ' '"
		_cQry += " AND B1_TIPO='PA' " 
		_cQry += " AND B1_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' ""
		If MV_PAR09 == 1 
			_cQry += " AND B1_XTOLVEN > 0 "
		Endif
		MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_SA1.SQL", _cQry )
		dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),_cAliasSB1,.F.,.T.)
		(_cAliasSB1)->(dbGoBottom())
		oProcess:SetRegua2((_cAliasSB1)->(LastRec()))
		(_cAliasSB1)->(dbGoTop())
		While !(_cAliasSB1)->(EOF())
			oProcess:IncRegua2("Prod.:" + SubStr((_cAliasSB1)->B1_DESC,1,20))
			ZP5->(dbSetOrder(1))
			If ZP5->(dbSeek(xFilial("SB5") + (_cAliasSA1)->(A1_COD+A1_LOJA) + (_cAliasSB1)->B1_COD))
				If MV_PAR08 == 1 //->Atualiza Dados
					RecLock("ZP5",.F.)
					Replace ZP5_TOLSB1 With Iif(MV_PAR07==1,"S","N")
					Replace ZP5_DIAS With (_cAliasSB1)->B1_XTOLVEN
					ZP5->(MsUnLock())
				Endif
			Else
				RecLock("ZP5",.T.)
				Replace ZP5_FILIAL With xFilial("ZP5")
				Replace ZP5_CLIENT With (_cAliasSA1)->A1_COD
				Replace ZP5_LOJA With (_cAliasSA1)->A1_LOJA
				Replace ZP5_PRODUT With (_cAliasSB1)->B1_COD
				Replace ZP5_TOLSB1 With Iif(MV_PAR07==1,"S","N")
				Replace ZP5_DIAS With (_cAliasSB1)->B1_XTOLVEN
				ZP5->(MsUnLock())
			Endif
			(_cAliasSB1)->(dbSkip())
		EndDo
		(_cAliasSB1)->(dbCloseArea())
		If File(_cAliasSB1+GetdbExtension())
			FErase(_cAliasSB1+GetDbExtension())
		Endif
		If File(_cAliasSB1+OrdBagExt())
			FErase(_cAliasSB1+ OrdBagExt())
		Endif

		oProcess:SetRegua2(0)

		(_cAliasSA1)->(dbSkip())
	EndDo
	(_cAliasSA1)->(dbCloseArea())
	If File(_cAliasSA1+GetdbExtension())
		FErase(_cAliasSA1+GetDbExtension())
	Endif
	If File(_cAliasSA1+OrdBagExt())
		FErase(_cAliasSA1+ OrdBagExt())
	Endif
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
_nTipo == 1 -> Filtro Cliente
_nTipo == 2 -> Importacao
*/                                                                           
Static Function PCP009Z(_nTipo, cPerg)
	If _nTipo == 1 //-> Filtro Cliente
		U_OHFUNAP3(cPerg,"01","Cliente De?"		,"","","mv_ch1","C",TAMSX3("A1_COD")[1],0,0,"G","","SA1","","","MV_PAR01","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"02","Loja de ?"			,"","","mv_ch2","C",TAMSX3("A1_LOJA")[1],0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"03","Produto De?"		,"","","mv_ch3","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"04","Produto Ate?"		,"","","mv_ch4","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR04","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"05","Tol. No Produto?"	,'','',"mv_ch5","N",01,0,1,"C","","","","","MV_PAR05","Sim","","","","Nao","","","Ambos","","","","","","","","","","","")
	Else //-> Importacao
		U_OHFUNAP3(cPerg,"01","Cliente De?"		,"","","mv_ch1","C",TAMSX3("A1_COD")[1],0,0,"G","","SA1","","","MV_PAR01","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"02","Loja de ?"			,"","","mv_ch2","C",TAMSX3("A1_LOJA")[1],0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"03","Cliente Ate?"		,"","","mv_ch3","C",TAMSX3("A1_COD")[1],0,0,"G","","SA1","","","MV_PAR03","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"04","Loja Ate?"			,"","","mv_ch4","C",TAMSX3("A1_LOJA")[1],0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"05","Produto De?"		,"","","mv_ch5","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR05","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"06","Produto Ate?"		,"","","mv_ch6","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR06","","","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"07","Tol. No Produto?"	,'','',"mv_ch7","N",01,0,1,"C","","","","","MV_PAR07","Sim","","","","Nao","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"08","Atualiza?"			,'','',"mv_ch8","N",01,0,1,"C","","","","","MV_PAR08","Sim","","","","Nao","","","","","","","","","","","","","","")
		U_OHFUNAP3(cPerg,"09","Somente C/ Tol?"	,'','',"mv_ch9","N",01,0,1,"C","","","","","MV_PAR09","Sim","","","","Nao","","","","","","","","","","","","","","")
	Endif
Return


