#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP042()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatorio Pedido x Faturamento x Expedido	  						³±±
±±³          ³			                                                        ³±±
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
User Function PCP042()
	Local oReport
	Local cTitulo 	:= "Relatorio Pedido x Faturamento x Expedido"
	Private aPCP041	:= {}
	Private cPerg		:= PADR("PCP042",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cAliasZP1	:= "ZP1"
	Private aPCP041	:= {}

	If !U_APPFUN01("Z6_SUSPENC")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return .F.
	Endif

	PCP042Z(cPerg) //->Cria Perguntas
	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	oReport:=TReport():New("PCP042",cTitulo,cPerg, {|oReport| PCP042A(0,oReport)},cTitulo)
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
Static Function PCP042A(nOpc,oReport)
	If nOpc==0 //-> Seleciona
		oProcess := MsNewProcess():New( { || PCP042B(oReport) } , "Imprimindo..." , "Aguarde..." , .F. )
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
Static Function PCP042B(oReport)
	Local cSql	:=""
	Local cAliasZP1	:= GetNextAlias()
	Local cAliasSC6	:= GetNextAlias()

	aPCP041	:= {}

	Pergunte(cPerg,.F.)

	oSection1:= TRSection():New(oReport,"",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A",cAliasZP1,OemToAnsi("Código"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"B",cAliasZP1,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"C",cAliasZP1,OemToAnsi("Pedido"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection1,"D",cAliasZP1,OemToAnsi("Faturado"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection1,"E",cAliasZP1,OemToAnsi("Expedido"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection1,"F",cAliasZP1,OemToAnsi(""),"@!",2+1)
	TRCell():New(oSection1,"G",cAliasZP1,OemToAnsi("Saldo"),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")
	TRFunction():New(oSection1:Cell("C"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("D"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("E"),NIL,"SUM",,,,,.F.,.T.)


	cSql	:= "SELECT 
	cSql	+= "DAI_COD "
	cSql	+= ", C6_PRODUTO"
	cSql	+= ", B1_DESC  "
	If MV_PAR09==1 //-> KG
		cSql	+= ",SUM(CASE "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN C6_QTDPED "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN C6_QTDPED*SB1.B1_CONV "
		cSql	+= " 		ELSE 0 END) C6QTDPED "
		cSql	+= ",SUM(CASE "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN D2_QUANT "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN D2_QUANT*SB1.B1_CONV "
		cSql	+= " 		ELSE 0 END) D2QUANT "
	ElseIf MV_PAR09==2 //-> UN
		cSql	+= ",SUM(CASE "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN C6_QTDPED/SB1.B1_CONV "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN C6_QTDPED "
		cSql	+= " 		ELSE 0 END) C6QTDPED "
		cSql	+= ",SUM(CASE "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN D2_QUANT/SB1.B1_CONV "
		cSql	+= " 		WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN D2_QUANT "
		cSql	+= " 		ELSE 0 END) D2QUANT "
	Endif
	cSql	+= " FROM "+RETSQLNAME("SC6")+" SC6 "
	cSql	+= " INNER JOIN "+RETSQLNAME("DAI")+" DAI "
	cSql	+= " 	ON DAI_FILIAL=C6_FILIAL "
	cSql	+= " 	AND DAI_PEDIDO=C6_NUM "
	cSql	+= "	AND DAI_COD BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cSql	+= "	AND DAI.D_E_L_E_T_ <> '*' "
	cSql	+= " INNER JOIN "+RETSQLNAME("SD2")+" SD2 "
	cSql	+= "	ON D2_FILIAL=C6_FILIAL "
	cSql	+= " 	AND D2_DOC=C6_NOTA "
	cSql	+= " 	AND D2_SERIE=C6_SERIE "
	cSql	+= "	AND D2_COD=C6_PRODUTO "
	cSql	+= "	AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cSql	+= "	AND SD2.D_E_L_E_T_ <> '*' "
	cSql	+= " INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
	cSql	+= " 	ON B1_COD=D2_COD "
	cSql	+= " 	AND SB1.D_E_L_E_T_ <> '*' "
	cSql	+= "WHERE "
	cSql	+= "C6_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cSql	+= "AND C6_PRODUTO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cSql	+= "AND SC6.D_E_L_E_T_ <> '*' "
	cSql	+= " GROUP BY DAI_COD, C6_PRODUTO, B1_DESC "
	cSql	+= " ORDER BY DAI_COD, C6_PRODUTO "
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasSC6,.T.,.F.)
	dbSelectArea(cAliasSC6)

	oProcess:SetRegua1((cAliasSC6)->(LastRec()))
	(cAliasSC6)->(dbGoTop())

	While !(cAliasSC6)->(Eof())

		oProcess:IncRegua1("Carga: "+(cAliasSC6)->DAI_COD)

		nPosAP:=ASCAN(aPCP041,{|x| AllTrim(x[1]) == AllTrim((cAliasSC6)->C6_PRODUTO)})
		If nPosAP > 0
			aPCP041[nPosAP,3]+= (cAliasSC6)->C6QTDPED
			aPCP041[nPosAP,4]+= (cAliasSC6)->D2QUANT
		Else
			AADD(aPCP041,{(cAliasSC6)->C6_PRODUTO, (cAliasSC6)->B1_DESC, (cAliasSC6)->C6QTDPED, (cAliasSC6)->D2QUANT, 0,IIf(MV_PAR09==1,"KG","UN")})
		Endif

		//->Expedição
		If MV_PAR09==1 //-> KG
			cSql	:= "SELECT ZP1_CODPRO, B1_DESC, SUM(ZP1_PESO) QTDCX"
		ElseIf MV_PAR09==2 //-> UN
			cSql	:= "SELECT ZP1_CODPRO, B1_DESC, COUNT(*) QTDCX"
		Endif
		cSql	+= " FROM "+RETSQLNAME("ZP1")+" ZP1 "
		cSql	+= " INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
		cSql	+= " 	ON B1_COD=ZP1_CODPRO "
		cSql	+= "WHERE "
		cSql	+= "ZP1_CARGA ='"+(cAliasSC6)->DAI_COD+"' "
		cSql	+= "AND ZP1_CODPRO ='"+(cAliasSC6)->C6_PRODUTO+"' "
		cSql	+= "AND ZP1.D_E_L_E_T_ <> '*' "
		cSql	+= "GROUP BY ZP1_CODPRO, B1_DESC "
		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasZP1,.T.,.F.)
		dbSelectArea(cAliasZP1)
		oProcess:SetRegua2((cAliasZP1)->(LastRec()))
		(cAliasZP1)->(dbGoTop())
		While !(cAliasZP1)->(Eof())

			oProcess:IncRegua2("Produto: "+SubStr((cAliasSC6)->B1_DESC,1,25))
			nPosAP:=ASCAN(aPCP041,{|x| AllTrim(x[1]) == AllTrim((cAliasZP1)->ZP1_CODPRO)})
			If nPosAP > 0
				aPCP041[nPosAP,5]+=(cAliasZP1)->QTDCX
			Else
				AADD(aPCP041,{(cAliasSC6)->C6_PRODUTO, (cAliasSC6)->B1_DESC, 0, 0, (cAliasZP1)->QTDCX,IIf(MV_PAR09==1,"KG","UN")})
			Endif

			(cAliasZP1)->(dbSkip())
		EndDo
		(cAliasZP1)->(dbCloseArea())
		If File(cAliasZP1+GetdbExtension())
			FErase(cAliasZP1+GetDbExtension())
		Endif

		(cAliasSC6)->(dbSkip())
	EndDo
	(cAliasSC6)->(dbCloseArea())
	If File(cAliasSC6+GetdbExtension())
		FErase(cAliasSC6+GetDbExtension())
	Endif

	aSort( aPCP041, , , {|x,y| x[2] < y[2] } )

	oSection1:Init()
	For _I := 1 To Len(aPCP041)
		oSection1:Cell("A"):SetValue(aPCP041[_I,1])
		oSection1:Cell("B"):SetValue(aPCP041[_I,2])
		oSection1:Cell("C"):SetValue(aPCP041[_I,3])
		oSection1:Cell("D"):SetValue(aPCP041[_I,4])
		oSection1:Cell("E"):SetValue(aPCP041[_I,5])
		oSection1:Cell("F"):SetValue(aPCP041[_I,6])
		oSection1:Cell("G"):SetValue(aPCP041[_I,4] - aPCP041[_I,5])
		oSection1:PrintLine()
	Next _I
	oSection1:Finish()
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Perguntas
*/
Static Function PCP042Z(cPerg)
	PutSx1(cPerg,"01","Filial de ?"  	,'','',"mv_ch1","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Filial ate?"    ,'','',"mv_ch2","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Data de ?"  		,'','',"mv_ch3","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","","",""	,"mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Data Ate ?"  	,'','',"mv_ch4","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","","",""	,"mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Produto de ?"  	,'','',"mv_ch5","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Produto Ate ?"  ,'','',"mv_ch6","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par06","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Carga de ?"  	,'','',"mv_ch7","C",TamSx3("DAK_COD")[1] ,0,,"G","","DAK","",""	,"mv_par07","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Carga Ate ?"  	,'','',"mv_ch8","C",TamSx3("DAK_COD")[1] ,0,,"G","","DAK","",""	,"mv_par08","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"09","Unidade Medida?",'','',"mv_ch7","N",01,0,1,"C","","","","","MV_PAR09","KG","","","","UN","","","","","","","","","","","","","","")
Return

