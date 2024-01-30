#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ PCP041()       ≥ Autor ≥ Evandro Gomes           ≥ Data ≥ 15/04/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥Relatório Suspensão de Etiqueta					  						≥±±
±±≥          ≥			                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico - Nutriza											      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Programador  ≥ Data   ≥ BOPS ≥          Manutencoes efetuadas                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Evandro Gomes≥ 29/09/17≥     ≥ Inclusão do sequestro dentro do modelo de susp.≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function PCP041()
	Local oReport
	Local cTitulo := "Relatorio de Caixas Suspensas"
	Private aWBrwPCP	:= {}
	Private cPerg		:= PADR("PCP041",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cAliasZP1	:= "ZP1"
	Private cUsSusFif	:= GetNewPar("MV_XUSUFIF",'000000') //-> Usuários que podem suspender caixas FIFO Fixo.
	Private _nTipoSus	:= 1 //-> Tipo de suspensão: 1=Padrão/2=Sequestro

	PCP041Z(cPerg) //->Cria Perguntas
	If !Pergunte(cPerg,.T.)
		Return .F.
	Else
		Private _nTipoSus	:= MV_PAR08 //-> Tipo de suspensão: 1=Padrão/2=Sequestro
	Endif

	//->Analisa Qual o tipo de suspensão que foi selecionada
	If _nTipoSus == 1 //->Padrão
		If !U_APPFUN01("Z6_SUSPENC")=="S" .And. __cUserId <> '000000' //-> .AND. !__cUserId $ cUsSusFif
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return .F.
		Endif
	Else
		If !U_APPFUN01("Z6_SEQUEST")=="S" .And. __cUserId <> '000000' //-> .AND. !__cUserId $ cUsSusFif
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return .F.
		Endif
	Endif

	oReport:=TReport():New("PCP041",cTitulo,, {|oReport| PCP041A(0,oReport)},cTitulo)
	oReport:SetPortrait(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return



/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa FunÁıes
*/
Static Function PCP041A(nOpc,oReport)
	If nOpc==0 //-> Seleciona
		oProcess := MsNewProcess():New( { || PCP041B(oReport) } , "Imprimindo..." , "Aguarde..." , .F. )
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
Static Function PCP041B(oReport)
	Local cSql	:=""
	Local aInfoBen
	Local _cAliasZP1	:= GetNextAlias()
	Local _cStatus	:= ""
	Local _nTipo
	aWBrwPCP:={}

	Pergunte(cPerg,.F.)
	_nTipo:= MV_PAR07
	oProcess:SetRegua1(1)

	oSection1:= TRSection():New(oReport,"",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	If _nTipo == 1 //->Sintético
		TRCell():New(oSection1,"A",cAliasZP1,OemToAnsi("Filial"),PesqPict('ZP1',"ZP1_FILIAL"),TamSX3("ZP1_FILIAL")[1]+1)
		TRCell():New(oSection1,"B",cAliasZP1,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection1,"C",cAliasZP1,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"D",cAliasZP1,OemToAnsi("Dta. Susp."),PesqPict('ZP1',"ZP1_DTSUSP"),TamSX3("ZP1_DTSUSP")[1]+1)
		TRCell():New(oSection1,"E",cAliasZP1,OemToAnsi("Status"),"@!",22+1)
		TRCell():New(oSection1,"F",cAliasZP1,OemToAnsi("Qtde"),"@E 99999",5+1)
		TRFunction():New(oSection1:Cell("F"),"Total de Caixas","SUM",,,"@E 99999",,.F.,.T.)
	Else
		TRCell():New(oSection1,"A",cAliasZP1,OemToAnsi("Filial"),PesqPict('ZP1',"ZP1_FILIAL"),TamSX3("ZP1_FILIAL")[1]+1)
		TRCell():New(oSection1,"B",cAliasZP1,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
		TRCell():New(oSection1,"C",cAliasZP1,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"D",cAliasZP1,OemToAnsi("Etiqueta"),PesqPict('ZP1',"ZP1_CODETI"),TamSX3("ZP1_CODETI")[1]+1)
		TRCell():New(oSection1,"E",cAliasZP1,OemToAnsi("Dta. Susp"),PesqPict('ZP1',"ZP1_DTSUSP"),TamSX3("ZP1_DTSUSP")[1]+1)
		TRCell():New(oSection1,"F",cAliasZP1,OemToAnsi("Dta. Fab"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
		TRCell():New(oSection1,"G",cAliasZP1,OemToAnsi("Dta. Val"),PesqPict('ZP1',"ZP1_DTVALI"),TamSX3("ZP1_DTVALI")[1]+1)
		TRCell():New(oSection1,"H",cAliasZP1,OemToAnsi("Palete"),PesqPict('ZP1',"ZP1_PALETE"),TamSX3("ZP1_PALETE")[1]+1)
		TRCell():New(oSection1,"I",cAliasZP1,OemToAnsi("Status"),"@!",22+1)
		TRFunction():New(oSection1:Cell("A"),"QTd. Registros" ,"COUNT",,,"@E 999999",,.F.,.T.)
	Endif


	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	cSql:="SELECT "
	If _nTipo == 1 //->Sintético
		cSql+="ZP1_FILIAL, ZP1_CODPRO, ZP1_DTSUSP, ZP1_STATUS, COUNT(*) QTDETI "
	Else
		cSql+="DISTINCT ZP1_FILIAL, ZP1_CODPRO, ZP1_CODETI, ZP1_DTSUSP, ZP1_DTPROD, ZP1_DTVALI, ZP1_PALETE, ZP1_STATUS "
	Endif
	cSql+="FROM "+RETSQLNAME("ZP1")+ " ZP1 "
	cSql+="WHERE "
	cSql+="ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	If !Empty(AllTrim(MV_PAR03))
		cSql+="AND ZP1_CODPRO = '"+MV_PAR03+"' "
	Endif
	If _nTipoSus == 1 //->Padrão
		If MV_PAR06 == 1
			cSql+="AND ZP1_STATUS IN ('1','2','3','4') "
		Elseif MV_PAR06 == 2
			cSql+="AND ZP1_STATUS IN ('9') "
		Else
			cSql+="AND ZP1_STATUS IN ('1','2','3','4','9') "
		Endif
	Else
		If MV_PAR06 == 1
			cSql+="AND ZP1_STATUS IN ('1','2','3','4') "
		Elseif MV_PAR06 == 2
			cSql+="AND ZP1_STATUS IN ('7') "
		Else
			cSql+="AND ZP1_STATUS IN ('1','2','3','4','7') "
		Endif
	Endif
	cSql+="AND ZP1_DTSUSP BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
	cSql+="AND ZP1_DTATIV <> '' "
	cSql+="AND ZP1_CARGA = '' "
	cSql+="AND ZP1_FLAGPR = '1' " //->Etiqueta já impressa
	cSql+="AND ZP1_REPROC <> 'S' "
	cSql+="AND ZP1.D_E_L_E_T_ <> '*' "

	If _nTipo == 1 //->Sintético
		cSql+="GROUP BY ZP1_FILIAL, ZP1_CODPRO, ZP1_DTSUSP, ZP1_STATUS "
	Else
		cSql+="ORDER BY ZP1_DTSUSP, ZP1_CODPRO "
	Endif

	cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP1,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP1)->(LastRec()))
	(_cAliasZP1)->(dbGoTop())

	While !(_cAliasZP1)->(Eof())

		If (_cAliasZP1)->ZP1_STATUS=="1"
			_cStatus:="1-ATIVADA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="3"
			_cStatus:="3-EXCLUIDA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="4"
			_cStatus:="4-ROTATIVIDADE"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="5"
			_cStatus:="5-NAO INVENTARIDADA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="7"
			_cStatus:="7-SEQUESTRADA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="9"
			_cStatus:="9-SUSPENSA"
		Endif

		If _nTipo == 1 //->Sintético
			AADD(aWBrwPCP,{;
			(_cAliasZP1)->ZP1_FILIAL,;
			(_cAliasZP1)->ZP1_CODPRO,;
			POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP1)->ZP1_CODPRO,"B1_DESC"),;
			DTOC(STOD((_cAliasZP1)->ZP1_DTSUSP)),;
			_cStatus,;
			(_cAliasZP1)->QTDETI;
			})
			oProcess:IncRegua2("Produto: "+AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP1)->ZP1_CODPRO,"B1_DESC")))
		Else
			AADD(aWBrwPCP,{;
			(_cAliasZP1)->ZP1_FILIAL,;
			(_cAliasZP1)->ZP1_CODPRO,;
			POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP1)->ZP1_CODPRO,"B1_DESC"),;
			(_cAliasZP1)->ZP1_CODETI,;
			DTOC(STOD((_cAliasZP1)->ZP1_DTSUSP)),;
			DTOC(STOD((_cAliasZP1)->ZP1_DTPROD)),;
			DTOC(STOD((_cAliasZP1)->ZP1_DTVALI)),;
			(_cAliasZP1)->ZP1_PALETE,;
			_cStatus;
			})
			oProcess:IncRegua2("Etiqueta: "+(_cAliasZP1)->ZP1_CODETI)
		Endif

		(_cAliasZP1)->(dbSkip())
	Enddo

	If Select(_cAliasZP1) > 0
		(_cAliasZP1)->(dbCloseArea())
		If File(_cAliasZP1+GetDBExtension())
			fErase(_cAliasZP1+GetDBExtension())
		Endif
	Endif

	//->Preenche dados do Browse
	If Len(aWBrwPCP) <= 0
		ASIZE(aWBrwPCP,0)
		If _nTipo == 1 //->Sintético
			aAdd(aWBrwPCP,{"","","","","",""})
		Else
			aAdd(aWBrwPCP,{"","","","","","","","",""})
		Endif
	Endif

	oSection1:Init()
	For _I := 1 To Len(aWBrwPCP)
		If _nTipo == 1 //->Sintético
			oSection1:Cell("A"):SetValue(aWBrwPCP[_I,1])
			oSection1:Cell("B"):SetValue(aWBrwPCP[_I,2])
			oSection1:Cell("C"):SetValue(aWBrwPCP[_I,3])
			oSection1:Cell("D"):SetValue(CTOD(aWBrwPCP[_I,4]))
			oSection1:Cell("E"):SetValue(aWBrwPCP[_I,5])
			oSection1:Cell("F"):SetValue(aWBrwPCP[_I,6])
		Else
			oSection1:Cell("A"):SetValue(aWBrwPCP[_I,1])
			oSection1:Cell("B"):SetValue(aWBrwPCP[_I,2])
			oSection1:Cell("C"):SetValue(aWBrwPCP[_I,3])
			oSection1:Cell("D"):SetValue(aWBrwPCP[_I,4])
			oSection1:Cell("E"):SetValue(CTOD(aWBrwPCP[_I,5]))
			oSection1:Cell("F"):SetValue(CTOD(aWBrwPCP[_I,6]))
			oSection1:Cell("G"):SetValue(CTOD(aWBrwPCP[_I,7]))
			oSection1:Cell("H"):SetValue(aWBrwPCP[_I,8])
			oSection1:Cell("I"):SetValue(aWBrwPCP[_I,9])
		Endif
		oSection1:PrintLine()
	Next _I
	oSection1:Finish()

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Perguntas
*/
Static Function PCP041Z(cPerg)
	PutSx1(cPerg,"01","Filial de ?"  	,'','',"mv_ch1","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Filial ate?"    ,'','',"mv_ch2","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Produto de ?"  	,'','',"mv_ch3","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","D. Suspenc. de?",'','',"mv_ch4","D",TamSx3("ZP1_DTSUSP")[1] ,0,,"G","","   ","",""	,"mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","D. Suspenc. Ate?" ,'','',"mv_ch5","D",TamSx3("ZP1_DTSUSP")[1] ,0,,"G","","   ","",""	,"mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Status?"			,'','',"mv_ch6","N",01,0,1,"C","","","","","MV_PAR06","Nao Suspensa","","","","Suspensa","","","Todas","","","","","","","","","","","")
	PutSx1(cPerg,"07","Tp. Relatorio?" ,'','',"mv_ch7","N",01,0,1,"C","","","","","MV_PAR07","Sintetico","","","","Analitico","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Tipo?"			,'','',"mv_ch8","N",01,0,1,"C","","","","","MV_PAR08","Susp. Padrao","","","","Sequestro","","","","","","","","","","","","","","")
Return

