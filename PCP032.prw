#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP032()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Geração de Ordem de Produção a partir dos apontamentos  			  ³±±
±±³          ³			                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Nutriza											      ³±±
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
User Function PCP032()
	Private cPerg		:= Padr("PCP032",10)
	Private oBtnProc
	Private oProds
	Private aProds := {}
	Private oDtProd
	Private dDtProd := CToD("//")
	Private oOk := LoadBitmap( GetResources(), "LBOK")
	Private oNo := LoadBitmap( GetResources(), "LBNO")
	Private oDlg
	Private cFilIni	:= ""
	Private cFilFim	:= ""
	Private cRecIni	:= ""
	Private cRecFim	:= ""
	Private cPrdIni	:= ""
	Private cPrdFim	:= ""
	Private cOprIni	:= ""
	Private cOprFim	:= ""
	Private cFerIni	:= ""
	Private cFerFim	:= ""
	Private cDtaIni	:= ""
	Private cDtaFim	:= ""
	Private nModRel	:= ""

	//->Cria Perguntas
	PCP032Z(cPerg)
	Pergunte(cPerg,.T.)

	DEFINE MSDIALOG oDlg TITLE "Apontamentos de Produção" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	//@ 002, 002 SAY oSay1 PROMPT "Data:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//@ 010, 002 MSGET oDtProd VAR dDtProd SIZE 060, 010 OF oDlg VALID PCP032D() COLORS 0, 16777215 PIXEL
	PCP032A(1)
	@ 230, 173 BUTTON oBtnInv PROMPT "Inverte" SIZE 037, 012 OF oDlg ACTION PCP032B() PIXEL
	@ 230, 210 BUTTON oBtnProc PROMPT "Carregar ZP1" SIZE 037, 012 OF oDlg ACTION Processa({ || PCP032E()}, "Processando o Apagar...") PIXEL
	@ 230, 247 BUTTON oBtnProc PROMPT "Filtrar" SIZE 037, 012 OF oDlg ACTION Processa({ || Pergunte(cPerg,.T.),PCP032A(1)}, "Processando o Apagar...") PIXEL
	@ 230, 284 BUTTON oBtnProc PROMPT "Canc. OP" SIZE 037, 012 OF oDlg ACTION Processa({ || PCP032C(2)}, "Processando o Cancelamento...") PIXEL
	@ 230, 321 BUTTON oBtnProc PROMPT "Gerar OP" SIZE 037, 012 OF oDlg ACTION Processa({ || PCP032C(1)}, "Gerando OP...") PIXEL
	@ 230, 358 BUTTON oBtnProc PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION Processa({ || Close(oDlg)}, "Processando o fechamento...") PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032A  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Lista Apontamentos									  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032A(nTipo)
	Local cSql
	Local cAliasZPA	:= "ZPATMP"
	Local aCampos	:= ZPA->(dbStruct())

	If nTipo==2
		Pergunte(cPerg,.T.)
	Endif

	cFilIni	:= MV_PAR01
	cFilFim	:= MV_PAR02
	cRecIni	:= MV_PAR03
	cRecFim	:= MV_PAR04
	cPrdIni	:= MV_PAR05
	cPrdFim	:= MV_PAR06
	cOprIni	:= MV_PAR07
	cOprFim	:= MV_PAR08
	cFerIni	:= MV_PAR09
	cFerFim	:= MV_PAR10
	cDtaIni	:= MV_PAR11
	cDtaFim	:= MV_PAR12
	nModRel	:= MV_PAR13

	aProds := {}

	cSql	:="SELECT "
	cSql	+="	ZPA_OP,H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON, SUM(ZPA_QTDPRO+ZPA_TARBAL+ZPA_TARFER) PBRUTO, SUM(ZPA_QTDPRO) PLIQUIDO "
	cSql	+="FROM "+RETSQLNAME("ZPA")+" ZPA "
	cSql	+="INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
	cSql	+="		ON B1_COD=ZPA_PRODUT "
	cSql	+="INNER JOIN "+RETSQLNAME("SH1")+" SH1 "
	cSql	+="		ON H1_CODIGO=ZPA_RECURS "
	cSql	+="INNER JOIN "+RETSQLNAME("SH4")+" SH4 "
	cSql	+="		ON H4_CODIGO=ZPA_FERRAM "
	cSql	+="INNER JOIN "+RETSQLNAME("SG2")+" SG2 "
	cSql	+="		ON G2_CODIGO = ZPA_OPERAC "
	cSql	+="		AND G2_RECURSO= H1_CODIGO "
	cSql	+="		AND G2_PRODUTO= ZPA_PRODUT"
	cSql	+="		AND SG2.D_E_L_E_T_ <> '*' "
	cSql	+=" WHERE "
	cSql	+="		ZPA_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
	cSql	+="		AND ZPA_RECURS BETWEEN '"+cRecIni+"' AND '"+cRecFim+"' "
	cSql	+="		AND ZPA_PRODUT BETWEEN '"+cPrdIni+"' AND '"+cPrdFim+"' "
	cSql	+="		AND ZPA_OPERAC BETWEEN '"+cOprIni+"' AND '"+cOprFim+"' "
	cSql	+="		AND ZPA_FERRAM BETWEEN '"+cFerIni+"' AND '"+cFerFim+"' "
	cSql	+="		AND ZPA_DATAFI BETWEEN '"+DTOS(cDtaIni)+"' AND '"+DTOS(cDtaFim)+"' "
	If nModRel == 1
		cSql	+="		AND ZPA_OP <> '' "
	Elseif nModRel == 2
		cSql	+="		AND ZPA_OP = '' "
	Endif
	cSql	+="		AND ZPA.D_E_L_E_T_ <> '*' "
	cSql	+="GROUP BY	ZPA_OP, H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "
	cSql	+="ORDER BY	ZPA_OP, H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "

	MemoWrite("C:\TEMP\"+FUNNAME()+".SQL", cSql)
	dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasZPA,.F.,.T.)

	For nZ := 1 to Len(aCampos)
		If aCampos[nZ,2] <> "C"
			TCSetField(cAliasZPA, aCampos[nZ,1], aCampos[nZ,2], aCampos[nZ,3], aCampos[nZ,4])
		Endif
	Next nZ
	TCSetField(cAliasZPA, "PBRUTO", "N", 15, 3)
	TCSetField(cAliasZPA, "PLIQUIDO", "N", 15, 3)

	While !(cAliasZPA)->(EOF())
		aAdd(aProds,{Iif((cAliasZPA)->ZPA_OP='',.T.,.F.),;
		DTOC((cAliasZPA)->ZPA_DTAPON),;
		(cAliasZPA)->ZPA_OP,;
		(cAliasZPA)->H1_CODIGO,;
		(cAliasZPA)->H1_DESCRI,;
		(cAliasZPA)->B1_COD,;
		(cAliasZPA)->B1_DESC,;
		Transform((cAliasZPA)->PBRUTO, PesqPict("ZPA","ZPA_QTDPRO")),;
		Transform((cAliasZPA)->PLIQUIDO, PesqPict("ZPA","ZPA_QTDPRO"))})
		(cAliasZPA)->(dbSkip())
	EndDo

	If Select(cAliasZPA) > 0
		(cAliasZPA)->(dbCloseArea())
		If File(cAliasZPA+GetDBExtension())
			fErase(cAliasZPA+GetDBExtension())
		Endif          
	Endif

	If Len(aProds) <= 0
		aAdd(aProds,{.F.,"","","","","","","",""})
	EndIf

	If oProds == Nil
		@ 025, 002 LISTBOX oProds Fields HEADER "","Data","OP","Recurso","Descricao","Produto","Descricao","Bruto","Liquido" SIZE 395, 200 OF oDlg PIXEL ColSizes 10,20,150
		oProds:bLDblClick := {|| aProds[oProds:nAt,1] := !aProds[oProds:nAt,1],oProds:DrawSelect()}
	EndIf

	oProds:SetArray(aProds)
	oProds:bLine := {|| {;
	Iif(aProds[oProds:nAT,1],oOk,oNo),;
	aProds[oProds:nAt,2],;
	aProds[oProds:nAt,3],;
	aProds[oProds:nAt,4],;
	aProds[oProds:nAt,5],;
	aProds[oProds:nAt,6],;
	aProds[oProds:nAt,7],;
	aProds[oProds:nAt,8],;
	aProds[oProds:nAt,9];
	}}
	oProds:Refresh()
Return

Static Function bStrToVal(_cPar)
	Local _nRet := 0
	_cPar := StrTran(_cPar,".","")
	_cPar := StrTran(_cPar,",",".")
	_nRet := Val(_cPar)
Return(_nRet)

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032C  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera OP													  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032C(_nOpc)
	Local _I := 0
	Local _dBkDt := dDataBase
	ProcRegua(Len(aProds))

	If Len(AllTrim(aProds[1,2])) <= 0
		MsgStop("Não ha dados a serem processados.")
		Return
	EndIf

	For _I := 1 To Len(aProds)
		IncProc()
		If aProds[_I,1] .And. Empty(Alltrim(aProds[_I,3])) .And. _nOpc == 1
			Begin Transaction
				lMsErroAuto := .F.
				SG1->(dbSetOrder(1))
				_cAutExpl := IIF(SG1->(dbSeek(xFilial()+aProds[_I,6])),"S","N")
				_cNumOp := GetNumSc2()
				aRotAuto  := {;
				{"C2_FILIAL"	,xFilial("SC2")	,NIL},;
				{"C2_NUM"		,_cNumOp		,NIL},;
				{"C2_ITEM"		,"01"			,NIL},;
				{"C2_SEQUEN"	,"001"			,NIL},;
				{"C2_PRODUTO"	,aProds[_I,6]	,NIL},;
				{"C2_LOCAL"		,"10"			,NIL},;
				{"C2_QUANT"		,bStrToVal(aProds[_I,9]),NIL},;
				{"C2_DATPRI"	,CTOD(aProds[_I,2]),NIL},;
				{"C2_DATPRF"	,CTOD(aProds[_I,2]),NIL},;
				{"AUTEXPLODE"	,_cAutExpl		,NIL}}
				dDataBase := CTOD(aProds[_I,2])
				CTPMT:=""
				MsExecAuto({|x,y| MATA650(x,y)},aRotAuto,3)
				dDataBase := Date()

				If lMsErroAuto
					MsgStop("Ocorreu um erro na criação da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+".")
					MostraErro()
					DisarmTransaction()
					LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
					dDataBase := _dBkDt
					Return()
				Else
					lMsErroAuto := .F.
					CriaSB2(aProds[_I,6],"10")
					aItens     := {;
					{"D3_TM"		, "103"					,NIL},;
					{"D3_COD"		, aProds[_I,6]			,NIL},;
					{"D3_QUANT"		, bStrToVal(aProds[_I,9])			,Nil},;
					{"D3_OP"		, _cNumOp+"01"+"001"	,Nil},;
					{"D3_LOCAL"		, "10"					,Nil},;
					{"D3_EMISSAO"	, CTOD(aProds[_I,2])    ,NIL},;
					{"D3_FILIAL"	, xFilial("SD3")		,Nil};
					}
					CTPMT:=""
					MSExecAuto({|x,y| mata250(x,y)},aItens,3)

					If lMsErroAuto
						MsgStop("Ocorreu um erro no apontamento da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+".")
						MostraErro()
						DisarmTransaction()
						LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
						dDataBase := _dBkDt
						Return()
					EndIf

					cSql:="UPDATE "+RETSQLNAME("ZPA")+" SET ZPA_OP='"+_cNumOp+"' WHERE ZPA_DATAFI='"+DTOS(CTOD(aProds[_I,2]))+"' AND ZPA_RECURS='"+aProds[_I,4]+"' AND ZPA_PRODUT='"+aProds[_I,6]+"' AND D_E_L_E_T_ <> '*' "
					MemoWrite("C:\TEMP\"+FUNNAME()+"_OP.SQL", cSql)
					nErr_Sql := TcSqlExec(cSql)
					If nErr_Sql < 0
						MsgStop("Ocorreu um erro no apontamento da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+", na tentativa de atualiza Apontamentos.")
						DisarmTransaction()
						LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
						dDataBase := _dBkDt
						Return()
					Endif
				EndIf
			End Transaction
		ElseIf aProds[_I,1] .And. !Empty(Alltrim(aProds[_I,3])) .And. _nOpc == 2 //->Exclusão
			Begin Transaction
				lMsErroAuto := .F.
				SG1->(dbSetOrder(1))
				_cAutExpl := IIF(SG1->(dbSeek(xFilial()+aProds[_I,6])),"S","N")
				aItens     := {;
				{"D3_TM"		, "103"					,NIL},;
				{"D3_COD"		, aProds[_I,6]			,NIL},;
				{"D3_QUANT"		, bStrToVal(aProds[_I,9])			,Nil},;
				{"D3_OP"		, Alltrim(aProds[_I,3])+"01"+"001"	,Nil},;
				{"D3_LOCAL"		, "10"					,Nil},;
				{"D3_EMISSAO"	, CTOD(aProds[_I,2])    ,NIL},;
				{"D3_FILIAL"	, xFilial("SD3")		,Nil};
				}
				CTPMT:=""
				dDataBase := Date()
				MSExecAuto({|x,y| mata250(x,y)},aItens,5)

				If lMsErroAuto
					MsgStop("Ocorreu um erro na criação da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+".")
					MostraErro()
					DisarmTransaction()
					LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
					dDataBase := _dBkDt
					Return()
				Else
					lMsErroAuto := .F.
					aRotAuto  := {;
					{"C2_FILIAL"	,xFilial("SC2")	,NIL},;
					{"C2_NUM"		,aProds[_I,3]	,NIL},;
					{"C2_ITEM"		,"01"			,NIL},;
					{"C2_SEQUEN"	,"001"			,NIL},;
					{"C2_PRODUTO"	,aProds[_I,6]	,NIL},;
					{"C2_LOCAL"		,"10"			,NIL},;
					{"C2_QUANT"		,bStrToVal(aProds[_I,9]),NIL},;
					{"C2_DATPRI"	,CTOD(aProds[_I,2]),NIL},;
					{"C2_DATPRF"	,CTOD(aProds[_I,2]),NIL},;
					{"AUTEXPLODE"	,_cAutExpl		,NIL}}
					dDataBase := CTOD(aProds[_I,2])
					CTPMT:=""
					MsExecAuto({|x,y| MATA650(x,y)},aRotAuto,5)
					dDataBase := Date()

					If lMsErroAuto
						MsgStop("Ocorreu um erro no apontamento da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+".")
						MostraErro()
						DisarmTransaction()
						LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
						dDataBase := _dBkDt
						Return()
					EndIf

					cSql:="UPDATE "+RETSQLNAME("ZPA")+" SET ZPA_OP='' WHERE ZPA_DATAFI='"+DTOS(CTOD(aProds[_I,2]))+"' AND ZPA_RECURS='"+aProds[_I,4]+"' AND ZPA_PRODUT='"+aProds[_I,6]+"' AND D_E_L_E_T_ <> '*' "
					MemoWrite("C:\TEMP\"+FUNNAME()+"_OP.SQL", cSql)
					nErr_Sql := TcSqlExec(cSql)

					If nErr_Sql < 0
						MsgStop("Ocorreu um erro no apontamento da Orderm de Produção para o produto "+AllTrim(aProds[_I,6])+", na tentativa de atualiza Apontamentos.")
						DisarmTransaction()
						LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
						dDataBase := _dBkDt
						Return()
					Endif

				EndIf
			End Transaction
		EndIf
	Next _I
	LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
	//->Ajusta ZP1
	PCP032E()
	dDataBase := _dBkDt
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032D  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032D()
	Local _lRet := .T.
	LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
Return(_lRet)


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032E  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Manipula dados na na ponte com a ZP1						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032E()
	Local cSql
	Local _x 		:= 0
	Local nErr_Sql	:= 0
	Local cAliasZPA	:= "ZPAZP1"
	Local aCampos	:= ZPA->(dbStruct())

	Local _dBkDt := dDataBase
	ProcRegua(Len(aProds))

	If Len(AllTrim(aProds[1,2])) <= 0
		MsgStop("Não ha dados a serem processados.")
		Return
	EndIf

	For _x := 1 To Len(aProds)
		IncProc()
		If aProds[_x,1] .And. !Empty(Alltrim(aProds[_x,3]))
			Begin Transaction
				cSql:="SELECT * FROM "+RETSQLNAME("ZPA")+" WHERE ZPA_DATAFI='"+DTOS(CTOD(aProds[_x,2]))+"' AND ZPA_RECURS='"+aProds[_x,4]+"' AND ZPA_PRODUT='"+aProds[_x,6]+"' AND D_E_L_E_T_ <> '*' "
				MemoWrite("C:\TEMP\"+FUNNAME()+"_ZP1_Consulta.SQL", cSql)
				dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasZPA,.F.,.T.)
				For nZ := 1 to Len(aCampos)
					If aCampos[nZ,2] <> "C"
						TCSetField(cAliasZPA, aCampos[nZ,1], aCampos[nZ,2], aCampos[nZ,3], aCampos[nZ,4])
					Endif
				Next nZ
				TCSetField(cAliasZPA, "PBRUTO", "N", 15, 3)
				TCSetField(cAliasZPA, "PLIQUIDO", "N", 15, 3)
				While !(cAliasZPA)->(EOF())

					cSql:="DELETE FROM "+RETSQLNAME("ZP1")+" WHERE ZP1_CODETI='"+(cAliasZPA)->(ZPA_RECURS+ZPA_FERRAM+ZPA_OPERAC+ZPA_PT+ZPA_TIPO)+"' AND ZP1_LOTE='"+STRZERO((cAliasZPA)->R_E_C_N_O_,10)+"' "
					MemoWrite("C:\TEMP\"+FUNNAME()+"_ZP1_Apaga.SQL", cSql)
					nErr_Sql := TcSqlExec(cSql)
					If nErr_Sql < 0
						MsgStop("Ocorreu um erro no apontamento da Orderm de Produção para o produto "+AllTrim(aProds[_x,6])+", na tentativa de atualiza Apontamentos, Na tabela ZP1.")
						DisarmTransaction()
						LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
						dDataBase := _dBkDt
						Return()
					Endif

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+(cAliasZPA)->ZPA_PRODUT))
						RecLock("ZP1",.T.)
						ZP1->ZP1_FILIAL	:= (cAliasZPA)->ZPA_FILIAL
						ZP1->ZP1_CODETI	:= (cAliasZPA)->(ZPA_RECURS+ZPA_FERRAM+ZPA_OPERAC+ZPA_PT+ZPA_TIPO)
						ZP1->ZP1_CODPRO	:= SB1->B1_COD
						ZP1->ZP1_PESO	:= SB1->B1_CONV
						ZP1->ZP1_DTPROD	:= (cAliasZPA)->ZPA_DATAFI
						ZP1->ZP1_DTVALI	:= (cAliasZPA)->ZPA_DATAFI
						ZP1->ZP1_EDATA	:= "N"	
						ZP1->ZP1_REPROC	:= "N"
						ZP1->ZP1_STATUS	:= "1"
						ZP1->ZP1_LOTE	:= STRZERO((cAliasZPA)->R_E_C_N_O_,10)
						ZP1->ZP1_DTIMPR	:= (cAliasZPA)->ZPA_DATAFI
						ZP1->ZP1_HRIMPR	:= (cAliasZPA)->ZPA_HORAFI
						ZP1->ZP1_USIMPR	:= (cAliasZPA)->ZPA_USERIC
						ZP1->ZP1_LOCAL	:= SB1->B1_LOCPAD
						ZP1->ZP1_OP		:= (cAliasZPA)->ZPA_OP
						ZP1->(MsUnLock())
					Endif

					(cAliasZPA)->(dbSkip())
				Enddo
				If Select(cAliasZPA) > 0
					(cAliasZPA)->(dbCloseArea())
					If File(cAliasZPA+GetDBExtension())
						fErase(cAliasZPA+GetDBExtension())
					Endif          
				Endif
			End Transaction
		Endif
	Next _x
	LjMsgRun( "Prcessando dados, aguarde...", "Fechamento", {|| PCP032A(2) } )
	dDataBase := _dBkDt
Return
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032B  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inverte seleção											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032B()
	Local _I := 0
	For _I := 1 To Len(aProds)
		aProds[_I,1] := !aProds[_I,1]
	Next _I
	oProds:SetArray(aProds)
	oProds:bLine := {|| {;
	If(aProds[oProds:nAT,1],oOk,oNo),;
	aProds[oProds:nAt,2],;
	aProds[oProds:nAt,3],;
	aProds[oProds:nAt,4],;
	aProds[oProds:nAt,5];
	}}
	oProds:Refresh()
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP032Z  ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera Perguntas									  	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                               
Static Function PCP032Z(cPerg)
	PutSx1(cPerg,"01","Filial de ?    		","","","mv_ch1","C",04,0,0,"G","","XM0","","","MV_PAR01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Filial Ate ?        	","","","mv_ch2","C",04,0,0,"G","","XM0","","","MV_PAR02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Recurso de ?    		","","","mv_ch3","C",06,0,0,"G","","SH1","","","MV_PAR03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Recurso Ate  ?       ","","","mv_ch4","C",06,0,0,"G","","SH1","","","MV_PAR04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Produto de  ? 	    ","","","mv_ch5","C",15,0,0,"G","","SB1","","","MV_PAR05","","","","","","","","","","","","","","","","") 
	PutSx1(cPerg,"06","Produto ate  ? 	    ","","","mv_ch6","C",15,0,0,"G","","SB1","","","MV_PAR06","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Operação de ?    	","","","mv_ch7","C",02,0,0,"G","","SG2","","","MV_PAR07","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Operação Ate  ?      ","","","mv_ch8","C",02,0,0,"G","","SG2","","","MV_PAR08","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"09","Ferramenta de ?    	","","","mv_ch9","C",06,0,0,"G","","SH4","","","MV_PAR09","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"10","Ferramenta Ate  ?    ","","","mv_chA","C",06,0,0,"G","","SH4","","","MV_PAR10","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"11","Data de   ? 	    	","","","mv_chB","D",08,0,0,"G","",""   ,"","","MV_PAR11","","","","","","","","","","","","","","","","") 
	PutSx1(cPerg,"12","Data ate  ? 	    	","","","mv_chC","D",08,0,0,"G","",""   ,"","","MV_PAR12","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"13","Status ?				","","","mv_chD","N",01,0,1,"C","",""   ,"","","MV_PAR13","OP Gerada","","","","OP Nao Gerada","","","Amboss","","","","","","","","","","","")
Return


