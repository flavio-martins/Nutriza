//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include 'Report.ch'

/*/{Protheus.doc} PCPR010
Relatório - Relatorio de Separação          
@author Flávio Martins dos Santos
@since 03/04/2019
@version 1.0
@example
u_PCPR010()
/*/

User Function PCPR010()
	Local aArea 	:= GetArea()
	Local lEmail 	:= .F.
	Local cPara 	:= ""	
	Local oFont1	:= TFont():New("Times New Roman",,044,,.T.,,,,,.F.,.F.)
	Local oFont2	:= TFont():New("Times New Roman",,020,,.T.,,,,,.F.,.F.)	
	Local nListBox1 := 1
	Local oMsCalen1
	Local oMsCalen2
	Local oSay1
	Local oSay2
	Local oSay3	
	Local oSButton1
	Local oSButton2
	Private STR_PULA :=	Chr(13)+Chr(10)
	Private oSay4	
	Private oCheckBo1
	Private oCheckBo2	
	Private oListBox1
	Private oSection1
	Private oTFont 	:= TFont():New('Courier new',,-16,.T.)
	Private oReport
	Private aItens	:= {{" ","","","",""}}
	Private OOK 	:= LOADBITMAP( GETRESOURCES(), "LBOK")
	Private ONO 	:= LOADBITMAP( GETRESOURCES(), "LBNO")	
	Private cPerg	:= ""	
	Private dData1
	Private dData2	
	Private cCargas := ""
	Private lCheckBo1 := .F.
	Private lCheckBo2 := .F.	
	Private cTotal := "0,00"
	Private nZP4Contad := 0
	Static oDlg
	oTFont:Bold
	DEFINE MSDIALOG oDlg TITLE "Retaório de Separação" FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL

	@ 220, 350 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT "Sintético." SIZE 100, 008 OF oDlg COLORS 0, 16777215 PIXEL 
	DEFINE SBUTTON oSButton1 FROM 229, 330 TYPE 02 OF oDlg ENABLE ACTION fSair()
	DEFINE SBUTTON oSButton2 FROM 229, 385 TYPE 01 OF oDlg ENABLE ACTION imprime()
	//	oMsCalen1 := MsCalend():New(052, 002, oDlg, .T.)
	//	oMsCalen1:dDiaAtu := ddatabase
	//	oMsCalen2 := MsCalend():New(146, 002, oDlg, .T.)
	//	oMsCalen2:dDiaAtu := CtoD("08/04/2019")
	//	@ 044, 009 SAY oSay1 PROMPT "Cargas De:" SIZE 046, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//	@ 137, 009 SAY oSay2 PROMPT "Cargas até:" SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 205, 390 SAY oSay4 PROMPT cTotal SIZE 320, 031 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
	@ 040, 004 LISTBOX oListBox1 FIELDS HEADER " ","Carga","Placa","Data","Peso"  SIZE 445, 157 OF oDlg COLORS 0, 16777215 PIXEL COLSIZES 50,50        
	@ 004, 146 SAY oSay3 PROMPT "Selecione as cargas" SIZE 320, 031 OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL
	@ 032, 350 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Somente com Placa." SIZE 100, 008 OF oDlg COLORS 0, 16777215 PIXEL 
	//	oMsCalen1:bChange := {|| oMsCalen1:CtrlRefresh(),dData1 := oMsCalen1:dDiaAtu,oMsCalen1:CtrlRefresh(),fCargs(dData1 := oMsCalen1:dDiaAtu,dData2 := oMsCalen2:dDiaAtu)}    
	//	oMsCalen2:bChange := {|| oMsCalen2:CtrlRefresh(),dData2 := oMsCalen2:dDiaAtu,oMsCalen2:CtrlRefresh(),fCargs(dData1 := oMsCalen1:dDiaAtu,dData2 := oMsCalen2:dDiaAtu)}    
	fCargs()
	If Len(aItens) = 0
		aItens	:= {{" ","","","",""}}
	EndIf
	oListBox1:SETARRAY(aItens)
	oListBox1:BLINE := {|| {;
	iif(aItens[oListBox1:NAT,1]=' ',ONO,OOK),;
	aItens[oListBox1:NAT,2],;
	aItens[oListBox1:NAT,3],;
	Dtoc(Stod(aItens[oListBox1:NAT,4])),;	
	aItens[oListBox1:NAT,5]}}
	oListBox1:bLDblClick   := {|| dblclick(oListBox1:NAT)}
	oListBox1:REFRESH()
	oCheckBo1:bChange	:= {|| fCargs()}
	/*	aItens[oListBox1:NAT,3],;*/
	/*	aItens[oListBox1:NAT,4],;*/

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function fCargs()
	cQuery := " SELECT ' ' as Contr, DAK_COD as Carga , DA3_PLACA as Placa, DAK_DATA as Data, DAK_PESO AS PESO " 
	cQuery += " FROM "+RetSQLName("DAK")+" A " 
	If lCheckBo1
		cQuery += " INNER JOIN "+RetSQLName("DA3")+" ON DA3_COD = DAK_CAMINH "
	Else
		cQuery += " LEFT JOIN "+RetSQLName("DA3")+" ON DA3_COD = DAK_CAMINH "
	EndIF
	cQuery += " WHERE DAK_XBLQCP IN ('2','3') "	
	cQuery += " AND DAK_DATA >= '20190101' "
	If lCheckBo1
		cQuery += " AND DA3_PLACA <> '' "
	EndIf
	cQuery += " AND A.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY DAK_DATA DESC "

	aItens := Qry2Arr(cQuery)
	oListBox1:SETARRAY(aItens)
	oListBox1:BLINE := {|| {;
	iif(aItens[oListBox1:NAT,1]=' ',ONO,OOK),;
	aItens[oListBox1:NAT,2],;
	aItens[oListBox1:NAT,3],;
	Dtoc(Stod(aItens[oListBox1:NAT,4])),;	
	aItens[oListBox1:NAT,5]}}
	oListBox1:REFRESH()

Return 

Static Function dblclick(NPOS)
	iF aItens[NPOS,1] = "X"
		aItens[NPOS,1] := " "
	ELSE
		aItens[NPOS,1] := "X"
	eNDif

	oListBox1:SETARRAY(aItens)
	oListBox1:BLINE := {|| {;
	iif(aItens[oListBox1:NAT,1]=' ',ONO,OOK),;
	aItens[oListBox1:NAT,2],;
	aItens[oListBox1:NAT,3],;
	Dtoc(Stod(aItens[oListBox1:NAT,4])),;	
	aItens[oListBox1:NAT,5]}}
	oListBox1:REFRESH()
	cTotal := Str(0)
	For i := 1 to Len(aItens)
		if aItens[i,1] # ' '
			cTotal := Str(Val(cTotal)+aItens[i,5])
		EndIF
	Next i
	oSay4:REFRESH()
Return

Static Function fSair()

	oDlg:end()

Return

Static Function imprime()

	cCargas := "'"
	For itm := 1 to len(aItens)
		If aitens[itm][1] = "X"
			cCargas += aitens[itm][2]+"','"
		EndIF
	Next itm
	cCargas := Substr(cCargas,1,len(cCargas)-2)
	oReport := fReportDef()                         

	oReport:PrintDialog()

Return

/*-------------------------------------------------------------------------------*
| Func:  fReportDef                                                             |
| Desc:  Função que monta a definição do relatório                              |
*-------------------------------------------------------------------------------*/

Static Function fReportDef()

	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil

	//Criação do componente de impressão
	//	oReport := TReport():New(cNome,"Relatório NCM x Cadastro Produtos",cNome,{|oReport| ReportPrint(oReport)},"Descrição do meu relatório")
	oReport := TReport():New("PCPR010","Relatorio de Separação","PCPR010",{|oReport| ReportPrint(oReport)},"descroao")
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	oReport:nEnvironment:= 2
	//Criando a seção de dados
	oSectDad := TRSection():New(oReport,"Dados",{"QRY_AUX"}, Nil, .F., .T.)
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	oSectDad:SetHeaderPage()
	//Colunas do relatório
	TRCell():New(oSectDad, "CODIGO", "QRY_AUX", "Produto", "@!", 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Descrição", "@!", 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.)
	If !lCheckBo2
		TRCell():New(oSectDad, "ZP1_PALETE", "QRY_AUX", "Pallet", "@!", 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZP4_ENDWMS", "QRY_AUX", "Endereco", "@!", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZP1_DTVALI", "QRY_AUX", "Validade", /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	EndIF
	TRCell():New(oSectDad, "ZP4_CONTAD", "QRY_AUX", "Quantidade", /*cPicture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	If !lCheckBo2
		//Definindo a quebra
		oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->PRODUTO },{|| "Total do Grupo:" })
		oSectDad:SetHeaderBreak(.T.)

		//Totalizadores
		oFunTot1 := TRFunction():New(oSectDad:Cell("ZP4_CONTAD"),,"SUM",oBreak,"Total:","@R 999,999.99"/*cPicture*/)
		oFunTot1:SetEndReport(.F.)
	EndIF	
Return oReport

/*-------------------------------------------------------------------------------*
| Func:  ReportPrint                                                              |
| Desc:  Função que imprime o relatório                                         |
*-------------------------------------------------------------------------------*/

Static Function ReportPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0

	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)

	//Montando consulta de dados
	cQryAux := ""
	If !lCheckBo2
		cQryAux += "SELECT C9_PRODUTO CODIGO, B1_DESC PRODUTO , ZP1_PALETE, ZP4_ENDWMS, ZP1_DTVALI, ZP4_CONTAD "		+ STR_PULA
		cQryAux += " FROM ( 	SELECT DAK_FILIAL, DAK.DAK_COD, SC9.C9_PRODUTO, SB1.B1_DESC"		+ STR_PULA
	Else
		cQryAux += "SELECT C9_PRODUTO CODIGO			
	EndIF
	cQryAux += "  	, SUM(CASE  		"		+ STR_PULA
	cQryAux += "	WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB/SB1.B1_CONV"		+ STR_PULA
	cQryAux += "	WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB"		+ STR_PULA
	If !lCheckBo2
		cQryAux += "	ELSE 0 END) CAIXASPED 	"		+ STR_PULA
		cQryAux += "	, SUM(CASE"		+ STR_PULA
		cQryAux += "	WHEN SB1.B1_TIPCONV = 'D' THEN SC9.C9_QTDLIB"		+ STR_PULA
		cQryAux += "	WHEN SB1.B1_TIPCONV = 'M' THEN SC9.C9_QTDLIB*SB1.B1_CONV"		+ STR_PULA
		cQryAux += "	ELSE 0 END) PESOPED"		+ STR_PULA

	Else
		cQryAux += "	ELSE 0 END) as ZP4_CONTAD 	"		+ STR_PULA		
		cQryAux += "	,B1_DESC PRODUTO	"		+ STR_PULA		
	EndIf
	cQryAux += "	FROM "+RetSQLName("DAK")+" DAK"		+ STR_PULA
	cQryAux += "	INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI.D_E_L_E_T_ = ' ' AND DAI.DAI_FILIAL = DAK_FILIAL "		+ STR_PULA
	cQryAux += "		AND DAI.DAI_COD = DAK.DAK_COD 	"		+ STR_PULA
	cQryAux += "	INNER JOIN "+RetSQLName("SC9")+" SC9 ON SC9.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = DAI.DAI_FILIAL "		+ STR_PULA
	cQryAux += "		AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' 	"		+ STR_PULA
	cQryAux += "	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '01  ' "		+ STR_PULA
	cQryAux += "		AND SB1.B1_COD = SC9.C9_PRODUTO 	"		+ STR_PULA	
	cQryAux += "	WHERE DAK.D_E_L_E_T_ = ' ' 	"		+ STR_PULA
	If !lCheckBo2
		cQryAux += "GROUP BY DAK_FILIAL, DAK.DAK_COD, SC9.C9_PRODUTO, SB1.B1_DESC ) A "		+ STR_PULA
		cQryAux += "	LEFT JOIN ( 	SELECT ZP1.ZP1_FILIAL, ZP1.ZP1_PALETE,  ZP1.ZP1_CARGA, ZP1.ZP1_CODPRO, ZP1.ZP1_DTVALI, 	ZP1.ZP1_STATUS, "		+ STR_PULA
		cQryAux += "					SUM(CASE  		"		+ STR_PULA
		cQryAux += "						WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 "		+ STR_PULA
		cQryAux += "							THEN ZP1.ZP1_PESO/SB1.B1_CONV 		"		+ STR_PULA
		cQryAux += "						WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 "		+ STR_PULA
		cQryAux += "							THEN ZP1.ZP1_PESO/SB1.B1_CONV 		"		+ STR_PULA
		cQryAux += "						ELSE 0 END) CAIXASEXP 	"		+ STR_PULA
		cQryAux += "					, SUM(ZP1.ZP1_PESO) PESOEXP 	"		+ STR_PULA
		cQryAux += "					FROM "+RetSQLName("ZP1")+" ZP1 	"		+ STR_PULA
		cQryAux += "					INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '01  ' "		+ STR_PULA
		cQryAux += "					AND SB1.B1_COD = ZP1.ZP1_CODPRO 	"		+ STR_PULA
		cQryAux += "	WHERE ZP1.D_E_L_E_T_ = ' ' AND ZP1.ZP1_PALETE <> '' AND ZP1_CARGA =''	"		+ STR_PULA
		cQryAux += "	"		+ STR_PULA
		cQryAux += "GROUP BY ZP1.ZP1_FILIAL, ZP1.ZP1_PALETE ,ZP1.ZP1_CARGA, ZP1.ZP1_CODPRO, ZP1.ZP1_DTVALI,ZP1_STATUS ) B ON B.ZP1_FILIAL = A.DAK_FILIAL "		+ STR_PULA
		cQryAux += "							AND B.ZP1_CODPRO = A.C9_PRODUTO "		+ STR_PULA
		cQryAux += "	LEFT JOIN "+RetSQLName("ZP4")+" ZP4 ON ZP4.ZP4_PALETE = ZP1_PALETE  AND ZP4_ENDWMS <> '' AND ZP4.D_E_L_E_T_ = ' '"		+ STR_PULA
		cQryAux += "WHERE DAK_FILIAL = '0101' AND DAK_COD IN ("+cCargas+")  AND (ZP1_STATUS = '1' OR ZP1_STATUS = '2') AND ZP4_ENDWMS <>''"		+ STR_PULA
		cQryAux += "	
		cQryAux += "GROUP BY C9_PRODUTO, B1_DESC, ZP1_PALETE, ZP4_ENDWMS, ZP1_DTVALI, ZP4_CONTAD"		+ STR_PULA
		cQryAux += "ORDER BY C9_PRODUTO, ZP1_PALETE, ZP1_DTVALI"		+ STR_PULA
	Else
		cQryAux += "AND DAK_COD IN ("+cCargas+") "		+ STR_PULA
		cQryAux += "GROUP BY C9_PRODUTO, B1_DESC "		+ STR_PULA
		cQryAux += "ORDER BY C9_PRODUTO "		+ STR_PULA	
	EndIF
	cQryAux := ChangeQuery(cQryAux)

	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "ZP1_DTVALI", "D")
	If !lCheckBo2
		MemoWrite("C:\TEMP\PCPR010_anal.SQL",cQryAux)
	Else
		MemoWrite("C:\TEMP\PCPR010_sint.SQL",cQryAux)
	EndIF
	cQuery := " SELECT SC9.C9_PRODUTO, 	"		+ STR_PULA
	cQuery += " 			SUM(CASE WHEN SB1.B1_TIPCONV = 'D' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB/SB1.B1_CONV  	"		+ STR_PULA
	cQuery += " 					WHEN SB1.B1_TIPCONV = 'M' AND SB1.B1_CONV > 0 THEN SC9.C9_QTDLIB ELSE 0 END) CAIXASPED 	"		+ STR_PULA
	cQuery += " 	FROM "+RetSQLName("DAK")+" DAK  	"		+ STR_PULA
	cQuery += " 		INNER JOIN "+RetSQLName("DAI")+" DAI ON DAI.D_E_L_E_T_ = ' ' AND DAI.DAI_FILIAL = DAK_FILIAL AND DAI.DAI_COD = DAK.DAK_COD  	"		+ STR_PULA
	cQuery += " 		INNER JOIN "+RetSQLName("SC9")+" SC9 ON SC9.D_E_L_E_T_ = ' ' AND SC9.C9_FILIAL = DAI.DAI_FILIAL AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO  	"		+ STR_PULA
	cQuery += " 														AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' '  	"		+ STR_PULA
	cQuery += " 		INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '01  ' AND SB1.B1_COD = SC9.C9_PRODUTO  	"		+ STR_PULA
	cQuery += " 	WHERE  DAK.D_E_L_E_T_ = ' '  	"		+ STR_PULA
	cQuery += " 	AND DAK_COD IN ("+cCargas+") 	"		+ STR_PULA
	cQuery += " 	GROUP BY SC9.C9_PRODUTO 	"		+ STR_PULA
	cQuery += " 	order by SC9.C9_PRODUTO 	"		+ STR_PULA

	aCxPedid := Qry2Arr(cQuery)

	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	nPosProd := 1
	nZP4Contad := 0
	lSum := .T.
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nZP4Contad += QRY_AUX->ZP4_CONTAD
		nPosProd := aScan(aCxPedid,{|x| x[1] == QRY_AUX->CODIGO })
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		If  nZP4Contad < aCxPedid[nPosProd][2]        
			oSectDad:PrintLine()
		ElseIF lSum
			oSectDad:PrintLine()
			lSum := .F.
		EndIf

		QRY_AUX->(DbSkip())

		If aCxPedid[nPosProd][1] # QRY_AUX->CODIGO
			nZP4Contad := 0
			lSum := .T.
		EndIF          

	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())

	RestArea(aArea)
Return

Static Function Qry2Arr(cQuery)

	Local aRet    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0
	Local i		   := 0
	cQuery := ChangeQuery(cQuery)

	If Select("_TRB") > 0
		_TRB->(dbCloseArea())
	Endif

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "_TRB" , .F. , .T. )

	dbSelectArea("_TRB")
	aStr 	:= _TRB->(dbStruct())
	aRet0	:= Array(Len(aStr))
	aRet1   := Array(Fcount())
	nRegAtu := 1
	For i := 1 to Len(aStr)
		aRet0[i] := aStr[i][1]
	Next
	//	Aadd(aRet,aclone(aRet0))   //cabeçalho com rotulos de campos

	While !Eof()

		For x:=1 To Fcount()
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet,aclone(aRet1))

		dbSkip()
		nRegAtu += 1
	Enddo

	dbSelectArea("_TRB")

Return(aRet)

