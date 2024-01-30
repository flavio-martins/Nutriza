#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

#Define STR_PULA    Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP040()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Suspensão de Etiqueta						  						  ³±±
±±³          ³			                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Nutriza											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Evandro Gomes³ 29/09/17³     ³ Inclus‹o do sequestro dentro do modelo de susp.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP040()

	Local nPosLf		:= 0
	Private _aDiaTbM	:= {}
	Private oDlg040
	Private _nOpca		:= 0
	Private aCabWzd		:= {}
	Private aIteWzd		:= {}
	Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Private oFld008
	Private aHeader		:= {}
	Private aCols		:= {}
	Private noBrw		:= 0
	Private aEntid		:= {}
	Private oWBrwPCP
	Private aWBrwPCP	:= {}
	Private aCampRel	:= {}
	Private lAssina1	:= .F.
	Private cFileRet	:= ""
	Private aInfoCed	:= {}
	Private aInfoBen	:= {}
	Private aOcorr		:= {}
	Private cPerg		:= PADR("PCP040",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog		:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cConcFifo	:= GetNewPar("MV_CONFIFO",'0002') //-> Famílias que devem entrar em FIFO sem restricoes ou excecoes
	Private cUsSusFif	:= GetNewPar("MV_XUSUFIF",'000000') //-> Usuários que podem suspender caixas FIFO Fixo.
	Private _nTipoSus	:= 1 //-> Tipo de suspensão: 1=Padrão/2=Sequestro

	//->Par‰metros para interface
	Private _aButts		:= {}
	Private _cTitulo	:= "Suspensao de Etiquetas"
	Private _aCabec		:= {}
	Private _aButts		:= {}
	Private aObjects	:= {}
	Private lf 			:= chr(13)+chr(10)

	PCP0401Z(cPerg) //->Cria Perguntas

	If !Pergunte(cPerg,.T.)
		Return .F.
	Else
		_nTipoSus	:= MV_PAR08 //-> Tipo de suspensão: 1=Padrão/2=Sequestro
	Endif

	If ValType(_nTipoSus) <> 'N'
		MsgInfo(OemToAnsi("Tipo de suspensao nao selecionada."))
		Return .F.
	Endif

	//->Analisa Qual o tipo de suspensão que foi selecionada
	If _nTipoSus == 1 //->Padr‹o
		If !U_APPFUN01("Z6_SUSPENC")=="S"  .And. __cUserId <> '000000' //-> .AND. !__cUserId $ cUsSusFif
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return .F.
		Endif
	Else
		If !U_APPFUN01("Z6_SEQUEST")=="S" .And. __cUserId <> '000000' //-> .AND. !__cUserId $ cUsSusFif
			MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
			Return .F.
		Endif
	Endif

	AADD(_aButts,{"", { || ExecBlock("PCP0401B",.F.,.F.,{9,oWBrwPCP,aWBrwPCP,.T.}) },"Filtrar", "Filtrar"})
	AADD(_aButts,{"", { || ExecBlock("PCP0401B",.F.,.F.,{2,oWBrwPCP,aWBrwPCP,.T.}) },"Inverte", "Inverte"})
	AADD(_aButts,{"", { || ExecBlock("PCP0401B",.F.,.F.,{3,oWBrwPCP,aWBrwPCP,.T.}) },"Processar", "Processar"})
	AADD(_aButts,{"", { || ExecBlock("PCP0401B",.F.,.F.,{4,oWBrwPCP,aWBrwPCP,.T.}) },"IMPRIMIR", "IMPRIMIR"})
	_aCabec:={"","Codigo","Produto","Etiqueta","Producao","Palete","Status"}
	ExecBlock("PCP0401B", .F., .F.,{1,oWBrwPCP,aWBrwPCP,.F.})
	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrwPCP, @oDlg040, @oWBrwPCP, .F.,,,,,'PCP0401X')
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: 
*/
Static Function PCP0401A()
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa Funcoes
*/
User Function PCP0401B()

	Private oProcess  //Quintais adicionou

	If ParamIXB[1] == 0 //-> Seleciona
		oProcess := MsNewProcess():New( { || ExecBlock("PCP0401E",.F.,.F.,{ParamIXB[1],ParamIXB[2],ParamIXB[3]}) } , "Marca..." , "Aguarde..." , .F. )
		oProcess:Activate()
	ElseIf ParamIXB[1] == 1 .Or. ParamIXB[1] == 9 //-> Filtra
		oProcess := MsNewProcess():New( { || PCP0401C(ParamIXB[1], ParamIXB[4]) } , "Selecionando  dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If PARAMIXB[4] //->Atualiza dados
			U_OHFUNA21(@oDlg040, @oWBrwPCP, _aCabec, @aWBrwPCP, 'PCP0401X')
		Endif
	ElseIf ParamIXB[1] == 2 //-> Inverte
		oProcess := MsNewProcess():New( { || ExecBlock("PCP0401E",.F.,.F.,{ParamIXB[1],ParamIXB[2],ParamIXB[3]}) } , "Inverte..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Elseif ParamIXB[1] == 4 //-> Imprimir
		oProcess := MsNewProcess():New( PCP040Y(ParamIXB[2]), "IMPRIMINDO..." , "Aguarde..." , .T. )
		oProcess:Activate()
	Elseif ParamIXB[1] == 3 //-> Processa
		oProcess := MsNewProcess():New( { || ExecBlock("PCP0401E",.F.,.F.,{ParamIXB[1],ParamIXB[2],ParamIXB[3]}) } , "Processando..." , "Aguarde..." , .F. ) 
		oProcess:Activate()
		Pergunte(cPerg,.F.)
		oProcess := MsNewProcess():New( { || PCP0401C(ParamIXB[1], ParamIXB[4]) } , "Selecionando  dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		U_OHFUNA21(@oDlg040, @oWBrwPCP, _aCabec, @aWBrwPCP, 'PCP0401X')	
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
Static Function PCP0401C(_nOpc, lObj)

	Local cSql	:=""
	Local aInfoBen
	Local _cAliasZP1	:= GetNextAlias()
	Local _cStatus	:= ""
	Local _lFifFix	:= .F.

	aWBrwPCP:={}

	Pergunte(cPerg,_nOpc==9)
	_lLog:= Iif(MV_PAR07==1,.T.,.F.)
	oProcess:SetRegua1(1)

	cSql:="SELECT " + lf
	cSql+="DISTINCT ZP1_FILIAL, ZP1_CODPRO, ZP1_CODETI, ZP1_DTPROD, ZP1_PALETE, ZP1_STATUS, B1_XGP1 " + lf
	dbSelectArea("SB1")
	If FieldPos(AllTrim("B1_XFIFFX")) > 0 //-> Fifo Fixo Por produto
		cSql+=",B1_XFIFFX " + lf
	Endif
	cSql+="FROM "+RETSQLNAME("ZP1")+ " ZP1 " + lf
	cSql+="INNER JOIN "+RETSQLNAME("SB1")+ " SB1 " + lf
	cSql+="ON B1_COD=ZP1_CODPRO " + lf
	If !Empty(Alltrim(MV_PAR09))
		cSql+="AND B1_GRUPO = '"+MV_PAR09+"' " + lf
	Endif
	cSql+="WHERE " + lf
	cSql+="ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + lf
	cSql+="AND ZP1_DTPROD BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " + lf
	If !Empty(Alltrim(MV_PAR03))
		cSql+="AND ZP1_CODPRO = '"+MV_PAR03+"' " + lf
	Endif
	If MV_PAR06 == 1
		cSql+="AND ZP1_STATUS IN ('1','2') " + lf
	Elseif MV_PAR06 == 2
		cSql+="AND ZP1_STATUS IN ('7','9') " + lf
	Else
		cSql+="AND ZP1_STATUS IN ('1','2','3','5','7','9') " + lf
	Endif
	cSql+="AND ZP1_DTATIV <> '' " + lf
	cSql+="AND ZP1_CARGA = '' " + lf
	//cSql+="AND ZP1_FLAGPR = '1' " //->Etiqueta já impressa
	cSql+="AND ZP1.D_E_L_E_T_ <> '*' " + lf
	cSql+="ORDER BY ZP1_DTPROD, ZP1_CODPRO " + lf
	//cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP1,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP1)->(LastRec()))
	(_cAliasZP1)->(dbGoTop())

	While !(_cAliasZP1)->(Eof())

		//->Fifo Fixo
		_lFifFix:=.F.
		dbSelectArea("SB1")
		If FieldPos(AllTrim("B1_XFIFFX")) > 0 .And. (_cAliasZP1)->ZP1_STATUS <> "5" //-> Fifo Fixo Por produto
			_lFifFix:= (_cAliasZP1)->B1_XFIFFX == "S"
		Endif

		If (_cAliasZP1)->B1_XGP1 $  cConcFifo .Or. _lFifFix
			_cStatus:="8-FIFO OBRIGATORIO"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="1"
			_cStatus:="1-ATIVADA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="2"
			_cStatus:="2-EM CARREGAMENTO"		
		ElseIf (_cAliasZP1)->ZP1_STATUS=="3"
			_cStatus:="3-CARREGADA/EXPEDIDA"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="4"
			_cStatus:="4-ROTATIVIDADE"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="5"
			_cStatus:="5-BAIXADA EM INVENTARIO"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="7"
			_cStatus:="7-SUSPENSAO SEQUESTRO"
		ElseIf (_cAliasZP1)->ZP1_STATUS=="9"
			_cStatus:="9-SUSPENSAO PADRAO"
		Endif

		AADD(aWBrwPCP,{;
		.F.,;
		(_cAliasZP1)->ZP1_CODPRO,;
		POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP1)->ZP1_CODPRO,"B1_DESC"),;
		(_cAliasZP1)->ZP1_CODETI,;
		DTOC(STOD((_cAliasZP1)->ZP1_DTPROD)),;
		(_cAliasZP1)->ZP1_PALETE,;
		_cStatus;
		})
		oProcess:IncRegua2("Etiqueta: "+(_cAliasZP1)->ZP1_CODETI)
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
		aAdd(aWBrwPCP,{.F.,"","","","","",""})
	Endif
	If lObj
		oWBrwPCP:Refresh()
	Endif

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Imprime Etiquetas Selecionadas
*/
Static Function PCP0401D(_cCodEti,aErros)

	Local cSql	:= ""
	Local _AliasETI	:= GetNextAlias()
	Local _cStrEtiq	:= ""
	Local cPorta		:= "LPT1"
	Local _dDtFabri	:= CTOD("  /  /    ") 
	Local _cTipo		:= ""
	Local _cStatus	:= ""

	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
		_dDtFabri	:= ZP1->ZP1_DTPROD
		_cCodEti 	:= ZP1->ZP1_CODETI
		_cTipo		:= ZP1->ZP1_TIPO
		_cStatus	:= ZP1->ZP1_STATUS

		//-> Fifo obrigatório por conservacao. Etiquetas suspensas podem ser retiradas da suspens‹o.
		/*_nProd:=AScan(aWBrwPCP,{|x| AllTrim(x[4]) == Alltrim(_cCodEti) })
		If _nProd > 0 .And. ZP1->ZP1_STATUS $ "1" 
		If SubStr(aWBrwPCP[_nProd,7],1,1) == "8" .And. __cUserId <> '000000'
		If _lLog
		AADD(aErros,{"Error: Etiqueta com fifo obrigatorio.",_cCodEti})
		Endif
		Return(.F.)
		Endif
		Endif*/

		If ZP1->ZP1_REPROC == "S"
			If _lLog
				AADD(aErros,{"Error: Etiqueta Reprocessada.",_cCodEti})
			Endif
			Return(.F.)
		Endif

		If !Empty(ZP1->ZP1_CARGA)
			If _lLog
				AADD(aErros,{"Error: Etiqueta Ja expedida.",_cCodEti})
			Endif
			Return(.F.)
		Endif

		If ZP1->ZP1_STATUS == "4"
			If _lLog
				AADD(aErros,{"Error: Etiqueta usada para rotividade de re-identificacao.",_cCodEti})
			Endif
			Return(.F.)
		Endif

		If ZP1->ZP1_STATUS == "5"
			If _lLog
				AADD(aErros,{"Error: Etiqueta nao identificada em inventario.",_cCodEti})
			Endif
			Return(.F.)
		Endif

		If !ZP1->ZP1_STATUS $ "1|2|7|9"
			If _lLog
				AADD(aErros,{"Error: Status Invalido para esta operacao.["+ZP1->ZP1_STATUS+"]",_cCodEti})
			Endif
			Return(.F.)
		Endif

		RecLock("ZP1",.F.)
		If _cStatus$"1|2"
			ZP1->ZP1_STATUS := Iif(MV_PAR08==1,"9","7")  //-> 1=Suspens‹o / 2=Sequestro
			ZP1->ZP1_DTSUSP := Date()
			ZP1->ZP1_HRSUSP := Time()
		Else
			ZP1->ZP1_STATUS := "2"
			ZP1->ZP1_DTSUSP := CTOD("  /  /    ")
			ZP1->ZP1_HRSUSP := ""
		Endif
		ZP1->(MsUnLock())

		If _cStatus == "1"
			If MV_PAR08==1 //-> 1=Suspens‹o / 2=Sequestro
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"97")
			Else
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"B8")
			Endif

			If _lLog
				AADD(aErros,{"Sucesso: Suspensao Executada com Sucesso.",_cCodEti})
			Endif
		Else
			If MV_PAR08==1 //-> 1=Suspens‹o / 2=Sequestro
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"98")
			Else
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"B9")
			Endif

			If _lLog
				AADD(aErros,{"Sucesso: Suspensao revogada com sucesso.",_cCodEti})
			Endif
		Endif

	Else
		If _lLog
			AADD(aErros,{"etiquetas: "+aDados[x,4]+" Nao encontrada.","NORMAL"})
		Endif
	Endif 
Return	

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Processa Browse
*/
User Function PCP0401E()

	Local _lMarked
	Local _cChave
	Local x:=0
	Local aErros:={}
	Local nOp		:= PARAMIXB[1]
	Local oDados	:= PARAMIXB[2]
	Local aDados	:= PARAMIXB[3]

	oProcess:SetRegua1(1)
	If nOp==0 //->Invertendo
		oProcess:IncRegua1("Marca...")
		_lMarked := aDados[oDados:nAt,1]
		If _lMarked
			aDados[oDados:nAt,1] := .F.
		Else
			aDados[oDados:nAt,1] := .T.
		Endif
		Return(.T.)
	ElseIf nOp==2 //->Invertendo
		oProcess:IncRegua1("Invertendo...")
	ElseIf nOp==3 //->Processando
		oProcess:IncRegua1("Processando...")
	Endif

	oProcess:SetRegua2(Len(aDados))

	If _lLog .And. nOp <> 2
		AADD(aErros,{"Processo de "+ if(MV_PAR06==1,"Suspensao",if(MV_PAR06==1,"Revoga Suspensao","Retira/Suspende")) + " de etiquetas iniciado.","NORMAL"})
	Endif

	For x:=1 To Len(aDados)
		_lMarked := aDados[x,1]
		oProcess:IncRegua2("Etiqueta: "+aDados[x,4])	
		If nOp==2 //->Inverte
			oWBrwPCP:aArray[x][1]:= !oWBrwPCP:aArray[x][1]
			aWBrwPCP[x][1]:=oWBrwPCP:aArray[x][1]
			oWBrwPCP:DrawSelect()
			oWBrwPCP:Refresh()
			aDados[x][1]:=.T.
		ElseIf nOp==3 .And. _lMarked
			AADD(aErros,{"Tentativa de "+ if(MV_PAR06==1,"Suspensao",if(MV_PAR06==1,"Revoga Suspensao","Retira/Suspende")) + " de etiquetas: "+aDados[x,4],"NORMAL"})
			PCP0401D(aDados[x,4],@aErros)
		Endif
	Next x

	If _lLog .And. nOp <> 2
		AADD(aErros,{"Processo de "+ if(MV_PAR06==1,"Suspensao",if(MV_PAR06==1,"Revoga Suspensao","Retira/Suspende")) + " de etiquetas finalziado","NORMAL"})
		If Len(aErros) > 0
			U_MFATA07Z(if(MV_PAR06==1,"Suspensao",if(MV_PAR06==1,"Revoga Suspensao","Revoga/Suspende")) + " de etiquetas",aErros)
			Return(.F.)
		Endif
	Endif

	oDados:Refresh()
	If oDlg040 <> Nil
		oDlg040:Refresh()
	Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Marca
*/
User Function PCP0401X(_nMarca)
	oWBrwPCP:aArray[oWBrwPCP:nAt][1]:= !oWBrwPCP:aArray[oWBrwPCP:nAt][1]
	aWBrwPCP[oWBrwPCP:nAt][1]:=oWBrwPCP:aArray[oWBrwPCP:nAt][1]
	oWBrwPCP:DrawSelect()
	oWBrwPCP:Refresh()
Return(.T.)



Static Function PCP040Y(oDados)
	Local aDados	:= oDados:AARRAY
	//Local nHDCSV	:= FCREATE("c:\TEMP\PCP040.CSV", FC_NORMAL)
	Local oFWMsExcel:= FWMSExcel():New()
	Local oExcel
	Local cArquivo


	cArquivo := "c:\temp\PCP040" + AllTrim(Str(Randomize(1,34000))) + ".xml"  //GetTempPath()+'pcp040.xml'
	//oProcess:SetRegua1(LEN(aDados))
	//oFWMsExcel := FWMSExcel():New()
	//cLinha := "PRODUTO;DESCRICAO;CODIGO;DATA;PALETE;STATUS;"
	//FSeek(nHDCSV, 0, FS_END)
	//FWrite(nHDCSV, cLinha,Len(cLinha)+3)

	//Criando Aba
	oFWMsExcel:AddworkSheet("PCP040") //Não utilizar número junto com sinal de menos. Ex.: 1-
	//Criando a Tabela
	oFWMsExcel:AddTable("PCP040","Suspenção de Etiquetas")
	//Criando Colunas
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","PRODUTO",1) //1 = Modo Texto
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","DESCRICAO",1) //2 = Valor sem R$
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","CODIGO",1) //3 = Valor com R$
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","DATA",1)
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","PALLET",1)
	oFWMsExcel:AddColumn("PCP040","Suspenção de Etiquetas","STATUS",1)
	For i := 1 to  LEN(aDados)
		//	oProcess:IncRegua1("Imprimindo...")

		//Criando as Linhas
		oFWMsExcel:AddRow("PCP040","Suspenção de Etiquetas",{aDados[i][2],aDados[i][3],aDados[i][4],aDados[i][5],aDados[i][6],aDados[i][7]})

		//	cLinha := aDados[i][2]+";"+aDados[i][3]+";'"+aDados[i][4]+";"+aDados[i][5]+";'"+aDados[i][6]+";"+aDados[i][7]+";"
		//	FSeek(nHDCSV, 0, FS_END)
		//	FWrite(nHDCSV, cLinha,Len(cLinha)+3)
	next i
	//fclose(nHDestino)

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()

	oFWMsExcel:GetXMLFile(cArquivo)
	oFWMSExcel:DeActivate()

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()
Return



/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Perguntas
*/
Static Function PCP0401Z(cPerg)
	U_OHFUNAP3(cPerg,"01","Filial de ?"  	,'','',"mv_ch1","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","","",""	,"mv_par01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Filial ate?"    ,'','',"mv_ch2","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","","",""	,"mv_par02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Produto ?"		,'','99999',"mv_ch3","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Data Fab. de?"  ,'','',"mv_ch4","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Date Fab. Ate?" ,'','',"mv_ch5","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par05","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Status?"			,'','',"mv_ch6","N",01,0,1,"C","","","","","MV_PAR06","Nao Suspensa","","","","Suspensa","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","Mostra Log?"	,'','',"mv_ch7","N",01,0,1,"C","","","","","MV_PAR07","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"08","Tipo?"			,'','',"mv_ch8","N",01,0,1,"C","","","","","MV_PAR08","Susp. Padrao","","","","Sequestro","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"09","Grupo ?"  		,'','',"mv_ch9","C",TamSx3("B1_GRUPO")[1] ,0,,"G","","SBM","",""	,"mv_par09","","","","","","","","","","","","","","","","")
Return

