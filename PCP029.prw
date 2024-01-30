#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function PCP029()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Estoque em Tunel" 
	Local cPict          := ""
	Local titulo       := "Produtos enviados para reprocesso"
	Local nLin         := 80
	Local Cabec1       := "Grupo           Produto                                                               Qtd. Caixas    Peso Liquido"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := FunName()
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := nomeprog+"A"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog
	Private cString := "ZP1"

	dbSelectArea("ZP1")
	dbSetOrder(1)

	putSx1(cPerg,"01","Produto de ?","."     ,"."       ,"mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Produto ate?","."     ,"."       ,"mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"03","Data de ?","."     ,"."       ,"mv_ch3","D",8,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"04","Data ate?","."     ,"."       ,"mv_ch4","D",8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","")

	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local lf := chr(13)+chr(10)	
	SetRegua(RecCount())


	_cQry := " SELECT SUBSTRING(BM_DESC,1,15) BM_DESC,ZP1_CODPRO, B1_DESC" + lf
	_cQry += " , COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO" + lf
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1" + lf
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO" + lf
	_cQry += " INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO" + lf
	_cQry += " WHERE ZP1.D_E_L_E_T_ <> ' '" + lf
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'" + lf
	_cQry += " AND ZP1_DTATIV <> ''" + lf
	_cQry += " AND ZP1_CARGA = ''" + lf
	_cQry += " AND ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + lf
	_cQry += " AND ZP1_DTREP BETWEEN '"+DToS(MV_PAR03)+"' AND '"+DToS(MV_PAR04)+"'" + lf
	_cQry += " GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC" + lf
	_cQry += " UNION ALL " + lf
	_cQry += " SELECT SUBSTRING(BM_DESC,1,15) BM_DESC,ZP1_CODPRO, B1_DESC" + lf
	_cQry += " , COUNT(DISTINCT ZP1MORTO.ZP1_CODETI) QTDCAIXA, SUM(ZP1MORTO.ZP1_PESO) PESO" + lf
	_cQry += " FROM ZP1010_MORTO ZP1MORTO " + lf
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1MORTO.ZP1_CODPRO" + lf
	_cQry += " INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO" + lf
	_cQry += " WHERE ZP1MORTO.D_E_L_E_T_ <> ' '" + lf
	_cQry += " AND ZP1MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'" + lf
	_cQry += " AND ZP1MORTO.ZP1_DTATIV <> ''" + lf
	_cQry += " AND ZP1MORTO.ZP1_CARGA = ''" + lf
	_cQry += " AND ZP1MORTO.ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + lf
	_cQry += " AND ZP1MORTO.ZP1_DTREP BETWEEN '"+DToS(MV_PAR03)+"' AND '"+DToS(MV_PAR04)+"'" + lf
	_cQry += " GROUP BY BM_DESC, ZP1MORTO.ZP1_CODPRO, B1_DESC" + lf
	_cQry += " ORDER BY 1,2" + lf

	TcQuery _cQry New Alias "QRY" 

	memowrite ("c:\temp\pcp029.sql", _cQry)

	_cGrpAnt := ""
	_nTotCx := 0
	_nTotPes := 0
	_nTotGCx := 0
	_nTotGPes := 0

	QRY->(dbGoTop())
	While !QRY->(EOF())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		If _cGrpAnt <> QRY->BM_DESC
			@nLin,000 PSAY QRY->BM_DESC
			_cGrpAnt := QRY->BM_DESC
		EndIf
		@nLin,016 PSAY SubStr(QRY->ZP1_CODPRO,1,6)+"-"+QRY->B1_DESC
		@nLin,084 PSAY QRY->QTDCAIXA Picture "@E 999,999,999.99"
		@nLin,099 PSAY QRY->PESO Picture "@E 999,999,999.99"
		nLin++

		_nTotCx += QRY->QTDCAIXA
		_nTotPes += QRY->PESO

		_nTotGCx += QRY->QTDCAIXA
		_nTotGPes += QRY->PESO

		QRY->(dbSkip())

		If _cGrpAnt <> QRY->BM_DESC
			@nLin,000 PSAY _cGrpAnt+" TOTAL"
			@nLin,084 PSAY _nTotCx Picture "@E 999,999,999.99"
			@nLin,099 PSAY _nTotPes Picture "@E 999,999,999.99"
			nLin+=2
			_nTotCx := 0
			_nTotPes := 0
		EndIf

	EndDo
	@nLin,000 PSAY "TOTAL GERAL"
	@nLin,084 PSAY _nTotGCx Picture "@E 999,999,999.99"
	@nLin,099 PSAY _nTotGPes Picture "@E 999,999,999.99"

	QRY->(dbCloseArea()())

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


/*
0         1         2         3         4         5         6         7         8         9         10        11        12        13
*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*1
Grupo           Produto                                                               Qtd. Caixas    Peso Liquido
XXXXXXXXXXXXXXX XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
.               XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 999,999,999.99
XXXXXXXXXXXXXXX TOTAL                                                               999,999,999.99 999,999,999.99
*/
