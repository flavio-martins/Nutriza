#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#define DS_MODALFRAME   128

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP030()	 ºAutor  ³Evandro Gomes    º Data ³ 02/05/13   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relat—rio de estoque por data							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP030()
	Private LF := chr(13)+chr(10)
	If MsgBox("Deseja Imprimir personalizado?","Atenção","YESNO")
		U_PCP030RT()
	Else
		U_PCP030RO()
	Endif
Return

User Function PCP030RT()
	Local oReport
	Private nPosLf		:= 0
	Private cTitulo		:= "Produtos em Estoque"
	Private cNomeProg	:= FunName()
	Private _nOpca		:= 0
	Private aCabWzd		:= {}
	Private aIteWzd		:= {}
	Private oFld008
	Private aHeader		:= {}
	Private aCols		:= {}
	Private noBrw		:= 0
	Private cPerg		:= Padr(cNomeProg+"P",10)
	Private aEntid		:= {}
	Private aWBrw009	:= {}
	Private aCampRel	:= {}
	Private lAssina1	:= .F.
	Private LF := chr(13)+chr(10)

	PCP030Z(cPerg)
	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	oReport:=PCP030A(oReport)
	oReport:PrintDialog()

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Preparando relatório
*/
Static Function PCP030A(oReport)

	oReport:=TReport():New(cPerg, cTitulo, cPerg, {|oReport| PCP030B(oReport) },cTitulo)
	oReport:SetPortraid(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()

Return(oReport)

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Imprime Relatório
*/
Static Function PCP030B(oReport)
	Local _cAlias030	:= GetNextAlias()
	Local oBreak
	Local oFunction
	Local _cQry
	Local oSection1
	Local oSection2
	Local _cGrpAnt:= ""
	LocaL _nRegs		:= 0
	Private LF := chr(13)+chr(10)

	If MV_PAR05==1 // -> Analitico
		oSection1:= TRSection():New(oReport,Iif(MV_PAR05==1,"Sintetico","Analitico"),{""})
		TRCell():New(oSection1,"A","SBM",OemToAnsi("Grupo"),PesqPict('SBM',"BM_GRUPO"),TamSX3("BM_GRUPO")[1]+1)
		TRCell():New(oSection1,"B","SBM",OemToAnsi("Descricao"),PesqPict('SBM',"BM_DESC"),TamSX3("BM_DESC")[1]+1)
		TRCell():New(oSection1,"C","SB1",OemToAnsi("Produto"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection1,"D","SB1",OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"E","SB1",OemToAnsi("Qtd. Caixa"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
		TRCell():New(oSection1,"F","SB1",OemToAnsi("Peso Liq."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	Else
		oSection1:= TRSection():New(oReport,Iif(MV_PAR05==1,"Sintetico","Analitico"),{""})
		TRCell():New(oSection1,"A","SBM",OemToAnsi("Grupo"),PesqPict('SBM',"BM_GRUPO"),TamSX3("BM_GRUPO")[1]+1)
		TRCell():New(oSection1,"B","SBM",OemToAnsi("Descricao"),PesqPict('SBM',"BM_DESC"),TamSX3("BM_DESC")[1]+1)
		oSection2:= TRSection():New(oSection1,Iif(MV_PAR05==1,"Sintetico","Analitico"),{""})
		TRCell():New(oSection2,"A","SB1",OemToAnsi("Produto"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection2,"B","SB1",OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection2,"C","SB1",OemToAnsi("Dt.Prod."),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+5)
		TRCell():New(oSection2,"D","SB1",OemToAnsi("Dt.Valid."),PesqPict('ZP1',"ZP1_DTVALI"),TamSX3("ZP1_DTVALI")[1]+5)
		TRCell():New(oSection2,"E","SB1",OemToAnsi("Qtd. Caixa"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
		TRCell():New(oSection2,"F","SB1",OemToAnsi("Peso Liq."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
		TRCell():New(oSection2,"G","SB1",OemToAnsi("% Vida util"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	Endif

	_cQry := " SELECT " + lf
	_cQry += "BM.BM_GRUPO BM_GRUPO, BM.BM_DESC AS BM_DESC, B1.B1_COD AS B1_COD, B1.B1_DESC AS B1_DESC " + lf
	If MV_PAR05==2 //->Sintético
		_cQry += ",ZP1_DTPROD AS DTPROD, ZP1_DTVALI AS DTVALI " + lf
	Endif
	_cQry += ", COUNT(ZP1.ZP1_CODETI) AS CAIXAS, SUM(ZP1.ZP1_PESO) AS PESO,  " + lf
	_cQry += " ROUND(((DATEDIFF(DAY,  CAST(ZP1_DTPROD AS SMALLDATETIME) , GETDATE()))/ B1.B1_PRVALID)*100,0,0) INDICE" + lf
	_cQry += " FROM "+RetSQLName("SBM")+" BM " + lf
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" B1 " + lf
	_cQry += " ON BM.BM_GRUPO = B1.B1_GRUPO " + lf
	_cQry += " AND B1.B1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + lf
	_cQry += " INNER JOIN "+RetSQLName("ZP1")+" ZP1 " + lf
	_cQry += " ON ZP1.ZP1_CODPRO = B1.B1_COD " + lf
	_cQry += " AND ZP1.ZP1_STATUS IN ('1','2','3','7','9') " + lf
	_cQry += " AND ZP1.ZP1_CARGA = '' " + lf
	_cQry += " AND ZP1.D_E_L_E_T_ = '' " + lf
	_cQry += " WHERE " + lf
	_cQry += " BM.D_E_L_E_T_ = '' " + lf
	_cQry += " AND BM.BM_FILIAL = '0101' " + lf
	_cQry += " AND BM.BM_GRUPO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + lf
	
	_cQry += " GROUP BY BM.BM_GRUPO,  BM.BM_DESC, B1.B1_COD , B1.B1_DESC, ROUND(((DATEDIFF(DAY,  CAST(ZP1_DTPROD AS SMALLDATETIME) , GETDATE()))/ B1.B1_PRVALID)*100,0,0) " + lf
	
	If MV_PAR05==2 //->SINTETICO 
		_cQry += " , ZP1_DTPROD , ZP1_DTVALI " + lf
	Endif
	
	_cQry += " ORDER BY  BM.BM_DESC, B1.B1_COD , B1.B1_DESC,ROUND(((DATEDIFF(DAY,  CAST(ZP1_DTPROD AS SMALLDATETIME) , GETDATE()))/ B1.B1_PRVALID)*100,0,0) DESC" + lf
	//If MV_PAR05==1 //->SINTETICO
	//	_cQry += " , cast(ZP1.ZP1_DTPROD as date)  " + lf
	//Endif

	//	_cQry:=ChangeQuery(_cQry)

	MemoWrite("C:\Temp\"+funname()+"_A.sql",_cQry)
	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),_cAlias030,.F.,.T.)
	_nRegs:=Contar(_cAlias030,"!EOF()")
	(_cAlias030)->(dbGoTop())
	oReport:SetMeter(_nRegs)

	oSection1:Init()

	If MV_PAR05==2 //->Sintético
		oSection2:Init()
	Endif

	While !(_cAlias030)->(Eof())

		If oReport:Cancel() //->Cancelar
			Exit
		EndIf

		oReport:IncMeter()

		If MV_PAR05==1 //->Analitico
			oSection1:Cell("A"):SetValue((_cAlias030)->BM_GRUPO)
			oSection1:Cell("B"):SetValue((_cAlias030)->BM_DESC)
			oSection1:Cell("C"):SetValue((_cAlias030)->B1_COD)
			oSection1:Cell("D"):SetValue((_cAlias030)->B1_DESC)
			oSection1:Cell("E"):SetValue((_cAlias030)->CAIXAS)
			oSection1:Cell("F"):SetValue((_cAlias030)->PESO)
			oSection1:Printline()
		Else
			If AllTrim(_cGrpAnt) <> Alltrim((_cAlias030)->BM_GRUPO)
				_cGrpAnt:=Alltrim((_cAlias030)->BM_GRUPO)
				oSection1:Cell("A"):SetValue((_cAlias030)->BM_GRUPO)
				oSection1:Cell("B"):SetValue((_cAlias030)->BM_DESC)
				oSection1:Printline()
			Endif
			oSection2:Cell("A"):SetValue((_cAlias030)->B1_COD)
			oSection2:Cell("B"):SetValue((_cAlias030)->B1_DESC)
			oSection2:Cell("C"):SetValue(STOD((_cAlias030)->DTPROD))
			oSection2:Cell("D"):SetValue(STOD((_cAlias030)->DTVALI))
			oSection2:Cell("E"):SetValue((_cAlias030)->CAIXAS)
			oSection2:Cell("F"):SetValue((_cAlias030)->PESO)
			oSection2:Cell("G"):SetValue((_cAlias030)->INDICE)
			oSection2:Printline()
			//	oBreak := TRBreak():New(oSection2,oSection2:Cell("A"),,.F.)
		//TRFunction():New(oSection2:Cell("A"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("A"):GETVALUE(),PesqPict('ZP1',"ZP1_PESO"),,.F.,.F.)
	
		Endif

		(_cAlias030)->(dbSkip())
	Enddo

	(_cAlias030)->(dbCloseArea())
	If File(_cAlias030+GetDBExtension())
		fErase(_cAlias030+GetDBExtension())
	Endif

	oSection1:Finish() //-> Finaliza a Secao 1
	If MV_PAR05==2 //->Sintético
		oSection2:Finish() //-> Finaliza a Secao 2
	Endif
Return(oReport)



/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Cria Perguntas
*/
Static Function PCP030Z(cPerg)
	Local aPrgBlq := {}

	U_OHFUNAP3(cPerg,"01","Grupo de?   		","","","mv_cx1","C",TamSx3("BM_GRUPO")[1],TamSx3("BM_GRUPO")[2],0,"G","","SBM","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Grupo Ate ?   	","","","mv_cx2","C",TamSx3("BM_GRUPO")[1],TamSx3("BM_GRUPO")[2],0,"G","","SBM","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Produto de?   	","","","mv_cx3","C",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],0,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Produto Ate ?   ","","","mv_cx4","C",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],0,"G","","SB1","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Layout?			","","","mv_cx5","N",1,0,1,"C","","","","","MV_PAR05","Analitico","","","","Sintetico","","","","","","","","","","","","","","")

Return


/* SETPRINT  */
User Function PCP030RO()

	Local cDesc1      	  := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2     	  := "de acordo com os parametros informados pelo usuario."
	Local cDesc3     	  := "Apontamentos da Produção"
	Local cPict      	  := ""
	Local titulo     	  := "Produtos em estoque"
	Local nLin       	  := 80

	Local Cabec2     	  := ""
	Local imprime      	  := .T.
	Local aOrd			  := {}	
	Local Cabec1     	  := "    Produto                                                               Dt. Producao   Dt. Validade  Qtd. Caixas   Peso Liquido"
	Private lEnd          := .F.
	Private lAbortPrint   := .F.
	Private CbTxt         := ""
	Private limite        := 132
	Private tamanho       := "M"
	Private nomeprog      := FunName()
	Private nTipo         := 15
	Private aReturn       := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey      := 0
	Private cPerg         := nomeprog+"A"
	Private cbtxt      	  := Space(10)
	Private cbcont        := 00
	Private CONTFL        := 01
	Private m_pag         := 01
	Private wnrel         := nomeprog

	Private cString := "ZP1"

	//	dbSelectArea("ZP1")
	//	dbSetOrder(1)

	putSx1(cPerg,"01","Produto de ?","."     ,"."       ,"mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Produto ate?","."     ,"."       ,"mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"03","Arquivo Excel (.CSV)?  ","."     ,"."       ,"mv_ch3","C",99,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")

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

	_cQry := " SELECT BM.BM_DESC AS BM_DESC, B1.B1_COD AS B1_COD, B1.B1_DESC AS B1_DESC," + lf
	_cQry += " cast(ZP1.ZP1_DTPROD as date) AS ZP1_DTPROD, cast(ZP1.ZP1_DTVALI as date) AS ZP1_DTVALI," + lf
	_cQry += " COUNT(ZP1.ZP1_CODETI) AS CAIXAS, SUM(ZP1.ZP1_PESO) AS PESO,  " + lf
	_cQry += " ROUND(((DATEDIFF(DAY,  CAST(ZP1_DTPROD AS SMALLDATETIME) , GETDATE()))/ B1.B1_PRVALID)*100,0,0) INDICE"
	_cQry += " 	FROM " + lf
	_cQry +=	+RetSQLName("ZP1")+" ZP1, " + lf
	_cQry +=	+RetSQLName("SB1")+" B1, " + lf
	_cQry +=	+RetSQLName("SBM")+" BM "	 + lf
	_cQry += " 	WHERE ZP1.D_E_L_E_T_ = '' " + lf
	_cQry += "	AND ZP1.ZP1_STATUS IN ('1','2','3','7','9') "  + lf
	_cQry += " 	AND ZP1.ZP1_CARGA = '' " + lf
	_cQry += " 	AND ZP1.ZP1_CODPRO = B1.B1_COD " + lf
	_cQry += "  AND BM.D_E_L_E_T_ = '' " + lf
	_cQry += "  AND BM.BM_FILIAL = '0101' " + lf
	_cQry += "  AND BM.BM_GRUPO = B1.B1_GRUPO " + lf
	_cQry += " 	GROUP BY  BM.BM_DESC, B1.B1_COD , B1.B1_DESC , cast(ZP1.ZP1_DTPROD as date) , cast(ZP1.ZP1_DTVALI as date),ROUND(((DATEDIFF(DAY,  CAST(ZP1_DTPROD AS SMALLDATETIME) , GETDATE()))/ B1.B1_PRVALID)*100,0,0) " + lf
	_cQry += " 	ORDER BY  BM.BM_DESC, B1.B1_COD , B1.B1_DESC , cast(ZP1.ZP1_DTPROD as date)  " + lf

	MemoWrite("C:\Temp\"+funname()+"_B.sql",_cQry)

	TcQuery _cQry New Alias "QRY"

	_cGrpAnt	:= ""
	_nTotCx 	:= 0
	_nTotPes 	:= 0
	_nTotGCx 	:= 0
	_nTotGPes 	:= 0
	_cExcel 	:= "Grupo;Produto;Descricao;Dt Producao;Dt Validade;Qtd. Caixas;Peso Liquido;Vida Util"+CHR(13)+CHR(10)

	//Cabec1       := ''//"Data: " +DToC(MV_PAR01)+ " a " +DToC(MV_PAR01)+"  -  Turno: "+MV_PAR05+" ate "+MV_PAR06

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
			nlin+=1
			_cGrpAnt := QRY->BM_DESC
		EndIf

		@nLin,005 PSAY SubStr(QRY->B1_COD,1,6) +"-"+ QRY->B1_DESC
		@nLin,075 PSAY (QRY->ZP1_DTPROD)
		@nLin,090 PSAY (QRY->ZP1_DTVALI)
		@nLin,100 PSAY QRY->CAIXAS Picture "@E 999,999,999"
		@nLin,115 PSAY QRY->PESO Picture "@E 999,999,999.99"

		_cData := CTOD(substr(QRY->ZP1_DTPROD,9,2) +"/"+ substr(QRY->ZP1_DTPROD,6,2)+"/"+substr(QRY->ZP1_DTPROD,1,4))
		_cData1 := CTOD(substr(QRY->ZP1_DTVALI,9,2) +"/"+ substr(QRY->ZP1_DTVALI,6,2)+"/"+substr(QRY->ZP1_DTVALI,1,4))

		//Alert(_cData)
		_cExcel += AllTrim(QRY->BM_DESC)+";"+AllTrim(QRY->B1_COD)+";"+AllTrim(QRY->B1_DESC)+";"+  DTOC(_cData) +";" + DTOC(_cData1) + ";"+AllTrim(Transform(QRY->CAIXAS,"@E 999,999,999"))+";"+AllTrim(Transform(QRY->PESO,"@E 999,999,999.99")) +";" + cValToChar(QRY->INDICE) + CHR(13)+CHR(10)

		nLin++

		_nTotCx += QRY->CAIXAS
		_nTotPes += QRY->PESO

		_nTotGCx += QRY->CAIXAS
		_nTotGPes += QRY->PESO

		QRY->(dbSkip())

		If _cGrpAnt <> QRY->BM_DESC
			@nLin,000 PSAY _cGrpAnt+" TOTAL"
			@nLin,100 PSAY _nTotCx Picture "@E 999,999,999.99"
			@nLin,115 PSAY _nTotPes Picture "@E 999,999,999.99"
			nLin+=2
			_nTotCx := 0
			_nTotPes := 0
		EndIf

	EndDo
	@nLin,000 PSAY "TOTAL GERAL"
	@nLin,100 PSAY _nTotGCx Picture "@E 999,999,999.99"
	@nLin,115 PSAY _nTotGPes Picture "@E 999,999,999.99"

	If Len(AllTrim(MV_PAR03)) > 0
		MemoWrite(AllTrim(MV_PAR03),_cExcel)
	EndIf

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
"    Produto                                                               Dt. Producao   Dt. Validade  Qtd. Caixas   Peso Liquido"
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
