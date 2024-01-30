#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ PCP043()       ≥ Autor ≥ Evandro Gomes           ≥ Data ≥ 15/04/15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥Relatório Processos por código de log                               ≥±±
±±≥          ≥			                            	                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico - Nutriza											      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Programador  ≥ Data   ≥ BOPS ≥          Manutencoes efetuadas                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function PCP043()
	Local oReport
	Local cTitulo := "Relatorio de Processos"
	Private aWBrwPCP	:= {}
	Private cPerg		:= PADR("PCP043",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cAliasZP	:= "ZP1"

	PCP043Z(cPerg) //->Cria Perguntas
	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	oReport:=TReport():New("PCP043",cTitulo,cPerg, {|oReport| PCP043A(0,oReport)},cTitulo)
	oReport:SetLandscape(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa FunÁıes
*/
Static Function PCP043A(nOpc,oReport)
	If nOpc==0 //-> Seleciona
		oProcess := MsNewProcess():New( { || PCP043B(oReport) } , "Imprimindo..." , "Aguarde..." , .F. )
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
Static Function PCP043B(oReport)
	Local cSql	:=""
	Local aInfoBen
	Local _cAliasZP	:= GetNextAlias()
	Local _cStatus	:= ""
	Local _nTipo
	Local _xCarga
	Local _xProduc
	aWBrwPCP:={}

	Pergunte(cPerg,.F.)
	_nTipo:= MV_PAR08
	oProcess:SetRegua1(1)

	oSection1:= TRSection():New(oReport,"",{""})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()

	If _nTipo == 1 //->Sintético
		TRCell():New(oSection1,"A",cAliasZP,OemToAnsi("Filial"),PesqPict('ZP1',"ZP1_FILIAL"),TamSX3("ZP1_FILIAL")[1]+1)
		TRCell():New(oSection1,"B",cAliasZP,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),5+1)
		TRCell():New(oSection1,"C",cAliasZP,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"D",cAliasZP,OemToAnsi("Data"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
		TRCell():New(oSection1,"E",cAliasZP,OemToAnsi("Acao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"F",cAliasZP,OemToAnsi("Qtde"),"@E 99999",5+1)
	Else
		TRCell():New(oSection1,"A",cAliasZP,OemToAnsi("Filial"),PesqPict('ZP1',"ZP1_FILIAL"),TamSX3("ZP1_FILIAL")[1]+1)
		TRCell():New(oSection1,"B",cAliasZP,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),5+1)
		TRCell():New(oSection1,"C",cAliasZP,OemToAnsi("Descricao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"D",cAliasZP,OemToAnsi("Data"),PesqPict('ZP1',"ZP1_DTPROD"),TamSX3("ZP1_DTPROD")[1]+1)
		TRCell():New(oSection1,"E",cAliasZP,OemToAnsi("Etiqueta"),PesqPict('ZP1',"ZP1_CODETI"),TamSX3("ZP1_CODETI")[1]+1)
		TRCell():New(oSection1,"F",cAliasZP,OemToAnsi("Acao"),PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+1)
		TRCell():New(oSection1,"G",cAliasZP,OemToAnsi("Usuario"),PesqPict('ZPE',"ZPE_NOMUSE"),TamSX3("ZPE_NOMUSE")[1]+1)
		TRCell():New(oSection1,"H",cAliasZP,OemToAnsi("Carga"),PesqPict('ZP1',"ZP1_CARGA"),20+1)
		TRCell():New(oSection1,"I",cAliasZP,OemToAnsi("Dt. Carga"),PesqPict('ZP1',"ZP1_DTCAR"),20+1)
		TRCell():New(oSection1,"J",cAliasZP,OemToAnsi("Dt. Produc."),PesqPict('ZP1',"ZP1_DTPROD"),20+1)
		TRCell():New(oSection1,"K",cAliasZP,OemToAnsi("Palete"),PesqPict('ZP1',"ZP1_DTPROD"),20+1)
		TRCell():New(oSection1,"L",cAliasZP,OemToAnsi("Peso"),PesqPict('ZP1',"ZP1_PESO"),10+1)
		TRCell():New(oSection1,"M",cAliasZP,OemToAnsi("Status"),PesqPict('SB1',"B1_DESC"),30+1)
	Endif
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	////*If _nTipo == 1 //->Sintético
	///	cSql+=" SELECT ZPE_FILIAL FILIAL, ZPE_CODIGO CODIGO, ZPE_DATA DATA, COUNT(*)"
	///Else
	///	cSql+=" SELECT ZP1_FILIAL FILIAL, ZPE_CODIGO CODIGO, ZP1_CODETI CODETI, ZPE_DATA DATA, ZP1_CODPRO CODPRO, B1_DESC DESCR, X5_DESCRI DESCRI, ZP1_STATUS STATUS, ZPE_USERID USERID, ZPE_NOMUSE NOMUSE"
	///Endif*/

	cSql+=" SELECT ZPE_FILIAL FILIAL, ZPE_CODIGO CODIGO, ZPE_CODETI CODETI, ZPE_DATA DATA, ZPE_USERID USERID, ZPE_NOMUSE NOMUSE "
	cSql+=" FROM  "+RETSQLNAME("ZPE")+ " ZPE "
	cSql+=" WHERE "
	cSql+="ZPE_DATA BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	If !Empty(AllTrim(MV_PAR07))
		cSql+="AND ZPE_CODIGO = '"+AllTrim(MV_PAR07)+"' "
	Endif
	If MV_PAR11==29
		cSql+="AND SUBSTRING(ZPE_CODETI,1,2) = '90' "
	ElseIf MV_PAR11==3
		cSql+="AND SUBSTRING(ZPE_CODETI,1,2) <> '90' "
	Endif
	If !Empty(AllTrim(MV_PAR15))
		cSql+="AND (ZPE_CODETI BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' OR ZPE_CODETI='"+MV_PAR15+"') "
	Else
		cSql+="AND ZPE_CODETI BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' "
	Endif
	If !Empty(AllTrim(MV_PAR14))
		If !Empty(AllTrim(MV_PAR15))
			cSql+="AND (ZPE_HISTOR LIKE '%"+AllTrim(MV_PAR14)+"%' OR ZPE_HISTOR LIKE '%"+AllTrim(MV_PAR15)+"%') "
		Else
			cSql+="AND ZPE_HISTOR LIKE '%"+AllTrim(MV_PAR14)+"%'"
		Endif
	Else
		cSql+="AND ZPE_HISTOR LIKE '%"+AllTrim(MV_PAR15)+"%'"
	Endif
	cSql+="AND ZPE_USERID BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
	cSql+="AND ZPE.D_E_L_E_T_ <> '*' "
	/*
	cSql+=" AND ( "
	cSql+=" EXISTS(SELECT COUNT(*) FROM "+RETSQLNAME("ZP1")+ " ZP1 WHERE ZP1_CODETI=ZPE_CODETI AND ZP1_CODPRO BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP1.D_E_L_E_T_ <> '*' )"
	cSql+=" OR EXISTS(SELECT COUNT(*) FROM ZP1010_MORTO ZP1 WHERE ZP1_CODETI=ZPE_CODETI AND ZP1_CODPRO BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP1.D_E_L_E_T_ <> '*' )"
	cSql+=" OR EXISTS(SELECT COUNT(*) FROM "+RETSQLNAME("ZP4")+ " ZP4 WHERE ZP4_PALETE=ZPE_CODETI AND ZP4_PRODUT BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP4.D_E_L_E_T_ <> '*' )"
	cSql+=" ) "
	*/

	cSql+=" UNION ALL "

	cSql+=" SELECT LOG_FILIAL FILIAL, LOG_CODIGO CODIGO, LOG_CODETI CODETI, LOG_DATA DATA, LOG_USERID USERID, LOG_NOMUSE NOMUSE "
	cSql+=" FROM  "+RETSQLNAME("LOGPCP")+ " LOGPCP "
	cSql+=" WHERE "
	cSql+="LOG_DATA BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	If !Empty(AllTrim(MV_PAR07))
		cSql+="AND LOG_CODIGO = '"+AllTrim(MV_PAR07)+"' "
	Endif
	If MV_PAR11==2
		cSql+="AND SUBSTRING(LOG_CODETI,1,2) = '90' "
	ElseIf MV_PAR11==3
		cSql+="AND SUBSTRING(LOG_CODETI,1,2) <> '90' "
	Endif
	If !Empty(AllTrim(MV_PAR15))
		cSql+="AND (LOG_CODETI BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' OR LOG_CODETI='"+MV_PAR15+"') "
	Else
		cSql+="AND LOG_CODETI BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' "
	Endif
	If !Empty(AllTrim(MV_PAR14))
		If !Empty(AllTrim(MV_PAR15))
			cSql+="AND (LOG_HISTOR LIKE '%"+AllTrim(MV_PAR14)+"%' OR LOG_HISTOR LIKE '%"+AllTrim(MV_PAR15)+"%') "
		Else
			cSql+="AND LOG_HISTOR LIKE '%"+AllTrim(MV_PAR14)+"%'"
		Endif
	Else
		cSql+="AND LOG_HISTOR LIKE '%"+AllTrim(MV_PAR15)+"%'"
	Endif
	cSql+="AND LOG_USERID BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "
	cSql+="AND LOGPCP.D_E_L_E_T_ <> '*' "
	/*
	cSql+=" AND ( "
	cSql+=" EXISTS(SELECT COUNT(*) FROM "+RETSQLNAME("ZP1")+ " ZP1 WHERE ZP1_CODETI=LOG_CODETI AND ZP1_CODPRO BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP1.D_E_L_E_T_ <> '*' )"
	cSql+=" OR EXISTS(SELECT COUNT(*) FROM ZP1010_MORTO ZP1 WHERE ZP1_CODETI=LOG_CODETI AND ZP1_CODPRO BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP1.D_E_L_E_T_ <> '*' )"
	cSql+=" OR EXISTS(SELECT COUNT(*) FROM "+RETSQLNAME("ZP4")+ " ZP4 WHERE ZP4_PALETE=LOG_CODETI AND ZP4_PRODUT BETWEEN '"+SUBSTRING(MV_PAR03,1,5)+"' AND '"+SUBSTRING(MV_PAR04,1,5)+"' AND ZP4.D_E_L_E_T_ <> '*' )"
	cSql+=" ) "
	*/

	cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP)->(LastRec()))
	(_cAliasZP)->(dbGoTop())

	While !(_cAliasZP)->(Eof())

		_cCodProd	:= ""
		_cStatuso	:= ""
		_cDesProd	:= ""
		_cX5Desc	:= ""
		_cCarga		:= ""
		_xCarga		:= ""
		_xProduc	:= ""
		_cPalete	:= ""
		_nPeso		:= ""

		_lLocEtiq	:= .F.

		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+(_cAliasZP)->CODETI))

			_cCodProd	:= ZP1->ZP1_CODPRO
			_cStatuso	:= ZP1->ZP1_STATUS  //1=Ativa;2=Em carga;3=Faturada;4=Bloqueada;5=Baixada Inventario;9=Suspensa
			_cCarga		:= ZP1->ZP1_CARGA
			_xCarga		:= Dtoc(ZP1->ZP1_DTCAR)
			_xProduc	:= Dtoc(ZP1->ZP1_DTPROD)
			_cPalete	:= ZP1->ZP1_PALETE
			_nPeso		:= ZP1->ZP1_PESO

		Else
			ZP4->(dbSetOrder(1))
			If ZP4->(dbSeek(xFilial("ZP4")+(_cAliasZP)->CODETI))
				_cCodProd:=ZP4->ZP4_PRODUT
				ZP1->(dbSetOrder(2))

				If ZP1->(dbSeek(xFilial("ZP1")+(_cAliasZP)->CODETI))

					_cStatuso	:= ZP1->ZP1_STATUS  //1=Ativa;2=Em carga;3=Faturada;4=Bloqueada;5=Baixada Inventario;9=Suspensa
					_cCodProd	:= ZP1->ZP1_CODPRO
					_cCarga		:= ZP1->ZP1_CARGA
					_xCarga		:= Dtoc(ZP1->ZP1_DTCAR)
					_xProduc	:= Dtoc(ZP1->ZP1_DTPROD)
					_cPalete	:= ZP1->ZP1_PALETE
					_nPeso		:= ZP1->ZP1_PESO

				Endif

			Else
				cSql:="SELECT * FROM ZP1010_MORTO ZP1 WHERE ZP1_CODETI='"+(_cAliasZP)->CODETI+"' AND ZP1.D_E_L_E_T_ <> '*' "
				TCQUERY cSql NEW ALIAS "ZP1MORTO"
				If !ZP1MORTO->(Eof())

					_cCodProd	:= ZP1MORTO->ZP1_CODPRO
					_cStatuso	:= ZP1MORTO->ZP1_STATUS  //1=Ativa;2=Em carga;3=Faturada;4=Bloqueada;5=Baixada Inventario;9=Suspensa
					_cCarga		:= ZP1MORTO->ZP1_CARGA
					_xCarga		:= Dtoc(Stod(ZP1MORTO->ZP1_DTCAR))
					_xProduc	:= Dtoc(Stod(ZP1MORTO->ZP1_DTPROD))
					_cPalete	:= ZP1MORTO->ZP1_PALETE
					_nPeso		:= ZP1MORTO->ZP1_PESO

				Else
					cSql:="SELECT * FROM "+RETSQLNAME("ZP4")+ " ZP4 WHERE ZP4_PALETE='"+(_cAliasZP)->CODETI+"' AND ZP4.D_E_L_E_T_ = '*' "
					TCQUERY cSql NEW ALIAS "ZP4MORTO"
					If !ZP4MORTO->(Eof())
						_cCodProd	:= ZP4MORTO->ZP4_PRODUT
						_cStatuso	:= "*"

					Endif
					ZP4MORTO->(dbCloseArea())
				Endif
				ZP1MORTO->(dbCloseArea())
			Endif
		Endif

		SB1->(dbSetOrder(1))
		If Len(AllTrim(_cCodProd)) > 0 .And. SB1->(dbSeek(xFilial("SB1")+_cCodProd))
			_cDesProd:=SB1->B1_DESC
		Else
			_cDesProd:="Não Encontrado"
		Endif

		SX5->(DBSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+'Z3'+(_cAliasZP)->CODIGO))
			_cX5Desc:=SX5->X5_DESCRI
		Endif

		If _nTipo == 1 //->Sintético
			_nPos:=aScan(aWBrwPCP,{|x| AllTrim(x[2]) == AllTrim(_cCodProd) })
			If _nPos == 0
				AADD(aWBrwPCP,{(_cAliasZP)->FILIAL,_cCodProd,	_cDesProd,DTOC(STOD((_cAliasZP)->DATA)),_cX5Desc,1	})
			Else
				aWBrwPCP[_nPos,6]+=1
			Endif
		Else

			If _cStatuso=="*"
				_cStatus:="*-Pal. Deletado"
			ElseIf _cStatuso=="1"
				IF !EMPTY(_cPalete)
					_cStatus:="1-ATIVADA/COM PALETE"
				ELSE
					_cStatus:="1-ATIVADA/SEM PALETE"
				ENDIF
			ElseIf _cStatuso=="3"
				_cStatus:="3-EXCLUIDA"
			ElseIf _cStatuso=="4"
				_cStatus:="4-ROTATIVIDADE"
			ElseIf _cStatuso=="5"
				_cStatus:="5-NAO INVENTARIDADA"
			ElseIf _cStatuso=="9"
				_cStatus:="9-SUSPENSA"
			Else
				_cStatus:=_cStatuso
			Endif
			If !(MV_PAR16 == 2 .and. EMPTY(_cPalete))
				AADD(aWBrwPCP,{	(_cAliasZP)->FILIAL,_cCodProd,	_cDesProd,	DTOC(STOD((_cAliasZP)->DATA)),	(_cAliasZP)->CODETI,_cX5Desc,(_cAliasZP)->NOMUSE,_cCarga, _xCarga, _xProduc, _cPalete, _nPeso, _cStatus })
			EndIf
		Endif

		oProcess:IncRegua2("Produto: "+_cCodProd + "-" + SubStr(_cDesProd,1,15))

		(_cAliasZP)->(dbSkip())
	Enddo

	If Select(_cAliasZP) > 0
		(_cAliasZP)->(dbCloseArea())
		If File(_cAliasZP+GetDBExtension())
			fErase(_cAliasZP+GetDBExtension())
		Endif
	Endif

	//->Preenche dados do Browse
	If Len(aWBrwPCP) <= 0
		ASIZE(aWBrwPCP,0)
		aAdd(aWBrwPCP,{"","","","","","","","","","","","","","","","","","","","",""})
	Endif

	If _nTipo == 1 //->Sintético
		aWBrwPCP := ASort(aWBrwPCP,,, { | x,y | x[1]+x[2]+x[4] < x[1]+x[2]+x[4] })
	Else
		aWBrwPCP := ASort(aWBrwPCP,,, { | x,y | x[1]+x[2]+x[4]+x[5] < x[1]+x[2]+x[4]+x[5] })
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
			oSection1:Cell("D"):SetValue(CTOD(aWBrwPCP[_I,4]))
			oSection1:Cell("E"):SetValue(aWBrwPCP[_I,5])
			oSection1:Cell("F"):SetValue(aWBrwPCP[_I,6])
			oSection1:Cell("G"):SetValue(aWBrwPCP[_I,7])
			oSection1:Cell("H"):SetValue(aWBrwPCP[_I,8])
			oSection1:Cell("I"):SetValue(aWBrwPCP[_I,9])
			oSection1:Cell("J"):SetValue(aWBrwPCP[_I,10])
			oSection1:Cell("K"):SetValue(aWBrwPCP[_I,11])
			oSection1:Cell("L"):SetValue(aWBrwPCP[_I,12])
			oSection1:Cell("M"):SetValue(aWBrwPCP[_I,13])
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
Static Function PCP043Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Filial de ?"  	,'','',"mv_ch1","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Filial ate?"    ,'','',"mv_ch2","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Produto de ?"  	,'','',"mv_ch3","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Produto ate ?"  ,'','',"mv_ch4","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Data Log de?"  	,'','',"mv_ch5","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par05","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Date Log Ate?" 	,'','',"mv_ch6","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par06","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","Código Ate?" 	,'','',"mv_ch7","C",6						  ,0,,"G","","Z3 ","",""	,"mv_par07","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"08","Tp. Relatorio?" ,'','',"mv_ch8","N",01,0,1,"C","","","","","MV_PAR08","Sintetico","","","","Analitico","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"09","Usuario de ?"  	,'','',"mv_ch9","C",TamSx3("ZPE_USERID")[1] ,0,,"G","","USR","",""	,"mv_par09","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"10","Usuario ate ?"  ,'','',"mv_cha","C",TamSx3("ZPE_USERID")[1] ,0,,"G","","USR","",""	,"mv_par10","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"11","Tp. Etiqueta?" ,'','',"mv_chb","N",01,0,1,"C","","","","","MV_PAR11","Ambas","","","","Palete","","","Caixa","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"12","Da Etiqueta?		",".","."       	,"mv_che","C",16,0,0,"G","","",""," ","mv_par12","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"13","Ate Etiqueta?	",".","."       	,"mv_chf","C",16,0,0,"G","","",""," ","mv_par13","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"14","Contem Hist.?	",".","."       	,"mv_chc","C",99,0,0,"G","","",""," ","mv_par14","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"15","Carga"  			,'','',"mv_chd","C",TamSx3("ZP1_CARGA")[1] ,0,,"G","","DAK","",""	,"mv_par15","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"16","Imp. s/ Palete?" ,'','',"mv_chg","N",01,0,1,"C","","","","","MV_PAR16","Sim","","","","N„o","","","","","","","","","","","","","","")
Return
