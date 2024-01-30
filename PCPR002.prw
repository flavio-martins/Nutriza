#Include 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCPR002()     ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exibe relatório de apontamentos de produção baseado na ZPA		  ³±±
±±³          ³							                                          ³±±
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

User Function PCPR002()
	Local cTitulo	:= "Relatório Apontamento Produção "
	Local cPerg		:= Padr("PCPR002",10)
	Local oReport
	Local cAliasZPA	:="ZPATMP"

	PCPR002Z(cPerg) //->Cria perguntas
	Pergunte(cPerg,.T.) //->Perguntas antes de iniciar interface
	oReport:=PCPR002A(cPerg, cTitulo,cAliasZPA)
	oReport:PrintDialog()
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Instancia Objeto oReport
*/
Static Function PCPR002A(cPerg,cTitulo,cAliasZPA)
	Local oReport
	oReport:=TReport():New(cPerg, cTitulo,cPerg, {|oReport| PCPR002B(oReport)},"Relatório de apontamento...")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
Return(oReport)


/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Gera Seções
*/
Static Function PCPR002B(oRept)
	Local oReport	:= oRept
	Local oSection1	:= Nil
	Local oSection2 := Nil
	Local oBreak
	Local oFunction
	Local cSql		:= ""
	Local cAliasZPA	:= "ZPATMP"
	Local aCampos	:= ZPA->(dbStruct())
	Local cH1_CODIGO:=""
	Private cFilIni	:= MV_PAR01
	Private cFilFim	:= MV_PAR02
	Private cRecIni	:= MV_PAR03
	Private cRecFim	:= MV_PAR04
	Private cPrdIni	:= MV_PAR05
	Private cPrdFim	:= MV_PAR06
	Private cOprIni	:= MV_PAR07
	Private cOprFim	:= MV_PAR08
	Private cFerIni	:= MV_PAR09
	Private cFerFim	:= MV_PAR10
	Private cDtaIni	:= MV_PAR11
	Private cDtaFim	:= MV_PAR12
	Private nModRel	:= MV_PAR13

	If nModRel==1 //-> Sintético
		oSection1:= TRSection():New(oReport,Iif(nModRel==1,"Sintético","Analítico"),{""})
		oSection1:SetTotalInLine(.F.)
		oSection1:ShowHeader()
		TRCell():New(oSection1,"H1_CODIGO",cAliasZPA,OemToAnsi("Código"),PesqPict('SH1',"H1_CODIGO"),TamSX3("H1_CODIGO")[1]+1)
		TRCell():New(oSection1,"H1_DESCRI",cAliasZPA,OemToAnsi("Recusro"),PesqPict('SH1',"H1_DESCRI"),TamSX3("H1_DESCRI")[1]+1)
		TRCell():New(oSection1,"B1_COD",cAliasZPA,OemToAnsi("Cod.Prd."),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection1,"B1_DESC",cAliasZPA,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"ZPA_DTAPON",cAliasZPA,OemToAnsi("Data"),PesqPict('ZPA',"ZPA_DTAPON"),TamSX3("ZPA_DTAPON")[1]+1)
		TRCell():New(oSection1,"PBRUTO",cAliasZPA,OemToAnsi("P. Bruto"),PesqPict('ZPA',"ZPA_QTDPRO"),TamSX3("ZPA_QTDPRO")[1]+1)
		TRCell():New(oSection1,"PLIQUIDO",cAliasZPA,OemToAnsi("P. Liquido"),PesqPict('ZPA',"ZPA_QTDPRO"),TamSX3("ZPA_QTDPRO")[1]+1)
		oSection1:SetLeftMargin(2)
		oSection1:SetPageBreak(.T.)
		oSection1:SetTotalText(" ")
		TRFunction():New(oSection1:Cell("PBRUTO"),NIL,"SUM",,,,,.F.,.T.)
		TRFunction():New(oSection1:Cell("PLIQUIDO"),NIL,"SUM",,,,,.F.,.T.)
		oReport:SetTotalInLine(.F.)

		//Aqui, farei uma quebra  por seção
		oSection1:SetPageBreak(.T.)
		oSection1:SetTotalText(" ")

	Elseif  nModRel==2 .Or. nModRel==3 //-> Analítico ou Mapa
		oSection1:= TRSection():New(oReport,Iif(nModRel==1,"Sintético","Analítico"),{""})
		oSection1:SetTotalInLine(.F.)
		oSection1:ShowHeader()
		TRCell():New(oSection1,"H1_CODIGO",cAliasZPA,OemToAnsi("Código"),PesqPict('SH1',"H1_CODIGO"),TamSX3("H1_CODIGO")[1]+1)
		TRCell():New(oSection1,"H1_DESCRI",cAliasZPA,OemToAnsi("Recusro"),PesqPict('SH1',"H1_DESCRI"),TamSX3("H1_DESCRI")[1]+1)
		oSection1:SetLeftMargin(2)
		oSection1:SetPageBreak(.T.)
		oSection1:SetTotalText(" ")
		oSection2:= TRSection():New(oSection1,"Ferramentas",{""})
		oSection2:SetTotalInLine(.F.)
		oSection2:ShowHeader()
		TRCell():New(oSection2,"H4_CODIGO",cAliasZPA,OemToAnsi("Cod.Rec."),PesqPict('SH4',"H4_CODIGO"),TamSX3("H4_CODIGO")[1]+1)
		TRCell():New(oSection2,"H4_DESCRI",cAliasZPA,OemToAnsi("Ferramenta"),PesqPict('SH4',"H4_DESCRI"),TamSX3("H4_DESCRI")[1]+1)
		TRCell():New(oSection2,"B1_COD",cAliasZPA,OemToAnsi("Cod.Prd."),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection2,"B1_DESC",cAliasZPA,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection2,"ZPA_DTAPON",cAliasZPA,OemToAnsi("Data"),PesqPict('ZPA',"ZPA_DTAPON"),TamSX3("ZPA_DTAPON")[1]+1)
		If nModRel==3 //->Mapa
			TRCell():New(oSection2,"ZPA_HORAFI",cAliasZPA,OemToAnsi("Hora"),PesqPict('ZPA',"ZPA_HORAFI"),TamSX3("ZPA_HORAFI")[1]+1)
			TRCell():New(oSection2,"ZPA_TARBAL",cAliasZPA,OemToAnsi("Tara Rec."),PesqPict('ZPA',"ZPA_TARBAL"),TamSX3("ZPA_TARBAL")[1]+1)
			TRCell():New(oSection2,"ZPA_TARFER",cAliasZPA,OemToAnsi("Tara Fer."),PesqPict('ZPA',"ZPA_TARFER"),TamSX3("ZPA_TARFER")[1]+1)
		Endif
		TRCell():New(oSection2,"PBRUTO",cAliasZPA,OemToAnsi("P. Bruto"),PesqPict('ZPA',"ZPA_QTDPRO"),TamSX3("ZPA_QTDPRO")[1]+1)
		TRCell():New(oSection2,"PLIQUIDO",cAliasZPA,OemToAnsi("P. Liquido"),PesqPict('ZPA',"ZPA_QTDPRO"),TamSX3("ZPA_QTDPRO")[1]+1)
		oSection2:SetLeftMargin(2)
		oBreak := TRBreak():New(oSection1,oSection1:Cell("H1_CODIGO"),"Total de Recurso")
		TRFunction():New(oSection2:Cell("PBRUTO"),NIL,"SUM",oBreak)
		TRFunction():New(oSection2:Cell("PLIQUIDO"),NIL,"SUM",oBreak)
		oSection1:SetPageBreak(.T.)
		oSection1:SetTotalText(" ")
	Endif

	cSql	:="SELECT "
	If nModRel == 1 //->Sintético
		cSql	+="	H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON, SUM(ZPA_QTDPRO+(ZPA_TARBAL+ZPA_TARFER)) PBRUTO,  SUM(ZPA_QTDPRO) PLIQUIDO "
	Elseif nModRel == 2 //-> Ananlítico
		cSql	+="	H1_CODIGO, H1_DESCRI, H4_CODIGO, H4_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON, SUM(ZPA_QTDPRO+(ZPA_TARBAL+ZPA_TARFER)) PBRUTO,  SUM(ZPA_QTDPRO) PLIQUIDO "
	Elseif nModRel == 3 //-> Mapa
		cSql	+="	H1_CODIGO, H1_DESCRI, H4_CODIGO, H4_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON, ZPA_HORAFI, ZPA_TARBAL, ZPA_TARFER, ZPA_QTDPRO+(ZPA_TARBAL+ZPA_TARFER) PBRUTO,  ZPA_QTDPRO PLIQUIDO "
	Endif
	cSql	+="FROM "+RETSQLNAME("ZPA")+" ZPA "
	cSql	+="INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
	cSql	+="		ON B1_COD=ZPA_PRODUT "
	cSql	+="INNER JOIN "+RETSQLNAME("SH1")+" SH1 "
	cSql	+="		ON H1_CODIGO=ZPA_RECURS "
	cSql	+="INNER JOIN "+RETSQLNAME("SH4")+" SH4 "
	cSql	+="		ON H4_CODIGO=ZPA_FERRAM "
	cSql	+="INNER JOIN "+RETSQLNAME("SG2")+" SG2 "
	cSql	+="		ON G2_CODIGO = ZPA_OPERAC "
	cSql	+="		AND G2_RECURSO= H1_CODIGO "
	cSql	+="		AND G2_PRODUTO= ZPA_PRODUT"
	cSql	+="		AND SG2.D_E_L_E_T_ <> '*' "
	cSql	+=" WHERE "
	cSql	+="		ZPA_FILIAL BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
	cSql	+="		AND ZPA_RECURS BETWEEN '"+cRecIni+"' AND '"+cRecFim+"' "
	cSql	+="		AND ZPA_PRODUT BETWEEN '"+cPrdIni+"' AND '"+cPrdFim+"' "
	cSql	+="		AND ZPA_OPERAC BETWEEN '"+cOprIni+"' AND '"+cOprFim+"' "
	cSql	+="		AND ZPA_FERRAM BETWEEN '"+cFerIni+"' AND '"+cFerFim+"' "
	cSql	+="		AND ZPA_DATAFI BETWEEN '"+DTOS(cDtaIni)+"' AND '"+DTOS(cDtaFim)+"' "
	cSql	+="		AND ZPA.D_E_L_E_T_ <> '*' "
	If nModRel == 1
		cSql	+="GROUP BY	H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "
		cSql	+="ORDER BY	H1_CODIGO, H1_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "
	Elseif nModRel == 2
		cSql	+="GROUP BY	H1_CODIGO, H1_DESCRI, H4_CODIGO, H4_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "
		cSql	+="ORDER BY	H1_CODIGO, H1_DESCRI, H4_CODIGO, H4_DESCRI, B1_COD, B1_DESC, ZPA_DTAPON "
	ElseIf nModRel == 3
		cSql	+="ORDER BY	ZPA_DTAPON, ZPA_HORAFI "
	Endif
	MemoWrite("C:\TEMP\"+FUNNAME()+".SQL", cSql)
	dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasZPA,.F.,.T.)

	For nZ := 1 to Len(aCampos)
		If aCampos[nZ,2] <> "C"
			TCSetField(cAliasZPA, aCampos[nZ,1], aCampos[nZ,2], aCampos[nZ,3], aCampos[nZ,4])
		Endif
	Next nZ
	TCSetField(cAliasZPA, "PBRUTO", "N", 15, 3)
	TCSetField(cAliasZPA, "PLIQUIDO", "N", 15, 3)

	oReport:SetMeter((cAliasZPA)->(LastRec()))
	(cAliasZPA)->(dbGoTop())

	If nModRel == 1 //->Sintético
		While !(cAliasZPA)->(Eof())
			If oReport:Cancel() //->Cancelar
				Exit
			EndIf
			oReport:IncMeter()
			IncProc("Imprimindo Registro "+cValToChar((cAliasZPA)->(Recno()))+" De "+cValToChar((cAliasZPA)->(LastRec())))
			oSection1:Init()
			oSection1:Cell("H1_CODIGO"):SetValue((cAliasZPA)->H1_CODIGO)
			oSection1:Cell("H1_DESCRI"):SetValue((cAliasZPA)->H1_DESCRI)
			oSection1:Cell("B1_COD"):SetValue((cAliasZPA)->B1_COD)
			oSection1:Cell("B1_DESC"):SetValue((cAliasZPA)->B1_DESC)
			oSection1:Cell("ZPA_DTAPON"):SetValue((cAliasZPA)->ZPA_DTAPON)
			oSection1:Cell("PBRUTO"):SetValue((cAliasZPA)->PBRUTO)
			oSection1:Cell("PLIQUIDO"):SetValue((cAliasZPA)->PLIQUIDO)
			oSection1:Printline()
			(cAliasZPA)->(dbSkip())
		Enddo	
	Elseif nModRel == 2 .Or. nModRel == 3 //-> Ananlítico ou Mapa
		While !(cAliasZPA)->(Eof())
			If oReport:Cancel() //->Cancelar
				Exit
			EndIf
			oReport:IncMeter()
			IncProc("Imprimindo Registro "+cValToChar((cAliasZPA)->(Recno()))+" De "+cValToChar((cAliasZPA)->(LastRec())))

			oSection1:Init()
			oSection1:Cell("H1_CODIGO"):SetValue((cAliasZPA)->H1_CODIGO)
			oSection1:Cell("H1_DESCRI"):SetValue((cAliasZPA)->H1_DESCRI)
			oSection1:Printline()

			cH1_CODIGO:=(cAliasZPA)->H1_CODIGO
			oSection2:Init()

			While (cAliasZPA)->H1_CODIGO==cH1_CODIGO
				oReport:IncMeter()
				IncProc("Imprimindo Registro "+cValToChar((cAliasZPA)->(Recno()))+" De "+cValToChar((cAliasZPA)->(LastRec())))

				oSection2:Cell("H4_CODIGO"):SetValue((cAliasZPA)->H4_CODIGO)
				oSection2:Cell("H4_DESCRI"):SetValue((cAliasZPA)->H4_DESCRI)
				oSection2:Cell("B1_COD"):SetValue((cAliasZPA)->B1_COD)
				oSection2:Cell("B1_DESC"):SetValue((cAliasZPA)->B1_DESC)
				oSection2:Cell("ZPA_DTAPON"):SetValue((cAliasZPA)->ZPA_DTAPON)
				If nModRel == 3
					oSection2:Cell("ZPA_HORAFI"):SetValue((cAliasZPA)->ZPA_HORAFI)
					oSection2:Cell("ZPA_TARBAL"):SetValue((cAliasZPA)->ZPA_TARBAL)
					oSection2:Cell("ZPA_TARFER"):SetValue((cAliasZPA)->ZPA_TARFER)
				Endif
				oSection2:Cell("PBRUTO"):SetValue((cAliasZPA)->PBRUTO)
				oSection2:Cell("PLIQUIDO"):SetValue((cAliasZPA)->PLIQUIDO)
				oSection2:Printline()
				(cAliasZPA)->(dbSkip())
			Enddo
		Enddo
	Endif


	oSection1:Finish()
	If nModRel == 2 .Or. nModRel == 3
		oSection2:Finish()
	Endif
	If Select(cAliasZPA) > 0
		(cAliasZPA)->(dbCloseArea())
		If File(cAliasZPA+GetDBExtension())
			fErase(cAliasZPA+GetDBExtension())
		Endif          
	Endif
Return


/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Cria Perguntas
*/
Static Function PCPR002Z(cPerg)
	PutSx1(cPerg,"01","Filial de ?    		","","","mv_ch1","C",04,0,0,"G","","XM0","","","MV_PAR01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Filial Ate ?        	","","","mv_ch2","C",04,0,0,"G","","XM0","","","MV_PAR02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Recurso de ?    		","","","mv_ch3","C",06,0,0,"G","","SH1","","","MV_PAR03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Recurso Ate  ?       ","","","mv_ch4","C",06,0,0,"G","","SH1","","","MV_PAR04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Produto de  ? 	    ","","","mv_ch5","C",15,0,0,"G","","SB1","","","MV_PAR05","","","","","","","","","","","","","","","","") 
	PutSx1(cPerg,"06","Produto ate  ? 	    ","","","mv_ch6","C",15,0,0,"G","","SB1","","","MV_PAR06","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Operação de ?    	","","","mv_ch7","C",02,0,0,"G","","SG2","","","MV_PAR07","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Operação Ate  ?      ","","","mv_ch8","C",02,0,0,"G","","SG2","","","MV_PAR08","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"09","Ferramenta de ?    	","","","mv_ch9","C",06,0,0,"G","","SH4","","","MV_PAR09","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"10","Ferramenta Ate  ?    ","","","mv_chA","C",06,0,0,"G","","SH4","","","MV_PAR10","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"11","Data de   ? 	    	","","","mv_chB","D",08,0,0,"G","",""   ,"","","MV_PAR11","","","","","","","","","","","","","","","","") 
	PutSx1(cPerg,"12","Data ate  ? 	    	","","","mv_chC","D",08,0,0,"G","",""   ,"","","MV_PAR12","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"13","Modelo ?				","","","mv_chD","N",01,0,1,"C","",""   ,"","","MV_PAR13","Sintetico","","","","Analitico","","","Mapa","","","","","","","","","","","")
Return