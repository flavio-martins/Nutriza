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
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ PCP052   ∫Autor  ≥Evandro Gomes     ∫ Data ≥ 02/05/13     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Relatório de Reprocesso										   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ NUTRIZA - PCP 													 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function PCP052()
	Local oReport
	Local cPerg	:= Padr(UPPER(FUNNAME()),10)
	Local _aDados	:= {}
	Private oProcess
	oProcess:=MsNewProcess():New( { || PCP052A(oReport, cPerg, _aDados) } , "Gerando Relatorio..." , "Aguarde..." , .F. )
	oProcess:Activate()
Return

/*
_____________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶Programa  ¶ PCP052A 	¶ Autor ¶ Evandro Oliveira Gomes¶ Data ¶16/02/2012¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶DescriÁ‡o ¶ Processa relatório												¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
_____________________________________________________________________________
*/ 
Static Function PCP052A(oReport, cPerg, _aDados)
	Local _lRet 	:= .T.
	Local cTitulo	:= "Relatorio de Reprocessamento"
	Private _cFilIni:=MV_PAR01
	Private _cFilFim:=MV_PAR02
	Private _dFabIni:=MV_PAR03
	Private _dFabFim:=MV_PAR04
	Private _cLotIni:=MV_PAR05
	Private _cLotFim:=MV_PAR06
	Private _cPrdIni:=MV_PAR07
	Private _cPrdFim:=MV_PAR08
	Private _dRepIni:=MV_PAR09
	Private _dRepFim:=MV_PAR10
	Private _cCCuIni:=MV_PAR11
	Private _cCCuFim:=MV_PAR12
	Private _cTMMIni:=MV_PAR13
	Private _cTMMFim:=MV_PAR14
	Private _nLayFim:=MV_PAR15
	Private cAliasPrt	:= "XXXZZB"

	PCP052Z(cPerg) //->Cria Perguntas

	oProcess:SetRegua1(3)

	//->Pergunte
	oProcess:IncRegua1("Ajustando Pergunta...")
	If !Pergunte(cPerg)
		Return .F.
	Else
		_cFilIni:=MV_PAR01
		_cFilFim:=MV_PAR02
		_dFabIni:=MV_PAR03
		_dFabFim:=MV_PAR04
		_cLotIni:=MV_PAR05
		_cLotFim:=MV_PAR06
		_cPrdIni:=MV_PAR07
		_cPrdFim:=MV_PAR08
		_dRepIni:=MV_PAR09
		_dRepFim:=MV_PAR10
		_cCCuIni:=MV_PAR11
		_cCCuFim:=MV_PAR12
		_cTMMIni:=MV_PAR13
		_cTMMFim:=MV_PAR14
		_nLayFim:=MV_PAR15
	Endif

	//->Imprime o relatorio
	oReport:=TReport():New(cPerg, cTitulo,cPerg, {|oReport| PCP052C(oReport, cPerg, cTitulo, cAliasPrt, @_aDados)},cTitulo)
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return

/*
_____________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶Programa  ¶ PCP052A 	¶ Autor ¶ Evandro Oliveira Gomes¶ Data ¶16/02/2012¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶DescriÁ‡o ¶ Localiza Dados													¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
_____________________________________________________________________________
*/ 
Static Function PCP052B(cPerg, _aDados, oReport)
	Local _cQry		:= ""
	Local _cDescMov	:= ""
	Local _cAliasZP	:= GetNextAlias()

	_cQry:=" SELECT "
	If MV_PAR15 == 1 //->Analitico
		_cQry+=" ZP1_CODETI, ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM, ZP1_PESO QTD_PESO, 1 QTD_CAIXAS  "
	ElseIf MV_PAR15 == 2 //->Sintético
		_cQry+=" ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM, SUM(ZP1_PESO) QTD_PESO, COUNT(*) QTD_CAIXAS   "
	Endif
	_cQry+=" FROM "+RETSQLNAME("ZP1")+" ZP1  WITH (NOLOCK)"
	_cQry+=" INNER JOIN "+RETSQLNAME("SB1")+" SB1  WITH (NOLOCK)"
	_cQry+=" ON B1_COD=ZP1_CODPRO "
	_cQry+=" AND SB1.D_E_L_E_T_ <> '*' "
	_cQry+=" LEFT JOIN "+RETSQLNAME("ZPB")+" ZPB  WITH (NOLOCK)"
	_cQry+=" ON ZP1_CODETI=ZPB_CODETI "
	_cQry+=" LEFT JOIN "+RETSQLNAME("CTT")+" CTT  WITH (NOLOCK)"
	_cQry+=" ON ZPB_CC=CTT_CUSTO "
	_cQry+=" WHERE "
	_cQry+=" ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQry+=" AND ZP1_DTPROD BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	_cQry+=" AND ZP1_LOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQry+=" AND ZP1_CODPRO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQry+=" AND ZP1_DTREP BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' "
	_cQry+=" AND ZP1_REPROC = 'S' "
	If _nLayFim == 2 //-> Sintetico
		_cQry+=" GROUP BY ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM
	Endif

	_cQry+=" UNION ALL "

	_cQry+=" SELECT "
	If MV_PAR15 == 1 //->Analitico
		_cQry+=" ZP1_CODETI, ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM, ZP1_PESO QTD_PESO, 1 QTD_CAIXAS  "
	ElseIf MV_PAR15 == 2 //->Sintético
		_cQry+=" ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM, SUM(ZP1_PESO) QTD_PESO, COUNT(*) QTD_CAIXAS   "
	Endif
	_cQry+=" FROM ZP1010_MORTO ZP1_MORTO WITH (NOLOCK)"
	_cQry+=" INNER JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK)"
	_cQry+=" ON B1_COD=ZP1_CODPRO "
	_cQry+=" AND SB1.D_E_L_E_T_ <> '*' "
	_cQry+=" LEFT JOIN "+RETSQLNAME("ZPB")+" ZPB  WITH (NOLOCK)"
	_cQry+=" ON ZP1_CODETI=ZPB_CODETI "
	_cQry+=" LEFT JOIN "+RETSQLNAME("CTT")+" CTT  WITH (NOLOCK)"
	_cQry+=" ON ZPB_CC=CTT_CUSTO "
	_cQry+=" WHERE "
	_cQry+=" ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQry+=" AND ZP1_DTPROD BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	_cQry+=" AND ZP1_LOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	_cQry+=" AND ZP1_CODPRO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	_cQry+=" AND ZP1_DTREP BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"' "
	_cQry+=" AND ZP1_REPROC = 'S' "
	If _nLayFim == 2 //-> Sintetico
		_cQry+=" GROUP BY ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM"
	Endif
	_cQry+=" ORDER BY ZP1_DTREP, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZPB_CC, CTT_DESC01, ZPB_TM"
	MemoWrite("C:\TEMP\"+ Upper(AllTrim(FUNNAME())) +"_ZP1.SQL", _cQry )
	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),_cAliasZP,.F.,.T.)
	(_cAliasZP)->(dbGoBottom())
	_nQtdReg:=Contar(_cAliasZP,"!EOF()")
	oProcess:SetRegua2(_nQtdReg)
	oReport:SetMeter(_nQtdReg)
	(_cAliasZP)->(dbGoTop())
	_aCodAnt:={}
	While !(_cAliasZP)->(EOF())

		oProcess:IncRegua2("Prod.:" + SubStr((_cAliasZP)->B1_DESC,1,20))
		IncProc("")

		dbSelectArea("SX5") 
		dbSeek(xFilial()+"Z8"+(_cAliasZP)->ZPB_TM) 
		_cDescMov:=IIF(Found(),Trim(X5Descri()),"")

		If ((_cAliasZP)->ZPB_CC >= _cCCuIni .And. (_cAliasZP)->ZPB_CC <= _cCCuFim) .And. ((_cAliasZP)->ZPB_TM >= _cTMMIni .And. (_cAliasZP)->ZPB_TM <= _cTMMFim)
			If _nLayFim == 1 //-> Analítico
				AADD(_aDados,{;
				(_cAliasZP)->ZP1_CODETI,;
				STOD((_cAliasZP)->ZP1_DTREP),;
				(_cAliasZP)->ZP1_CODPRO,;
				(_cAliasZP)->B1_DESC,;
				STOD((_cAliasZP)->ZP1_DTPROD),;
				(_cAliasZP)->ZPB_CC,;
				(_cAliasZP)->CTT_DESC01,;
				(_cAliasZP)->ZPB_TM,;
				_cDescMov,;
				(_cAliasZP)->QTD_PESO,;
				0})
			ElseIf _nLayFim == 2 //-> Sintético
				AADD(_aDados,{;
				"",;
				STOD((_cAliasZP)->ZP1_DTREP),;
				(_cAliasZP)->ZP1_CODPRO,;
				(_cAliasZP)->B1_DESC,;
				STOD((_cAliasZP)->ZP1_DTPROD),;
				(_cAliasZP)->ZPB_CC,;
				(_cAliasZP)->CTT_DESC01,;
				(_cAliasZP)->ZPB_TM,;
				_cDescMov,;
				(_cAliasZP)->QTD_PESO,;
				(_cAliasZP)->QTD_CAIXAS})
			Endif
		Endif
		(_cAliasZP)->(dbSkip())
	Enddo
	(_cAliasZP)->(dbCloseArea())
Return

/*
_____________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶Programa  ¶ PCP052C 	¶ Autor ¶ Evandro Oliveira Gomes¶ Data ¶16/02/2012¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶DescriÁ‡o ¶ Localiza Dados													¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
_____________________________________________________________________________
*/ 
Static Function PCP052C(oReport, cPerg, cTitulo, cAliasPrt, _aDados)
	Local oSection1

	//->Seleciona dados
	oProcess:IncRegua1("Seleciona Dados...")
	_aDados:={}
	PCP052B(cPerg, @_aDados, oReport)
	If Len(_aDados) == 0
		MsgStop("Dados nao encontrados.","Atencao")
		Return .F.
	Endif

	oProcess:IncRegua1("Imprimindo...")

	oSection1:=TRSection():New(oReport,cTitulo+" Reprocesso entre: "+DTOC(_dRepIni)+" e "+DTOC(_dRepFim),{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()


	If _nLayFim == 1 //-> Analítico
		TRCell():New(oSection1,"A0",cAliasPrt,OemToAnsi("Etiqueta"),PesqPict('ZP1',"ZP1_CODETI"),TamSX3("ZP1_CODETI")[1]+1)
	Endif

	TRCell():New(oSection1,"A1",cAliasPrt,OemToAnsi("Dt.Rep"),PesqPict('ZP1',"ZP1_DTREP"),TamSX3("ZP1_DTREP")[1]+1)			
	TRCell():New(oSection1,"A2",cAliasPrt,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"A3",cAliasPrt,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"A4",cAliasPrt,OemToAnsi("Dt.Prod"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
	TRCell():New(oSection1,"A5",cAliasPrt,OemToAnsi("CC"),PesqPict('CTT',"CTT_CUSTO"),TamSX3("CTT_CUSTO")[1]+1)
	TRCell():New(oSection1,"A6",cAliasPrt,OemToAnsi("Descricao"),PesqPict('CTT',"CTT_DESC01"),TamSX3("CTT_DESC01")[1]+1)
	TRCell():New(oSection1,"A7",cAliasPrt,OemToAnsi("TM"),PesqPict('ZPB',"ZPB_TM"),TamSX3("ZPB_TM")[1]+1)
	TRCell():New(oSection1,"A8",cAliasPrt,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"A9",cAliasPrt,OemToAnsi("Peso"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)

	If _nLayFim == 2 //-> Sintético
		TRCell():New(oSection1,"A10",cAliasPrt,OemToAnsi("Qtd"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	Endif


	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")
	TRFunction():New(oSection1:Cell("A9"),NIL,"SUM",,,,,.F.,.T.)
	If _nLayFim == 2 //-> Sintético
		TRFunction():New(oSection1:Cell("A10"),NIL,"SUM",,,,,.F.,.T.)
	Endif

	oSection1:Init()

	oReport:SetMeter(Len(_aDados))
	oProcess:SetRegua1(1)
	oProcess:SetRegua2(Len(_aDados))
	oProcess:IncRegua1("Gerando Relatorio")

	For x:=1 To Len(_aDados)

		If oReport:Cancel() //->Cancelar
			Exit
		EndIf
		oReport:IncMeter()

		IncProc("Imprimindo Produto "+cValToChar(_aDados[x,4]))
		oProcess:IncRegua2("Prod: "+_aDados[x,4])

		If _nLayFim == 1 //-> Analítico
			oSection1:Cell("A0"):SetValue(_aDados[x,1])
		Endif
		oSection1:Cell("A1"):SetValue(_aDados[x,2])
		oSection1:Cell("A2"):SetValue(_aDados[x,3])
		oSection1:Cell("A3"):SetValue(_aDados[x,4])
		oSection1:Cell("A4"):SetValue(_aDados[x,5])
		oSection1:Cell("A5"):SetValue(_aDados[x,6])
		oSection1:Cell("A6"):SetValue(_aDados[x,7])
		oSection1:Cell("A7"):SetValue(_aDados[x,8])
		oSection1:Cell("A8"):SetValue(_aDados[x,9])
		oSection1:Cell("A9"):SetValue(_aDados[x,10])		
		If _nLayFim == 2 //-> Sintético
			oSection1:Cell("A10"):SetValue(_aDados[x,11])
		Endif
		oSection1:Printline()
	Next x

	oSection1:Finish()
Return(oReport)


/*
_____________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶Programa  ¶ PCP052 	¶ Autor ¶ Evandro Oliveira Gomes¶ Data ¶16/02/2012¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶DescriÁ‡o ¶ Ajusta SX1 Perguntas										  	¶¶¶
¶¶+----------+------------------------------------------------------------¶¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
_____________________________________________________________________________
*/                                                                           
Static Function PCP052Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Filial de?	",".","."       	,"mv_ch1","C",04,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Filial Ate?	",".","."       	,"mv_ch2","C",04,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Dta.Fab. de?	",".","."       	,"mv_ch3","D",08,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Dta.Fab. Ate?",".","."       	,"mv_ch4","D",08,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Lote de?		",".","."       	,"mv_ch5",TAMSX3("ZP1_LOTE")[3],TAMSX3("ZP1_LOTE")[1],TAMSX3("ZP1_LOTE")[2],0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Lote Ate?	",".","."       	,"mv_ch6",TAMSX3("ZP1_LOTE")[3],TAMSX3("ZP1_LOTE")[1],TAMSX3("ZP1_LOTE")[2],0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","Produto de?	",".","."       	,"mv_ch7",TAMSX3("ZP1_CODPRO")[3],TAMSX3("ZP1_CODPRO")[1],TAMSX3("ZP1_CODPRO")[2],0,"G","","SB1","","","mv_par07","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"08","Produto Ate?	",".","."       	,"mv_ch8",TAMSX3("ZP1_CODPRO")[3],TAMSX3("ZP1_CODPRO")[1],TAMSX3("ZP1_CODPRO")[2],0,"G","","SB1","","","mv_par08","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"09","Dta.Reproc. de?	",".","."     ,"mv_ch9","D",08,0,0,"G","","   ","","","mv_par09","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"10","Dta.Reproc. Ate?",".","."     ,"mv_cha","D",08,0,0,"G","","   ","","","mv_par10","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"11","C. de Custos de?",".","."     ,"mv_chb",TAMSX3("D3_CC")[3],TAMSX3("D3_CC")[1],TAMSX3("D3_CC")[2],0,"G","","CTT","","","mv_par11","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"12","C. de Custos Ate?",".","."    ,"mv_chc",TAMSX3("D3_CC")[3],TAMSX3("D3_CC")[1],TAMSX3("D3_CC")[2],0,"G","","CTT","","","mv_par12","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"13","TM De?",".","."     ,"mv_chb",TAMSX3("ZPB_TM")[3],TAMSX3("ZPB_TM")[1],TAMSX3("ZPB_TM")[2],0,"G","","Z8","","","mv_par13","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"14","TM Ate?",".","."    ,"mv_chc",TAMSX3("ZPB_TM")[3],TAMSX3("ZPB_TM")[1],TAMSX3("ZPB_TM")[2],0,"G","","Z8","","","mv_par14","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"15","Layout?","","","mv_chd","N",1,0,1,"C","","","","","MV_PAR15","Analitico","","","","Sintetico","","","","","","","","","","","","","","")
Return

