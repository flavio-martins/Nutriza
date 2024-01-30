#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function PCP022
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatório de Expedicão de Carga"
	Local cPict        	:= ""
	Local titulo       	:= "Relatório de Expedicão de Carga"
	Local nLin         	:= 80
	Local Cabec1       	:= ""
	Local Cabec2       	:= "Código Descricao do Produto                                         Qtde. Caixas Peso Expedição    Peso Bruto"
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
	Private cPerg       	:= nomeprog
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= nomeprog

	Private cString := "DAK"

	dbSelectArea("DAK")
	dbSetOrder(1)

	putSx1(cPerg,"01","Carga  ?","."     ,"."       ,"mv_ch1","C",06,0,0,"G","","DAK","","","mv_par01","","","","","","","","","","","","","","","","")

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

	DAK->(dbSetOrder(1))

	//0=Aberta;1=Bloqueada;2=Expedicao;3=Apta a faturar;4=Faturada

	_cQry := " SELECT ZP1_CODPRO, B1_DESC , COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " , ROUND(SUM(ZP1_PESO*CASE WHEN SB1.B1_XPESROM > 0 THEN B1_XPESROM ELSE 1 END),2) PESOB"
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("DAK")+" DAK ON DAK.D_E_L_E_T_ = ' ' AND DAK_FILIAL = ZP1_FILIAL AND DAK_COD = ZP1_CARGA"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CARGA <> ''"
	_cQry += " AND DAK.DAK_XBLQCP IN ('3','4')"
	_cQry += " AND DAK_COD  = '"+MV_PAR01+"'"
	_cQry += " GROUP BY ZP1_CODPRO, B1_DESC"
	_cQry += " UNION ALL"
	_cQry += " SELECT ZP1_CODPRO, B1_DESC , COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " , ROUND(SUM(ZP1_PESO*CASE WHEN SB1.B1_XPESROM > 0 THEN B1_XPESROM ELSE 1 END),2) PESOB"
	_cQry += " FROM ZP1010_MORTO A"
	_cQry += " INNER JOIN "+RetSQLName("DAK")+" DAK ON DAK.D_E_L_E_T_ = ' ' AND DAK_FILIAL = ZP1_FILIAL AND DAK_COD = ZP1_CARGA"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " WHERE A.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_CARGA <> ''"
	_cQry += " AND DAK.DAK_XBLQCP IN ('3','4')"
	_cQry += " AND DAK_COD  = '"+MV_PAR01+"'"
	_cQry += " GROUP BY ZP1_CODPRO, B1_DESC"
	_cQry += " ORDER BY 1,2"

	MemoWrite("C:\TEMP\PCP022.SQL",_cQry)

	TcQuery _cQry New Alias "QRYC"
	dbGoTop()
	SetRegua(RecCount())

	aTot := {0,0,0}

	If DAK->(dbSeek(xFilial()+MV_PAR01)) .AND. !QRYC->(EOF())
		Cabec1 := "Carga N.: "+DAK->DAK_COD+" Data Expedição: "+DToC(DAK->DAK_XDTFEC)+" Veículo: "+If(Len(AllTrim(DAK->DAK_CAMINH))>0,Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_PLACA"),"")
		While !QRYC->(EOF())

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nLin > 70
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@nLin,000 PSAY SubStr(QRYC->ZP1_CODPRO,1,5)
			@nLin,007 PSAY SubStr(QRYC->B1_DESC,1,60)
			@nLin,069 PSAY QRYC->QTDCAIXA Picture "@E 99,999,999.99"
			@nLin,082 PSAY QRYC->PESO Picture "@E 99,999,999.99"
			@nLin,096 PSAY QRYC->PESOB Picture "@E 99,999,999.99"

			aTot[1] += QRYC->QTDCAIXA
			aTot[2] += QRYC->PESO
			aTot[3] += QRYC->PESOB

			nLin++

			QRYC->(dbSkip())
		EndDo
		@nLin,060 PSAY "TOTAIS:"
		@nLin,069 PSAY aTot[1] Picture "@E 99,999,999.99"
		@nLin,082 PSAY aTot[2] Picture "@E 99,999,999.99"
		@nLin,096 PSAY aTot[3] Picture "@E 99,999,999.99"
		nLin+=2

		@nLin,000 PSAY "+---------------------------------------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "|                                               Dados do Carregamento                                           |";nLin++
		@nLin,000 PSAY "+---------------------------------------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "|N. do Lacre                                                        Início Expedição       Final Expedição      |";nLin++
		@nLin,000 PSAY "+---------------------------------------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "|"+Pad(SubStr(DAK->DAK_XLACRE,1,60),60)+"       "+DToC(DAK->DAK_XDTABE)+" "+DAK->DAK_XHRABE+"  "+DToC(DAK->DAK_XDTFEC)+" "+DAK->DAK_XHRFEC+"    |";nLin++
		@nLin,000 PSAY "+---------------------------------------------------------------------------------------------------------------+";nLin+=2

		@nLin,000 PSAY "               +------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "               |                     Dados da Pesagem Balança Rodoviaria                      |";nLin++
		@nLin,000 PSAY "               +------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "               |   Pesagem Inicial |   Pesagem Final  | Peso Líquido Balança | Diferença Peso |";nLin++
		@nLin,000 PSAY "               +------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "               |     "+TransForm(DAK->DAK_XPESEN,"@E 99,999,999.99")+" |   "+TransForm(DAK->DAK_XPESSA,"@E 99,999,999.99")+"  |        "+TransForm(DAK->DAK_XPESSA-DAK->DAK_XPESEN,"@E 99,999,999.99")+" |  "+TransForm((DAK->DAK_XPESSA-DAK->DAK_XPESEN)-aTot[3],"@E 99,999,999.99")+" |";nLin++
		@nLin,000 PSAY "               +------------------------------------------------------------------------------+";nLin+=2

		@nLin,000 PSAY "       +-------------------------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "       |Motorista                      | Expedidor Abriu Carga          | Expedidor Fechou Carga         |";nLin++
		@nLin,000 PSAY "       +-------------------------------------------------------------------------------------------------+";nLin++
		@nLin,000 PSAY "       |"+Pad(SubStr(If(Len(AllTrim(DAK->DAK_MOTORI))>0,Posicione("DA4",1,xFilial("DA4")+DAK->DAK_MOTORI,"DA4_NOME"),""),1,30),30)+" | "+Pad(SubStr(DAK->DAK_XUSABE,1,30),30)+" | "+Pad(SubStr(DAK->DAK_XUSFEC,1,30),30)+" |";nLin++
		@nLin,000 PSAY "       +----------------------------------------------------------------+--------------------------------+";nLin+=4

		@nLin,000 PSAY "                 ----------------------------------------     ----------------------------------------";nLin++
		@nLin,000 PSAY "                          Assinatura Motorista                          Assinatura Expedidor";nLin++


	EndIf
	QRYC->(dbCloseArea())
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
Carga N.: XXXXXX Data Expedição: 99/99/9999 Veículo: XXX9999
Código Descricao do Produto                                         Qtde. Caixas Peso Expedição    Peso Bruto
------------------------------------------------------------------------------------------------------------------------------------
XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999  99,999,999.99 99,999,999.99
XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999  99,999,999.99 99,999,999.99
XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999  99,999,999.99 99,999,999.99
XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999  99,999,999.99 99,999,999.99
.                                                           TOTAIS:  999,999,999  99,999,999.99 99,999,999.99


+---------------------------------------------------------------------------------------------------------------+
|                                               Dados do Carregamento                                           |
+---------------------------------------------------------------------------------------------------------------+
|N. do Lacre                                                        Início Expedição       Final Expedição      |
+---------------------------------------------------------------------------------------------------------------+
|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       99/99/9999 - 99:99:99  99/99/9999 - 99:99:99|
+---------------------------------------------------------------------------------------------------------------+

.              +------------------------------------------------------------------------------+
.              |                     Dados da Pesagem Balança Rodoviaria                      |
.              +------------------------------------------------------------------------------+
.              |   Pesagem Inicial |   Pesagem Final  | Peso Líquido Balança | Diferença Peso |
.              +------------------------------------------------------------------------------+
.              |     99,999,999.99 |   99,999,999.99  |        99,999,999.99 |  99,999,999.99 |
.              +------------------------------------------------------------------------------+

.      +-------------------------------------------------------------------------------------------------+
.      |Motorista                      | Expedidor Abriu Carga          | Expedidor Fechou Carga         |
.      +-------------------------------------------------------------------------------------------------+
.      |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
.      +----------------------------------------------------------------+--------------------------------+




.                ----------------------------------------     ----------------------------------------
.                         Assinatura Motorista                          Assinatura Expedidor


*/
