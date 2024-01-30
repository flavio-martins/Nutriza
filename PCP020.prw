#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦                                                     
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP020 ¦ Autor ¦ Evandro Oliveira Gomes ¦ Data ¦ 14/03/12  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Estoque em C‰mara												¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ NUTRIZA                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

ESTE RELATîRIO FOI TOTALMENTE RE-DESENVOLVIDO PARA ATENDER CORRETAMENTE
A NUTRIZA.
*/

User Function PCP020
	Local cTitulo		:= "Estoque em Camara"
	Local oReport
	Private nomeprog	:= FunName()
	Private cPerg		:= nomeprog+"A"

	dbSetOrder(1)

	putSx1(cPerg,"01","Produto de ?","."     ,"."       ,"mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"02","Produto ate?","."     ,"."       ,"mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","")

	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	oReport:=TReport():New(cPerg, cTitulo, cPerg, {|oReport| PCP020A(oReport,cTitulo) },cTitulo)
	oReport:SetPortrait(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()	
Return



Static Function PCP020A(oReport,cTitulo)
	Local aDados	:= {}
	Local _cQry	:= ""
	Local _nPos	:= 0

	_cQry := " SELECT B1_COD, B1_GRUPO, SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_STATUS"
	_cQry += " ,COUNT(DISTINCT ZP1_CODETI) QTDCAIXA "
	_cQry += " ,SUM(ZP1_PESO) PESO "
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1.ZP1_STATUS IN ('1','9','7') "
	_cQry += " AND ZP1_CARGA = ''"
	_cQry += " AND ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	_cQry += " GROUP BY B1_COD,B1_GRUPO,BM_DESC, ZP1_CODPRO, B1_DESC, ZP1_STATUS"
	_cQry += " ORDER BY 1,2"
	TcQuery _cQry New Alias "QRY"
	_cGrpAnt := ""
	QRY->(dbGoTop())
	While !QRY->(EOF())
		_nPos:=aScan(aDados,{|x| AllTrim(x[3]) == AllTrim(QRY->ZP1_CODPRO)})
		If _nPos==0
			AADD(aDados,{;
			QRY->B1_GRUPO,;
			QRY->BM_DESC,;
			SubStr(QRY->ZP1_CODPRO,1,6),;
			QRY->B1_DESC,;
			Iif(QRY->ZP1_STATUS $ "7/9",QRY->QTDCAIXA,0), Iif(QRY->ZP1_STATUS $ "7/9",QRY->PESO,0),;
			Iif(QRY->ZP1_STATUS=='1',QRY->QTDCAIXA,0), Iif(QRY->ZP1_STATUS=='1',QRY->PESO,0),;
			QRY->QTDCAIXA, QRY->PESO })
		Else
			If QRY->ZP1_STATUS=='1'
				aDados[_nPos,7]+= QRY->QTDCAIXA
				aDados[_nPos,8]+= QRY->PESO
			Else
				aDados[_nPos,5]+= QRY->QTDCAIXA
				aDados[_nPos,6]+= QRY->PESO
			Endif
			aDados[_nPos,9]+= QRY->QTDCAIXA
			aDados[_nPos,10]+= QRY->PESO
		Endif
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea()())

	//->Re-Organiza array
	oSection1:=TRSection():New(oReport,cTitulo,{""})
	oSection1:SetLeftMargin(2)
	oSection1:ShowHeader(.T.)
	oSection1:SetHeaderSection(.T.)
	oSection1:SetPageBreak(.T.)
	TRCell():New(oSection1,"A","ZP1",OemToAnsi("C—digo"),PesqPict('SB1',"B1_GRUPO"),TamSX3("B1_GRUPO")[1]+1)
	TRCell():New(oSection1,"B","ZP1",OemToAnsi("Grupo"),PesqPict('SBM',"BM_DESC"),TamSX3("BM_DESC")[1]+1)

	oSection2:=TRSection():New(oReport,"",{""})
	oSection2:SetLeftMargin(2)
	oSection2:ShowHeader(.T.)
	oSection2:SetPageBreak(.T.)
	oSection2:SetTotalText(" ")
	TRCell():New(oSection2,"A","ZP1",OemToAnsi("C—digo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection2,"B","ZP1",OemToAnsi("Produto"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)	
	TRCell():New(oSection2,"C","ZP1",OemToAnsi("Cxs. Susp."),"@E 999999999",9+1)
	TRCell():New(oSection2,"D","ZP1",OemToAnsi("Peso Susp."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"E","ZP1",OemToAnsi("Qtd. Ativ."),"@E 999999999",9+1)
	TRCell():New(oSection2,"F","ZP1",OemToAnsi("Peso Ativ."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	TRCell():New(oSection2,"G","ZP1",OemToAnsi("Qtd. Tota."),"@E 999999999",9+1)
	TRCell():New(oSection2,"H","ZP1",OemToAnsi("Peso Tota."),PesqPict('ZP1',"ZP1_PESO"),TamSX3("ZP1_PESO")[1]+1)
	oSection1:SetTotalText("TOTAL GERAL:")
	oBreak := TRBreak():New(oSection1,oSection1:Cell("B"),,.F.)
	TRFunction():New(oSection2:Cell("C"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("C"):GETVALUE(),"@E 999999999",,.F.,.F.)
	TRFunction():New(oSection2:Cell("D"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("D"):GETVALUE(),PesqPict('ZP1',"ZP1_PESO"),,.F.,.F.)
	TRFunction():New(oSection2:Cell("E"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("E"):GETVALUE(),"@E 999999999",,.F.,.F.)
	TRFunction():New(oSection2:Cell("F"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("F"):GETVALUE(),PesqPict('ZP1',"ZP1_PESO"),,.F.,.F.)
	TRFunction():New(oSection2:Cell("G"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("G"):GETVALUE(),"@E 999999999",,.F.,.F.)
	TRFunction():New(oSection2:Cell("H"),"SUB-TOTAL","SUM",oBreak,oSection2:Cell("H"):GETVALUE(),PesqPict('ZP1',"ZP1_PESO"),,.F.,.F.)

	aSort(aDados,,,{|x,y| x[2] + x[4] < y[2] + y[4]})

	oReport:SetMeter(Len(aDados))
	oSection1:Init() //-> Inicia a Seção 1
	oSection2:Init() //-> Inicia a Seção 2
	For _x:=1 To Len(aDados)

		If oReport:Cancel() //->Cancelar
			Exit
		EndIf

		oReport:IncMeter()

		If _cGrpAnt <> aDados[_x,1]

			If !Empty(_cGrpAnt)
				//oReport:ThinLine()
				oReport:SkipLine()
			Endif

			oSection1:Cell("A"):SetValue(aDados[_x,1])
			oSection1:Cell("B"):SetValue(aDados[_x,2])
			oSection1:PrintLine()

			If !Empty(_cGrpAnt)
				oReport:SkipLine()
				oReport:ThinLine()
			Endif

			_cGrpAnt := aDados[_x,1]
		EndIf
		oSection2:Cell("A"):SetValue(aDados[_x,3])
		oSection2:Cell("B"):SetValue(aDados[_x,4])
		oSection2:Cell("C"):SetValue(aDados[_x,5])
		oSection2:Cell("D"):SetValue(aDados[_x,6])
		oSection2:Cell("E"):SetValue(aDados[_x,7])
		oSection2:Cell("F"):SetValue(aDados[_x,8])
		oSection2:Cell("G"):SetValue(aDados[_x,9])
		oSection2:Cell("H"):SetValue(aDados[_x,10])
		oSection2:PrintLine()
	Next _x

	oSection1:Finish()
	oSection2:Finish()
Return