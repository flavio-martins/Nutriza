#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'                       
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH
#Include 'FWMVCDef.ch'

#define DS_MODALFRAME   128

Static cTitulo := ""

//->Novo Processo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP005() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descricao
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
/*
Por: Evandro Gomes
Em: 23/08/16
Descricao: Nova rotina para corrigir as não conformidades de impressao de etiquetas

*/
User Function PCP005(_cTitulo)

Local nPosLf		:= 0
Private nZ6_QDRIETI	:= 0
Private nZ6_QDAIETI	:= 0
Private lZ6_PCPUFIL	:= .F.
Private oDlgZP1
Private oDados
Private _nOpca		:= 0
Private oFldZP1
Private cPerg		:= Padr("PCP005",10)
Private aEntid		:= {}
Private _lLimData	:= .T. //->Habilita rotina de validacao de dias retroceder / dias avancas para geracao de etiquetas
Private _nQtEtiq 	:= 0
Private _cTipo		:='1' //->  1-Normal(Entrou e saiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao 4-Re-Identificacao Rotatividade
Private aErros		:={}
Private _lLog		:= .F.
Private _cEnvPer	:= GETMV("MV_ENVPER")   /*GetNewPar("MV_ENVPER","PCP")*/
Private _nTpLog		:= GETMV("MV_PCPTLOG")  /*GetNewPar("MV_PCPTLOG",1)*/
Private _lConAM		:= GETMV("MV_AMCONSU")  /*GetNewPar("MV_AMCONSU",.F.)*/
Private oWBrwZP1
Private aWBrwZP1	:= {}
//->Par‰metros para interface  ---   MSGALERT (len(oWBrwZP1:array)),
Private bTeclaF5 	:= SetKey( VK_F5, { ||  oWBrwZP1:Refresh(),oDlgZP1:Refresh() } )
Private bTeclaF6 	:= SetKey( VK_F6, { ||  u_zCadSX5("KL","Geração de Etiquetas") } )
//oWBrwZP1:Refresh()
Private _aArrayAnt	:= {}
Private _aButts		:= {}
Private _cTitulo	:= Iif(Len(AllTrim(_cTitulo))>0,_cTitulo,"Impressão de Etiquetas 1-Normal")
Private _aCabec		:= {"","Filial","Lote","Código","Produto","Dta. Prod.","Cod. Eti.","Qtd.","Qtd.Imp."}
Private _aButts		:= {}
Private _aSayHd		:= {}
Private _aGetHd		:= {}
Private aObjects	:= {}
Private _cFilIni	:= "0101"
Private _cFilFim	:= "0101"
Private _dDtFabIn	:= CTOD("  /  /    ")
Private _dDtFabFi	:= CTOD("  /  /    ")
Private _cLotIni	:= ""
Private _cLotFim	:= "ZZZ"
Private _cProdIn	:= ""
Private _cProdFi	:= "ZZZZZZZZZZZZZZZ"
Private _nSituac	:= 3
Private _VisLog		:= 1
Private _lLog		:= .F.
Private cAliasZP1	:= "ZP1TMP"

//->Testa ambientes que podem ser usados
If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
	Alert("Ambiente não homologado para o uso desta rotina!!!")
	Return .F.
Endif

//->Impressão etiquetas Re-Identificação de etiqueta caixa tunel

If ("PCP018" $ Upper(AllTrim(FunName())))
	_cTipo:='2'
	//->Analiza se usuário pode acessar esta rotina
	If !U_APPFUN01("Z6_REIMEPT")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif
Elseif ("PCP036" $ Upper(AllTrim(FunName())))  //->Impressão etiquetas Re-Identificacao de etiqueta caixa estoque
	_cTipo:='3'
	//->Analiza se usuário pode acessar esta rotina
	If !U_APPFUN01("Z6_RIETIPE")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif
Else
	//->Analiza se usuário pode acessar esta rotina
	If !U_APPFUN01("Z6_IMPRETI")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif
EndIf


nZ6_QDRIETI:=Iif(ValType(U_APPFUN01("Z6_QDRIETI"))="N", U_APPFUN01("Z6_QDRIETI"), 0)
nZ6_QDAIETI:=Iif(ValType(U_APPFUN01("Z6_QDAIETI"))="N", U_APPFUN01("Z6_QDAIETI"), 0)
lZ6_PCPUFIL:= U_APPFUN01("Z6_PCPUFIL")=='S'

//PCP5Z(cPerg) //->Cria perguntas
//pergunte(cPerg) //->Cria perguntas

AADD(_aButts,{"", { || ExecBlock("PCP5C",.F.,.F.,{9,.T.,oWBrwZP1,aWBrwZP1,.T.,.T.}) },"Filtrar", "Filtrar"})
AADD(_aButts,{"", { || ExecBlock("PCP5E",.F.,.F.,{"Gerar Etiquetas"}) },"Gerar", "Gerar"})
AADD(_aButts,{"", { || ExecBlock("PCP5C",.F.,.F.,{1,.T.,oWBrwZP1,aWBrwZP1,.T.,.F.}) },"Imprimir", "Imprimir"})
_aCabec:={"","Filial","Lote","Código","Produto","Dta. Prod.","Cod. Eti.","Qtd.","Qtd.Imp."}

EXECBLOCK("PCP5C",.F.,.F.,{9,.T.,oWBrwZP1,aWBrwZP1,.F.,.T.})

If Len(aWBrwZP1) <= 0
	AADD(aWBrwZP1,{.F.,"","","","",DTOC(CTOD("  /  /    ")),"",0,0})
Endif
U_OHFUNAP2(aObjects,_aButts, _cTitulo, _aCabec, @aWBrwZP1, @oDlgZP1, @oWBrwZP1, .F.,,,,,"PCP5X")
//oWBrwZP1:Refresh()
SetKey( VK_F5, { || } )
SetKey( VK_F6, { || } )
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Seleciona etiquetas
*/
Static Function PCP5B(lPerg,lObj)

Local cSql			:= ""
Local _CodEnt		:= ""
Local _CGCPEnt		:= ""
Local nPos			:= 0
Local cStatus		:= ""
Local _CSTAT_SEFR	:= ""
Local _XMOT_SEFR	:= ""
Local aCodRSef		:= {}
Local aCodRSefN		:= {}
Local _cCodRSef		:= ""
Local _cMenRSef		:= ""
Local _cProRsef		:= ""
Local _lAdic		:= .F.
Local _nTotReg		:= 0
Local _cDtCanc		:= ""
Local _cOberv		:= ""
Local _cCabDel		:= "N"
Local _cIteDel		:= "N"



If lPerg //-> Executa Pergunte
	If !Pergunte(cPerg,lPerg)
		Return .F.
	Endif
	_cFilIni	:= MV_PAR01
	_cFilFim	:= MV_PAR02
	_dDtFabIn	:= MV_PAR03
	_dDtFabFi	:= MV_PAR04
	_cLotIni	:= MV_PAR05
	_cLotFim	:= MV_PAR06
	_cProdIn	:= MV_PAR07
	_cProdFi	:= MV_PAR08
	_nSituac	:= MV_PAR09
	_VisLog		:= MV_PAR10
	_lLog		:= Iif(_VisLog==1,.F.,.T.)

Else
	MV_PAR01	:=_cFilIni
	MV_PAR02	:=_cFilFim
	MV_PAR03	:=_dDtFabIn
	MV_PAR04	:=_dDtFabFi
	MV_PAR05	:=_cLotIni
	MV_PAR06	:=_cLotFim
	MV_PAR07	:=_cProdIn
	MV_PAR08	:=_cProdFi
	MV_PAR09	:=_nSituac
	MV_PAR10	:=_VisLog
	_lLog		:= Iif(_VisLog==1,.F.,.T.)

Endif


SELETIQT()

If Select(cAliasZP1) > 0
	(cAliasZP1)->(dbCloseArea())
	If File(cAliasZP1+GetDBExtension())
		fErase(cAliasZP1+GetDBExtension())
	Endif
Endif

If Len(aWBrwZP1) <= 0
	AADD(aWBrwZP1,{.F.,"","","","",DTOC(CTOD("  /  /    ")),"",0,0})
Endif
If lObj
	oWBrwZP1:bGotFocus := {|| oWBrwZP1:Refresh()}
	oWBrwZP1:Refresh()
Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Preenche Gride
*/
User Function PCP5C()
Local lRet	:= .T.
Local _nTipo    :=PARAMIXB[1]
Local _lPerg    :=PARAMIXB[2]
Local _oWBZP1   :=PARAMIXB[3]
Local _aWBZP1   :=PARAMIXB[4]
Local _lOnjAt   :=PARAMIXB[5]
Local _lValid   :=PARAMIXB[6]
//Private oProcess

If _nTipo==9 //->Localizando registros
	oProcess:=MsNewProcess():New( { || lRet:=PCP5B(_lPerg,_lOnjAt) } , "Selecionando Registros..." , "Aguarde..." , .F. )
	oProcess:Activate()
	If _lOnjAt
		U_OHFUNA21(@oDlgZP1, @oWBrwZP1, _aCabec, @aWBrwZP1, "PCP5X")
		oWBrwZP1:Refresh()
	Endif
ElseIf _nTipo==1 //->Imprime etiqueta
	oProcess:=MsNewProcess():New( { || EXECBLOCK("PCP5D",.F.,.F.,{_nTipo,_oWBZP1,_aWBZP1}) } , "Processando Registros..." , "Aguarde..." , .F. )
	oProcess:Activate()
ElseIf _nTipo==10 .Or. _nTipo==11
	oProcess:=MsNewProcess():New( { || EXECBLOCK("PCP5D",.F.,.F.,{_nTipo,_oWBZP1,_aWBZP1}) } , "Processando Registros..." , "Aguarde..." , .F. )
	oProcess:Activate()
ElseIf _nTipo==0
	oProcess:=MsNewProcess():New( { || EXECBLOCK("PCP5D",.F.,.F.,{_nTipo,_oWBZP1,_aWBZP1}) } , "Marcando Registro..." , "Aguarde..." , .F. )
	oProcess:Activate()
Endif

//oWBrwZP1:Refresh()
Return(lRet)
/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Percorre grid
*/
User Function PCP5D()
Local _lMarked
Local _cChave
Local _lProssegue	:= .F.
Local _I			:= 0
Local _X			:= 0
Local aResult 		:= {}
Local aRet			:= {}
Local cTitulox		:= ""
Local nOpc			:= PARAMIXB[1]
Local oDados		:= PARAMIXB[2]
Local aDados		:= PARAMIXB[3]
Private aErros		:= {}

If nOpc==1 //->Imprimie
	cTitulox:="Imprime Etiquetas: "
ElseIf nOpc==10 //->Seleciona
	cTitulox:="Seleciona: "
ElseIf nOpc==11 //->Tira Seleciona
	cTitulox:="Tira Seleção: "
Endif

If _lLog .And. !(nOpc==10 .Or. nOpc==11)
	AADD(aErros,{"Processo de "+cTitulox+" de etiquetas Iniciado","NORMAL"})
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

If nOpc <> 1
	oProcess:SetRegua2(Len(aDados))
	oProcess:SetRegua1(1)
	If nOpc==10
		oProcess:IncRegua1(cTitulox)
	Elseif nOpc==11
		oProcess:IncRegua1(cTitulox)
	Endif
Endif

For _I := 1 To Len(aDados)
	
	If nOpc <> 1
		oProcess:IncRegua2(cTitulox + "Cod. Eti:" + AllTrim(aDados[_I,5]))
	Endif
	
	//->Marca Desmarcar
	_lMarked := oDados:AARRAY[_I,1]
	If nOpc==1 .And. _lMarked //->Imprimir
		If _lLog .And. !(nOpc==10 .Or. nOpc==11)
			AADD(aErros,{"Enviando grupo: " + AllTrim(aDados[_I,7]) + " Lote: "+aDados[_I,3]+" para impressão.","NORMAL"})
		Endif
		PCP5G({aDados[_I,2], aDados[_I,7], aDados[_I,4], DTOS(CTOD(aDados[_I,6])), aDados[_I,3] })
		AADD(aErros,{"Finaliza Enviando grupo: " + AllTrim(aDados[_I,7]) + " Lote: "+aDados[_I,3]+" para impressão.","NORMAL"})
	ElseIf nOpc==10
		aDados[_I,1] := .T.
	ElseIf nOpc==11
		aDados[_I,1] := .F.
	Endif
	
Next _I

If _lLog .And. !(nOpc==10 .Or. nOpc==11)
	AADD(aErros,{"Processo de "+cTitulox+" de etiquetas finalizado","NORMAL"})
	If Len(aErros) > 0
		U_MFATA07Z("Geração de etiquetas",aErros)
		Return(.F.)
	Endif
ElseIf !(nOpc==10 .Or. nOpc==11)
	Alert("Processo finalizado!!!")
Endif

IF nOpc==1
	EXECBLOCK("PCP5C",.F.,.F.,{9,.F.,oWBrwZP1,aWBrwZP1,.T.,.F.})
Else
	oWBrwZP1:Refresh()
	oDados:Refresh()
	oDlgZP1:Refresh()
Endif

Return

User Function PCP5E()
Local _dDtValid
Local _cCodEti		:= ""
Local _cSeq			:= ""
Local _I			:= 0
Local _cCadastro	:=PARAMIXB[1]
Private oDescr
Private cDescr		:= ""
Private oDtFabri
Private cProduto	:= Space(15)
Private _dDtFabri 	:= CToD("//")
Private _cLote		:= Space(3)
Private oLote
Private oProduto
Private oQtEtiq
Private _cLocal		:= ""
Private oDlg

_cCadastro := IIf(_cCadastro==Nil,"Impressão de Etiquetas",_cCadastro)

DEFINE MSDIALOG oDlg TITLE _cCadastro FROM 000, 000  TO 110, 500 COLORS 0, 16777215 PIXEL
@ 002, 002 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 027, 002 SAY oSay3 PROMPT "Data Produção" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 027, 065 SAY oSay4 PROMPT "Lote" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 027, 097 SAY oSay5 PROMPT "Quantidade" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 012, 002 MSGET oProduto VAR cProduto SIZE 060, 010 OF oDlg PICTURE "@!" VALID bValPrd() COLORS 0, 16777215 F3 "SB1" HASBUTTON PIXEL
@ 012, 065 MSGET oDescr VAR cDescr SIZE 180, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
@ 037, 002 MSGET oDtFabri VAR _dDtFabri SIZE 060, 010 OF oDlg VALID bValDtPrd() COLORS 0, 16777215 PIXEL
@ 037, 065 MSGET oLote VAR _cLote SIZE 030, 010 OF oDlg VALID bValKL(_cLote) COLORS 0, 16777215 F3 "KL" PIXEL WHEN .T.
@ 037, 097 MSGET oQtEtiq VAR _nQtEtiq SIZE 060, 010 OF oDlg COLORS 0, 16777215 Picture "@E 9999"  PIXEL
DEFINE SBUTTON oSButton1 FROM 037, 168 TYPE 01 OF oDlg ENABLE ACTION PCP5F()
DEFINE SBUTTON oSButton2 FROM 037, 207 TYPE 02 OF oDlg ENABLE ACTION {|| oWBrwZP1:Refresh(),oDlg:End()}
ACTIVATE MSDIALOG oDlg ON INIT oWBrwZP1:Refresh() CENTERED

Return


/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Gerar Etiquetas
*/
Static function PCP5F()
Local cSeq 			:= ""
Local cCodEti 		:= ""
Local cLote			:= ""
Local _cAliasZP1	:= GetNextAlias()
Local _cSql			:= ""
Local _nReg			:= 0
///_lLog				:= .T.

aErros	:={}
If _lLog
	AADD(aErros,{"Processo de geração de etiquetas iniciado","NORMAL"})
Endif

If !bValDtPrd()
	If _lLog
		AADD(aErros,{"Range de dias para gerar etiquetas.","NORMAL"})
	Else
		Return(.F.)
	Endif
Endif

//Begin Transaction

If !bValForm()
	//DisarmTransaction()
	Return
EndIf

If _lLog
	AADD(aErros,{"Formulário Validado","NORMAL"})
Endif

cCodEti := SubStr(SB1->B1_COD,1,5)+SubStr(DToS(_dDtFabri),7,2)+SubStr(DToS(_dDtFabri),5,2)+SubStr(DToS(_dDtFabri),3,2)
If _lLog
	AADD(aErros,{"Código Base:"+cCodEti,"NORMAL"})
Endif

//->Semáforo
cSeq	:=GetNumEti(1,"ZP1",cCodEti,5)
If _lLog
	AADD(aErros,{"Sequência inicial:"+cSeq,"NORMAL"})
Endif

For _I := 1 To _nQtEtiq
	
	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+cCodEti+cSeq))
		If _lLog
			AADD(aErros,{"Etiqueta: "+ AllTrim(cCodEti+cSeq) +" não pôde ser gerada, pois já existe.","ERRO"})
		Endif
		cSeq:=Soma1(cSeq,5)
		Loop
	Endif
	
	/*
	ANALISA ARQUIVO MORTO
	*/
	If _lConAM
		_nReg:= 0
		_cSql:="SELECT COUNT(*) QtdReg FROM ZP1010_MORTO WITH(NOLOCK) WHERE ZP1_FILIAL='"+xFilial("ZP1")+"' AND ZP1_CODETI='"+cCodEti+"' "
		dbUseArea(.T.,"TopConn",TCGenQry(,,_cSql),_cAliasZP1,.F.,.T.)
		_nReg := (_cAliasZP1)->QtdReg
		If Select(_cAliasZP1) > 0
			(_cAliasZP1)->(dbCloseArea())
			If File(_cAliasZP1+GetDBExtension())
				fErase(_cAliasZP1+GetDBExtension())
			Endif
		Endif
		
		If _nReg > 0
			If _lLog
				AADD(aErros,{"Etiqueta: "+ AllTrim(cCodEti+cSeq) +" não pôde ser gerada, pois já existe.","ERRO"})
			Endif
			cSeq:=Soma1(cSeq,5)
			Loop
		Endif
	Endif
	
	ZP1->(dbSetOrder(1))
	_lSeek := ZP1->(dbSeek(xFilial("ZP1")+cCodEti+cSeq))
	If !_lSeek
		RecLock("ZP1",.T.)
		ZP1->ZP1_FILIAL	:= xFilial("ZP1")
		ZP1->ZP1_CODETI	:= cCodEti+cSeq
		ZP1->ZP1_CODPRO	:= SB1->B1_COD
		ZP1->ZP1_PESO	:= SB1->B1_CONV
		ZP1->ZP1_DTPROD	:= _dDtFabri
		ZP1->ZP1_DTVALI	:= _dDtFabri + SB1->B1_PRVALID //_dDtValid
		ZP1->ZP1_EDATA	:= "N"
		ZP1->ZP1_REPROC	:= "N"
		ZP1->ZP1_LOTE	:= _cLote
		ZP1->ZP1_MODETI	:= SB1->B1_XMODETI
		ZP1->ZP1_DTIMPR	:= Date()
		ZP1->ZP1_HRIMPR	:= Time()
		ZP1->ZP1_USIMPR	:= AllTrim(cUserName)
		ZP1->ZP1_LOCAL	:= _cLocal
		ZP1->ZP1_FLAGPR	:= "0"
		ZP1->ZP1_TIPO	:= _cTipo
		ZP1->(MsUnLock())
	Endif
	
	If _lLog
		AADD(aErros,{"Etiqueta: "+ AllTrim(cCodEti+cSeq) +" Gerada com sucessso.","NORMAL"})
	Endif
	
	//->Log
	U_PCPRGLOG(_nTpLog,cCodEti+cSeq,IIF(_cTipo='1',"01",IIF(_cTipo='2',"38","40")),AllTrim(Upper(FunName())))
	
	//->Sem‡foro
	cSeq:=Soma1(cSeq,5)
	
Next _I
//AADD(OWBRWZP1:AARRAY, {.F.,xFilial("ZP1"), _cLote, SB1->B1_COD, SB1->B1_DESC, DTOC(DDATABASE), cCodEti, _nQtEtiq, 0})
SELETIQT()
oWBrwZP1:Refresh()
//oDados:Refresh()
oDlgZP1:Refresh()
//->Semáforo
ComNumEti("ZP1",cCodEti,5,cSeq)
If _lLog
	AADD(aErros,{"Processo de geração de etiquetas finalizado","NORMAL"})
	If Len(aErros) > 0
		U_MFATA07Z("Geração de etiquetas",aErros,.T.)
		//		SELETIQT()
		Return(.F.)
	Endif
Endif
EXECBLOCK("PCP5C",.F.,.F.,{9,.F.,oWBrwZP1,aWBrwZP1,.T.,.F.})

cProduto 	:= Space(15)
_dDtFabri 	:= CToD("//")
_cLote		:= Space(3)
_nQtEtiq 	:= 0
cDescr		:= ""
oWBrwZP1:Refresh()
oProduto:Refresh()
oDescr:Refresh()
oDtFabri:Refresh()
oLote:Refresh()
oQtEtiq:Refresh()
oDescr:Refresh()
//End Transaction

Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Imprime Etiquetas
*/
Static Function PCP5G(_aEti)
Local cSql		:= ""
Local _AliasETI	:= "AliasETI"
Local _cStrEtiq	:= ""
Local cPorta	:= "LPT1"
Local _aEtiImp	:= {}
Local _lCont	:= .F.

cSql:="SELECT "
cSql+="DISTINCT "
cSql+="ZP1_DTVALI, ZP1_DTPROD, ZP1_CODETI, ZP1_LOTE, B1_COD, B1_XMODETI, B1_DESC "
cSql+=",B1_XEAN14, B1_XDESCE1, B1_XDESCE2, B1_XDESCE3, B1_CONV, B1_XACOND1, B1_XACOND2, B1_XSIF, B1_UM "
cSql+=",B1_XTPEMB1, B1_XTPEMB2, ZP1_TIPO, ZP1_DTVALI, ZP1_DTPROD "
cSql+="FROM "+RETSQLNAME("ZP1")+" ZP1 "
cSql+="INNER JOIN "+RETSQLNAME("SB1")+" SB1 "
cSql+="	ON B1_COD=ZP1_CODPRO "
cSql+="WHERE "
cSql+=" ZP1_FILIAL='"+_aEti[1]+"' "
cSql+=" AND SUBSTRING(ZP1_CODETI,1,11)='"+_aEti[2]+"' "
cSql+=" AND ZP1_CODPRO='"+_aEti[3]+"' "
cSql+=" AND ZP1_DTPROD='"+_aEti[4]+"' "
cSql+=" AND ZP1_LOTE='"+_aEti[5]+"' "
cSql+=" AND ZP1_DTATIV='' "
cSql+=" AND ZP1_FLAGPR <> '1' "
cSql+=" AND ZP1_STATUS NOT IN ('5','9','7') "
cSql+=" AND NOT EXISTS (SELECT ZPE_CODETI FROM "+RETSQLNAME("ZPE")+" ZPE WHERE ZPE_CODETI=ZP1_CODETI AND ZPE_CODIGO='02' AND ZPE.D_E_L_E_T_ <>'*') "
cSql+=" AND NOT EXISTS (SELECT LOG_CODETI FROM LOGPCP WHERE LOG_CODETI=ZP1_CODETI AND LOG_CODIGO='02' AND LOGPCP.D_E_L_E_T_ <>'*') "
cSql+=" AND ZP1.D_E_L_E_T_ <> '*' "
If !U_APPFUN01("Z6_VISTPAL")=="S"
	cSql+=" AND (EXISTS ( SELECT ZPE_CODIGO FROM  "+RETSQLNAME("ZPE")+ " ZPE "
	cSql+="	WHERE ZPE_CODETI=ZP1_CODETI "
	If _cTipo='1'	//->  1-Normal(Entrou e saiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao
		cSql+="	AND ZPE_CODIGO='01' "
	ElseIf _cTipo='2'  //->Impressao etiquetas Re-Identificacao de etiqueta caixa tunel
		cSql+="	AND ZPE_CODIGO='38' "
	ElseIf _cTipo='3' //->Impressao etiquetas Re-Identificacao de etiqueta caixa estoque
		cSql+="	AND ZPE_CODIGO='40' "
	Endif
	cSql+="	AND ZPE_USERID='"+__cUserId+"' "
	cSql+="	AND ZPE.D_E_L_E_T_ <>'*') "
	cSql+=" OR EXISTS ( SELECT LOG_CODIGO FROM LOGPCP LOG "
	cSql+="	WHERE LOG_CODETI=ZP1_CODETI "
	If _cTipo='1'	//->  1-Normal(Entrou e saiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao
		cSql+="	AND LOG_CODIGO='01' "
	ElseIf _cTipo='2'  //->Impressao etiquetas Re-Identificacao de etiqueta caixa tunel
		cSql+="	AND LOG_CODIGO='38' "
	ElseIf _cTipo='3' //->Impressao etiquetas Re-Identificacao de etiqueta caixa estoque
		cSql+="	AND LOG_CODIGO='40' "
	Endif
	cSql+="	AND LOG_USERID='"+__cUserId+"' "
	cSql+="	AND LOG.D_E_L_E_T_ <>'*') "
	cSql+=") "
Endif
cSql+=" ORDER BY ZP1_CODETI "
cSql:=ChangeQuery(cSql)

If Select(_AliasETI) > 0
	(_AliasETI)->(dbCloseArea())
	If File(_AliasETI+GetDBExtension())
		fErase(_AliasETI+GetDBExtension())
	Endif
Endif

MemoWrite("C:\TEMP\Prt_" + UPPER(Funname()) + ".SQL",cSql)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_AliasETI,.T.,.F.)

While !IsPrinter(cPorta)
	If _lLog
		AADD(aErros,{"Impressora Zebra (Etiqueta) não esta pronta, A Porta " + cPorta + " não está Respondendo","ERRO"})
	Endif
	If !MsgBox("Impressora Zebra (Etiqueta) não esta pronta, A Porta " + cPorta + " não está Respondendo! Deseja continuar?" ,"Atenção","YESNO")
		DisarmTransaction()
		Return .F.
	Endif
Enddo

(_AliasETI)->(dbGoTop())
While !(_AliasETI)->(Eof())
	
	_dDtValid	:= STOD((_AliasETI)->ZP1_DTVALI)
	_dDtFabri	:= STOD((_AliasETI)->ZP1_DTPROD)
	_cCodEti 	:= (_AliasETI)->ZP1_CODETI
	_cLote 		:= (_AliasETI)->ZP1_LOTE
	
	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
		If ZP1->ZP1_FLAGPR='1'
			If _lLog
				AADD(aErros,{"Etiqueta: " + _cCodEti + " já impressa.","ERRO"})
			Endif
			(_AliasETI)->(dbSkip())
			Loop
		Endif
		
		If !RecLock("ZP1",.F.)
			If _lLog
				AADD(aErros,{"Etiqueta: " + _cCodEti + " sendo impressa por outra estação.","ERRO"})
			Endif
			(_AliasETI)->(dbSkip())
			Loop
		EndIf
		
		If Len(AllTrim((_AliasETI)->B1_XMODETI)) > 0
			ZP2->(dbSetOrder(1))
			If !ZP2->(dbSeek(xFilial()+(_AliasETI)->B1_XMODETI))
				//DisarmTransaction()
				If _lLog
					AADD(aErros, {"Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC+" Sem modelo de etiqueta cadastrado.","ERRO"})
				Else
					Alert("Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC+" Sem modelo de etiqueta cadastrado.")
				Endif
				Return .F.
			EndIf
		Else
			//DisarmTransaction()
			If _lLog
				AADD(aErros, {"Campo: B1_XMODETI Vazio para o Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC,"ERRO"})
			Else
				Alert("Campo: B1_XMODETI Vazio para o Produto: "+(_AliasETI)->B1_COD+"/"+(_AliasETI)->B1_DESC)
			Endif
			Return .F.
		Endif
		
		//->Indica que etiqueta esta sendo impressa
		_cStrEtiq 	:= ZP2->ZP2_ETIQ
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cEan14%"			,NoAcento((_AliasETI)->B1_XEAN14))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc01%"		,Ctrliz(NoAcento((_AliasETI)->B1_XDESCE1),39))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc02%"		,Ctrliz(NoAcento((_AliasETI)->B1_XDESCE2),39))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDesc03%"		,Ctrliz(NoAcento((_AliasETI)->B1_XDESCE3),39))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDTFab%"			,NoAcento(DToC(_dDtFabri)))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cDtValidade%"	,NoAcento(DToC(_dDtValid)))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cLote%"			,NoAcento(_cLote) + " " +IIF(_cTipo='2',"(T)",IIF(_cTipo='3',"(R)",'')))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cPeso%"			,NoAcento(AllTrim(Str((_AliasETI)->B1_CONV))+" "+(_AliasETI)->B1_UM))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cCodEtiq%"		,NoAcento(_cCodEti))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cAcond01%"		,Ctrliz(Alltrim(NoAcento((_AliasETI)->B1_XACOND1))+Alltrim(NoAcento((_AliasETI)->B1_XACOND2)),39))
		_cStrEtiq	:= StrTran(_cStrEtiq,"%cSIF%"			,NoAcento((_AliasETI)->B1_XSIF))
		_cStrEtiq 	:= StrTran(_cStrEtiq,"%cCodProd%"		,NoAcento((_AliasETI)->B1_COD))
		
		//			_cStrEtiq	:= StrTran(_cStrEtiq,"%cTipoEmb01%"		,NoAcento((_AliasETI)->B1_XTPEMB1))
		//			_cStrEtiq 	:= StrTran(_cStrEtiq,"%cTipoEmb02%"		,NoAcento((_AliasETI)->B1_XTPEMB2))
		
		AADD(_aEtiImp,{_cCodEti, _cStrEtiq, (_AliasETI)->ZP1_TIPO, STOD((_AliasETI)->ZP1_DTVALI), STOD((_AliasETI)->ZP1_DTPROD), 0}) //->Seleciona etiquetas para impressao
		
		
	Endif
	//MrkNumEti('1',_cCodEti)
	
	(_AliasETI)->(dbSkip())
EndDo

If Select(_AliasETI) > 0
	(_AliasETI)->(dbCloseArea())
	If File(_AliasETI+GetDBExtension())
		fErase(_AliasETI+GetDBExtension())
	Endif
Endif

For x:=1 To Len(_aEtiImp)
	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+_aEtiImp[x][1]))
		_lCont	:= .T. //->Continua com a impressao
		If U_PCPVET01(ZP1->ZP1_CODETI, "'02','41','39','42','43','44','96'")
			If _lLog
				AADD(aErros,{"Etiqueta: " + ZP1->ZP1_CODETI + ". Já impressa. Consulte Log.","ERROR"})
			Endif
			RecLock("ZP1",.F.)
			REPLACE ZP1_FLAGPR WITH '1'
			ZP1->(MsUnLock())
			_lCont:=.F.
		ElseIf ZP1->ZP1_FLAGPR == '1'
			If _lLog
				AADD(aErros,{"Etiqueta: " + ZP1->ZP1_CODETI + ". Já impressa.","ERROR"})
			Endif
			_lCont:=.F.
		Else
			RecLock("ZP1",.F.)
			REPLACE ZP1_FLAGPR WITH '1'
			
			_aEtiImp[x][6]:= "1" //-> Marca etiqueta como impressa
			For i := 1 To Len(oWBrwZP1:AARRAY)
				If oWBrwZP1:AARRAY[i,7] == SUBSTR(_aEtiImp[x][1],1,11)
					oWBrwZP1:AARRAY[i,9]++
					oWBrwZP1:AARRAY[i,8]--
					oWBrwZP1:Refresh()
				EndIF
			Next i
			//	oWBrwZP1 oDados:AARRAY[_I,1]  oWBrwZP1:AARRAY[_I,1]
			If ZP1->ZP1_FLAGPR == '1'
				If _lLog
					AADD(aErros,{"Etiqueta: " + ZP1->ZP1_CODETI + " enviada para impressão.","OK"})
				Endif
				MSCBPRINTER("S4M",cPorta,,,.F.,,,,)
				MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
				MSCBBEGIN(1,4)
				MSCBWrite(_aEtiImp[x][2])
				MSCBEND()
				MSCBCLOSEPRINTER()
				
				//->Log
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,IIF(_aEtiImp[x][3]='1',"02",IIF(_aEtiImp[x][3]='2',"39","41")),"Dta. Val.: "+DTOC(_aEtiImp[x][4])+"/Dta. Prod.: "+ DTOC(_aEtiImp[x][5]))
				If _lLog
					AADD(aErros,{"Etiqueta:" + ZP1->ZP1_CODETI + " impressa com sucesso.","OK"})
				Endif
			Else
				If _lLog
					AADD(aErros,{"Etiqueta: " + ZP1->ZP1_CODETI + " Não enviada para impressão. Erro ao Marcar como impressa.","ERRO"})
				Endif
			Endif
			ZP1->(MsUnLock())
		Endif
	Else
		If _lLog
			AADD(aErros,{"Etiqueta: erro ao imprimir etiqueta " + _aEtiImp[x][1] + ". Não Encontrada.","ERROR"})
		Endif
	Endif
	
Next x


Return .T.

/*
Por: Fabricio
Em: 01/05/16
Descrição: Valida Data
*/
Static Function bValDtPrd()
Local _lRet := .T.
If _lLimData
	If _dDtFabri < (Date()-nZ6_QDRIETI) .OR. _dDtFabri > (Date()+nZ6_QDAIETI)
		MsgStop("Data inválida.")
		_lRet := .F.
	EndIf
EndIf
Return(_lRet)

/*
Por: FabrÍcio
Em: 01/05/16
Descrição: Valida Produto
*/
Static Function bValPrd()
Local _lRet := .T.
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial()+cProduto))
	If SB1->B1_MSBLQL="1"
		MsgStop("Produto Bloqueado.")
		_lRet := .F.
	ElseIf Len(AllTrim(SB1->B1_XMODETI)) > 0
		ZP2->(dbSetOrder(1))
		If !ZP2->(dbSeek(xFilial()+SB1->B1_XMODETI))
			MsgStop("Produto sem modelo de etiqueta informado.")
			_lRet := .F.
		EndIf
	ElseIf SB1->B1_PRVALID <= 0
		MsgStop("Produto sem prazo de validade cadastrado.")
		_lRet := .F.
	Else
		MsgStop("Produto sem modelo de etiqueta informado.")
		_lRet := .F.
	EndIf
Else
	MsgStop("Produto inválido.")
	_lRet := .F.
EndIf

If _lRet
	_dDtFabri := CToD("//")
	oDtFabri:Refresh()
	cDescr := SB1->B1_DESC
	oDescr:Refresh()
EndIf
Return(_lRet)

/*
Por: Fabricio
Em: 01/05/16
Descrição: Valida Formulário de Geracao de Etiquetas
*/
Static Function bValForm()
Local _lRet := .T.
If Len(AllTrim(cProduto)) <= 0
	MsgStop("Informe o Produto.")
	Return(.F.)
EndIf

If Len(AllTrim(_cLote)) <= 0
	MsgStop("Informe o Lote.")
	Return(.F.)
EndIf

If _nQtEtiq <= 0
	MsgStop("Informe a quantidade de etiquetas a serem impressas.")
	Return(.F.)
EndIf

If Empty(_dDtFabri)
	MsgStop("Informe a data da produção.")
	Return(.F.)
EndIf
oWBrwZP1:Refresh()
Return(_lRet)

/*
Por: Fabricio
Em: 01/05/16
Descrição: Retira caracteres especiais e acentos de string
*/
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString
	cString := strTran( cString, cMaior, "" )
EndIf
If cMenor$ cString
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetNumEti() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Sem‡foro de etiquetas										    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descricao
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_nOpc				NœmŽrico		1=Retorna o œltimo valor e prende o registro
_cAlias			Tabela			Nome da tabela para retorno da chave
_cChave

*/
Static Function GetNumEti(_nOpc,_cAlias,_cChave,_nTam)
Local _cValor:=StrZero(1,_nTam)
If _nOpc==1
	ZPD->(dbSetOrder(1))
	If ZPD->(dbSeek(xFilial("ZPD")+_cAlias+_cChave))
		ZPD->(RecLock("ZPD",.F.))
		_cValor := StrZero(Val(ZPD->ZPD_VALOR) ,_nTam) //->Soma1(AllTrim(ZPD->ZPD_VALOR),_nTam)
		Return(_cValor)
	Else
		RecLock("ZPD",.T.)
		Replace ZPD_FILIAL 	With xFilial("ZPD")
		Replace ZPD_ALIAS		With _cAlias
		Replace ZPD_CHAVE		With _cChave
		Replace ZPD_VALOR		With _cValor
		ZPD->(MsUnLock())
		ZPD->(RecLock("ZPD",.F.))
		Return(_cValor)
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ComNumEti() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Comita Sem‡foro													º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descricao
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_nOpc				NœmŽrico		1=Commitar Valor
_cAlias			Tabela			Nome da tabela para retorno da chave
_cChave

*/
Static Function ComNumEti(_cAlias,_cChave,_nTam,_cValor)
dbSelectArea("ZPD")
dbSetOrder(1)
If dbSeek(xFilial("ZPD")+_cAlias+_cChave)
	_cValor:=StrZero(Val(_cValor),_nTam)
	If ZPD->(RecLock("ZPD",.F.))
		Replace ZPD_VALOR		With _cValor
		ZPD->(MsUnLock())
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MrkNumEti  ºAutor  ³Evandro Gomes     º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Marca como impresso										    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descricao
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_nOpc				NœmŽrico		1=Retorna o œltimo valor e prende o registro
_cAlias			Tabela			Nome da tabela para retorno da chave
_cChave

*/
Static Function MrkNumEti(_Flag,_CodEti)
ZP1->(dbSetOrder(1))
If ZP1->(dbSeek(xFilial("ZP1")+_CodEti))
	RecLock("ZP1",.F.)
	Replace ZP1_FLAGPR	With _Flag
	ZP1->(MsUnLock())
Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Marca
*/
User Function PCP5X()
oWBrwZP1:aArray[oWBrwZP1:nAt][1]:= !oWBrwZP1:aArray[oWBrwZP1:nAt][1]
aWBrwZP1[oWBrwZP1:nAt][1]:=oWBrwZP1:aArray[oWBrwZP1:nAt][1]
oWBrwZP1:DrawSelect()
oWBrwZP1:Refresh()
Return(.T.)

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Cria Perguntas
*/
Static Function PCP5Z(cPerg)
Local aPrgBlq:={}

putSx1(cPerg,"01","Filial de?	",".","."       	,"mv_ch1","C",04,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
putSx1(cPerg,"02","Filial Ate?	",".","."       	,"mv_ch2","C",04,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","")
putSx1(cPerg,"03","Dta.Fab. de?	",".","."       	,"mv_ch3","D",08,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
putSx1(cPerg,"04","Dta.Fab. Ate?",".","."       	,"mv_ch4","D",08,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
putSx1(cPerg,"05","Lote de?		",".","."       	,"mv_ch5",TAMSX3("ZP1_LOTE")[3],TAMSX3("ZP1_LOTE")[1],TAMSX3("ZP1_LOTE")[2],0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
putSx1(cPerg,"06","Lote Ate?	",".","."       	,"mv_ch6",TAMSX3("ZP1_LOTE")[3],TAMSX3("ZP1_LOTE")[1],TAMSX3("ZP1_LOTE")[2],0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
putSx1(cPerg,"07","Produto de?	",".","."       	,"mv_ch7",TAMSX3("ZP1_CODPRO")[3],TAMSX3("ZP1_CODPRO")[1],TAMSX3("ZP1_CODPRO")[2],0,"G","","SB1","","","mv_par07","","","","","","","","","","","","","","","","")
putSx1(cPerg,"08","Produto Ate?	",".","."       	,"mv_ch8",TAMSX3("ZP1_CODPRO")[3],TAMSX3("ZP1_CODPRO")[1],TAMSX3("ZP1_CODPRO")[2],0,"G","","SB1","","","mv_par08","","","","","","","","","","","","","","","","")
putSx1(cPerg,"09","Situacao?	",".","."			,"mv_ch9","N",01,0,0,"C","","   ","","S","mv_par09","Nao Impresso",,,,"Impresso",,,"Ambas",,,)
putSx1(cPerg,"10","Vis.Log Acoes?",".","."			,"mv_cha","N",01,0,0,"C","","   ","","S","mv_par10","Nao",,,,"Sim",,,"",,,)

AADD(aPrgBlq,{"01","0101"})
AADD(aPrgBlq,{"02","0101"})
AADD(aPrgBlq,{"05",""})
AADD(aPrgBlq,{"06","ZZZ"})
AADD(aPrgBlq,{"07","" })
AADD(aPrgBlq,{"08","ZZZZZZZZZZ"})
AADD(aPrgBlq,{"09",'3'})
AADD(aPrgBlq,{"10",'1'})

//->Ajusta Bloqueios de Perguntas
For x:=1 to Len(aPrgBlq)
	SXK->(dbSetOrder(1))
	If !SXK->(dbSeek(PADR(cPerg,10)+aPrgBlq[x,1]+"U"+__cUserID))
		If !lZ6_PCPUFIL
			RecLock("SXK",.T.)
			REPLACE XK_GRUPO 		WITH PADR(cPerg,10)
			REPLACE XK_SEQ 		WITH aPrgBlq[x,1]
			REPLACE XK_IDUSER		WITH "U"+__cUserID
			REPLACE XK_CONTEUD	WITH aPrgBlq[x,2]
			SXK->(MSUnLock())
		Endif
	Else
		If lZ6_PCPUFIL
			RecLock("SXK",.F.)
			SXK->(dbDelete())
			SXK->(MSUnLock())
		Else
			RecLock("SXK",.F.)
			REPLACE XK_CONTEUD	WITH aPrgBlq[x,2]
			SXK->(MSUnLock())
		Endif
	Endif
Next x
Return

Static Function Ctrliz(ctexto,ntam)

ctexto	:=	ALLTRIM(ctexto)
nBlSp   := (ntam-len(ctexto))/2
cString := SPACE(nBlSp)+ctexto

Return cString

STATIC FUNCTION SELETIQT()

cSql:="SELECT "
cSql+="DISTINCT ZP1_FILIAL, ZP1_DTPROD, ZP1_LOTE, ZP1_CODPRO, SUBSTRING(ZP1_CODETI,1,11) CODETI"
cSql+=",SUM(CASE WHEN ZP1_FLAGPR='0' THEN 1 ELSE 0 END) IMP_NAO "
cSql+=",SUM(CASE WHEN ZP1_FLAGPR='1' THEN 1 ELSE 0 END) IMP_SIM "
cSql+="FROM "+RETSQLNAME("ZP1")+ " ZP1 "
cSql+="WHERE "
cSql+="ZP1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cSql+="AND ZP1_DTPROD BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
cSql+="AND ZP1_LOTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
cSql+="AND ZP1_CODPRO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
cSql+="AND ZP1_STATUS NOT IN('5','9','7') "
If MV_PAR09 == 1 //-> Não Impressa
	cSql+="AND ZP1_FLAGPR='0' "
ElseIf MV_PAR09 == 2 //-> Impressa
	cSql+="AND ZP1_FLAGPR='1' "
Endif
cSql+="AND ZP1_TIPO='"+_cTipo+"' "
cSql+="AND ZP1.D_E_L_E_T_ <> '*' "
If !U_APPFUN01("Z6_VISTPAL")=="S"
	cSql+=" AND (EXISTS ( SELECT ZPE_CODIGO FROM  "+RETSQLNAME("ZPE")+ " ZPE "
	cSql+="	WHERE ZPE_CODETI=ZP1_CODETI "
	If _cTipo='1'	//->  1-Normal(Entrou e saiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao
		cSql+="	AND ZPE_CODIGO='01' "
	ElseIf _cTipo='2'  //->Impressao etiquetas Re-Identificacao de etiqueta caixa tunel
		cSql+="	AND ZPE_CODIGO='38' "
	ElseIf _cTipo='3' //->Impressao etiquetas Re-Identificacao de etiqueta caixa estoque
		cSql+="	AND ZPE_CODIGO='40' "
	Endif
	cSql+="	AND ZPE_USERID='"+__cUserId+"' "
	cSql+="	AND ZPE.D_E_L_E_T_ <>'*') "
	cSql+=" OR EXISTS ( SELECT LOG_CODIGO FROM LOGPCP LOG "
	cSql+="	WHERE LOG_CODETI=ZP1_CODETI "
	If _cTipo='1'	//->  1-Normal(Entrou e saiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao
		cSql+="	AND LOG_CODIGO='01' "
	ElseIf _cTipo='2'  //->Impressao etiquetas Re-Identificacao de etiqueta caixa tunel
		cSql+="	AND LOG_CODIGO='38' "
	ElseIf _cTipo='3' //->Impressao etiquetas Re-Identificacao de etiqueta caixa estoque
		cSql+="	AND LOG_CODIGO='40' "
	Endif
	cSql+="	AND LOG_USERID='"+__cUserId+"' "
	cSql+="	AND LOG.D_E_L_E_T_ <>'*') "
	cSql+=") "
Endif
cSql+="GROUP BY ZP1_FILIAL, ZP1_DTPROD, ZP1_LOTE, ZP1_CODPRO, SUBSTRING(ZP1_CODETI,1,11)"
cSql:=ChangeQuery(cSql)
MemoWrite("C:\TEMP\"+Alltrim(UPPER(Funname()))+".sql", cSql)

If Select(cAliasZP1) > 0
	(cAliasZP1)->(dbCloseArea())
	If File(cAliasZP1+GetDBExtension())
		fErase(cAliasZP1+GetDBExtension())
	Endif
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasZP1,.T.,.F.)

//oProcess:SetRegua1(1)
//oProcess:IncRegua1("Listando Etiquetas...")
_nTotReg:=Contar(cAliasZP1,"!Eof()")
//oProcess:SetRegua2(_nTotReg)
(cAliasZP1)->(dbGoTop())

aWBrwZP1 := {}
LPASS := .F.
iF VALTYPE(OWBRWZP1) == 'O'
	OWBRWZP1:AARRAY := {}
	LPASS := .T.
ENDIF
While !(cAliasZP1)->(Eof())
	DbSelectArea(cAliasZP1)
	//oProcess:IncRegua2("Processando nota:"+(cAliasZP1)->CODETI+"/"+AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasZP1)->ZP1_CODPRO,"B1_DESC")))
	//sysRefresh()
	AADD(aWBrwZP1,{;
	.F.,;
	(cAliasZP1)->ZP1_FILIAL,;
	(cAliasZP1)->ZP1_LOTE,;
	(cAliasZP1)->ZP1_CODPRO,;
	AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasZP1)->ZP1_CODPRO,"B1_DESC")),;
	DTOC(STOD((cAliasZP1)->ZP1_DTPROD)),;
	(cAliasZP1)->CODETI,;
	(cAliasZP1)->IMP_NAO,;
	(cAliasZP1)->IMP_SIM})
	IF LPASS
		AADD(OWBRWZP1:AARRAY,{;
		.F.,;
		(cAliasZP1)->ZP1_FILIAL,;
		(cAliasZP1)->ZP1_LOTE,;
		(cAliasZP1)->ZP1_CODPRO,;
		AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasZP1)->ZP1_CODPRO,"B1_DESC")),;
		DTOC(STOD((cAliasZP1)->ZP1_DTPROD)),;
		(cAliasZP1)->CODETI,;
		(cAliasZP1)->IMP_NAO,;
		(cAliasZP1)->IMP_SIM})
	ENDIF
	(cAliasZP1)->(dbSkip())
	
Enddo
IF VALTYPE(oWBrwZP1) == "O"
	U_OHFUNA21(@oDlgZP1, @oWBrwZP1, _aCabec, @aWBrwZP1, "PCP5X")
	oWBrwZP1:Refresh()
	IF VALTYPE(oDados) == "O"
		oDados:Refresh()
	ENDIF
	oDlgZP1:Refresh()
ENDIF
RETURN


Static Function bValKL(cChave)

DbSelectArea('SX5')
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(DbGoTop())
lRet := SX5->(DbSeek(FWxFilial("SX5") + "KL" + cChave))

return lRet


/*/{Protheus.doc} zCadSX5
Cadastro de tabelas SX5
@author Atilio
@since 05/08/2016
@version 1.0
@param cTabela, character, Código da tabela genérica
@param cTitRot, character, Título da Rotina
@example
u_zCadSX5("01", "Séries de NF")
/*/

User Function zCadSX5(cTabela, cTitRot)
Local aArea   := GetArea()
Local oBrowse
Local cFunBkp := FunName()
Default cTitRot := ""
Private cTabX := cTabela


//Senão tiver chave, finaliza
If Empty(cTabela)
	Return
EndIf

DbSelectArea('SX5')
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(DbGoTop())

//Se vier título por parâmetro
If !Empty(cTitRot)
	cTitulo := cTitRot
EndIf

//Se ainda tiver em branco, pega o da própria tabela
If Empty(cTitulo)
	//Se conseguir posicionar
	If SX5->(DbSeek(FWxFilial("SX5") + "00" + cTabela))
		cTitulo := SX5->X5_DESCRI
		
	Else
		MsgAlert("Tabela não encontrada!", "Atenção")
		Return
	EndIf
EndIf

//Instânciando FWMBrowse - Somente com dicionário de dados
SetFunName("zCadSX5")
oBrowse := FWMBrowse():New()

//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("SX5")

//Setando a descrição da rotina
oBrowse:SetDescription(cTitulo)

//Filtrando
oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"'")

//Ativa a Browse
oBrowse:Activate()

SetFunName(cFunBkp)
RestArea(aArea)
Return

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Daniel Atilio                                                |
| Data:  05/08/2016                                                   |
| Desc:  Criação do menu MVC                                          |
*---------------------------------------------------------------------*/

Static Function MenuDef()
Local aRot := {}

//Adicionando opções
ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zCadSX5' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Daniel Atilio                                                |
| Data:  05/08/2016                                                   |
| Desc:  Criação do modelo de dados MVC                               |
*---------------------------------------------------------------------*/

Static Function ModelDef()
//Criação do objeto do modelo de dados
Local oModel := Nil

//Criação da estrutura de dados utilizada na interface
Local oStSX5 := FWFormStruct(1, "SX5")

//Editando características do dicionário
oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edição
oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                     //Ini Padrão
oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edição
oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Chv()'))               //Validação de Campo
oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
oStSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório

//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
oModel := MPFormModel():New("zCadSX5M",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)

//Atribuindo formulários para o modelo
oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)

//Setando a chave primária da rotina
oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})

//Adicionando descrição ao modelo
oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

//Setando a descrição do formulário
oModel:GetModel("FORMSX5"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Daniel Atilio                                                |
| Data:  05/08/2016                                                   |
| Desc:  Criação da visão MVC                                         |
*---------------------------------------------------------------------*/

Static Function ViewDef()
//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
Local oModel := FWLoadModel("zCadSX5")

//Criação da estrutura de dados utilizada na interface do cadastro de Autor
Local oStSX5 := FWFormStruct(2, "SX5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'}

//Criando oView como nulo
Local oView := Nil

//Criando a view que será o retorno da função e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formulários para interface
oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_SX5', 'Dados - '+cTitulo )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

//O formulário da interface será colocado dentro do container
oView:SetOwnerView("VIEW_SX5","TELA")

//Retira o campo de tabela da visualização
oStSX5:RemoveField("X5_TABELA")
Return oView

/*/{Protheus.doc} zSX5Chv
Função que valida a digitação do campo Chave, para verificar se já existe
@type function
@author Atilio
@since 05/08/2016
@version 1.0
/*/

User Function zSX5Chv()
Local aArea    := GetArea()
Local lRet     := .T.
Local cX5Chave := M->X5_CHAVE

DbSelectArea('SX5')
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
SX5->(DbGoTop())

//Se conseguir posicionar, já existe
If SX5->(DbSeek(FWxFilial('SX5') + cTabX + cX5Chave))
	MsgAlert("Já existe chave com esse código (<b>"+cX5Chave+"</b>)!", "Atenção")
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet
