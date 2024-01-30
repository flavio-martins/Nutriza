#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function PCP015

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Apontamentos da Produção"
	Local cPict          := ""
	Local titulo       	:= "Apontamentos da Produção"
	Local nLin         	:= 80
	Local Cabec1       	:= ""
	Local Cabec2       	:= "Grupo           Produto                                                               Qtd. Caixas    Peso Liquido"
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := FunName()
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg      	:= nomeprog+"A"
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel     	:= nomeprog

	Private cString := "ZP1"

	dbSelectArea("ZP1")
	dbSetOrder(1)

	putSx1(cPerg,"01","Data de    ?","."     ,"."       ,"mv_ch1","D",08,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Data ate   ?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"03","Produto de ?","."     ,"."       ,"mv_ch3","C",15,0,0,"G","","SB1","","","mv_par03","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"04","Produto ate?","."     ,"."       ,"mv_ch4","C",15,0,0,"G","","SB1","","","mv_par04","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"05","Turno de ?  ","."     ,"."       ,"mv_ch5","C",03,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"06","Turno ate?  ","."     ,"."       ,"mv_ch6","C",03,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"07","Arquivo Excel (.CSV)?  ","."     ,"."    ,"mv_ch7","C",99,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"08","Grupo de ?","."     ,"."       ,"mv_ch8","C",4,0,0,"G","","SBM","","","mv_par08","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"09","Grupo ate?","."     ,"."       ,"mv_ch9","C",4,0,0,"G","","SBM","","","mv_par09","","","","","","","","","","","","","","","","")

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
	******************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _nConv	:= 0
	Local _lPrimLn:= .T.

	SetRegua(RecCount())

	_cQry := " SELECT SUBSTRING(BM_DESC,1,15) BM_DESC , ZP1_CODPRO, B1_DESC, SUM(QTDCAIXA) QTDCAIXA, SUM(PESO) PESO ,B1_TIPCONV"
	_cQry += " FROM("
	_cQry += " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC"
	_cQry += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO,B1_TIPCONV"
	_cQry += " 	FROM ("
	_cQry += " 		SELECT"
	_cQry += " 		  ZP1_DTPROD DATAPROD"
	_cQry += " 		, CASE "
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007','1/1','1/2','1/3','5/1','5/2','5/3') THEN '001'" //Inclusão de lotes Wendel 02/07/2019 
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010','3/1','3/2','3/3') THEN '002'" //Inclusão de lotes Wendel 02/07/2019
	_cQry += " 		  END TURNO"
	_cQry += " 		, BM_DESC,ZP1_CODPRO, B1_DESC"
	_cQry += " 		, ZP1_CODETI, ZP1_PESO,B1_TIPCONV"
	_cQry += " 		FROM ("
	_cQry += " 			SELECT  ZP1_DTPROD, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_LOTE"
	_cQry += " 			, ZP6_HORA"
	_cQry += " 			, ZP1_CODETI, ZP1_PESO,B1_TIPCONV"
	_cQry += " 			FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO "
	_cQry += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO AND BM_GRUPO BETWEEN '"+MV_PAR08+ "' AND '"+MV_PAR09+" ' "
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	_cQry += " 			AND (ZP1_STATUS IN ('1','2','3','5','7','9') OR ZP6_HORA IS NOT NULL )"
	_cQry += " 			AND ZP1.ZP1_REPROC <> 'S'"
	_cQry += " 		) A"
	_cQry += " 	) B"
	_cQry += " 	WHERE DATAPROD BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY SUBSTRING(BM_DESC,1,15) , ZP1_CODPRO, B1_DESC,B1_TIPCONV"

	_cQry += " 	UNION ALL"
	_cQry += " 		SELECT SUBSTRING(BM_DESC,1,15) BM_DESC , ZP1_CODPRO, B1_DESC, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO,B1_TIPCONV "
	//	_cQry += " 		, CASE "
	//	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007') THEN '001'"
	//	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010') THEN '002'"
	//	_cQry += " 		  END TURNO2"
	_cQry += " 			FROM "+RetSQLName("ZP1")+"_MORTO"
	_cQry += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO AND BM_GRUPO BETWEEN '"+MV_PAR08+ "' AND '"+MV_PAR09+" ' "
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1010_MORTO.ZP1_FILIAL AND ZP6_ETIQ = ZP1010_MORTO.ZP1_CODETI"
	_cQry += " 			WHERE ZP1010_MORTO.D_E_L_E_T_ = ' '"
	_cQry += " 			AND ZP1010_MORTO.ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " 			AND (ZP1010_MORTO.ZP1_OP <> 'ESTEDATA' AND ZP1010_MORTO.ZP1_OP <> 'TUNEDATA' AND ZP1010_MORTO.ZP1_OP <> 'RETEDATA')"
	_cQry += " 			AND (ZP1010_MORTO.ZP1_STATUS IN ('1','2','3','5','7','9') OR ZP6_HORA IS NOT NULL )"
	_cQry += " 			AND ZP1010_MORTO.ZP1_REPROC <> 'S'"
	_cQry += " 			AND ZP1_DTPROD BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 			AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	//	_cQry += " 			AND TURNO2 BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 			GROUP BY SUBSTRING(BM_DESC,1,15) , ZP1_CODPRO, B1_DESC,B1_TIPCONV"	

	_cQry += " 	UNION ALL"
	_cQry += " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, D3_COD, B1_DESC, SUM(D3_QUANT/CASE WHEN B1_CONV > 0 THEN B1_CONV ELSE 1 END), SUM(D3_QUANT) ,B1_TIPCONV"
	_cQry += " 	FROM "+RetSQLName("SD3")+" SD3"
	_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D3_COD"
	_cQry += " 	INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO AND BM_GRUPO BETWEEN '"+MV_PAR08+ "' AND '"+MV_PAR09+" ' "
	_cQry += " 	WHERE SD3.D_E_L_E_T_ = ' '"
	_cQry += " 	AND D3_FILIAL = '"+xFilial("SD3")+"'"
	_cQry += " 	AND D3_ESTORNO = ''"
	_cQry += " 	AND D3_TM IN ('101','102')
	_cQry += " 	AND D3_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND CASE D3_TM WHEN '101' THEN '001' ELSE '002' END BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY SUBSTRING(BM_DESC,1,15), D3_COD, D3_EMISSAO, B1_DESC,B1_TIPCONV"

	_cQry += " 	UNION ALL"
	_cQry += " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, D3_COD, B1_DESC,"
	_cQry += "    CASE  WHEN B1_TIPCONV = 'D' THEN   SUM(D3_QUANT/CASE WHEN B1_CONV > 0 THEN B1_CONV ELSE 1 END)  ELSE  SUM(D3_QUANT) END , "
	_cQry += "    CASE  WHEN B1_TIPCONV = 'D' THEN   SUM(D3_QUANT)  ELSE SUM(D3_QUANT*CASE WHEN B1_CONV > 0 THEN B1_CONV ELSE 1 END)   END"
	_cQry += "   ,B1_TIPCONV"
	_cQry += " 	FROM "+RetSQLName("SD3")+" SD3"
	_cQry += " 	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = D3_COD"
	_cQry += " 	INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO AND BM_GRUPO BETWEEN '"+MV_PAR08+ "' AND '"+MV_PAR09+" ' "
	_cQry += " 	WHERE SD3.D_E_L_E_T_ = ' '"
	_cQry += " 	AND D3_FILIAL = '"+xFilial("SD3")+"'"
	_cQry += " 	AND D3_ESTORNO = ''"
	_cQry += " 	AND ((D3_TM = '103' )  OR (D3_TM='100' AND D3_GRUPO IN ('0743','0734') ))"
	//_cQry += " 	AND D3_COD='00224' "
	_cQry += "    AND B1_XPROD2='1'" //Producao sem paletizacao # // AND B1_GRUPO='004'
	_cQry += " 	AND D3_EMISSAO BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	//_cQry += " 	AND CASE D3_TM WHEN '101' THEN '001' ELSE '002' END BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY SUBSTRING(BM_DESC,1,15), D3_COD, B1_DESC,B1_TIPCONV"

	_cQry += " ) C"
	_cQry += " GROUP BY SUBSTRING(BM_DESC,1,15), ZP1_CODPRO, B1_DESC,B1_TIPCONV"
	_cQry += " ORDER BY 1,2"

	memowrite('c:\temp\pcp015.sql',_cQry)

	TcQuery _cQry New Alias "QRY"

	_cGrpAnt := ""
	_nTotCx := 0
	_nTotPes := 0
	_nTotGCx := 0
	_nTotGPes := 0
	_cExcel := "Grupo;Produto;Descricao;Qtd. Caixas;Peso Liquido"+CHR(13)+CHR(10)

	Cabec1       := "Data: "+DToC(MV_PAR01)+" a "+DToC(MV_PAR01)+"  -  Turno: "+MV_PAR05+" ate "+MV_PAR06

	QRY->(dbGoTop())
	_cGrpAnt:=QRY->BM_DESC
	While !QRY->(EOF())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_nConv:=0
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+QRY->ZP1_CODPRO))
			_nConv:=SB1->B1_CONV
		Endif

		If _cGrpAnt == QRY->BM_DESC .Or. _lPrimLn
			_nTotCx += QRY->QTDCAIXA
			_nTotPes += IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0)
			_nTotGCx += QRY->QTDCAIXA
			_nTotGPes += IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0)
		ElseIf !_lPrimLn
			@nLin,000 PSAY _cGrpAnt+" TOTAL"
			@nLin,084 PSAY _nTotCx Picture "@E 999,999,999.99"
			@nLin,099 PSAY _nTotPes Picture "@E 999,999,999.99"
			nLin+=2
			_nTotCx := 0
			_nTotPes := 0
			@nLin,000 PSAY QRY->BM_DESC
			_cGrpAnt 	:= QRY->BM_DESC
			_nTotCx 	+= QRY->QTDCAIXA
			_nTotPes 	+= IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0)
			_nTotGCx 	+= QRY->QTDCAIXA
			_nTotGPes 	+= IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0)
		Endif

		/*If _cGrpAnt <> QRY->BM_DESC
		@nLin,000 PSAY QRY->BM_DESC
		_cGrpAnt := QRY->BM_DESC
		EndIf*/

		@nLin,016 PSAY SubStr(QRY->ZP1_CODPRO,1,6)+"-"+QRY->B1_DESC
		@nLin,084 PSAY QRY->QTDCAIXA Picture "@E 999,999,999.99"
		//@nLin,084 PSAY IIF(_nConv>0,QRY->PESO/_nConv,0) Picture "@E 999,999,999.99"
		//@nLin,099 PSAY QRY->PESO Picture "@E 999,999,999.99"
		@nLin,099 PSAY IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0) Picture "@E 999,999,999.99"

		_cExcel += AllTrim(QRY->BM_DESC)+";"+AllTrim(QRY->ZP1_CODPRO)+";"+AllTrim(QRY->B1_DESC)+";"+AllTrim(Transform(QRY->QTDCAIXA,"@E 999,999,999.99"))+";"+AllTrim(Transform(IIF(_nConv>0,QRY->QTDCAIXA*_nConv,0),"@E 999,999,999.99"))+CHR(13)+CHR(10)
		nLin++
		_lPrimLn:=.F.

		QRY->(dbSkip())

	EndDo

	//If _lPrimLn
	@nLin,000 PSAY _cGrpAnt+" TOTAL"
	@nLin,084 PSAY _nTotCx Picture "@E 999,999,999.99"
	@nLin,099 PSAY _nTotPes Picture "@E 999,999,999.99"
	nLin+=2
	_nTotCx := 0
	_nTotPes := 0
	@nLin,000 PSAY "TOTAL GERAL"
	@nLin,084 PSAY _nTotGCx Picture "@E 999,999,999.99"
	@nLin,099 PSAY _nTotGPes Picture "@E 999,999,999.99"
	//Endif

	If Len(AllTrim(MV_PAR07)) > 0
		MemoWrite(AllTrim(MV_PAR07),_cExcel)
	EndIf

	QRY->(dbCloseArea())

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
