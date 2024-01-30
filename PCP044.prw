#Include 'Protheus.ch'

#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP044()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relat—rio de apontamento de ativação			                       ³±±
±±³          ³			                            	                          ³±±
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
User Function PCP044()
	Local oReport
	Local cTitulo := "Relatório de apontamento de ativação"
	Private aWBrwPCP	:= {}
	Private cPerg		:= PADR("PCP044",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cAliasZP	:= "ZP1"

	PCP044Z(cPerg) //->Cria Perguntas
	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	oReport:=TReport():New("PCP044",cTitulo,cPerg, {|oReport| PCP044A(0,oReport)},cTitulo)
	oReport:SetPortrait(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return



/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa Funções
*/
Static Function PCP044A(nOpc,oReport)
	If nOpc==0 //-> Seleciona
		oProcess := MsNewProcess():New( { || PCP044B(oReport) } , "Imprimindo..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif 
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Processa arquivo selecionado
ZP1_TIPO
1-Normal(Entrouesaiu do tunel) 
2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 
3-Re-Identificacao 
4-Re-Identificacao Rotatividade
*/
Static Function PCP044B(oReport)
	Local cSql	:=""
	Local aInfoBen
	Local _cAliasZP	:= GetNextAlias()
	Local _cStatus	:= ""
	Local _nTipo
	Local _GrpAnt		:= ""

	aWBrwPCP:={}

	Pergunte(cPerg,.F.)
	_nTipo:= MV_PAR08
	oProcess:SetRegua1(2)

	oSection1:= TRSection():New(oReport,"",{"Grupo"})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A",cAliasZP,OemToAnsi("Grupo"),PesqPict('SBM',"BM_DESC"),TamSx3("BM_DESC")[1]+1)
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	oSection2:= TRSection():New(oReport,"",{"Produtos"})
	oSection2:SetTotalInLine(.F.)
	oSection2:ShowHeader()
	TRCell():New(oSection2,"A",cAliasZP,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),5+1)
	TRCell():New(oSection2,"B",cAliasZP,OemToAnsi("Produto"),PesqPict('SB1',"B1_DESC"),TamSx3("B1_DESC")[1]+1)
	TRCell():New(oSection2,"C",cAliasZP,OemToAnsi("Dta.Ativ"),PesqPict('ZP1',"ZP1_DTATIV"),TamSx3("ZP1_DTATIV")[1]+1)
	TRCell():New(oSection2,"D",cAliasZP,OemToAnsi("Dta.Fabr"),PesqPict('ZP1',"ZP1_DTPROD"),TamSx3("ZP1_DTPROD")[1]+1)
	TRCell():New(oSection2,"E",cAliasZP,OemToAnsi("Dta.Venc"),PesqPict('ZP1',"ZP1_DTVALI"),TamSx3("ZP1_DTVALI")[1]+1)
	TRCell():New(oSection2,"F",cAliasZP,OemToAnsi("Qtd. Caixas"),PesqPict('ZP1',"ZP1_PESO"),TamSx3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"G",cAliasZP,OemToAnsi("Peso Total"),PesqPict('ZP1',"ZP1_PESO"),TamSx3("ZP1_PESO")[1]+1)
	oSection2:SetLeftMargin(2)
	oSection2:SetPageBreak(.F.)
	oSection2:SetTotalText(" ")

	cSql := " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI, DATAATIV "
	cSql += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	cSql += " 	FROM ("
	cSql += " 		SELECT"
	cSql += " 		  ZP1_DTATIV DATAATIV" 
	cSql += " 		, CASE "
	cSql += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007') THEN '001'"
	cSql += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010') THEN '002'"
	cSql += " 		  END TURNO"
	cSql += " 		, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI"
	cSql += " 		, ZP1_CODETI, ZP1_PESO"
	cSql += " 		FROM ("
	cSql += " 			SELECT  ZP1_DTATIV, ZP1_DTVALI, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_LOTE, ZP1_DTPROD"
	cSql += " 			, ZP6_HORA"
	cSql += " 			, ZP1_CODETI, ZP1_PESO"
	cSql += " 			FROM "+RetSQLName("ZP1")+" ZP1"
	cSql += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	cSql += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	cSql += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	cSql += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	cSql += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	cSql += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	cSql += " 			AND (ZP1_STATUS = '1' OR ZP6_HORA IS NOT NULL )"
	cSql += " 			AND ZP1.ZP1_REPROC <> 'S'"
	cSql += " 			AND ZP1.ZP1_DTATIV <> ''"
	cSql += " 		) A"
	cSql += " 	) B"
	cSql += " 	WHERE DATAATIV BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	cSql += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	cSql += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cSql += " 	GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI, DATAATIV "
	cSql += " UNION ALL "
	cSql += " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI, DATAATIV "
	cSql += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	cSql += " 	FROM ("
	cSql += " 		SELECT"
	cSql += " 		  ZP1_DTATIV DATAATIV"
	cSql += " 		, CASE "
	cSql += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007') THEN '001'"
	cSql += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010') THEN '002'"
	cSql += " 		  END TURNO"
	cSql += " 		, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI"
	cSql += " 		, ZP1_CODETI, ZP1_PESO"
	cSql += " 		FROM ("
	cSql += " 			SELECT  ZP1_DTATIV, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_LOTE, ZP1_DTPROD, ZP1_DTVALI"
	cSql += " 			, ZP6_HORA"
	cSql += " 			, ZP1_CODETI, ZP1_PESO"
	cSql += " 			FROM ZP1010_MORTO ZP1"
	cSql += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	cSql += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	cSql += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	cSql += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	cSql += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	cSql += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	cSql += " 			AND (ZP1_STATUS = '1' OR ZP6_HORA IS NOT NULL )"
	cSql += " 			AND ZP1.ZP1_REPROC <> 'S'"
	cSql += " 			AND ZP1.ZP1_DTATIV <> ''"
	cSql += " 		) A"
	cSql += " 	) B"
	cSql += " 	WHERE DATAATIV BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	cSql += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	cSql += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cSql += " 	GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_DTPROD, ZP1_DTVALI, DATAATIV "
	cSql += " ORDER BY 1,2"

	cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP)->(LastRec()))
	(_cAliasZP)->(dbGoTop())

	While !(_cAliasZP)->(Eof())

		AADD(aWBrwPCP,{;
		(_cAliasZP)->BM_DESC,;
		(_cAliasZP)->ZP1_CODPRO,;
		(_cAliasZP)->B1_DESC,;
		DTOC(STOD((_cAliasZP)->DATAATIV)),;
		DTOC(STOD((_cAliasZP)->ZP1_DTPROD)),; 
		DTOC(STOD((_cAliasZP)->ZP1_DTVALI)),;
		(_cAliasZP)->QTDCAIXA,;
		(_cAliasZP)->PESO;
		})

		oProcess:IncRegua2("Produto: "+(_cAliasZP)->B1_DESC)

		(_cAliasZP)->(dbSkip())
	Enddo

	If Select(_cAliasZP) > 0
		(_cAliasZP)->(dbCloseArea())
		If File(_cAliasZP+GetDBExtension())
			fErase(_cAliasZP+GetDBExtension())
		Endif
	Endif

	//->Preenche dados do Browse
	If Len(aWBrwPCP) <= 0
		ASIZE(aWBrwPCP,0)
		aAdd(aWBrwPCP,{"","","","","","","","","","","","","","","","","","","","",""})
	Endif

	oSection1:Init()
	Section2:=oReport:Section(1)
	oSection2:Init()

	oProcess:IncRegua1("Imprimindo...")
	oProcess:SetRegua2(Len(aWBrwPCP))

	For _I := 1 To Len(aWBrwPCP)

		If _GrpAnt<>aWBrwPCP[_I,1]
			oSection1:Cell("A"):SetValue(aWBrwPCP[_I,1])
			oSection1:PrintLine()
			_GrpAnt:=aWBrwPCP[_I,1]
		Endif

		oSection2:Cell("A"):SetValue(aWBrwPCP[_I,2])
		oSection2:Cell("B"):SetValue(aWBrwPCP[_I,3])
		oSection2:Cell("C"):SetValue(CTOD(aWBrwPCP[_I,4]))
		oSection2:Cell("D"):SetValue(CTOD(aWBrwPCP[_I,5]))
		oSection2:Cell("E"):SetValue(CTOD(aWBrwPCP[_I,6]))
		oSection2:Cell("F"):SetValue(aWBrwPCP[_I,7])
		oSection2:Cell("G"):SetValue(aWBrwPCP[_I,8])
		oSection2:PrintLine()

		oProcess:IncRegua2("Produto: "+aWBrwPCP[_I,3])

	Next _I
	oSection2:Finish()
	oSection1:Finish()

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Perguntas
*/
Static Function PCP044Z(cPerg)
	PutSx1(cPerg,"01","Data de    ?","."     ,"."       ,"mv_ch1","D",08,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Data ate   ?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Produto de ?","."     ,"."       ,"mv_ch3","C",15,0,0,"G","","SB1","","","mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Produto ate?","."     ,"."       ,"mv_ch4","C",15,0,0,"G","","SB1","","","mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Turno de ?  ","."     ,"."       ,"mv_ch5","C",03,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Turno ate?  ","."     ,"."       ,"mv_ch6","C",03,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
Return