#INCLUDE "rwmake.ch" 
#INCLUDE "TopConn.ch"
#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#include "apwizard.ch"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦                                                     
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP039   ¦ Autor ¦ Evandro Oliveira Gomes ¦ Data ¦ 14/03/12¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦          ¦  Rotatividade re-identificacao                             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ NUTRIZA                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User Function PCP039()
	Local nPosLf		:= 0
	Private _aDiaTbM	:= {}
	Private oDlg009
	Private _nOpca	:= 0
	Private aCabWzd	:= {}
	Private aIteWzd	:= {}
	Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Private oFld008
	Private aHeader	:= {}
	Private aCols		:= {}
	Private noBrw		:= 0
	Private aEntid	:= {}
	Private oWBrwPCP
	Private aWBrwPCP	:= {}
	Private aCampRel	:= {}
	Private lAssina1	:= .F.
	Private cFileRet	:= ""
	Private aInfoCed	:= {}
	Private aInfoBen	:= {}
	Private aOcorr	:= {}
	Private cPerg		:= PADR("PCP039",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.

	If !U_APPFUN01("Z6_ROTATIV")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return .F.
	Endif

	PCP0391Z(cPerg) //->Cria Perguntas
	If !Pergunte(cPerg,.T.)
		Return .F.
	Endif

	DEFINE MSDIALOG oDlg009 TITLE OemtoAnsi("Rotatividade de Etiquetas") FROM 005,000 TO 600,1000 PIXEL	
	oFld008:= TFolder():New( 006,006,{"Etiquetas"},{},oDlg009,,,,.T.,.F.,490,260,)
	nPosV:=270
	nPosLf:= 460
	oBntFec      := TButton():New( nPosV,nPosLf,"&Fechar",oDlg009,{|u|Close(oDlg009)},035,012,,,,.T.,,"",,,,.F. )
	nPosLf-=35
	oBntLib      := TButton():New( nPosV,nPosLf,"&Filtrar",oDlg009,{|u| Iif(Pergunte(cPerg,.T.),PCP0391B(1),.F.) },035,012,,,,.T.,,"",,,,.F. )
	nPosLf-=35
	oBntLib      := TButton():New( nPosV,nPosLf,"&Imprimir",oDlg009,{|u|PCP0391B(2)},035,012,,,,.T.,,"",,,,.F. )
	PCP0391A() //-> Colunas do Browse
	PCP0391B(1) //-> Seleciona dadso
	ACTIVATE MSDIALOG oDlg009 CENTERED
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Browse
*/
Static Function PCP0391A()
	If oWBrwPCP <> Nil
		oWBrwPCP:Destroy()
	Endif 
	aCampRel	:= {}
	@ 000, 000 LISTBOX oWBrwPCP Fields HEADER "","Codigo","Produto","Etiqueta","Palete","Status";
	SIZE 490, 240 OF oFld008:aDialogs[1] PIXEL ColSizes 10,40,150,60,60,150
	oWBrwPCP:bLDblClick := {|| Iif(SubStr(aWBrwPCP[oWBrwPCP:nAt,6],1,1)<>"4",PCP0391B(0),oWBrwPCP:Refresh()), Iif(SubStr(aWBrwPCP[oWBrwPCP:nAt,6],1,1)<>"4",oWBrwPCP:DrawSelect(),oWBrwPCP:Refresh()) }
	oWBrwPCP:Align := CONTROL_ALIGN_TOP
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa Funções
*/
Static Function PCP0391B(nOpc)
	Pergunte(cPerg,.F.)
	_lLog:=Iif(MV_PAR07==1,.T.,.F.)

	If nOpc==0 //-> Selecionar
		oProcess := MsNewProcess():New( { || PCP0391E(nOpc) } , "Imprimindo..." , "Aguarde..." , .F. ) //->Seleciona Dados
	ElseIf nOpc==1
		oProcess := MsNewProcess():New( { || PCP0391C() } , "Selecionando  dados..." , "Aguarde..." , .F. ) //->Seleciona
	Elseif nOpc==2 //-> Imprimir
		oProcess := MsNewProcess():New( { || PCP0391E(nOpc) } , "Imprimindo..." , "Aguarde..." , .F. ) //->Imprime
	Endif
	oProcess:Activate() 
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Processa arquivo selecionado
1-Normal(Entrouesaiu do tunel) 
2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 
3-Re-Identificacao 
4-Re-Identificacao Rotatividade
*/
Static Function PCP0391C()
	Local cSql		:=""
	Local aInfoBen:=""
	Local _cTipo	:= ""
	Local _cAliasZP1	:= GetNextAlias()

	aWBrwPCP:={}

	Pergunte(cPerg,.F.)
	_lLog:=Iif(MV_PAR07==1,.T.,.F.)

	oProcess:SetRegua1(1)

	cSql:="SELECT "
	cSql+=" TOP 1 ZP1_FILIAL, ZP1_DTPROD, ZP1_CODPRO, ZP1_CODETI, ZP1_PALETE, ZP1_TIPO "
	cSql+="FROM "+RETSQLNAME("ZP1")+ " ZP1 "
	cSql+="WHERE "
	cSql+="ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cSql+="AND ZP1_DTPROD BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
	cSql+="AND ZP1_CODPRO = '"+MV_PAR03+"' "
	cSql+="AND ZP1_STATUS NOT IN('5','9','7') "
	cSql+="AND ZP1_DTATIV <> '' "
	cSql+="AND ZP1_CARGA = '' "
	cSql+="AND ZP1_FLAGPR = '1' " //->Etiqueta j‡ impressa
	If MV_PAR06 == 1 //->Rotatividade n‹o realizada
		cSql	+="AND ZP1_TIPO NOT IN ('4','5') "
	Elseif MV_PAR06 == 2
		cSql	+="AND ZP1_TIPO IN ('4') "	
	Endif
	cSql+="AND ZP1.D_E_L_E_T_ <> '*' "
	cSql+=" AND ( SELECT COUNT(*) FROM  "+RETSQLNAME("ZPE")+ " ZPE "
	cSql+="	WHERE ZPE_CODETI=ZP1_CODETI "
	cSql+="	AND ZPE_CODIGO='96' "
	cSql+="	AND ZPE.D_E_L_E_T_ <>'*')= 0 "
	cSql+=" AND ( SELECT COUNT(*) FROM LOGPCP LOG "
	cSql+="	WHERE LOG_CODETI=ZP1_CODETI "
	cSql+="	AND LOG_CODIGO='96' "
	cSql+="	AND LOG.D_E_L_E_T_ <>'*')=0 "

	cSql+="ORDER BY ZP1_DTPROD "
	cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP1,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP1)->(LastRec()))
	(_cAliasZP1)->(dbGoTop())

	While !(_cAliasZP1)->(Eof())
		If (_cAliasZP1)->ZP1_TIPO=="1"
			_cTipo="1-Normal(Entrouesaiu do tunel)"
		ElseIf (_cAliasZP1)->ZP1_TIPO=="2"
			_cTipo="2-Re-identicacao paletizacao"
		ElseIf (_cAliasZP1)->ZP1_TIPO=="3"
			_cTipo="3-Re-Identificacao"
		ElseIf (_cAliasZP1)->ZP1_TIPO=="4"
			_cTipo="4-Re-Identificacao Rotatividade"
		ElseIf (_cAliasZP1)->ZP1_TIPO=="5"
			_cTipo="5-Suspensa do FIFO"
		Else
			_cTipo=(_cAliasZP1)->ZP1_TIPO
		Endif
		AADD(aWBrwPCP,{;
		.F.,;
		(_cAliasZP1)->ZP1_CODPRO,;
		POSICIONE("SB1",1,XFILIAL("SB1")+(_cAliasZP1)->ZP1_CODPRO,"B1_DESC"),;
		(_cAliasZP1)->ZP1_CODETI,;
		(_cAliasZP1)->ZP1_PALETE,;
		_cTipo;
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
		aAdd(aWBrwPCP,{.F.,"","","","",""})
	Endif

	oWBrwPCP:SetArray(aWBrwPCP)
	oWBrwPCP:bLine := {|| {;
	IIf(aWBrwPCP[oWBrwPCP:nAT,1],oOk,oNo),;
	aWBrwPCP[oWBrwPCP:nAt,2],;
	aWBrwPCP[oWBrwPCP:nAt,3],;
	aWBrwPCP[oWBrwPCP:nAt,4],;
	aWBrwPCP[oWBrwPCP:nAt,5],;
	aWBrwPCP[oWBrwPCP:nAt,6];
	}}

	If oDlg009 <> Nil
		oDlg009:Refresh()
	Endif

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Imprime Etiuetas Selecionadas
*/
Static Function PCP0391D(_cCodEti,aErros)
	Local cSql	:= ""
	Local _AliasETI	:= GetNextAlias()
	Local _cStrEtiq	:= ""
	Local cPorta		:= "LPT1"
	Begin Transaction

		cSql:="SELECT "
		cSql+="DISTINCT * "
		cSql+="FROM "+RETSQLNAME("ZP1")+" ZP1 "
		cSql+="INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
		cSql+="	ON B1_COD=ZP1_CODPRO "
		cSql+="WHERE " 
		cSql+=" ZP1_CODETI='"+_cCodEti+"' "
		cSql:=ChangeQuery(cSql)
		MemoWrite("C:\TEMP\" + UPPER(Funname()) + ".SQL",cSql)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_AliasETI,.T.,.F.)

		(_AliasETI)->(dbGoTop())

		If (_AliasETI)->(Eof())
			AADD(aErros,{"Etiqueta nao encontrada.",_cCodEti})
		Endif

		While !(_AliasETI)->(Eof())

			_dDtValid	:= STOD((_AliasETI)->ZP1_DTVALI)
			_dDtFabri	:= STOD((_AliasETI)->ZP1_DTPROD)
			_cCodEti 	:= (_AliasETI)->ZP1_CODETI
			_cLote 	:= (_AliasETI)->ZP1_LOTE
			_cStrEtiq 	:= ZP2->ZP2_ETIQ

			ZP1->(dbSetOrder(1))
			If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))

				If ZP1->ZP1_FLAGPR<>'1'
					If _lLog
						AADD(aErros,{"Etiqueta: Nao impressa.",_cCodEti})
					Endif
					(_AliasETI)->(dbSkip())
					Loop
				Endif

				If !RecLock("ZP1",.F.)
					If _lLog
						AADD(aErros,{"Etiqueta: Sendo impressa por outra estação.",_cCodEti})
					Endif
					(_AliasETI)->(dbSkip())
					Loop	
				EndIf

				RecLock("ZP1",.F.)
				Replace ZP1_FLAGPR WITH '4'
				ZP1->(MsUnLock())

				RecLock("ZP1",.F.)

				If Len(AllTrim((_AliasETI)->B1_XMODETI)) > 0
					ZP2->(dbSetOrder(1))
					If !ZP2->(dbSeek(xFilial()+(_AliasETI)->B1_XMODETI))
						If _lLog
							AADD(aErros, {"Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC+" Sem modelo de etiqueta cadastrado.",_cCodEti})
						Else
							Alert("Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC+" Sem modelo de etiqueta cadastrado.")
						Endif
						Return .F.
					EndIf
				Else
					If _lLog
						AADD(aErros, {"Campo: B1_XMODETI Vazio para o Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC,_cCodEti})
					Else
						Alert("Campo: B1_XMODETI Vazio para o Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC)
					Endif
					Return .F.
				Endif

				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cEan14%"			,NoAcento((_AliasETI)->B1_XEAN14))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc01%"		,NoAcento((_AliasETI)->B1_XDESCE1))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc02%"		,NoAcento((_AliasETI)->B1_XDESCE2))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc03%"		,NoAcento((_AliasETI)->B1_XDESCE3))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDTFab%"			,NoAcento(DToC(_dDtFabri)))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDtValidade%"	,NoAcento(DToC(_dDtValid)))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cLote%"			,NoAcento(_cLote))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cPeso%"			,NoAcento(AllTrim(Str((_AliasETI)->B1_CONV))))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cCodEtiq%"		,NoAcento(_cCodEti))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cAcond01%"		,NoAcento((_AliasETI)->B1_XACOND1))
				_cStrEtiq	:= StrTran(_cStrEtiq,"%cAcond02%"		,NoAcento((_AliasETI)->B1_XACOND2))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cSIF%"			,NoAcento((_AliasETI)->B1_XSIF))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cTipoEmb01%"	,NoAcento((_AliasETI)->B1_XTPEMB1))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cTipoEmb02%"	,NoAcento((_AliasETI)->B1_XTPEMB2))
				_cStrEtiq 	:= StrTran(_cStrEtiq,"%cCodProd%"		,NoAcento((_AliasETI)->B1_COD))

				MSCBPRINTER("S4M",cPorta,,,.F.,,,,)
				MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
				MSCBWrite(_cStrEtiq)
				MSCBEND()
				MSCBCLOSEPRINTER()

				U_PCPRGLOG(_nTpLog,_cCodEti,"96","")

				ZP1->(MsUnLock())
				If _lLog
					AADD(aErros,{"Etiqueta: Impressa.",_cCodEti})
				Endif
			Endif
			(_AliasETI)->(dbSkip())
		EndDo

		If Select(_AliasETI) > 0
			(_AliasETI)->(dbCloseArea())
			If File(_AliasETI+GetDBExtension())
				fErase(_AliasETI+GetDBExtension())
			Endif
		Endif

	End Transaction 
Return	

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Processa Browse
*/
Static Function PCP0391E(nOp)
	Local _lMarked
	Local _cChave
	Local x:=0
	Local aErros:={}

	_lMarked := aWBrwPCP[oWBrwPCP:nAt,1]
	oProcess:SetRegua1(1)
	oProcess:IncRegua1("Imprimindo...")

	//->Marca Desmarcar
	If nOp==0
		If _lMarked
			aWBrwPCP[oWBrwPCP:nAt,1] := .F.
		Else
			aWBrwPCP[oWBrwPCP:nAt,1] := .T.
		Endif
		Return
	Endif

	oProcess:SetRegua2(Len(aWBrwPCP))
	For x:=1 To Len(aWBrwPCP)
		AADD(aErros,{"Processando...",aWBrwPCP[x,4]})
		If aWBrwPCP[x,1] .And. SubStr(aWBrwPCP[x,6],1,1) <> '4'
			PCP0391D(aWBrwPCP[x,4],@aErros)
			aWBrwPCP[x,6]:="4-Re-Identificacao Rotatividade"
		Endif
	Next x

	If _lLog
		AADD(aErros,{"Processo de Rotatividade finalizado","NORMAL"})
		If Len(aErros) > 0
			U_MFATA07Z("Rotatividade de etiquetas",aErros)
			Return(.F.)
		Endif
	Endif

	oWBrwPCP:Refresh()
	If oDlg009 <> Nil
		oDlg009:Refresh()
	Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Cria Perguntas
*/
Static Function PCP0391Z(cPerg)
	PutSx1(cPerg,"01","Filial de ?"  	,'','',"mv_ch1","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Filial ate?"    ,'','',"mv_ch2","C",TamSx3("ZP1_FILIAL")[1] ,0,,"G","","SM0","",""	,"mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"03","Produto de ?"  	,'','',"mv_ch3","C",TamSx3("ZP1_CODPRO")[1] ,0,,"G","","SB1","",""	,"mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"04","Data Fab. de?"  ,'','',"mv_ch4","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"05","Date Fab. Ate?" ,'','',"mv_ch5","D",TamSx3("ZP1_DTPROD")[1] ,0,,"G","","   ","",""	,"mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Tipo?"			,'','',"mv_ch6","N",01,0,1,"C","","","","","MV_PAR06","Nao Efetuado","","","","Efetuado","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Mostra Log?"		,'','',"mv_ch7","N",01,0,1,"C","","","","","MV_PAR07","Sim","","","","Nao","","","","","","","","","","","","","","")
Return

