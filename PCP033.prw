#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP033() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Relat—rio de Producao (Paletizacao)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Em: 01/11/16                                                            ±±
±± Por: Evandro Gomes                                                      ±±
±± Descricao: Relatorio adaptado para dados do arquivo morto.              ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

*/  
User Function PCP033()

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "Apontamentos da Produção"
	Local cPict        := ""
	Local titulo       := "Apontamentos da Produção (PALETIZAÇÃO)"
	Local nLin         := 80

	Local Cabec1       := ""
	//1234567890123456789012345678901234567890123456789012345678901234567890123456789_01234567890123456789012345678901234567890
	Local Cabec2       := "Grupo                                              Qtd. Caixas    Peso Liquido"
	Local imprime      := .T.
	Local aOrd := {}

	Local lComp             := .T.  

	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 80 //80
	Private tamanho    := "P" //PMG
	Private nomeprog   := FunName()
	Private nTipo      := 15
	Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	//Private areturn    := { "Zebrado", 1,"Administracao", 1, 2, 1, "",2 } 
	Private nLastKey   := 0
	Private cPerg      := "PCP033A"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog

	Private aDriver := {} 

	Private cString := "ZP1"

	dbSelectArea("ZP1")
	dbSetOrder(1)

	putSx1(cPerg,"01","Data de    ?","."     ,"."       ,"mv_ch1","D",08,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Data ate   ?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"03","Produto de ?","."     ,"."       ,"mv_ch3","C",15,0,0,"G","","SB1","","","mv_par03","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"04","Produto ate?","."     ,"."       ,"mv_ch4","C",15,0,0,"G","","SB1","","","mv_par04","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"05","Turno de ?  ","."     ,"."       ,"mv_ch5","C",03,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"06","Turno ate?  ","."     ,"."       ,"mv_ch6","C",03,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"07","Arquivo Excel (.CSV)?  ","."     ,"."       ,"mv_ch7","C",99,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")

	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString) //,,,"P",1)
	aDriver :=ReadDriver() 
	//(aReturncAlias [ uParm3 ] [ lNoAsk ] [ cSize ] [ nFormat ] ) 
	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return
	*************************************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local aDados	:= {}
	Local nPos		:= 0
	Local lImpTot	:= .F.

	SetRegua(RecCount())

	_cQry := " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " 	FROM ("
	_cQry += " 		SELECT"
	_cQry += " 		  ZP1_DTPROD DATAPROD" //->ZP1_DTPROD
	_cQry += " 		, CASE "
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007','1/1','1/2','1/3','5/1','5/2','5/3') THEN '001'" //Inclusão de lotes Wendel 02/07/2019 
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010','3/1','3/2','3/3','240') THEN '002'" //Inclusão de lotes Wendel 02/07/2019
	_cQry += " 		  END TURNO"
	_cQry += " 		, BM_DESC,ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " 		, ZP1_CODETI, ZP1_PESO"
	_cQry += " 		FROM ("
	_cQry += " 			SELECT  ZP1_DTPROD, BM_DESC,ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_LOTE" //->ZP1_DTPROD
	_cQry += " 			, ZP6_HORA"
	_cQry += " 			, ZP1_CODETI, ZP1_PESO"
	_cQry += " 			FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	_cQry += " 			AND (ZP1_STATUS IN ('1','2','3','5','7','9') OR ZP6_HORA IS NOT NULL )" //Wendel Inclusão de status ('2','3','5','7') 27/11/2018
	_cQry += " 			AND ZP1.ZP1_REPROC <> 'S'"
	_cQry += " 			AND ZP1.ZP1_DTATIV <> ''"
	_cQry += " 		) A"
	_cQry += " 	) B"
	_cQry += " 	WHERE DATAPROD BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " UNION ALL "
	_cQry += " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " 	FROM ("
	_cQry += " 		SELECT"
	_cQry += " 		  ZP1_DTPROD DATAPROD" //->ZP1_DTPROD
	_cQry += " 		, CASE "
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007','1/1','1/2','1/3','5/1','5/2','5/3') THEN '001'"
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010','3/1','3/2','3/3','240') THEN '002'"
	_cQry += " 		  END TURNO"
	_cQry += " 		, BM_DESC,ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " 		, ZP1_CODETI, ZP1_PESO"
	_cQry += " 		FROM ("
	_cQry += " 			SELECT  ZP1_DTPROD, BM_DESC,ZP1_CODPRO, B1_DESC, B1_CONV, ZP1_LOTE" //->ZP1_DTPROD
	_cQry += " 			, ZP6_HORA"
	_cQry += " 			, ZP1_CODETI, ZP1_PESO"
	_cQry += " 			FROM ZP1010_MORTO ZP1"
	_cQry += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	_cQry += " 			AND (ZP1_STATUS IN ('1','2','3','5','7','9')  OR ZP6_HORA IS NOT NULL )"  //Wendel Inclusão de status ('2','3','5','7') 27/11/2018
	_cQry += " 			AND ZP1.ZP1_REPROC <> 'S'"
	_cQry += " 			AND ZP1.ZP1_DTATIV <> ''"
	_cQry += " 		) A"
	_cQry += " 	) B"
	_cQry += " 	WHERE DATAPROD BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC, B1_CONV"
	_cQry += " ORDER BY 1,2"

	//MemoWrite("C:\Temp\"+AllTrim(Funname())+".Sql",_cQry)  //Wendel Inclusão para salvar query temporário 27/11/2018

	TcQuery _cQry New Alias "QRY"
	QRY->(dbGoTop())
	aDados:={}
	While !QRY->(EOF())

		_nConv:=0
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+QRY->ZP1_CODPRO))
			_nConv:=SB1->B1_CONV
			_nPeso:=QRY->QTDCAIXA*_nConv
		Endif

		nPos:=aScan(aDados,{|x| AllTrim(x[2]) == AllTrim(QRY->ZP1_CODPRO)})
		If nPos > 0
			aDados[nPos,4]+=QRY->QTDCAIXA
			//aDados[nPos,5]+=QRY->PESO
			aDados[nPos,5]+= _nPeso

		Else
			//AADD(aDados,{QRY->BM_DESC,QRY->ZP1_CODPRO,QRY->B1_DESC,QRY->QTDCAIXA,QRY->PESO})
			AADD(aDados,{QRY->BM_DESC,QRY->ZP1_CODPRO,alltrim(QRY->B1_DESC),QRY->QTDCAIXA,_nPeso})
		Endif
		QRY->(dbSkip())
	Enddo
	QRY->(dbCloseArea()())

	_cGrpAnt := ""
	_nTotCx := 0
	_nTotPes := 0
	_nTotGCx := 0
	_nTotGPes := 0
	_cExcel := "Grupo;Produto;Descricao;Qtd. Caixas;Peso Liquido"+CHR(13)+CHR(10)

	Cabec1       := "Data: "+DToC(MV_PAR01)+" a "+DToC(MV_PAR01)+"  -  Turno: "+ALLtRIM(MV_PAR05)+" ate "+ALLTRIM(MV_PAR06)

	lImpTot:=.T.

	@ nLin++,000 PSAY &(aDriver[2]) 

	For x:=1 To Len(aDados)

		lImpTot	:= .F.

		If nLin > 60
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		If Len(_cGrpAnt) > 0 .And. _cGrpAnt <> aDados[x,1]
			@nLin,000 PSAY _cGrpAnt+" TOTAL"
			@nLin,050 PSAY _nTotCx Picture "@E 999,999,999"
			@nLin,065 PSAY _nTotPes Picture "@E 999,999,999"
			nLin+=2
			_nTotCx := 0
			_nTotPes := 0
			lImpTot:=.T.
		EndIf

		If _cGrpAnt <> aDados[x,1]
			@nLin,000 PSAY aDados[x,1]
			_cGrpAnt := aDados[x,1]
			nLin+=2
		EndIf
		
		If nLin > 60
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		
		@nLin,003 PSAY SubStr(aDados[x,2],1,6)+"-"+SubStr(aDados[x,3],1,40)
		@nLin,050 PSAY aDados[x,4] Picture "@E 999,999,999"
		@nLin,065 PSAY aDados[x,5] Picture "@E 999,999,999"

		_cExcel += AllTrim(aDados[x,1])+";"+AllTrim(aDados[x,2])+";"+AllTrim(aDados[x,3])+";"+AllTrim(Transform(aDados[x,4],"@E 999,999,999.99"))+";"+AllTrim(Transform(aDados[x,5],"@E 999,999,999.99"))+CHR(13)+CHR(10)
		nLin++

		_nTotCx += aDados[x,4]
		_nTotPes += aDados[x,5]

		_nTotGCx += aDados[x,4]
		_nTotGPes += aDados[x,5]



	Next x
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	If !lImpTot
		@nLin,000 PSAY _cGrpAnt+" TOTAL"
		@nLin,050 PSAY _nTotCx Picture "@E 999,999,999"
		@nLin,065 PSAY _nTotPes Picture "@E 999,999,999"
		_nTotCx := 0
		_nTotPes := 0
		nLin+=2
		lImpTot:=.T.
	Endif

    @nlin,000 Psay(replicate("_",80))
    nlin++
	@nLin,000 PSAY "TOTAL GERAL"
	@nLin,050 PSAY _nTotGCx Picture "@E 999,999,999"
	@nLin,065 PSAY _nTotGPes Picture "@E 999,999,999"

	/*
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

	_cExcel += AllTrim(QRY->BM_DESC)+";"+AllTrim(QRY->ZP1_CODPRO)+";"+AllTrim(QRY->B1_DESC)+";"+AllTrim(Transform(QRY->QTDCAIXA,"@E 999,999,999.99"))+";"+AllTrim(Transform(QRY->PESO,"@E 999,999,999.99"))+CHR(13)+CHR(10)
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

	If Len(AllTrim(MV_PAR07)) > 0
	MemoWrite(AllTrim(MV_PAR07),_cExcel)
	EndIf
	QRY->(dbCloseArea()())
	*/

	If Len(AllTrim(MV_PAR07)) > 0
		MemoWrite(AllTrim(MV_PAR07),_cExcel)
	EndIf

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
