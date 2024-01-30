#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function PCP024

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Estoque em Tunel"
	Local cPict          := ""
	Local titulo       := "Estoque em Tunel"
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

	SetRegua(RecCount())


	_cQry := " SELECT SUBSTRING(BM_DESC,1,15) BM_DESC,ZP1_CODPRO, B1_DESC"
	_cQry += " , COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_STATUS = ''"
	_cQry += " AND ZP1_CARGA = ''"
	_cQry += " AND ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	_cQry += " AND EXISTS ("
	_cQry += " 	SELECT ZP6_ETIQ" 
	_cQry += " 	FROM "+RetSQLName("ZP6")
	_cQry += " 	WHERE D_E_L_E_T_ = ' '" 
	_cQry += " 	AND ZP6_FILIAL = '"+xFilial("ZP6")+"'" 
	_cQry += " 	AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " 	GROUP BY ZP6_ETIQ"
	_cQry += " )"
	_cQry += " GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC"
	_cQry += " ORDER BY 1,2"
	TcQuery _cQry New Alias "QRY"

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
