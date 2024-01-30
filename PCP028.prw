#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function PCP028()
	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Registro de Pendura"
	Local cPict        	:= ""
	Local titulo       	:= "Registro de Pendura"
	Local nLin         	:= 80
	Local Cabec1       	:= "Tempo de Tempo de   Qtde.     Animais Mortalidade Peso Medio Integrado                                Lote                  Animais"
	Local Cabec2       	:= "Percurso Espera     Cabecas    Mortos              /Cabeca                                                                  Abatidos"
	Local imprime      	:= .T.
	Local aOrd				:= {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := FunName()
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg       	:= nomeprog
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= nomeprog
	Private cString 		:= "ZP0"

	dbSelectArea("ZP0")
	dbSetOrder(1)

	putSx1(cPerg,"01","Do Fornecedor ?    ","."     ,"."       ,"mv_ch1","C",06,0,0,"G","","SA2","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Da Loja ?          ","."     ,"."       ,"mv_ch2","C",03,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"03","Ate Fornecedor ?   ","."     ,"."       ,"mv_ch3","C",06,0,0,"G","","SA2","","","mv_par03","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"04","Ate Loja ?         ","."     ,"."       ,"mv_ch4","C",03,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"05","Da Data Saida ?    ","."     ,"."       ,"mv_ch5","D",08,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"06","Ate Data Saida ?   ","."     ,"."       ,"mv_ch6","D",08,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"07","Da Data Pesagem ?  ","."     ,"."       ,"mv_ch7","D",08,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"08","Ate Data Pesagem ? ","."     ,"."       ,"mv_ch8","D",08,0,0,"G","","   ","","","mv_par08","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"09","Da Data Pendura ?  ","."     ,"."       ,"mv_ch9","D",08,0,0,"G","","   ","","","mv_par09","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"10","Ate Data Pendura ? ","."     ,"."       ,"mv_cha","D",08,0,0,"G","","   ","","","mv_par10","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"11","Caminho Excel ?    ","."     ,"."       ,"mv_chb","C",99,0,0,"G","","   ","","","mv_par11","","","","","","","","","","","","","","","","")

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

	_cQry := " SELECT"
	_cQry += " REPLACE(RTRIM(CAST(DATEDIFF(mi,DTHRSAIDA,DTHRPES)/60 AS CHAR(5))),'-','')+':'+"
	_cQry += " REPLICATE('0',2-LEN(REPLACE(CAST(DATEDIFF(mi,DTHRSAIDA,DTHRPES)-((DATEDIFF(mi,DTHRSAIDA,DTHRPES)/60)*60) AS CHAR(3)),'-','')))+"
	_cQry += " REPLACE(CAST(DATEDIFF(mi,DTHRSAIDA,DTHRPES)-((DATEDIFF(mi,DTHRSAIDA,DTHRPES)/60)*60) AS CHAR(3)),'-','') PERCUR"
	_cQry += " ,REPLACE(RTRIM(CAST(DATEDIFF(mi,DTHRPES,DTHRPEN)/60 AS CHAR(5))),'-','')+':'+"
	_cQry += " REPLICATE('0',2-LEN(REPLACE(CAST(DATEDIFF(mi,DTHRPES,DTHRPEN)-((DATEDIFF(mi,DTHRPES,DTHRPEN)/60)*60) AS CHAR(3)),'-','')))+"
	_cQry += " REPLACE(CAST(DATEDIFF(mi,DTHRPES,DTHRPEN)-((DATEDIFF(mi,DTHRPES,DTHRPEN)/60)*60) AS CHAR(3)),'-','') ESPERA"
	_cQry += " ,ZP0_TOTANI+ZP0_ANIMOR TOTANI"
	_cQry += " ,ZP0_ANIMOR ANIMOR"
	_cQry += " ,ROUND((ZP0_ANIMOR/(ZP0_TOTANI+ZP0_ANIMOR))*100,2) TAXAMOR"
	_cQry += " ,ROUND(ZP0_PESOL/(ZP0_TOTANI+ZP0_ANIMOR),2) PESMED"
	_cQry += " ,A2_NOME INTEGRADO"
	_cQry += " ,ZP0_LOTECO LOTE"
	_cQry += " ,ZP0_TOTANI ANIABA"
	_cQry += " FROM ("
	_cQry += " 	SELECT"
	_cQry += " 	CAST(ZP0_DTSAID+' '+SUBSTRING(ZP0_HRSAID,1,2)+':'+SUBSTRING(ZP0_HRSAID,3,2) AS SMALLDATETIME) DTHRSAIDA"
	_cQry += " 	,CAST(ZP0_DTPESB+' '+ZP0_HRPESB AS SMALLDATETIME) DTHRPES"
	_cQry += " 	,CAST(ZP0_DINIPE+' '+SUBSTRING(ZP0_HINIPE,1,2)+':'+SUBSTRING(ZP0_HINIPE,3,2) AS SMALLDATETIME) DTHRPEN"
	_cQry += " 	, ZP0.ZP0_TOTANI, ZP0.ZP0_ANIMOR"
	_cQry += " 	, ZP0.ZP0_PESOL"
	_cQry += " 	, A2_NOME"
	_cQry += " 	, ZP0.ZP0_LOTECO"
	_cQry += " 	FROM "+RetSQLName("ZP0")+" ZP0"
	_cQry += " 	INNER JOIN "+RetSQLName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = ZP0_FORNEC AND A2_LOJA = ZP0_LOJA"
	_cQry += " 	WHERE ZP0.D_E_L_E_T_ = ''"
	_cQry += " 	AND ZP0_FILIAL = '"+xFilial("ZP0")+"'"
	_cQry += " 	AND ZP0.ZP0_DINIPE <> ''"
	_cQry += " 	AND ZP0.ZP0_HINIPE <> ''"
	_cQry += " 	AND ZP0_TOTANI+ZP0_ANIMOR > 0"
	_cQry += " 	AND ZP0_FORNEC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"'"
	_cQry += " 	AND ZP0_LOJA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND ZP0_DTSAID BETWEEN '"+DToS(MV_PAR05)+"' AND '"+DToS(MV_PAR06)+"'"
	_cQry += " 	AND ZP0_DTPESB BETWEEN '"+DToS(MV_PAR07)+"' AND '"+DToS(MV_PAR08)+"'"
	_cQry += " 	AND ZP0_DINIPE BETWEEN '"+DToS(MV_PAR09)+"' AND '"+DToS(MV_PAR10)+"'"
	_cQry += " ) A"
	_cQry += " ORDER BY 7,8"
	TcQuery _cQry New Alias "QRYP"

	_nTotCab := 0
	_nTotMor := 0

	SetRegua(RecCount())

	_cExcel := "Tempo de Percurso;Tempo de Espera;Qtde. Cabecas;Animais Mortos;Mortalidade;Peso Medio/Cabeca;Integrado;Lote;Animais Abatidos"+CHR(10)

	dbGoTop()
	While !QRYP->(EOF())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		@nLin,000 PSAY Alltrim(QRYP->PERCUR)
		@nLin,009 PSAY Alltrim(QRYP->ESPERA)
		@nLin,018 PSAY QRYP->TOTANI Picture "@E 9,999,999"
		@nLin,028 PSAY QRYP->ANIMOR Picture "@E 9,999,999"
		@nLin,043 PSAY QRYP->TAXAMOR Picture "@E 999.99"
		@nLin,054 PSAY QRYP->PESMED Picture "@E 999.99"
		@nLin,061 PSAY QRYP->INTEGRADO
		@nLin,102 PSAY QRYP->LOTE
		@nLin,123 PSAY QRYP->ANIABA Picture "@E 9,999,999"

		_nTotCab += QRYP->TOTANI
		_nTotMor += QRYP->ANIMOR

		nLin++

		_cExcel += AllTrim(QRYP->PERCUR)+";"
		_cExcel += AllTrim(QRYP->ESPERA)+";"
		_cExcel += Transform(QRYP->TOTANI,"@E 9,999,999")+";"
		_cExcel += Transform(QRYP->ANIMOR,"@E 9,999,999")+";"
		_cExcel += Transform(QRYP->TAXAMOR,"@E 999.99")+";"
		_cExcel += Transform(QRYP->PESMED,"@E 999.99")+";"
		_cExcel += QRYP->INTEGRADO+";"
		_cExcel += QRYP->LOTE+";"
		_cExcel += Transform(QRYP->ANIABA,"@E 9,999,999")+";"
		_cExcel += CHR(10)
		QRYP->(dbSkip())
	EndDo
	QRYP->(dbCloseArea())

	@nLin,000 PSAY "Total"
	@nLin,018 PSAY _nTotCab Picture "@E 9,999,999"
	@nLin,028 PSAY _nTotMor Picture "@E 9,999,999"
	@nLin,123 PSAY _nTotCab-_nTotMor Picture "@E 9,999,999"

	If Len(AllTrim(MV_PAR11)) > 0
		MemoWrite(AllTrim(MV_PAR11),_cExcel)
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
0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18
*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*123456789*
Tempo de Tempo de   Qtde.     Animais Mortalidade Peso Medio Integrado                                Lote                  Animais
Percurso Espera     Cabecas    Mortos              /Cabeca                                                                  Abatidos
99999:99 99999:99 9,999,999 9,999,999      999.99     999.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9,999,999
Total             9,999,999 9,999,999      999.99     999.99                                                               9,999,999
*/
