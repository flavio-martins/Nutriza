#Include 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCPR001()      ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe relatório de custo fechado de produtos Mês a Mês originados   ³±±
±±³          ³da Tabela SD3. Este programa trata somente Custo do Mês.			  ³±±
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
User Function PCPR001()
	Local wnRel    	:= "PCPR001"	//-> Nome da rotina a ser exibida no relatorio 
	Local cString  	:= ""			//-> Nome da tabela principal do relatorio
	Local cDesc1   	:= ""			//-> Descricao referente a FormBath ou Relatorio
	Local cDesc2   	:= ""			//-> Descricao referente a FormBath ou Relatorio
	Local cDesc3   	:= ""			//-> Descricao referente a FormBath ou Relatorio
	Local cTamanho 	:= "G"			//-> Tamanho a ser considerado no relatorio para dimencionamento das colunas
	Local cTitulo  	:= "Custo de Produtos Mês a Mês" //-> Titulo referente a FormBath ou Relatorio
	Local nOpc     	:= 0			//-> Opcao selecionada pelo usuario na FormBatch
	Local nDias    	:= 0			//-> Quantidade de dias a serem  considerados para apuracao da data inicial e final 
	Local aSay    	:= {}			//-> Array com linhas a serem exibidas na FormBatch
	Local aButton  	:= {}			//-> Array referente aos botoes da FormBatch
	Local Limite   	:= 220
	Private dDatIni  	//-> Data inicial referente a segunda-feira da semana de impressao do relatorio
	Private dDatFim  	//-> Data final referente a sabado da semana de impressao do relatorio
	Private aReturn := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private m_Pag   := 0
	Private nLastKey:= 0
	Private lEnd    := 0
	Private aCabec	:= {}
	Private aDados	:= {}
	Private cPerg    := PADR("PCPR001",10)  	// Nome do pergunte referente ao SX1
	Private aMesAno  := {	"   Janeiro",;
	" Fevereiro",;
	"     Março",;
	"     Abril",;
	"      Maio",;
	"     Junho",;
	"     Julho",;
	"    Agosto",;
	"  Setembro",;
	"   Outubro",;
	"  Novembro",;
	"  Dezembro"}
	Private lNeg	:= .F.

	cTitulo := "Custo de Produto x Mês"
	cDesc1  := "Esta rotina tem como objetivo imprimir o relatório Anual de " 
	cDesc2  := "custo de produto com base na virada mensal, com parâmetros" 
	cDesc3  := "informados pelo uasuário. 

	PUTSX1(cPerg,"01","Filial de       ?","","","MV_CH1","C",04,00,00,"G","","SM0","","S",MV_PAR01)
	PUTSX1(cPerg,"02","Filial Ate      ?","","","MV_CH2","C",04,00,00,"G","","SM0","","S",MV_PAR02)
	PUTSX1(cPerg,"03","Produto de      ?","","","MV_CH3","C",15,00,00,"G","","SB1","","S",MV_PAR03)
	PUTSX1(cPerg,"04","Produto Ate     ?","","","MV_CH4","C",15,00,00,"G","","SB1","","S",MV_PAR04)
	PUTSX1(cPerg,"05","Tipo de         ?","","","MV_CH5","C",02,00,00,"G","","02","","S",MV_PAR05)
	PUTSX1(cPerg,"06","Tipo Ate        ?","","","MV_CH6","C",02,00,00,"G","","02","","S",MV_PAR06)
	PUTSX1(cPerg,"07","Local de        ?","","","MV_CH7","C",02,00,00,"G","","","","S",MV_PAR07)
	PUTSX1(cPerg,"08","Local Ate       ?","","","MV_CH8","C",02,00,00,"G","","","","S",MV_PAR08)
	PUTSX1(cPerg,"09","Data Inicial    ?","","","MV_CH9","D",08,00,00,"G","","","","S",MV_PAR09)
	PUTSX1(cPerg,"10","Grupo de        ?","","","MV_CHA","C",04,00,00,"G","","SBM","","S",MV_PAR10)
	PUTSX1(cPerg,"11","Grupo Ate       ?","","","MV_CHB","C",04,00,00,"G","","SBM","","S",MV_PAR11)
	PUTSX1(cPerg,"12","Relação         ?","","","MV_CHC","N",01,00,00,"C","","","","","MV_PAR12","Analítico","","","","Sintético","","","","","","","","","","","")
	PUTSX1(cPerg,"13","Calc. Real pelo ?","","","MV_CHD","N",01,00,00,"C","","","","","MV_PAR13","Consumo","","","","Producao","","","","","","","","","","","")
	Pergunte( cPerg, .F. )

	oReport:= PCPRA99(lEnd,wnRel,cTamanho,cTitulo)
	oReport:PrintDialog()
Return

/*
Função:PCPRA99
Data: 13/04/16
Descrição: Prepara Relatório
*/             
Static Function PCPRA99(lEnd,wnRel,cTamanho,cTitulo)
	Local oReport
	oReport := TReport():New(cPerg, cTitulo,cPerg , {|oReport| PCPRA01(oReport,lEnd,wnRel,cTamanho,cTitulo)},"Este relatorio ira imprimir Custo Produto Acabado")
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:lParamPage:= .F.

Return(oReport)

/*
Função:PCPRA01
Data: 13/04/16
Descrição: Gera Relatório
*/             
Static Function PCPRA01(oRpt,lEnd,wnRel,cTamanho,cTitulo)
	Local oReport  		:= oRpt
	Private cCabec1  	:= ""		// Cabecalho das colunas do relatorio
	Private cCabec2  	:= ""		// Cabecalho das colunas do relatorio
	Private cPlanta  	:= ""		// Codigo da planta
	Private cCodCli  	:= ""		// Codigo do cliente
	Private cLoja    	:= ""		// Codigo da loja
	Private cCodPro  	:= ""		// Codigo do produto
	Private cQuery   	:= ""		// Auxiliar para montagem de query
	Private cbtxt    	:= Space(10)	// Usada para impressao do rodape
	Private cbcont   	:= 0			// Usada para impressao do rodape
	Private nAbate   	:= 0			// Quantidade entregue a ser abatida da quantidade programada
	Private nLin     	:= 80		// Contador de linhas detalhes 
	Private dDatMax 	    			// Data maxima para filtro das programacoes considerando a semana seguinte
	Private cPartNumber	:="" 
	Private nTotMes  	:= 0        
	Private nSegMes  	:= 0
	Private nTerMes  	:= 0
	Private nQuaMes  	:= 0
	Private nQuimes  	:= 0
	Private nSexmes  	:= 0
	Private nSetmes  	:= 0
	Private nOitmes  	:= 0
	Private nNonmes  	:= 0
	Private nDecmes  	:= 0
	Private nOnzmes  	:= 0
	Private nDozmes  	:= 0
	Private nTotalGer	:= {0,0,0,0,0,0,0,0,0,0,0,0}     
	Private nTotalPar	:= {0,0,0,0,0,0,0,0,0,0,0,0}     
	Private _cUm     	:= "" 
	Private cAnt       	:= ""
	Private cbCont     	:= 0
	Private nQuantG1   	:= 0
	Private CbTxt      	:= Space(10)
	Private cPicD3C114 	:= PesqPict("SD3","D3_CUSTO1",14)
	Private cPicD3C116 	:= PesqPict("SD3","D3_CUSTO1",16)
	Private cPicD3C118 	:= PesqPict("SD3","D3_CUSTO1",18)
	Private aAreaD3    	:= SD3->(GetArea())
	Private aRetSD3    	:= {} // Variavel que recebe conteudo de controle das validacoes das RE's Fantasma
	Private cCondFiltr 	:= ""
	Private nPosTrb1   	:= 0
	Private nPosTrb2   	:= 0
	Private nPosTrb3   	:= 0
	Private nPosTrb4   	:= 0
	Private cabec1
	Private cabec2
	Private nI
	Private nX
	Private cAnt       	:= ""
	Private cOpAnt     	:= ""
	Private nQuantG1   	:= 0
	Private lOpConf    	:= .T.
	Private aRecnoD4   	:= {}
	Private cCondicao  	:= ""
	Private nTotalVar  	:= 0
	Private nQtdVar    	:= 0
	Private nPercent   	:= 0
	Private nCusStdOP  	:= nTotStdOP := nCusRealOP := nTotRealOP := nTotVarOP := 0
	Private nCusUnit   	:= nCusUnitR := nCusUnitS  := nCusUStd   := 0
	Private nSValor    	:= 0
	Private nSQuant    	:= 0
	Private nI		 	:= 0
	Private cFilIni  	:= MV_PAR01	// Filial de 
	Private cFilFim  	:= MV_PAR02	// Filial ate
	Private cProdIni 	:= MV_PAR03	// Produto de
	Private cProdFim 	:= MV_PAR04	// Produto ate
	Private cTipIni  	:= MV_PAR05  // Tipo de
	Private cTipFim  	:= MV_PAR06  // Tipo ate
	Private cLocIni  	:= MV_PAR07  // Private de
	Private cLocFim  	:= MV_PAR08  // Private ate
	Private dDatini  	:= MV_PAR09
	Private cGrpIni  	:= MV_PAR10  // Grupo de
	Private cGrpFim  	:= MV_PAR11  // Grupo ate
	Private nRelac	 	:= MV_PAR12  // Gerar pela Estrura ou Empenho?
	Private nCalcPor	:= MV_PAR13 
	Private dDatMes1	:= lastday(dDatIni)
	Private dDatMes2	:= lastday(dDatMes1+2)
	Private dDatMes3	:= lastDay(dDatMes2+2)
	Private dDatMes4	:= lastDay(dDatMes3+2)
	Private dDatMes5	:= lastDay(dDatMes4+2)
	Private dDatMes6	:= lastDay(dDatMes5+2)
	Private dDatMes7	:= lastDay(dDatMes6+2)
	Private dDatMes8	:= lastDay(dDatMes7+2)
	Private dDatMes9	:= lastDay(dDatMes8+2)
	Private dDatMes10	:= lastDay(dDatMes9+2)
	Private dDatMes11	:= lastDay(dDatMes10+2)
	Private dDatMes12	:= lastDay(dDatMes11+2)
	Private aTam       	:= TamSX3("D3_CUSTO1")
	Private nTamDecQtd 	:= TamSX3("D3_QUANT")[2]
	Private nTamIntCus 	:= aTam[1]
	Private nTamDecCus 	:= aTam[2]
	Private aLstTrb1   	:= {}
	Private aLstTrb2   	:= {}
	Private aLstTrb3   	:= {}
	Private aLstTrb4   	:= {}
	Private lQuery     	:= .F.
	Private cAliasNew 	:= "SD3"
	Private cAliasIt 	:= "SD3IT"

	aTam        		:= TamSX3("D3_CUSTO1")
	nTamIntCus  		:= aTam[1]
	nTamDecCus  		:= aTam[2]

	//->Cria Seções
	oSection1 := TRSection():New(oReport,cTitulo,{""})
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"B1_COD",cAliasNew,OemToAnsi("Código"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"B1_DESC",cAliasNew,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"B1_LOCPAD",cAliasNew,OemToAnsi("Local"),PesqPict('SB1',"B1_LOCPAD"),TamSX3("B1_LOCPAD")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO01",cAliasNew,aMesAno[month(dDatMes1)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO02",cAliasNew,aMesAno[month(dDatMes2)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO03",cAliasNew,aMesAno[month(dDatMes3)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO04",cAliasNew,aMesAno[month(dDatMes4)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO05",cAliasNew,aMesAno[month(dDatMes5)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO06",cAliasNew,aMesAno[month(dDatMes6)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO07",cAliasNew,aMesAno[month(dDatMes7)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO08",cAliasNew,aMesAno[month(dDatMes8)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO09",cAliasNew,aMesAno[month(dDatMes9)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO10",cAliasNew,aMesAno[month(dDatMes10)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO11",cAliasNew,aMesAno[month(dDatMes11)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	TRCell():New(oSection1,"D1_CUSTO12",cAliasNew,aMesAno[month(dDatMes12)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")

	If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
		oSection2 := TRSection():New(oSection1,cTitulo,{"SD3"})
		oSection2:SetHeaderPage(.T.)
		oSection2:SetHeaderSection(.T.)  
		TRCell():New(oSection2,"B1_COD",cAliasNew,OemToAnsi("Código"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection2,"B1_DESC",cAliasNew,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection2,"B1_LOCPAD",cAliasNew,OemToAnsi("Local"),PesqPict('SB1',"B1_LOCPAD"),TamSX3("B1_LOCPAD")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO01",cAliasNew,aMesAno[month(dDatMes1)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO02",cAliasNew,aMesAno[month(dDatMes2)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO03",cAliasNew,aMesAno[month(dDatMes3)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO04",cAliasNew,aMesAno[month(dDatMes4)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO05",cAliasNew,aMesAno[month(dDatMes5)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO06",cAliasNew,aMesAno[month(dDatMes6)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO07",cAliasNew,aMesAno[month(dDatMes7)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO08",cAliasNew,aMesAno[month(dDatMes8)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO09",cAliasNew,aMesAno[month(dDatMes9)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO10",cAliasNew,aMesAno[month(dDatMes10)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO11",cAliasNew,aMesAno[month(dDatMes11)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		TRCell():New(oSection2,"D1_CUSTO12",cAliasNew,aMesAno[month(dDatMes12)],PesqPict('SD1',"D1_CUSTO"),TamSX3("D1_CUSTO")[1]+1)
		oSection2:SetLeftMargin(2)
		oSection2:SetPageBreak(.T.)
		oSection2:SetTotalText(" ")
	Endif

	If Empty(cCondFiltr)
		cCondFiltr := ".T."
	EndIf

	dbSelectArea("SB1")
	dbClearFilter()

	dbSelectArea("SD3")
	dbSetOrder(6)

	cAliasNew := CriaTrab(NIL,.F.)

	lQuery    := .T.
	cQuery := "SELECT D3_COD, SUBSTRING(D3_EMISSAO,1,6) MESANO, SUM(D3_QUANT) QUANT, SUM(D3_CUSTO1) CUSTO"
	cQuery += " FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += " WHERE SD3.D3_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' AND "
	cQuery += " SD3.D3_COD >= '"+cProdIni+"' AND "
	cQuery += " SD3.D3_COD <= '"+cProdFim+"' AND "
	cQuery += " SD3.D3_OP <> '' AND "
	cQuery += " SUBSTRING(SD3.D3_CF,1,2) = 'PR' AND "
	cQuery += " SD3.D3_EMISSAO >= '" + DtoS(dDatIni) + "' AND "
	cQuery += " SD3.D3_EMISSAO <= '" + DtoS(lastDay(dDatMes12)) + "' AND "
	cQuery += " SD3.D3_ESTORNO = ' ' AND "
	cQuery += " SD3.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D3_COD, SUBSTRING(D3_EMISSAO,1,6) "
	cQuery += " ORDER BY D3_COD, SUBSTRING(D3_EMISSAO,1,6) "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.T.,.T.)

	oSection1 := oReport:Section(1)
	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
		oSection2  := oReport:Section(1):Section(1)
		oSection1:SetHeaderSection(.F.)
		oSection2:Init()
	Endif

	oReport:SetMeter(SD3->(RecCount())) //-> Total de Elementos da regua

	While (cAliasNew)->(!Eof())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		//-- Posiciona tabela SB1
		If SB1->(B1_FILIAL+B1_COD)#(xFilial("SB1")+(cAliasNew)->D3_COD)
			SB1->( dbSeek(xFilial("SB1")+(cAliasNew)->D3_COD) )
		EndIf

		If nCalcPor == 1 //-> Por Consumo
			//->Localiza Dados de Produtos diferentes de Produçao
			cQuery := " SELECT "
			cQuery += " 	SD3A.D3_COD, SD3A.D3_CF "
			cQuery += " 	,SUBSTRING(SD3A.D3_EMISSAO,1,6) MESANO "
			cQuery += " 	,SUM(SD3A.D3_QUANT) QUANT "
			cQuery += " 	,SUM(SD3A.D3_CUSTO1)*SUM(SD3A.D3_QUANT) AS CUSTO "
			cQuery += " FROM SD3010 SD3A "
			cQuery += " INNER JOIN SC2010 SC2A "
			cQuery += " 	ON SC2A.C2_PRODUTO='"+(cAliasNew)->D3_COD+"' "
			cQuery += " 	AND (C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)=SD3A.D3_OP " 
			cQuery += " 	AND SC2A.D_E_L_E_T_ <> '*' "
			cQuery += " WHERE "
			cQuery += " 	SUBSTRING(SD3A.D3_EMISSAO,1,6)='"+(cAliasNew)->MESANO+"' " 
			cQuery += " 	AND SUBSTRING(SD3A.D3_CF,1,2) <> 'PR' "
			cQuery += " 	AND SD3A.D_E_L_E_T_ <>'*' "
			cQuery += " GROUP BY SD3A.D3_COD, SD3A.D3_CF, SUBSTRING(SD3A.D3_EMISSAO,1,6) "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasIt,.T.,.T.)
			While !(cAliasIt)->(Eof())

				//-> Le requisicoes e devolucoes SD3 e grava no Array aLstTrb1 para gravacao do REAL
				If SubStr((cAliasIt)->D3_CF,2,1)$"E"
					nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]==SC2->C2_PRODUTO+(cAliasNew)->D3_COD})
					If Empty(nPosTrb1)
						aAdd(aLstTrb1,{	(cAliasIt)->D3_COD,;				//01 - PRODUTO
						"",;	 							//02 - OP
						"",; 								//03 - NUMSEQ
						"",;						 		//04 - TRT
						"",;		 						//05 - CHAVE
						(cAliasIt)->MESANO,; 				//06 - EMISSAO
						(cAliasNew)->D3_COD,;			 	//07 - PAI
						"",	;							 	//08 - FIXVAR
						PCPRQtd("R",0,cAliasIt),; 			//09 - QTDREAL
						0,;						 			//10 - QTDSTD
						0,;						 			//11 - QTDVAR
						0,;						 			//12 - CUSTOSTD
						PCPRCus('R',1,,cAliasIt),;			//13 - CUSTOREAL
						0,})						  		//14 - CUSTOVAR
					Else
						aLstTrb1[nPosTrb1,09] += PCPRQtd("R",0,cAliasIt)	// 09 - QTDREAL
						aLstTrb1[nPosTrb1,13] += PCPRCus('R',1,,cAliasIt)	// 13 - CUSTOREAL
					EndIf
				Endif

				(cAliasIt)->(dbSkip())
			Enddo
			(cAliasIt)->(dbCloseArea())

			//-> Le producoes e grava aLstTrb2 para gravacao do STANDARD
			nPosTrb2 := aScan(aLstTrb2,{|x| x[1]==(cAliasNew)->D3_COD .And. x[4]==(cAliasNew)->MESANO})
			If nPosTrb2==0
				aAdd(aLstTrb2,{	(cAliasNew)->D3_COD,;		// 01 - PRODUTO
				(cAliasNew)->QUANT,;		// 02 - QTDREAL
				(cAliasNew)->CUSTO,;		// 03 - CUSTOREAL
				(cAliasNew)->MESANO,;		// 04 - MES/ANO
				" "})						// 05 - IMPRESSO?
				/*Else
				aLstTrb2[nPosTrb2,2] += (cAliasNew)->QUANT	// 02 - QTDREAL
				aLstTrb2[nPosTrb2,3] += (cAliasNew)->CUSTO  // 03 - CUSTOREAL*/
			EndIf

			dbSelectArea(cAliasNew)

		Else //->Por Produção
			nPosTrb1 := aScan(aLstTrb1,{|x| x[1] == (cAliasNew)->D3_COD .And. x[6] == (cAliasNew)->MESANO})
			If Empty(nPosTrb1)
				aAdd(aLstTrb1,{	(cAliasNew)->D3_COD,;		//01 - PRODUTO
				"",	;	 					//02 - OP
				"",	; 						//03 - NUMSEQ
				"",;						//04 - TRT
				"",;		 				//05 - CHAVE
				(cAliasNew)->MESANO,;		//06 - EMISSAO
				(cAliasNew)->D3_COD,;		//07 - PAI
				"",	;						//08 - FIXVAR
				(cAliasNew)->QUANT,; 		//09 - QTDREAL
				0,;						 	//10 - QTDSTD
				0,;						 	//11 - QTDVAR
				0,;						 	//12 - CUSTOSTD
				(cAliasNew)->CUSTO,;		//13 - CUSTOREAL
				0	})						//14 - CUSTOVAR
			Else
				aLstTrb1[nPosTrb1,09] += (cAliasNew)->QUANT         	// 09 - QTDREAL
				aLstTrb1[nPosTrb1,13] += (cAliasNew)->CUSTO			// 13 - CUSTOREAL
			EndIf
		EndIf

		dbSkip()

	EndDo

	oReport:SetMeter(Len(aLstTrb1)) // Total de Elementos da regua
	aLstTrb1 := ASort(aLstTrb1,,, { | x,y | x[7]+x[1] < y[7]+y[1] })
	nQuantOp := 0.00 //->Inicio da Impressao

	For nI:=1 To Len(aLstTrb1)

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		nCusUnit   := IIf(Empty(aLstTrb1[nI,09]),aLstTrb1[nI,13],Round(aLstTrb1[nI,13]/aLstTrb1[nI,09],nTamDecCus))	//Round(CUSTOREAL/IIF(QTDREAL=0,1,QTDREAL),nTamDecCus)

		If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
			//nCusUnit   := aLstTrb1[nI,13]
			nPosTrb4 := aScan(aLstTrb4,{|x| x[1] == aLstTrb1[nI,1] .And. x[14] == aLstTrb1[nI,7]})
			If nPosTrb4==0
				aAdd(aLstTrb4,{	aLstTrb1[nI,1],; //PRODUTO
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				aLstTrb1[nI,7]})
			EndIf

			//->Analítico
			nPosTrb4 := aScan(aLstTrb4,{|x| x[1] == aLstTrb1[nI,1] .And. x[14] == aLstTrb1[nI,7]})
			If nPosTrb4 > 0
				if aLstTrb1[nI,06] = SubStr(DtoS(dDatMes1),1,6)
					aLstTrb4[nPosTrb4,02]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes2),1,6)
					aLstTrb4[nPosTrb4,03]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes3),1,6)
					aLstTrb4[nPosTrb4,04]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes4),1,6)
					aLstTrb4[nPosTrb4,05]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes5),1,6)
					aLstTrb4[nPosTrb4,06]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes6),1,6)
					aLstTrb4[nPosTrb4,07]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes7),1,6)
					aLstTrb4[nPosTrb4,08]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes8),1,6)
					aLstTrb4[nPosTrb4,09]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes9),1,6)
					aLstTrb4[nPosTrb4,10]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes10),1,6)
					aLstTrb4[nPosTrb4,11]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes11),1,6)
					aLstTrb4[nPosTrb4,12]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes12),1,6)
					aLstTrb4[nPosTrb4,13]+=nCusUnit
				endIf
			Endif
		Endif

		//-> Filtrar por Produto Pai
		If aLstTrb1[nI,7] < cProdIni .Or. aLstTrb1[nI,7] > cProdFim
			Loop	
		EndIf

		//->Somente produtos finais podem constar no relatório
		/*If nCalcPor == 1
		nPosTrb2 := aScan(aLstTrb2,{|x| x[1]==aLstTrb1[nI,7]})	
		If Empty(nPosTrb2)
		Loop
		EndIf
		Endif*/

		SB1->(dbSeek(xFilial("SB1")+aLstTrb1[nI,7]))

		If SB1->B1_TIPO < cTipIni .Or. SB1->B1_TIPO > cTipFim
			Loop
		Endif

		If SB1->B1_GRUPO < cGrpIni .Or. SB1->B1_GRUPO > cGrpFim
			Loop
		Endif

		If SB1->B1_MSBLQL <> '2'
			Loop
		Endif

		If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
			nPosTrb2 := aScan(aLstTrb2,{|x| x[1] == aLstTrb1[nI,7] .And. x[5] == " " })
			If nPosTrb2 > 0
				aLstTrb2[nPosTrb2,5]:="X" 
				nCusUnit:= IIf(aLstTrb2[nPosTrb2,2]==0,aLstTrb2[nPosTrb2,3],Round(aLstTrb2[nPosTrb2,3]/aLstTrb2[nPosTrb2,2],nTamDecCus))	//Round(CUSTOREAL/IIF(QTDREAL=0,1,QTDREAL),nTamDecCus)
				nPosTrb3 := aScan(aLstTrb3,{|x|x[1]==aLstTrb1[nI,7]})
				If nPosTrb3==0
					aAdd(aLstTrb3,{aLstTrb1[nI,07],; //PRODUTO
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,})
				EndIf
				nPosTrb3 := aScan(aLstTrb3,{|x|x[1]==aLstTrb1[nI,7]})
				If nPosTrb3 > 0
					if aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes1),1,6)
						aLstTrb3[nPosTrb3,02]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes2),1,6)
						aLstTrb3[nPosTrb3,03]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes3),1,6)
						aLstTrb3[nPosTrb3,04]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes4),1,6)
						aLstTrb3[nPosTrb3,05]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes5),1,6)
						aLstTrb3[nPosTrb3,06]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes6),1,6)
						aLstTrb3[nPosTrb3,07]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes7),1,6)
						aLstTrb3[nPosTrb3,08]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes8),1,6)
						aLstTrb3[nPosTrb3,09]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes9),1,6)
						aLstTrb3[nPosTrb3,10]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes10),1,6)
						aLstTrb3[nPosTrb3,11]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes11),1,6)
						aLstTrb3[nPosTrb3,12]+=nCusUnit
					elseif aLstTrb2[nPosTrb2,04] = SubStr(DtoS(dDatMes12),1,6)
						aLstTrb3[nPosTrb3,13]+=nCusUnit
					endIf
				Endif
			Endif
		Else
			nPosTrb3 := aScan(aLstTrb3,{|x|x[1]==aLstTrb1[nI,7]})
			If nPosTrb3==0
				aAdd(aLstTrb3,{aLstTrb1[nI,07],; //PRODUTO
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,;
				0,})
			EndIf

			nPosTrb3 := aScan(aLstTrb3,{|x|x[1]==aLstTrb1[nI,7]})
			If nPosTrb3 > 0
				if aLstTrb1[nI,06] = SubStr(DtoS(dDatMes1),1,6)
					aLstTrb3[nPosTrb3,02]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes2),1,6)
					aLstTrb3[nPosTrb3,03]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes3),1,6)
					aLstTrb3[nPosTrb3,04]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes4),1,6)
					aLstTrb3[nPosTrb3,05]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes5),1,6)
					aLstTrb3[nPosTrb3,06]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes6),1,6)
					aLstTrb3[nPosTrb3,07]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes7),1,6)
					aLstTrb3[nPosTrb3,08]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes8),1,6)
					aLstTrb3[nPosTrb3,09]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes9),1,6)
					aLstTrb3[nPosTrb3,10]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes10),1,6)
					aLstTrb3[nPosTrb3,11]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes11),1,6)
					aLstTrb3[nPosTrb3,12]+=nCusUnit
				elseif aLstTrb1[nI,06] = SubStr(DtoS(dDatMes12),1,6)
					aLstTrb3[nPosTrb3,13]+=nCusUnit
				endIf
			Endif
		Endif
	Next

	//->Imprimir
	oReport:SetMeter(Len(aLstTrb3))// Total de Elementos da regua
	aLstTrb3 := aSort(aLstTrb3,,, { | x,y | x[1] < y[1] })
	For nI:=1 To Len(aLstTrb3)
		//->Posiciona Produto
		SB1->(DbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aLstTrb3[nI,01]))

		oReport:IncMeter()

		oSection1:Cell("B1_COD"):SetValue(aLstTrb3[nI,01])
		oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
		oSection1:Cell("B1_LOCPAD"):SetValue(SB1->B1_LOCPAD)
		oSection1:Cell("D1_CUSTO01"):SetValue(aLstTrb3[nI,02])
		oSection1:Cell("D1_CUSTO02"):SetValue(aLstTrb3[nI,03])
		oSection1:Cell("D1_CUSTO03"):SetValue(aLstTrb3[nI,04])
		oSection1:Cell("D1_CUSTO04"):SetValue(aLstTrb3[nI,05])
		oSection1:Cell("D1_CUSTO05"):SetValue(aLstTrb3[nI,06])
		oSection1:Cell("D1_CUSTO06"):SetValue(aLstTrb3[nI,07])
		oSection1:Cell("D1_CUSTO07"):SetValue(aLstTrb3[nI,08])
		oSection1:Cell("D1_CUSTO08"):SetValue(aLstTrb3[nI,09])
		oSection1:Cell("D1_CUSTO09"):SetValue(aLstTrb3[nI,10])
		oSection1:Cell("D1_CUSTO10"):SetValue(aLstTrb3[nI,11])
		oSection1:Cell("D1_CUSTO11"):SetValue(aLstTrb3[nI,12])
		oSection1:Cell("D1_CUSTO12"):SetValue(aLstTrb3[nI,13])
		oSection1:PrintLine()

		If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
			cAnt 	:= aLstTrb3[nI,01]
			aLstTrb4:= ASort(aLstTrb4,,, { | x,y | x[14]+x[1] < y[14]+y[1] })
			nX 		:= aScan(aLstTrb4,{|x|x[14]==cAnt})
			If nX > 0
				While nX <= Len(aLstTrb4) .And. aLstTrb4[nX,14] == cAnt
					SB1->(DbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+aLstTrb4[nX,1]))

					oSection2:Cell("B1_COD"):SetValue(aLstTrb4[nX,01])
					oSection2:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
					oSection2:Cell("B1_LOCPAD"):SetValue(SB1->B1_LOCPAD)
					oSection2:Cell("D1_CUSTO01"):SetValue(aLstTrb4[nX,02])
					oSection2:Cell("D1_CUSTO02"):SetValue(aLstTrb4[nX,03])
					oSection2:Cell("D1_CUSTO03"):SetValue(aLstTrb4[nX,04])
					oSection2:Cell("D1_CUSTO04"):SetValue(aLstTrb4[nX,05])
					oSection2:Cell("D1_CUSTO05"):SetValue(aLstTrb4[nX,06])
					oSection2:Cell("D1_CUSTO06"):SetValue(aLstTrb4[nX,07])
					oSection2:Cell("D1_CUSTO07"):SetValue(aLstTrb4[nX,08])
					oSection2:Cell("D1_CUSTO08"):SetValue(aLstTrb4[nX,09])
					oSection2:Cell("D1_CUSTO09"):SetValue(aLstTrb4[nX,10])
					oSection2:Cell("D1_CUSTO10"):SetValue(aLstTrb4[nX,11])
					oSection2:Cell("D1_CUSTO11"):SetValue(aLstTrb4[nX,12])
					oSection2:Cell("D1_CUSTO12"):SetValue(aLstTrb4[nX,13])
					oSection2:PrintLine()
					oReport:ThinLine() //-- Impressao de Linha Simples
					//oReport:SkipLine() //-- Salta linha

					nX++
					If nX > Len(aLstTrb4) .Or. aLstTrb4[nX,14] # cAnt
						nX--
						Exit
					EndIf
				EndDo
				oReport:ThinLine() //-- Impressao de Linha Simples
				oReport:SkipLine() //-- Salta linha
			Endif
		Endif
	Next

	dbSelectArea("SB1")
	RetIndex("SB1")
	dbClearFilter()
	dbSetOrder(1)

	If lQuery
		dbSelectArea(cAliasNew)
		dbCloseArea()
		dbSelectArea("SD3")
	EndIf
	RestArea(aAreaD3)

	oSection1:Finish()
	If nRelac==1 .And. nCalcPor == 1 //-> Analítico Somente por Consumo
		oSection2:Finish()
	Endif
Return(oReport)

/*
Nome: PCPRCus
Data: 07/04/16
Descrição: Calcula Custo
*/
Static Function PCPRCus(cTipo,nMoeda,nQtd,cAliasSD3)
	Local aAreaAnt  := GetArea()
	Local nRet      := 0

	Default cAliasSD3 := "SD3"
	Default nQtd      := 0

	If cTipo = "R" 	// Custo Real
		If cAliasSD3="SD3IT"
			nRet := (cAliasSD3)->( &("CUSTO") ) * IIf(SubStr((cAliasSD3)->D3_CF, 1, 1) == 'R', 1, -1)
		Else
			nRet := (cAliasSD3)->( &("CUSTO") ) 
		Endif
	Else  // Custo Standard
		dbSelectArea("SB1")
		nRet := (nQtd*xMoeda(RetFldProd(SB1->B1_COD,"B1_CUSTD"),Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD")), nMoeda, RetFldProd(SB1->B1_COD,"B1_DATREF") ))
	EndIf

	RestArea(aAreaAnt)
Return (nRet)

/*
Nome: PCPRTRT
Data: 07/04/16
Descrição: 	Funcao para tratar duas ou mais requisicoes de um mesmo
componente utilizados dentro da mesma estrutura.
*/
Static Function PCPRTRT(cTipoMov,nLin)
	Local cConteudo := If(Empty(nLin),"",RTrim(aLstTrb1[nLin,4]))
	Local nRegSD3,xRetorno,nPosCorte,lReposSD3

	If cTipoMov == "RE"
		// Chamado apartir da leitura das REQUISICOES para compor o REAL
		If !Empty((cAliasNew)->D3_TRT)
			If Empty(cConteudo)
				xRetorno := "   /" + (cAliasNew)->D3_TRT
			Else
				xRetorno := cConteudo+"/" + (cAliasNew)->D3_TRT
			EndIf
		EndIf
	Else
		// Chamado apartir da leitura das PRODUCOES para compor o STANDARD
		lReposSD3	:= .F.
		nPosCorte	:= At("/",cConteudo)
		If nposCorte <> 0
			cTRTCorte	:= SubStr(cConteudo,1,nPosCorte-1)
			cConteudo	:= Substr(cConteudo,nPosCorte+1,Len(cConteudo))
		Else
			cTRTCorte	:= AllTrim(cConteudo)
			cConteudo	:= ""
		EndIf
		nRegSD3	:= SD3->( Recno() )
		If SD3->( dbSeek(xFilial("SD3")+DTOS(aLstTrb1[nLin,06])+aLstTrb1[nLin,03]+aLstTrb1[nLin,05]+aLstTrb1[nLin,01]) )
			Do While ! SD3->(Eof())
				If SD3->D3_TRT == cTRTCorte
					lReposSD3 := .T.
					Exit
				EndIf
				SD3->( dbSkip() )
			EndDo
			xRetorno := {cConteudo,nRegSD3,lReposSD3}
		EndIf
	EndIf
Return (xRetorno)


/*
Nome: PCPRQtd
Data: 07/04/16
Descrição: 	Retorna Quantidade
*/
Static Function PCPRQtd(cTipo,nQuant,cAliasSD3)

	Local aAreaAnt   := GetArea()
	Local nRet       := 0

	Default cAliasSD3:= "SD3"

	If cTipo = "R" // Quantidade Real
		If cAliasSD3="SD3IT"
			nRet := (cAliasSD3)->QUANT*IIf(SubStr((cAliasSD3)->D3_CF, 1, 1)=='R', 1, -1)
		Else
			nRet := (cAliasSD3)->QUANT
		Endif
	Else // Quantidade Standard
		nRet := nQuant
	EndIf

	RestArea(aAreaAnt)
Return (nRet)


/*
Nome: PCPRFant
Data: 07/04/16
Descrição: Retorna a estrutura do produto fantasma 	
*/
Static Function PCPRFant(nQuantPai)
	Local aAreaAnt  := GetArea()
	Local aAreaSB1  := SB1->(GetArea())
	Local aAreaSG1  := SG1->(GetArea())
	Local cComponen := SG1->G1_COMP
	Local nPosTrb1  := 0
	Local nPosTrb2  := 0
	Local nPosTrb3  := 0
	Local nPosTrb4  := 0

	dbSelectArea("SG1")
	If dbSeek(xFilial("SG1")+cComponen, .F.)
		While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cComponen
			If G1_INI > dDataBase .Or. G1_FIM < dDataBase
				dbSkip()
				Loop
			EndIf
			//-> Gravar Valores da Producao em TRB do componente.
			dbSelectArea("SB1")
			If dbSeek(xFilial("SB1")+SG1->G1_COMP)
				If SG1->G1_FIXVAR == "F"
					nQuantG1 := SG1->G1_QUANT
				Else
					nQuantG1 := ExplEstr(nQuantPai,,SC2->C2_OPC)
				EndIf

				nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]==SC2->C2_PRODUTO+SG1->G1_COMP})

				If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
					//-> Se Produto for FANTASMA gravar so os componentes.
					PCPRFant(nQuantG1 )
				Else
					If !Empty(nPosTrb1) .And. !Empty(aLstTrb1[nPosTrb1,04])
						aRetSD3 := PCPRTRT("PR",nPosTrb1)
					Else
						aRetSD3 := {"",0,.F.}
					EndIF

					If Empty(nPosTrb1)
						aAdd(aLstTrb1,Array(14))
						nPosTrb1 := Len(aLstTrb1)
						aLstTrb1[nPosTrb1,01] := SG1->G1_COMP
						aLstTrb1[nPosTrb1,02] := (cAliasNew)->D3_OP
						aLstTrb1[nPosTrb1,06] := (cAliasNew)->D3_EMISSAO
						aLstTrb1[nPosTrb1,09] := 0
						aLstTrb1[nPosTrb1,10] := 0
						aLstTrb1[nPosTrb1,12] := 0
						aLstTrb1[nPosTrb1,13] := 0
						aLstTrb1[nPosTrb1,14] := 0
					EndIf
					aLstTrb1[nPosTrb1,04] := aRetSD3[1]
					aLstTrb1[nPosTrb1,07] := cProduto
					aLstTrb1[nPosTrb1,08] := SG1->G1_FIXVAR
					aLstTrb1[nPosTrb1,10] += Round(nQuantG1,nTamDecQtd)
					aLstTrb1[nPosTrb1,12] += PCPRCus("S",1,Round(nQuantG1,nTamDecCus))

					// Volta ao Registro Original do SD3
					If aRetSD3[3] .And. ! lQuery
						(cAliasNew)->( dbGoTo(aRetSD3[2]) )
					EndIf

				EndIf
			EndIf
			dbSelectArea("SG1")
			dbSkip()
		End
	EndIf
	RestArea(aAreaSB1)
	RestArea(aAreaSG1)
	RestArea(aAreaAnt)
Return(Nil)