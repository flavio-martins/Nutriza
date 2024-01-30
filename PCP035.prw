#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP035()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Consulta Etiquetas									  			  ³±±
±±³          ³			                                                          ³±±
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
User Function PCP035A(__cCodEti)
	If !U_APPFUN01("Z6_CONSPAL")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif
	U_PCP035(1,__cCodEti) //->Leitura de código de barras de etiqueta Pallet
Return

User Function PCP035(_nTipo,__cCodEti)
	Local nPosLf		:= 0
	Private oDlgZPE
	Private _nOpca		:= 0
	Private aCabWzd		:= {}
	Private aIteWzd		:= {}
	Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Private oFldZPE
	Private noBrw		:= 0
	Private cPerg		:= Padr("PCP005",10)
	Private aEntid		:= {}
	Private sCodEti
	Private oCodEti
	Private cCodEti 	:= Iif(!Empty(AllTrim(__cCodEti)),__cCodEti,Space(16))
	Private sProduto
	Private oProduto
	Private cProduto 	:= Space(15)
	Private oDescPro
	Private sDescPro
	Private cDescPro 	:= Space(40)
	Private oStatusOK
	Private oStatusER
	Private cStatus

	//->Browse de ZPEs
	Private oWBrwZPE
	Private aWBrwZPE 	:= {}
	Private cStatus		:= ""
	Private oFntSt 		:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private __nTipo		:= Iif(!_nTipo == Nil,_nTipo,0)
	private _lHabCon	:= !Empty(AllTrim(__cCodEti))

	//->Parâmetros para interface
	Private _aButts		:= {}
	Private _cTitulo	:= "Log de Etiqueta"
	Private _aCabec		:= {}
	Private _aButts		:= {}
	Private aObjects	:= {}


	If !U_APPFUN01("Z6_CONSETI")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif

	AADD(_aButts,{"", { || ExecBlock("PCP035C",.F.,.F.,{10,.T.,oWBrwZPE,aWBrwZPE,.T.}) },"Sel.Todos", "Sel.Todos"})
	AADD(_aButts,{"", { || ExecBlock("PCP035C",.F.,.F.,{11,.T.,oWBrwZPE,aWBrwZPE,.T.}) },"Tira Sel.", "Tira Sel."})
	AADD(_aButts,{"", { || ExecBlock("PCP035E",.F.,.F.,{oWBrwZPE,aWBrwZPE}) },"Imprimir", "Imprimir"})
	ExecBlock("PCP035C",.F.,.F.,{1,.T.,oWBrwZPE,aWBrwZPE,.F.})
	_aCabec:={"", "Código", "Descrição", "Data", "Hora", "Código", "Usuário", "Histórico", "Etiqueta"}
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrwZPE, @oDlgZPE, @oWBrwZPE, .T., .T., @oStatusOK, @oStatusER, @cStatus, "PCP035X",,,,"PCP35GET" )
Return

/*
Funcao: OHFAP2P1
Descricao: Ponto de entrada para adiconar Say e Get.
*/
//User Function OHFAP2P1
User Function PCP35GET
	U_OHFUNA22(@oDlgZPE,@sCodEti,,"Cod. Etiqueta:",50,10,,,038,007,,-15,.T.)
	U_OHFUNA23(@oDlgZPE,@oCodEti, @cCodEti,,80,10,"@E 9999999999999999",.T.,037,57,,-15,.T., "PCP035A1", {})

	//@ 010,050 MSGET cProduto SIZE 145,11 OF oDlgZPE PIXEL PICTURE "@!"
	//@ 010,250 MSGET cDescPro SIZE 280,11 OF oDlgZPE PIXEL PICTURE "@!"


	/*
	U_OHFUNA22(@oDlgZPE,@sProduto,,"Produto:",50,10,,,038,145,,-15,.T.)
	U_OHFUNA23(@oDlgZPE,@oProduto, @cProduto,,50,10,"@!",.F.,037,175,,-15,.t.,)
	U_OHFUNA22(@oDlgZPE,@sDescPro,,"Descricao:",50,10,,,038,240,,-15,.T.)
	U_OHFUNA23(@oDlgZPE,@oDescPro, @cDescPro,,250,10,"@!",.F.,037,280,,-15,.t.,)
	*/
Return

/*
Funcao:PCP035A1()
Descricao: Valida Etiqueta
*/
User Function PCP035A1()
	Local lRet	:= .T.
	cStatus := OemToAnsi("")
	PCP035Z(1)
	If SubStr(cCodEti,1,2)=='90'
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+cCodEti))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+ZP1->ZP1_CODPRO))
			cProduto := ZP1->ZP1_CODPRO
			cDescPro := SB1->B1_DESC
			cStatus := ""
			oDescPro:refresh()
			oProduto:refresh()
		Else
			PCP035Z(0)
		Endif
	Else
		ZP4->(dbSetOrder(1))
		If ZP4->(dbSeek(xFilial()+cCodEti))
			ZP1->(dbSetOrder(2))
			If ZP1->(dbSeek(xFilial("ZP1")+cCodEti))
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+ZP1->ZP1_CODPRO))
				cProduto := ZP1->ZP1_CODPRO
				cDescPro := SB1->B1_DESC
				cStatus := ""
				oDescPro:refresh()
				oProduto:refresh()
			Endif
		Else
			PCP035Z(0)
		Endif
	Endif
	EXECBLOCK("PCP035C",.F.,.F.,{1,.T.,oWBrwZPE,aWBrwZPE,.T.})
Return lRet

/*
Funcao:PCP035B()
Descricao: Consulta Log.
*/
Static Function PCP035B(lObjCre)
	Local cSql	:= ""
	Local cAliasZPE := GetNextAlias()
	Local cAliasZPE2:= GetNextAlias()
	Local nReg	:= 0
	aWBrwZPE	:={}
	oProcess:SetRegua1(2)
	oProcess:IncRegua1("Logs do Dia...")

	cSql:=""
	If __nTipo == 0
		cSql:="SELECT * FROM "+RetSqlName("ZPE")+" ZPE WHERE ZPE_CODETI='"+cCodEti+"' AND ZPE_CODETI <> '' AND ZPE.D_E_L_E_T_ <> '*' ORDER BY ZPE_DATA, ZPE_HORA "
	ElseIf __nTipo == 1 .And. SubStr(cCodEti,1,2)=="90"
		cSql:="SELECT "
		cSql+="ZPE_FILIAL,ZPE_CODIGO,ZPE_DATA,ZPE_HORA,ZPE_USERID,ZPE_CODETI,ZPE_NOMUSE,ZPE_ORIGEM,ZPE_HISTOR,D_E_L_E_T_,R_E_C_N_O_ "
		cSql+="FROM "+RetSqlName("ZPE")+" ZPE WHERE (ZPE_CODPAL = '"+cCodEti+"' OR ZPE_CODETI='"+cCodEti+"') AND ZPE.D_E_L_E_T_ <> '*' AND ZPE_CODETI <> '' ORDER BY ZPE_DATA, ZPE_HORA "
	Else
		cStatus := OemToAnsi("Erro: Esta Consulta so pode ser utilizada por cartão palete.")
		PCP035Z(0)
	Endif
	If !Empty(AllTrim(cSql))
		cSql:= ChangeQuery(cSql)
		MemoWrite("C:\TEMP\"+Upper(FunName())+"_A.Sql",cSql)
		dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasZPE,.T.,.F.)
		oProcess:SetRegua2((cAliasZPE)->(LastRec()))
		(cAliasZPE)->(dbGoTop())
		While !(cAliasZPE)->(Eof())
			AADD(aWBrwZPE,{.F.,;
			(cAliasZPE)->ZPE_CODIGO,;
			POSICIONE("SX5",1,XFILIAL("SX5")+"Z3"+(cAliasZPE)->ZPE_CODIGO,"X5_DESCRI"),;
			DTOC(STOD((cAliasZPE)->ZPE_DATA)),;
			TRANSFORM((cAliasZPE)->ZPE_HORA,"@R 99:99:99"),;
			(cAliasZPE)->ZPE_USERID,;
			(cAliasZPE)->ZPE_NOMUSE,;
			(cAliasZPE)->ZPE_HISTOR,;
			(cAliasZPE)->ZPE_CODETI})
			oProcess:IncRegua2("Código: "+(cAliasZPE)->ZPE_CODIGO)
			(cAliasZPE)->(dbSkip())
		Enddo
		If Select(cAliasZPE) > 0
			(cAliasZPE)->(dbCloseArea())
			If File(cAliasZPE+GetDBExtension())
				fErase(cAliasZPE+GetDBExtension())
			Endif
		Endif
	Endif

	cSql:=""
	oProcess:IncRegua1("Arquivo Morto...")
	If __nTipo == 0
		cSql:="SELECT * FROM LOGPCP LOG WHERE LOG_CODETI='"+cCodEti+"' AND LOG_CODETI <> '' AND LOG.D_E_L_E_T_ <> '*' ORDER BY LOG_DATA, LOG_HORA "
	ElseIf __nTipo == 1 .And. SubStr(cCodEti,1,2)=="90"
		cSql:="SELECT "
		cSql+="LOG_FILIAL,LOG_CODIGO,LOG_DATA,LOG_HORA,LOG_USERID,LOG_CODETI,LOG_NOMUSE,LOG_ORIGEM,LOG_HISTOR,D_E_L_E_T_,R_E_C_N_O_ "
		cSql+="FROM LOGPCP LOG WHERE (LOG_PCP = '"+cCodEti+"' OR LOG_CODETI='"+cCodEti+"') AND LOG.D_E_L_E_T_ <> '*' AND LOG_CODETI <> '' ORDER BY LOG_DATA, LOG_HORA "
	Else
		cStatus := OemToAnsi("Erro: Esta Consulta só pode ser utilizada por cartão Pallet.")
		PCP035Z(0)
	Endif
	If !Empty(AllTrim(cSql))
		cSql:= ChangeQuery(cSql)
		MemoWrite("C:\TEMP\"+Upper(FunName())+"_B.Sql",cSql)
		dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasZPE2,.T.,.F.)
		oProcess:SetRegua2((cAliasZPE2)->(LastRec()))
		(cAliasZPE2)->(dbGoTop())
		While !(cAliasZPE2)->(Eof())
			AADD(aWBrwZPE,{.F.,;
			(cAliasZPE2)->LOG_CODIGO,;
			POSICIONE("SX5",1,XFILIAL("SX5")+"Z3"+(cAliasZPE2)->LOG_CODIGO,"X5_DESCRI"),;
			DTOC(STOD((cAliasZPE2)->LOG_DATA)),;
			TRANSFORM((cAliasZPE2)->LOG_HORA,"@R 99:99:99"),;
			(cAliasZPE2)->LOG_USERID,;
			(cAliasZPE2)->LOG_NOMUSE,;
			(cAliasZPE2)->LOG_HISTOR,;
			(cAliasZPE2)->LOG_CODETI})
			oProcess:IncRegua2("Código: "+(cAliasZPE2)->LOG_CODIGO)
			(cAliasZPE2)->(dbSkip())
		Enddo
		If Select(cAliasZPE2) > 0
			(cAliasZPE2)->(dbCloseArea())
			If File(cAliasZPE2+GetDBExtension())
				fErase(cAliasZPE2+GetDBExtension())
			Endif
		Endif
	Endif

	If Len(aWBrwZPE) >  0
		cStatus := OemToAnsi("Log de Etiqueta Encontrado.")
		If lObjCre
			PCP035Z(1)
		Endif
		Return .T.
	Else
		If 	Len(aWBrwZPE) <= 0
			AADD(aWBrwZPE,{.F.,"","","","","","","",""})
		Endif
		cStatus := OemToAnsi("Erro: Etiqueta não encontrada.")
		If lObjCre
			PCP035Z(0)
			cCodEti	:= Space(16)
			cProduto	:= Space(15)
			cDescPro	:= Space(40)
			ODLGZPE:Refresh()
			oCodEti:SetFocus()
		Endif
		Return .F.
	Endif
Return


/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Preenche Gride
*/
User Function PCP035C()
	Private oProcess
	If PARAMIXB[1]==0
		oProcess:=MsNewProcess():New( { || PCP035D(PARAMIXB[1],PARAMIXB[3],PARAMIXB[4]) } , "Marcando Registro..." , "Aguarde..." , .F. )
		oProcess:Activate()
	ElseIf PARAMIXB[1]==1
		oProcess:=MsNewProcess():New( { || PCP035B(PARAMIXB[5]) } , "Localizando Log..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If PARAMIXB[5]
			U_OHFUNA21(@oDlgZPE, @oWBrwZPE, _aCabec, @aWBrwZPE, "PCP035X")
		Endif
	ElseIf PARAMIXB[1]==10 .Or. PARAMIXB[1]==11
		oProcess:=MsNewProcess():New( { || PCP035D(PARAMIXB[1],PARAMIXB[3],PARAMIXB[4]) } , "Processando Registros..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Percorre grid
*/
Static Function PCP035D(nOpc,oDados,aDados)
	Local _lMarked
	Local _cChave
	Local _lProssegue	:= .F.
	Local _I		:= 0
	Local _X		:= 0
	Local aResult := {}
	Local aRet		:= {}
	Local cTitulox:= ""
	Private aErros	:= {}

	If nOpc==10 //->Seleciona
		cTitulox:="Seleciona: "
	ElseIf nOpc==11 //->Tira Seleciona
		cTitulox:="Tira Seleção: "
	Endif

	//->Marcar/Desmarcar
	If nOpc==0
		oProcess:SetRegua2(1)
		If _lMarked
			aDados[oDados:nAt,1] := .F.
		Else
			aDados[oDados:nAt,1] := .T.
		Endif
		oProcess:IncRegua2("Marcando...")
		Return
	Endif

	oProcess:SetRegua2(Len(aDados))
	oProcess:SetRegua1(1)
	If nOpc==10
		oProcess:IncRegua1(cTitulox)
	Elseif nOpc==11
		oProcess:IncRegua1(cTitulox)
	Endif

	For _I := 1 To Len(aDados)
		oProcess:IncRegua2(cTitulox + "Cod. Eti:" + AllTrim(aDados[_I,5]))
		//->Marca Desmarcar
		_lMarked := aDados[_I,1]
		If nOpc==10
			aDados[_I,1] := .T.
			oWBrwZPE:aArray[_I][1]:= .T.
			aWBrwZPE[_I][1]:=.T.
		ElseIf nOpc==11
			aDados[_I,1] := .F.
			oWBrwZPE:aArray[_I][1]:= .F.
			aWBrwZPE[_I][1]:=.F.
		Endif
	Next _I

	oDados:Refresh()
	oDlgZPE:Refresh()
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Prepara para Imprime Gride
*/
User Function PCP035E()
	Local oReport
	Local cTitulo := "Log de Etiqueta"
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport:=TReport():New("PCP035",cTitulo,, {|oReport| PCP035F(oReport,PARAMIXB[1],PARAMIXB[2])},cTitulo)
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return
/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Imprime Gride
*/
Static Function PCP035F(oReport,oDados,aDados)
	Local oSection1	:= Nil
	Local oBreak
	Local oFunction
	Local cAliasNFe	:= "NFeTMP"
	Local _I			:= 0

	oSection1:= TRSection():New(oReport,"",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A",cAliasNFe,OemToAnsi("Etiqueta"),PesqPict('ZP1',"ZP1_CODETI"),TamSX3("ZP1_CODETI")[1]+1)
	TRCell():New(oSection1,"B",cAliasNFe,OemToAnsi("Código"),PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+1)
	TRCell():New(oSection1,"C",cAliasNFe,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection1,"D",cAliasNFe,OemToAnsi("Qtd. Leituras"),"@!",15+1)
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	oSection2:= TRSection():New(oReport,"",{""})
	oSection2:SetTotalInLine(.F.)
	oSection2:ShowHeader()
	TRCell():New(oSection2,"A",cAliasNFe,OemToAnsi("Seq"),"@!",4+1)
	TRCell():New(oSection2,"B",cAliasNFe,OemToAnsi("Código"),PesqPict('ZPE',"ZPE_CODIGO"),TamSX3("ZPE_CODIGO")[1]+1)
	TRCell():New(oSection2,"C",cAliasNFe,OemToAnsi("Descrição"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
	TRCell():New(oSection2,"D",cAliasNFe,OemToAnsi("Data"),PesqPict('ZPE',"ZPE_DATA"),TamSX3("ZPE_DATA")[1]+1)
	TRCell():New(oSection2,"E",cAliasNFe,OemToAnsi("Hora"),"@R 99:99:99",TamSX3("ZPE_HORA")[1]+1)
	TRCell():New(oSection2,"F",cAliasNFe,OemToAnsi("Código"),"@!",6+1)
	TRCell():New(oSection2,"G",cAliasNFe,OemToAnsi("Usuário"),"@!",30+1)
	TRCell():New(oSection2,"H",cAliasNFe,OemToAnsi("Etiqueta"),"@!",16+1)
	TRCell():New(oSection2,"I",cAliasNFe,OemToAnsi("Histórico"),"@!",40+1)
	oSection2:SetLeftMargin(2)
	oSection2:SetPageBreak(.F.)
	oSection2:SetTotalText(" ")

	oSection1:Init()
	oSection2:= oReport:Section(2)
	oSection2:Init()
	oSection1:Cell("A"):SetValue(cCodEti)
	oSection1:Cell("B"):SetValue(cProduto)
	oSection1:Cell("C"):SetValue(cDescPro)
	oSection1:Cell("D"):SetValue(StrZero(Len(aDados),6))
	oSection1:PrintLine()
	For _I := 1 To Len(aDados)
		oSection2:Cell("A"):SetValue(StrZero(_I,3))
		oSection2:Cell("B"):SetValue(aDados[_I,2])
		oSection2:Cell("C"):SetValue(aDados[_I,3])
		oSection2:Cell("D"):SetValue(aDados[_I,4])
		oSection2:Cell("E"):SetValue(aDados[_I,5])
		oSection2:Cell("F"):SetValue(aDados[_I,6])
		oSection2:Cell("G"):SetValue(aDados[_I,7])
		oSection2:Cell("H"):SetValue(aDados[_I,9])
		oSection2:Cell("I"):SetValue(aDados[_I,8])
		oSection2:PrintLine()
	Next _I
	oSection1:Finish()
	oSection2:Finish()
Return


/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Marca
*/
User Function PCP035X()
	oWBrwZPE:aArray[oWBrwZPE:nAt][1]:= !oWBrwZPE:aArray[oWBrwZPE:nAt][1]
	aWBrwZPE[oWBrwZPE:nAt][1]:=oWBrwZPE:aArray[oWBrwZPE:nAt][1]
	oWBrwZPE:DrawSelect()
	oWBrwZPE:Refresh()
Return(.T.)

/*
Função:PCP035Z()
Descrição: Ativa Barra de Status
*/
Static Function PCP035Z(nTipo)
	If oStatusOK == Nil .Or. oStatusER == Nil
		Return
	Endif
	If nTipo==0
		oStatusOK:Hide()
		oStatusER:Show()
	Else
		oStatusOK:Show()
		oStatusER:Hide()
	EndIf
	oStatusOK:Refresh()
	oStatusER:Refresh()
	ODLGZPE:Refresh()
Return
