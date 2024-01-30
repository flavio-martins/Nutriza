#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
User Function PCP027
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Itens Expedidos na Carga"
	Local cPict          := ""
	Local titulo       := "Itens Expedidos na Carga"
	Local nLin         := 80
	Local Cabec1       := "Identificação     Nº Carga  Placa     Transportador                             Data Carga Cód. Produto    Descrição do Produto                                         Data Produção"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 220
	Private tamanho          := "G"
	Private nomeprog         := FunName()
	Private nTipo            := 15
	Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := nomeprog
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := nomeprog
	Private cString := "ZP1"

	dbSelectArea("ZP1")
	dbSetOrder(1)

	putSx1(cPerg,"01","Carga ?        ","."     ,"."       ,"mv_ch1","C",06,0,0,"G","","DAK","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Caminho Excel ?","."     ,"."       ,"mv_ch2","C",99,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")

	pergunte(cPerg,.F.)

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

	_cQry := " SELECT ZP1_CODETI, ZP1_CARGA, DA3.DA3_PLACA, ISNULL(A2_NOME,'') A2_NOME, DAK_DATA, ZP1_CODPRO, B1_DESC, ZP1.ZP1_DTPROD, ZP1_PESO"
	_cQry += " FROM "+RetSqlName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSqlName("DAK")+" DAK ON DAK.D_E_L_E_T_ = ' ' AND DAK_FILIAL = ZP1_FILIAL AND DAK_COD = ZP1_CARGA"
	_cQry += " INNER JOIN "+RetSqlName("DA3")+" DA3 ON DA3.D_E_L_E_T_ = ' ' AND DA3.DA3_FILIAL = '"+xFilial("DA3")+"' AND DA3.DA3_COD = DAK.DAK_CAMINH"
	_cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = DA3.DA3_XCODTR"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CARGA = '"+MV_PAR01+"'"
	_cQry += " ORDER BY 1"
	TcQuery _cQry New Alias "QRY"
	SetRegua(RecCount())

	_nTotPeso := 0
	_nTotCaixa := 0
	_cExcel := "Identificação;Nº Carga;Placa;Transportador;Data Carga;Cód. Produto;Descrição do Produto;Data Produção"+Chr(10)
	QRY->(dbGoTop())
	While !QRY->(EOF())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		_nTotCaixa ++
		_nTotPeso += ZP1_PESO

		@nLin,000 PSAY QRY->ZP1_CODETI
		@nLin,018 PSAY QRY->ZP1_CARGA
		@nLin,028 PSAY QRY->DA3_PLACA
		@nLin,038 PSAY QRY->A2_NOME
		@nLin,080 PSAY DToC(SToD(QRY->DAK_DATA))
		@nLin,091 PSAY QRY->ZP1_CODPRO
		@nLin,107 PSAY QRY->B1_DESC
		@nLin,168 PSAY DToC(SToD(QRY->ZP1_DTPROD))
		nLin++

		_cExcel += QRY->ZP1_CODETI+";"
		_cExcel += QRY->ZP1_CARGA+";"
		_cExcel += QRY->DA3_PLACA+";"
		_cExcel += QRY->A2_NOME+";"
		_cExcel += DToC(SToD(QRY->DAK_DATA))+";"
		_cExcel += QRY->ZP1_CODPRO+";"
		_cExcel += QRY->B1_DESC+";"
		_cExcel += DToC(SToD(QRY->ZP1_DTPROD))+";"
		_cExcel += Chr(10)

		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())
	@nLin,000 PSAY "Total Caixas: "+Transform(_nTotCaixa,"@E 999,999,999.99")+"   Peso Total: "+Transform(_nTotPeso,"@E 999,999,999.99")

	If Len(AllTrim(MV_PAR02)) > 0
		MemoWrite(AllTrim(MV_PAR02),_cExcel)
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
Identificação     Nº Carga  Placa     Transportador                             Data Carga Cód. Produto    Descrição do Produto                                         Data Produção
XXXXXXXXXXXXXXXX  XXXXXX    XXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999 XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/99
*/
