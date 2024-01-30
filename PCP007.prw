#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH
#INCLUDE 'PARMTYPE.CH'
#define DS_MODALFRAME   128

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP007()	ºAutor  ³Infinit             º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Paletização												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
REVISAO: 2016/13
Descricao:
Foi criado o parametro MV_PCPEMBE, e foi adicionado ao codigo de validacao
e update de dados da etoqueta no momento da leitura, comandos embedded. Este
procedimento foi criado para avaliar o time de leitura de processamento dos
dados da etiqueta. Foi consevada a rotina padr‹o.
Par‰metros: Separados por "/"
P=Consulta etiqueta apos a leitura paletizacao
E=Consulta etiqueta apos a leitura Expedicao
W=Consulta rotinas WMS customizado
I=Consulta etiquetas no processo de Invent‡rio
G=Salvar dados de etiqueta caixa.


*/
/*
Funcao: PCP07A
Descricao: Funcao para picking
Parametro: cXOpc
1=Normal
2=Picking
*/
User Function PCP07A()
Private _cOpc
U_PCP007("2")
Return

User Function PCP007(cXOpc)
Local oBtnAbrir
Local oBtnAtu
Local oBtnEtiq
Local oBtnExcl
Local oBtnNew
Local oBtnSai
Local oBtnViz
Private _cOpc
Private cStatus 	:= ""
Private _cNilAu 	:= 8 //If(MsgYesNo("Nivel 8?"),8,2)
Private oRelPale
Private aRelPale	:= {}
Private oDlg
Private _nPeso		:= 0
Private _cFiltro 	:= ""
Private QPAL		:= GetNextAlias()
Private _cAlias		:= GetNextAlias()
Private aErros		:= {}
Private _nNumSeq 	:= GetNewPar("MV_PCP7NUM",0) //-> 0=Sequencial Direta / 1=Sequencial com semaforo
Private _nPCPEMB 	:= GetNewPar("MV_PCPEMBE","")
Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
Private _nTpLog		:= GetNewPar("MV_PCPTLOG",1) //-> 1=Usa tabelas Protheus/2=u
Private oProcess
Private lRLogPal	:= .F.
Private _cXOpc		:= Iif(cXOpc = Nil,'1',cXOpc) //-> 1=Palete normal / 2=Palete Picking
Private _lFecEst	:= GetNewPar("MV_XFEHPRD",.F.)
Private dDataFec 	:= STOD(GetNewPar("MV_XDTAPRD",'20180101'))
Private cClassifi	:= Space(3)
Private cDescClas	:= Space(TamSx3("ZZS_DESCRI")[1])
/*
//->Testa ambientes que podem ser usados
If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
Alert("Ambiente nao homologado para o uso desta rotina!!!")
Return .F.
Endif

//->Analiza se usuário pode acessar esta rotina
If !U_APPFUN01("Z6_PALETIZ")=="S"
MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
Return
Endif
*/
DEFINE MSDIALOG oDlg TITLE "Pallets"+Iif(_cXOpc=="2"," Picking","") FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

PCP7X(9,"C")

@ 230, 010 BUTTON oBtnNew PROMPT "Novo" SIZE 037, 012 OF oDlg ACTION bTela("N") PIXEL

@ 230, 060 BUTTON oBtnAbrir PROMPT "Abrir" SIZE 037, 012 OF oDlg ACTION fAbrir() PIXEL

@ 230, 210 BUTTON oBtnAtu PROMPT "Filtro" SIZE 037, 012 OF oDlg ACTION bFiltro() PIXEL
If cXOpc = "2"
	@ 230, 310 BUTTON oBtnCompl PROMPT "Completar" SIZE 037, 012 OF oDlg ACTION bTela("C") PIXEL
	//oBtnNew:lactive := .f.
	//oBtnAbrir:lactive := .f.
EndIf
If U_APPFUN01("Z6_IETIPAL")=="S"
	@ 230, 260 BUTTON oBtnEtiq PROMPT "Etiqueta" SIZE 037, 012 OF oDlg ACTION bImp(aRelPale[oRelPale:nAt,1],_nPeso,"R") PIXEL
Endif
If U_APPFUN01("Z6_EETIPAL")=="S"
	@ 230, 160 BUTTON oBtnExcl PROMPT "Excluir" SIZE 037, 012 OF oDlg ACTION bTela("E") PIXEL
EndIf
@ 230, 110 BUTTON oBtnViz PROMPT "Visualizar" SIZE 037, 012 OF oDlg ACTION bTela("V") PIXEL

oRelPale:Align := CONTROL_ALIGN_TOP

ACTIVATE MSDIALOG oDlg CENTERED


Return

Static Function fAbrir()
ZP4->(dbSetOrder(1))
ZP4->(XFILIAL("ZP4")+aRelPale[oRelPale:nAt,1])
IF Substr(aRelPale[oRelPale:nAt,4],1,1) # "F"
	bTela("A")
Else
	If U_APPFUN01("Z6_ENVREPR")=="S" .and. (Empty(AllTrim(ZP4->ZP4_ENDWMS)))
		bTela("A")
	Else
		MsgStop("Você não tem permissão para usar este recurso!"+CHR(13)+CHR(10)+"ou o pallet, já está endereçado. ["+AllTrim(ZP4->ZP4_ENDWMS)+"]","Friato")
	EndIf
Endif

Return


Static Function fRelPale()
Local _cQry := ""

aRelPale := {}
_cQry += " SELECT ZP4_PALETE, ZP4_DATA, LTRIM(RTRIM(ZP4_PRODUT))+'-'+LTRIM(RTRIM(B1_DESC)) PRODUTO"
_cQry += " , CASE ZP4_STATUS"
_cQry += " 	WHEN 'M' THEN 'MONTANDO'"
_cQry += " 	WHEN 'S' THEN 'SUSPENSO'"
_cQry += " 	WHEN 'F' THEN 'FECHADO'"
_cQry += " 	WHEN 'C' THEN 'CARREGANDO'"
_cQry += " 	WHEN 'E' THEN 'EXPEDIDO'"
_cQry += " 	ELSE '' END STATUS"
_cQry += " , ZP4.ZP4_USABER, CONVERT(VARCHAR(10),CAST(ZP4.ZP4_DTABER AS SMALLDATETIME),103)+'/'+ZP4.ZP4_HRABER DTHRABE"
_cQry += " , ZP4.ZP4_USFECH, CASE WHEN ZP4_HRFECH = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(ZP4.ZP4_DTFECH AS SMALLDATETIME),103)+'/'+ZP4.ZP4_HRFECH END DTHRFEC"
_cQry += " FROM "+RetSQLName("ZP4")+" ZP4"
_cQry += " INNER JOIN "+RetSQLName("SB1")+" B1 ON B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP4_PRODUT"
_cQry += " WHERE ZP4.D_E_L_E_T_ = ' ' "
If !U_APPFUN01("Z6_VISTPAL")=="S"
	_cQry += " AND ZP4_USABER='"+SubStr(cUserName,1,30)+"' "
Endif
_cQry += " AND ZP4_FILIAL = '"+xFilial("ZP4")+"'"
If Len(AllTrim(_cFiltro)) > 0
	_cQry += "	AND ("+_cFiltro+")"
Else
	_cQry += " AND (ZP4_STATUS = 'M' OR ZP4_STATUS = 'S')"
EndIf
_cQry += " ORDER BY ZP4_DATA, ZP4_PALETE"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),QPAL,.T.,.F.)
MemoWrite("C:\TEMP\"+UPPER(Funname()), _cQry)
oProcess:SetRegua2( Contar(QPAL,"!EOF()") )
(QPAL)->(dbGoTop())

While !(QPAL)->(EOF())
	oProcess:IncRegua2("Listando Palete"+Iif(_cXOpc=="2"," Picking","")+":"+(QPAL)->ZP4_PALETE)
	Aadd(aRelPale,{(QPAL)->ZP4_PALETE, DToS(SToD((QPAL)->ZP4_DATA)), (QPAL)->PRODUTO, (QPAL)->STATUS, (QPAL)->ZP4_USABER, (QPAL)->DTHRABE, (QPAL)->ZP4_USFECH, (QPAL)->DTHRFEC})
	(QPAL)->(dbSkip())
EndDo
(QPAL)->(dbCloseArea())

If Len(aRelPale) <= 0
	Aadd(aRelPale,{"","","","","","","",""})
EndIf

If oRelPale == Nil
	@ 000, 000 LISTBOX oRelPale Fields HEADER "Pallet","Data","Produto","Status","Usuário Abertura","Data/Hora Abertura","Usuário Fechamento","Data/Hora Fech." SIZE 500, 225 OF oDlg PIXEL ColSizes 50,30,100,40,55,55,55,55
EndIf

oRelPale:SetArray(aRelPale)
oRelPale:bLine := {|| {;
aRelPale[oRelPale:nAt,1],;
aRelPale[oRelPale:nAt,2],;
aRelPale[oRelPale:nAt,3],;
aRelPale[oRelPale:nAt,4],;
aRelPale[oRelPale:nAt,5],;
aRelPale[oRelPale:nAt,6],;
aRelPale[oRelPale:nAt,7],;
aRelPale[oRelPale:nAt,8];
}}

oRelPale:bLDblClick := {|| oRelPale:DrawSelect()}
oRelPale:Refresh()
oDlg:Refresh()

Return

Static Function bTela(_cOpc)
Private oAcao
Private nAcao := 1
Private oBtnCanc
Private oCodigo
Private oClassifi
Private oDescClas
Private oData
Private dData := Date()
Private cPalete := ""
Private cCodigo := Space(15)
Private cProduto := ""
Private nContado := 0
Private oGrava
Private oIdEtiq
Private cIdEtiq := Space(17)
Private oPalete
Private oPrdLido
Private cPrdLido := ""
Private oProduto
Private oStatusOK
Private oStatusEr
Private oDlgPal
Private oContado
Private oEtiquetas
Private aEtiquetas := {}
Private _nCapPale := 0
Private oPBase
Private nPBase := 0
Private oPStrech
Private nPStrech := 0
Private oFntSt := TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
Private xAliasTMP := GetNextAlias()

If _cOpc == "N"
	cPalete := bNxtPal()
	If cPalete="0"
		Return .F.
	Endif
Else
	iF _cOpc # "C"
		If Len(AllTrim(aRelPale[1,1])) <= 0
			Return
		EndIf
		cPalete := aRelPale[oRelPale:nAt,1]
	Else
		cPalete := FWInputBox('Digite ou capture o número do Pallet "PAI"',space(17))
		If Empty(cPalete)
			Return
		EndIF
	EndIf
	ZP4->(dbSetOrder(1))
	If !ZP4->(dbSeek(xFilial()+cPalete))
		If ZP4->ZP4_CODEST <> _cXOpc
			MsgStop("Tipo de Palete Diferente para rotina.")
			PCP7X(9,"C")
			Return
		Endif
		MsgStop("Palete invalido")
		PCP7X(9,"C")
		Return
	EndIf
	If !(_cOpc $ "V|C")
		If !(ZP4->ZP4_STATUS $ "S|M") .AND. cNivel < _cNilAu
			MsgStop("Somente um palete suspenso ou montando, pode ser aberto.")
			Return
		EndIf
		
		If ZP4->ZP4_STATUS $ "CE"
			MsgStop("Palete em carregamento ou ja expedido.")
			Return
		EndIf
	EndIf
	
	If _cOpc == "A"
		nCaixas := FCONTACAIXA(ZP4->ZP4_PALETE)
		RecLock("ZP4",.F.)
		ZP4->ZP4_CONTAD := nCaixas
		ZP4->ZP4_STATUS	:= "S"
		ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
		ZP4->(MsUnLock())
		U_PCPRGLOG(_nTpLog,ZP4->ZP4_PALETE,"14")
	EndIf
	If _cOpc == "C"
		If !Empty(ZP4->ZP4_ENDWMS)
			MsgStop("Somente pallets sem endereço podem usar esta rotina. ---> ["+ZP4->ZP4_ENDWMS+"] ")
			Return
		EndIf
		
		_cQry := "SELECT * FROM "+RetSqlName("ZP1")+" WHERE ZP1_PALETE = '"+AllTrim(cPalete)+"' AND ZP1_LOCAL <> '10' "
		
		MemoWrite("C:\Temp\"+AllTrim(Funname())+"_local.Sql",_cQry)
		
		If Select(xAliasTMP) > 0
			(xAliasTMP)->(dbCloseArea())
		Endif
		
		dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),xAliasTMP,.F.,.T.)
		
		If 	!(xAliasTMP)->(EOF()) .OR. !(xAliasTMP)->(BOF())
			MsgStop("Existe ao menos uma caixa ["+AllTrim((xAliasTMP)->ZP1_CODETI)+"], com o aramzém diferente de 10, neste pallet. ---> ["+(xAliasTMP)->ZP1_LOCAL+"] ")
			Return
		EndIF
	EndIF
	
	dData 		:= ZP4->ZP4_DATA
	cPalete 	:= ZP4->ZP4_PALETE
	cClassifi	:= ZZS->ZZS_COD
	cDescClas	:= Posicione("ZZS",1,xFilial("ZZS")+ZZS->ZZS_COD,"ZZS_DESCRI")
	cCodigo 	:= ZP4->ZP4_PRODUT
	cProduto 	:= Posicione("SB1",1,xFilial("SB1")+ZP4->ZP4_PRODUT,"B1_DESC")
	_nCapPale 	:= Posicione("SB1",1,xFilial("SB1")+ZP4->ZP4_PRODUT,"B1_XQTDPAL")
	nContado 	:= ZP4->ZP4_CONTAD
	nPBase 		:= ZP4->ZP4_PBASE
	nPStrech 	:= ZP4->ZP4_PSTREC
	cClassifi	:= ZP4->ZP4_CODCLA
	cDescClas	:= Posicione("ZZS",1,xFilial("ZZS")+ZP4->ZP4_CODCLA,"ZZS_DESCRI")
	
	If _cOpc == "E"
		ZP1->(dbSetOrder(2))
		If ZP1->(dbSeek(xFilial()+cPalete)) .or. nContado > 0
			MsgStop("Não é possível excluir pallet com caixas.","Friato")
			Return
		Else
			RecLock("ZP4",.F.)
			ZP4->(dbDelete())
			ZP4->(MsUnLock())
			MsgAlert("Pallet ["+cPalete+"] excluído com sucesso.","Friato")
			PCP7X(9,"C")
			Return
		EndIf
	EndIf
EndIf

DEFINE MSDIALOG oDlgPal TITLE "Montagem Palete" FROM 000, 000  TO 600, 500 COLORS 0, 16777215 PIXEL

@ 002, 002 SAY oSay1 PROMPT "Data" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 010, 002 MSGET oData VAR dData SIZE 040, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
@ 002, 050 SAY oSay2 PROMPT "Palete" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 010, 050 MSGET oPalete VAR cPalete SIZE 065, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
@ 002, 120 SAY oSay8 PROMPT "Peso Base" SIZE 035, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 010, 120 MSGET oPBase VAR nPBase SIZE 035, 010 OF oDlgPal PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL
@ 002, 170 SAY oSay9 PROMPT "Peso Strech" SIZE 035, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 010, 170 MSGET oPStrech VAR nPStrech SIZE 035, 010 OF oDlgPal PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL

@ 025, 002 SAY oSay3 PROMPT "Classificação" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 032, 002 MSGET oClassifi VAR cClassifi SIZE 045, 010 OF oDlgPal COLORS 0, 16777215 F3 "ZZS" Valid bValClas() PIXEL
@ 025, 050 SAY oSay4 PROMPT "Descrição" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 032, 050 MSGET oDescClas VAR cDescClas SIZE 150, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

@ 048, 002 SAY oSay3 PROMPT "Código" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 054, 002 MSGET oCodigo VAR cCodigo SIZE 045, 010 OF oDlgPal COLORS 0, 16777215 F3 "SB1" When Len(AllTrim(cProduto)) <= 0 Valid bValProd() PIXEL
@ 048, 050 SAY oSay4 PROMPT "Produto" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 054, 050 MSGET oProduto VAR cProduto SIZE 150, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
fEtiquetas(_cOpc)
If _cOpc $ "A|N|C"
	@ 222, 002 SAY oSay5 PROMPT "Identificação" SIZE 050, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
	@ 229, 002 MSGET oIdEtiq VAR cIdEtiq SIZE 060, 010 OF oDlgPal COLORS 0, 16777215 Valid Iif(Upper(AllTrim(cIdEtiq))="FECHAR",oDlgPal:End(),Iif(bValEtiq(_cOpc),.T.,oIdEtiq:SetFocus())) PIXEL
EndIf
@ 222, 082 SAY oSay7 PROMPT "Contador" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 229, 082 MSGET oContado VAR nContado SIZE 025, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

@ 222, 132 SAY oSay17 PROMPT "Qtd. Palete" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
@ 229, 132 MSGET _oCapPale VAR _nCapPale SIZE 025, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL

//@ 220, 002 SAY oSay6 PROMPT "Produto" SIZE 025, 007 OF oDlgPal COLORS 0, 16777215 PIXEL
//@ 227, 002 MSGET oPrdLido VAR cPrdLido SIZE 150, 010 OF oDlgPal COLORS 0, 16777215 When .F. PIXEL
@ 267, 000 GET oStatusOK VAR cStatus OF oDlgPal MULTILINE SIZE 200, 055 COLORS 0, 32768 FONT oFntSt READONLY HSCROLL PIXEL
@ 267, 000 GET oStatusER VAR cStatus OF oDlgPal MULTILINE SIZE 200, 055 COLORS 0, 255 FONT oFntSt READONLY HSCROLL PIXEL
oStatusER:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
oStatusOK:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")

If _cOpc == "E"
	@ 032, 207 BUTTON oGrava PROMPT "Excluir" SIZE 037, 012 OF oDlgPal Action bExcl() PIXEL
Else
	@ 032, 207 BUTTON oGrava PROMPT "Fechar" SIZE 037, 012 OF oDlgPal Action oDlgPal:End() PIXEL
EndIf

//@ 020, 207 BUTTON oBtnCanc PROMPT "Cancelar" SIZE 037, 012 OF oDlgPal PIXEL
If _cOpc $ "A|N|C"
	@ 054, 207 BUTTON oZerar PROMPT "Zerar" SIZE 037, 012 OF oDlgPal Action bZera() PIXEL
	@ 072, 207 RADIO oAcao VAR nAcao ITEMS "Inclusão","Exclusão" SIZE 037, 025 OF oDlgPal COLOR 0, 16777215 MESSAGE "Leitura" PIXEL
	oAcao:bChange := {|| oIdEtiq:SetFocus()}
EndIf

If _cOpc $ "A|C"
	oIdEtiq:SetFocus()
EndIf

// Don't change the Align Order
oStatusOK:Align := CONTROL_ALIGN_BOTTOM
oStatusER:Align := CONTROL_ALIGN_BOTTOM

oStatusOK:Hide()
oStatusER:Hide()

ACTIVATE MSDIALOG oDlgPal CENTERED VALID PCP7X(1,_cOpc)
//bValFrm(_cOpc)

Return

Static Function fEtiquetas(_cOpc)
If _cOpc == "N"
	Aadd(aEtiquetas,{"","","",""})
Else
	ZP1->(dbSetOrder(2))
	ZP1->(dbSeek(xFilial()+aRelPale[oRelPale:nAt,1]))
	While !ZP1->(EOF()) .AND. ZP1->ZP1_FILIAL == xFilial("ZP1") .AND. ZP1->ZP1_PALETE == aRelPale[oRelPale:nAt,1]
		aAdd(aEtiquetas,{ZP1->ZP1_CODETI,ZP1->ZP1_LOTE,DToC(ZP1->ZP1_DTPROD),DToC(ZP1->ZP1_DTVALI)})
		ZP1->(dbSkip())
	EndDo
EndIf

If Len(aEtiquetas) <= 0
	Aadd(aEtiquetas,{"","","",""})
EndIf

@ 069, 002 LISTBOX oEtiquetas Fields HEADER "Identificação","Lote","Dt. Produção","Dt. Validade" SIZE 197, 150 OF oDlgPal PIXEL ColSizes 50,50
oEtiquetas:SetArray(aEtiquetas)
oEtiquetas:bLine := {|| {aEtiquetas[oEtiquetas:nAt,1],aEtiquetas[oEtiquetas:nAt,2],aEtiquetas[oEtiquetas:nAt,3],aEtiquetas[oEtiquetas:nAt,4]}}
oEtiquetas:bLDblClick := {|| oEtiquetas:DrawSelect()}

Return

Static Function bNxtPal(_dDtFabri,_cProd)
Local _cRet := Replicate("0",15)
Local _cQry := ""
Local _aArea := GetArea()
Local _CodPal:='90'+Replicate("0",14)
If _nNumSeq=0 //-> Sequencia de numeracao normal
	_cRet := GetNumPa2(1,"ZP4","PAL_0101",14)
Elseif _nNumSeq=1 //-> Sequencia de numeracao por semaforo
	_cRet := GetNumPal(1,"ZP4","PAL_0101",14)
Endif
_CodPal 	:= "90"+_cRet

//->Valida Enderecamento
If !U_GTOWMSVEE(_CodPal)
	Alert("Etiqueta enderecada, impossivel movimentações.")
	Return(.F.)
Endif

ZP4->(dbSetOrder(1))
If ZP4->(dbSeek(xFilial("ZP4")+_CodPal))
	Alert("Palete existente, Tente Novamente!!!")
	Return "0"
Endif
nCaixas := FCONTACAIXA(ZP4->ZP4_PALETE)
RecLock("ZP4",.T.)
ZP4->ZP4_FILIAL	:= xFilial("ZP4")
ZP4->ZP4_PALETE	:= _CodPal
ZP4->ZP4_CONTAD	:= nCaixas
ZP4->ZP4_STATUS	:= "M"
ZP4->ZP4_USABER	:= SubStr(cUserName,1,30)
ZP4->ZP4_DTABER	:= Date()
ZP4->ZP4_HRABER	:= Time()
ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
ZP4->ZP4_CODCLA := cClassifi

ZP4->(MsUnLock())

If _nNumSeq=1 //-> Sequência de numerário por semáforo
	_cRet:=Soma1(_cRet,15)
	ComNumPal("ZP4","PAL_"+xFilial("ZP4"),15,_cRet)
Endif
//->Registro de Log
U_PCPRGLOG(_nTpLog,_CodPal,"18")
Return(_CodPal)

Static Function bValProd()
Local _lRet := .T.
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial()+cCodigo))
	_nCapPale := SB1->B1_XQTDPAL
	_oCapPale:Refresh()
	cProduto := SB1->B1_DESC
	oProduto:Refresh()
	oIdEtiq:SetFocus()
Else
	MsgStop("Produto invalido")
	_lRet := .F.
EndIf
Return(_lRet)


Static Function bValClas()
Local _lRet := .T.
ZZS->(dbSetOrder(1))
If ZZS->(dbSeek(xFilial()+cClassifi))
	cDescClas := ZZS->ZZS_DESCRI
	oDescClas:Refresh()
	oCodigo:SetFocus()
ElseIf cClassifi = ' '
	cDescClas := Space(TamSx3("ZZS_DESCRI")[1])
	oDescClas:Refresh()
	oCodigo:SetFocus()
	_lRet := .T.
Else
	cDescClas := Space(TamSx3("ZZS_DESCRI")[1])
	oDescClas:Refresh()
	oCodigo:SetFocus()
	MsgStop("Classificação invalida!")
	_lRet := .F.
EndIf
Return(_lRet)


Static Function bValEtiq(_cOpc)
Local _lRet 	:= .T.
Local _nPos 	:= 0
Local _cAlias	:= GetNextAlias()
cStatus := ""
If Len(AllTrim(cIdEtiq)) <= 0 .Or. Upper(AllTrim(cIdEtiq)) == "FECHAR"
	oIdEtiq:SetFocus()
	Return(_lRet)
EndIf

//->Valida se estoque esta fechado
If dDataFec >= Date() .And. _lFecEst
	cStatus := "Estoque fechado na data:"+DTOC(Date())+"."
	oIdEtiq:SetFocus()
	Return(.F.)
Endif


cIdEtiq := Upper(SubStr(cIdEtiq,1,16))

//->Valida Enderecamento
If !U_GTOWMSVEE(cIdEtiq)
	cStatus := "Etiqueda Enderecada, impossivel movimentacoes."
	oIdEtiq:SetFocus()
	Return(.F.)
Endif
//nContado	:= U_ValPalet(1,cPalete) //->Contagem de caixas do Palete
If Empty(AllTrim(cStatus))
	If nAcao == 1 //->Inclus‹o
		If (nContado < _nCapPale .And. _cXOpc=='1') .Or. (nContado < (_nCapPale-1) .And. _cXOpc=='2')
			If _nPCPEMB $ "P" //->Usa Embedded
				BeginSql alias _cAlias
					SELECT *
					FROM %table:ZP1% ZP1
					WHERE
					ZP1.ZP1_FILIAL= %xfilial:ZP1%
					AND ZP1.ZP1_CODETI=%exp:cIdEtiq%
					AND ZP1.%notDel%
					ORDER BY %Order:ZP1%
				EndSql
				If !(_cAlias)->(Eof()) .And. !(_cAlias)->(Bof())
					If (_cAlias)->ZP1_CODPRO <> cCodigo
						_lRet := .F.
						cStatus := "O produto da etiqueta e diferente do informado acima."
					ElseIf (_cAlias)->ZP1_STATUS=="5"
						_lRet := .F.
						cStatus := "Etiqueta excluida em inventario."
					ElseIf (_cAlias)->ZP1_STATUS=="9"
						_lRet := .F.
						cStatus := "Etiqueta suspensa."
					ElseIf (_cAlias)->ZP1_STATUS=="7"
						_lRet := .F.
						cStatus := "Etiqueta sequestrada."
					ElseIf Len(AllTrim((_cAlias)->ZP1_CARGA)) > 0
						_lRet := .F.
						cStatus := "Etiqueta ja Expedida "+(_cAlias)->ZP1_CODETI
					ElseIf aScan(aEtiquetas,{|x| x[1]==cIdEtiq}) > 0
						_lRet := .F.
						cStatus := "Etiqueta ja lançada neste palete"
					ElseIf Len(AllTrim((_cAlias)->ZP1_PALETE)) > 0
						_lRet := .F.
						cStatus := "Etiqueta ja lançada no palete "+(_cAlias)->ZP1_PALETE
					Else
						bManEtiq(0,_cAlias)
						cStatus := ""
					Endif
				Else
					lCharInv:=.F. //->Testa caracter invalido
					For i:=1 To Len(cIdEtiq)
						If !SubStr(cIdEtiq,i,1) $ "0/9/8/7/6/5/4/3/2/1"
							lCharInv:=.T.
						Endif
					Next i
					U_PCPRGLOG(_nTpLog,Iif(lCharInv, "", cIdEtiq),"69",)
					U_PCPRGLOG(_nTpLog,cPalete,"69","Etiq: "+Iif(lCharInv, "", cIdEtiq))
					_lRet := .F.
					cStatus := "Etiqueta invalida!!!"
				Endif
				(_cAlias)->(dbCloseArea())
				If File(_cAlias+GetdbExtension())
					FErase(_cAlias+GetDbExtension())
				Endif
			Else //->N‹o usa Embbed
				ZP1->(dbSetOrder(1))
				If ZP1->(dbSeek(xFilial("ZP1")+cIdEtiq))
					If ZP1->ZP1_CODPRO <> cCodigo
						_lRet := .F.
						cStatus := "O produto da etiqueta é diferente do informado acima."
					ElseIf ZP1->ZP1_STATUS=="5"
						_lRet := .F.
						cStatus := "Etiqueta baixada em inventario."
					ElseIf ZP1->ZP1_STATUS=="9"
						_lRet := .F.
						cStatus := "Etiqueta suspensa."
					ElseIf ZP1->ZP1_STATUS=="7"
						_lRet := .F.
						cStatus := "Etiqueta sequestrada."
					ElseIf Len(AllTrim(ZP1->ZP1_CARGA)) > 0
						_lRet := .F.
						cStatus := "Etiqueta ja Expedida na carga --> ["+ZP1->ZP1_CARGA+"] "
					ElseIf aScan(aEtiquetas,{|x| x[1]==cIdEtiq}) > 0
						_lRet := .F.
						cStatus := "Etiqueta ja lancada neste palete"
					ElseIf Len(AllTrim(ZP1->ZP1_PALETE)) > 0 .and. _cOpc # "C"
						_lRet := .F.
						cStatus := "Etiqueta ja lancada no palete --> ["+ZP1->ZP1_PALETE+"] "
					ElseIf ZP1->ZP1_STATUS # '2' .and. _cOpc = "C"
						_lRet := .F.
						cStatus := "Status da caixa é diferente de 2 --> ["+ZP1->ZP1_STATUS+"] "
					ElseIf ZP1->ZP1_LOCAL # '10' .and. _cOpc = "C"
						_lRet := .F.
						cStatus := "Armazém da caixa é diferente de 10 --> ["+ZP1->ZP1_LOCAL+"] "
					ElseIf !(EMPTY(AllTrim(ZP1->ZP1_ENDWMS))) .and. _cOpc = "C"
						_lRet := .F.
						cStatus := "Esta caixa ainda está endereçada. ---> ["+ZP1->ZP1_ENDWMS+"] "
						/*
						ElseIf ZP1->ZP1_LOCAL = '10' .AND.  _cOpc = "N"
						_lRet := .F.
						cStatus := "Etiqueta proveniente da expedição."
						*/
					ElseIf (ZP1->ZP1_STATUS # "2" .or. ZP1->ZP1_LOCAL # '10' ) .AND.  _cOpc = "C"
						_lRet := .F.
						cStatus := "Etiqueta não pode completar pallet picking."
					Else
						bManEtiq(,,_cOpc)
						cStatus := ""
					Endif
				Else
					lCharInv:=.F. //->Testa caracter inv‡lido
					For i:=1 To Len(cIdEtiq)
						If !SubStr(cIdEtiq,i,1) $ "0/9/8/7/6/5/4/3/2/1"
							lCharInv:=.T.
						Endif
					Next i
					U_PCPRGLOG(_nTpLog,Iif(lCharInv, "", cIdEtiq),"69",)
					U_PCPRGLOG(_nTpLog,cPalete,"69","Etiq: "+Iif(lCharInv, "", cIdEtiq))
					_lRet := .F.
					cStatus := "Etiqueta invalida!!!"
				EndIf
			EndIf
		Else
			U_PCPRGLOG(_nTpLog,cIdEtiq,"68",)
			U_PCPRGLOG(_nTpLog,cPalete,"68","Etiq.: "+cIdEtiq)
			_lRet := .F.
			cStatus := "Capacidade do Palete Excedida!!!"
		Endif
	Else
		If (_nPos := aScan(aEtiquetas,{|x| x[1]==cIdEtiq})) > 0
			bManEtiq(_nPos)
		Else
			U_PCPRGLOG(_nTpLog,cIdEtiq,"70",)
			U_PCPRGLOG(_nTpLog,cPalete,"70","Etiq: "+cIdEtiq)
			_lRet := .F.
			cStatus := "Etiqueta não localizada!!!"
		EndIf
	EndIf
EndIF
cIdEtiq := Space(17)
oIdEtiq:Refresh()
bMsgStat()
oContado:Refresh()
oIdEtiq:SetFocus()
Return(_lRet)

/*
Rotina: bManEtiq(_nPos,_cAlias)
Descriacao: Manutencao de etiquetas apos a leitura e validacao
Proteus ja altera o palete da etiqueta para o palete de leitura
*/
Static Function bManEtiq(_nPos,_cAlias,_cOpc)
Local _cAliasU	:= GetNextAlias()
Local xAliasCT	:= GetNextAlias()
Local cSql			:= ""

//->Valida Enderecamento
If !U_GTOWMSVEE(cPalete)
	cStatus := "Etiqueta Enderecada, impossivel movimentacoes."
	Return(.F.)
Endif

Begin Transaction
nContado	:= U_ValPalet(1,cPalete) //->Contagem de caixas do Palete
oContado:Refresh()
oDlgPal:Refresh()

If nAcao == 1
	
	//->Atualiza registro de caixas
	If _nPCPEMB $ "G" //->Usa Embedded
		cSql:="UPDATE "+RETSQLNAME("ZP1")+" SET ZP1_PALETE='"+cPalete+"' "
		cSql+="WHERE ZP1_CODETI='"+cIdEtiq+"' AND D_E_L_E_T_ <> '*' "
		If TCSQLExec(cSql) < 0
			DisarmTransaction()
			cStatus := "Erro na atualizacao de leitura!!!"
			oContado:Refresh()
			oIdEtiq:SetFocus()
			Return
		EndIf
	ElseIf _cOpc == "C"
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial()+cIdEtiq))
			_cPalZP1 := ZP1->ZP1_PALETE
			RecLock("ZP1",.F.)
			ZP1->ZP1_PALETE	:= cPalete
			ZP1->ZP1_LOCAL  := '10'
			ZP1->ZP1_STATUS := '2'
			ZP1->(MsUnLock())
			If !Empty(_cPalZP1)
				ZP4->(dbSetOrder(1))
				ZP4->(dbSeek(xFilial()+_cPalZP1))
				Reclock("ZP4",.F.)
				ZP4_CONTAD := (ZP4->ZP4_CONTAD-1)
				ZP4_CODEST := (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
				MsUnLock()
				If ZP4->ZP4_CONTAD == 0
					Reclock("ZP4",.F.)
					ZP4->(DbDelete())
					MsUnLock()
				EndIf
				ZP4->(dbSetOrder(1))
				ZP4->(dbSeek(xFilial()+cPalete))
				Reclock("ZP4",.F.)
				ZP4_CONTAD := (ZP4->ZP4_CONTAD+1)
				ZP4_CODEST := (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
				MsUnLock()
			EndIF
		EndIF
		//U_PCPRGLOG(_nTpLog,(_cAlias)->ZP1_CODETI,"D6","Palete: "+cPalete) //-> Log
		U_PCPRGLOG(_nTpLog,cIdEtiq,"D6","Palete: "+cPalete) //-> Log //retirei pois o ALIAS veio sem definicão, e devo testar para saber se está OK. a linha comentada acima, é a original.
	Else
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial()+cIdEtiq))
			RecLock("ZP1",.F.)
			ZP1->ZP1_PALETE	:= cPalete
			ZP1->(MsUnLock())
		Endif
	Endif
	nContado++
	
	//->Atualiza array de etiquetas
	If Len(aEtiquetas) == 1 .AND. Len(AllTrim(aEtiquetas[1,1])) <= 0
		aEtiquetas := {}
	EndIf
	aAdd(aEtiquetas,{cIdEtiq,Iif(_nPCPEMB $ "P",(_cAlias)->ZP1_LOTE,ZP1->ZP1_LOTE),DToC(Iif(_nPCPEMB $ "P",STOD((_cAlias)->ZP1_DTPROD),ZP1->ZP1_DTPROD)),DToC(Iif(_nPCPEMB $ "P",STOD((_cAlias)->ZP1_DTVALI),ZP1->ZP1_DTVALI))})
	If _cOpc # "C"
		//-> Atualiza tabela de etiquetas
		ZP4->(dbSetOrder(1))
		_lRec := !ZP4->(dbSeek(xFilial()+cPalete))
		nCaixas := FCONTACAIXA(cPalete)
		RecLock("ZP4",_lRec)
		ZP4->ZP4_FILIAL	:= xFilial("ZP4")
		ZP4->ZP4_PALETE	:= cPalete
		ZP4->ZP4_CONTAD	:= nCaixas
		ZP4->ZP4_STATUS	:= "M"
		ZP4->ZP4_PRODUT	:= SB1->B1_COD
		ZP4->ZP4_USABER	:= SubStr(cUserName,1,30)
		ZP4->ZP4_DTABER	:= Date()
		ZP4->ZP4_HRABER	:= Time()
		ZP4->ZP4_DATA	:= dData
		ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
		ZP4->ZP4_CODCLA := cClassifi
		ZP4->(MsUnLock())
		If _lRec
			U_PCPRGLOG(_nTpLog,cPalete,"18") //-> Log
			U_PCPRGLOG(_nTpLog,cPalete,"14") //-> Log
		Endif
	EndIF
	//->Log de registro
	//U_PCPRGLOG(_nTpLog,Iif(_nPCPEMB $ "P",(_cAlias)->ZP1_CODETI,ZP1->ZP1_CODETI),"03","Palete: "+cPalete) //-> Log
ElseIf _nPos > 0 .and. _cOpc # "C"
	aEtiquetas := aClone(_aDel(aEtiquetas,_nPos))
	If _nPCPEMB $ "G" //->Usa Embedded
		cSql:="UPDATE "+RETSQLNAME("ZP1")+" SET ZP1_PALETE='' "
		cSql+="WHERE ZP1_CODETI='"+cIdEtiq+"' AND D_E_L_E_T_ <> '*' "
		If TCSQLExec(cSql) < 0
			DisarmTransaction()
			cStatus := "Erro na atualizacao de leitura!!!"
			oContado:Refresh()
			oIdEtiq:SetFocus()
			Return
		EndIf
	Else
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial()+cIdEtiq))
			RecLock("ZP1",.F.)
			ZP1->ZP1_PALETE	:= ""
			ZP1->(MsUnLock())
		EndIf
	Endif
	nContado--
	U_PCPRGLOG(_nTpLog,cIdEtiq,"05","Palete: "+cPalete)
	U_PCPRGLOG(_nTpLog,cPalete,"05","Etiq: "+cIdEtiq)
EndIf

//-> Atualiza tela de etiquetas
If Len(aEtiquetas) <= 0
	Aadd(aEtiquetas,{"","","",""})
EndIf
oEtiquetas:SetArray(aEtiquetas)
oEtiquetas:bLine := {|| {aEtiquetas[oEtiquetas:nAt,1],aEtiquetas[oEtiquetas:nAt,2],aEtiquetas[oEtiquetas:nAt,3],aEtiquetas[oEtiquetas:nAt,4]}}
oEtiquetas:Refresh()

If Select(xAliasCT) > 0
	(xAliasCT)->(dbCloseArea())
Endif

BeginSql alias xAliasCT
	SELECT
	COUNT(*) AS TOTREG
	FROM
	%table:ZP1% ZP1
	WHERE
	ZP1.ZP1_PALETE = %exp:cPalete% AND
	ZP1.%notDel%
EndSql
//->Atualiza contador do palete
ZP4->(dbSetOrder(1))
If ZP4->(dbSeek(xFilial()+cPalete))
	RecLock("ZP4",.F.)
	ZP4->ZP4_CONTAD	:= (xAliasCT)->TOTREG
	ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
	ZP4->(MsUnLock())
EndIf

oContado:Refresh()
oDlgPal:Refresh()
End Transaction
Return

Static Function _aDel(_aPar,_nPar)
Local _aRet := {}
Local _I := {}
For _I := 1 To Len(_aPar)
	If _I <> _nPar
		aAdd(_aRet,_aPar[_I])
	EndIf
Next _I
Return(_aRet)

/*
Funcao: bValFrm
Descricao: Grava um palete em suspens‹o ou fechado
Data:
Analista:
*/
Static Function bValFrm(_cOpc)
Local _lRet 	:= .T.
Local _cAliasx:= "ALITMP"
Local _cAlias := GetNextAlias()
Local _nAtivEt:= 0

//->Barra de Progresso
If nContado < _nCapPale
	oProcess:SetRegua1(5)
Elseif nContado == _nCapPale .Or. (nContado > 0 .And. nContado < _nCapPale .And. _cXOpc=='2' )
	oProcess:SetRegua1(8)
Endif

If nContado = 0 .And. _cXOpc=='2'
	cStatus := "Quantidade de etiquetas apontadas esta zerada."
	Return(.F.)
ElseIf nContado >= _nCapPale .And. _cXOpc=='2'
	cStatus := "Quantidade de etiquetas excedida para palete picking."
	Return(.F.)
Endif

If !(_cOpc $ "ANC")
	Return(_lRet)
EndIf

//->Valida Enderecamento
oProcess:IncRegua1("Validando Enderecamento...")
If !U_GTOWMSVEE(cPalete)
	cStatus := "Etiqueta enderecada, impossivel movimentacoes."
	Return(.F.)
Endif

oProcess:IncRegua1("Executando Contagem...")
nContado	:= U_ValPalet(1,cPalete)

oProcess:IncRegua1("Executando Pesagem...")
_nPeso		:= U_ValPalet(3,cPalete)

ZP4->(dbSetOrder(1))
If ZP4->(dbSeek(xFilial()+cPalete))
	If Len(AllTrim(ZP4->ZP4_PRODUT)) > 0
		If nContado < _nCapPale .And. _cXOpc=="1"
			If _lRet := MsgYesNo("Confirma a supencao da montagem do palete?")
				oProcess:IncRegua1("Suspendendo...")
				nCaixas := FCONTACAIXA(ZP4->ZP4_PALETE)
				RecLock("ZP4",.F.)
				ZP4->ZP4_STATUS	:= "S"
				ZP4->ZP4_CONTAD	:= nCaixas
				ZP4->ZP4_PBASE 	:= nPBase
				ZP4->ZP4_PSTREC := nPStrech
				ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
				ZP4->(MsUnLock())
				U_PCPRGLOG(_nTpLog,cPalete,"15")
				PCP7X(9,"C")
			EndIf
		Else
			//->Validacoes
			If nContado < _nCapPale .And. nContado > 0 .And. _cXOpc=="1"
				cStatus := "Numero de Etiquetas Lidas menor que capacidade."
				Return(.F.)
			ElseIf nContado >= _nCapPale .And. _cXOpc=="2"
				cStatus := "Numero de etiquetas lidas excede a capacidade para palete picking."
				Return(.F.)
			ElseIf nContado > _nCapPale
				cStatus := "Numero de Etiquetas Lidas Maior que capacidade."
				Return(.F.)
			Endif
			_nAtivEt:= 0
			If _lRet := MsgYesNo("Confirma fechamento do palete?")
				oProcess:IncRegua1("Fechando Palete...")
				oProcess:SetRegua2(Len(aEtiquetas))
				BeginSql alias _cAlias
					SELECT *
					FROM %table:ZP1% ZP1
					WHERE
					ZP1.ZP1_FILIAL= %xfilial:ZP1%
					AND ZP1.ZP1_PALETE=%exp:cPalete%
					AND ZP1.%notDel%
					ORDER BY %Order:ZP1%
				EndSql
				Do While !(_cAlias)->(Eof())
					oProcess:IncRegua2("Conf. Etiqueta: "+(_cAlias)->ZP1_CODETI)
					cSql:="UPDATE "+RETSQLNAME("ZP1")+"  "
					cSql+="SET "
					If  _cOpc # "C"
						cSql+="ZP1_STATUS='1' "
					Else
						cSql+="ZP1_STATUS='2' "
					EndIf
					If StoD((_cAlias)->ZP1_DTATIV) = CtoD("")
						cSql+=", ZP1_DTATIV='"+dtos(Date())+"',ZP1_HRATIV='"+Time()+"' "
					Endif
					If !(_nPCPEMB $ "P") .and.  _cOpc # "C"
						cSql+=", ZP1_LOCAL='40' "
					EndIF
					cSql+="WHERE ZP1_CODETI='"+(_cAlias)->ZP1_CODETI+"' AND D_E_L_E_T_ <> '*' "
					TCSQLExec(cSql)
					If  _cOpc # "C"
						U_PCPRGLOG(_nTpLog,(_cAlias)->ZP1_CODETI,"03","Palete: "+cPalete) //-> Log
					EndIF
					(_cAlias)->(dbSkip())
				Enddo
				(_cAlias)->(dbCloseArea())
				If File(_cAlias+GetdbExtension())
					FErase(_cAlias+GetDbExtension())
				Endif
				
				//->Valida Etiquetas Ativadas
				oProcess:IncRegua1("Validando Ativacao...")
				If U_ValPalet(1,cPalete) <> U_ValPalet(2,cPalete)
					cStatus := "Erro validacao ativas x palete"
					Return(.F.)
				Endif
				
				//->Salvando dados do Palete
				oProcess:IncRegua1("Salvando Dados do Palete...")
				nCaixas := FCONTACAIXA(ZP4->ZP4_PALETE)
				RecLock("ZP4",.F.)
				ZP4->ZP4_STATUS	:= "F"
				ZP4->ZP4_PBASE 	:= nPBase
				ZP4->ZP4_CONTAD	:= nCaixas
				ZP4->ZP4_PSTREC := nPStrech
				ZP4->ZP4_USFECH	:= SubStr(cUserName,1,30)
				ZP4->ZP4_DTFECH	:= Date()
				ZP4->ZP4_HRFECH	:= Time()
				ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
				ZP4->ZP4_CODCLA := cClassifi
				ZP4->(MsUnLock())
				//->Log de Regsitro
				U_PCPRGLOG(_nTpLog,cPalete,"16")
				
				//->Imprime palete
				oProcess:IncRegua1("Imprimindo Etiqueta...")
				bImp(ZP4->ZP4_PALETE,_nPeso)
				//->Refresh
				oProcess:IncRegua1("Refresh Dados da Tela...")
				PCP7X(9,"C")
			EndIf
		EndIf
	Else
		oProcess:IncRegua1("Apagando Palete...")
		RecLock("ZP4",.F.)
		ZP4->(dbDelete())
		ZP4->(MsUnLock())
		//->Log de Registro
		U_PCPRGLOG(_nTpLog,cPalete,"17")
	EndIf
EndIf
cClassifi	:= Space(TamSX3("ZP4_CODCLA")[1])
cDescClas	:= Space(TamSx3("ZZS_DESCRI")[1])

Return(_lRet)

Static Function bZera()
Local xAliasCT	:= GetNextAlias()
nContado := 0
aEtiquetas := {}
Aadd(aEtiquetas,{"","","",""})

//->Valida Enderecamento
If !U_GTOWMSVEE(cPalete)
	cStatus := "Etiqueta Enderecada, Impossivel movimentacoes."
	Return(.F.)
Endif

ZP1->(dbSetOrder(2))
While ZP1->(dbSeek(xFilial()+cPalete))
	RecLock("ZP1",.F.)
	ZP1->ZP1_PALETE	:= ""
	ZP1->(MsUnLock())
	//->Log de Registro
	U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"49")
EndDo

If Select(xAliasCT) > 0
	(xAliasCT)->(dbCloseArea())
Endif

BeginSql alias xAliasCT
	SELECT
	COUNT(*) AS TOTREG
	FROM
	%table:ZP1% ZP1
	WHERE
	ZP1.ZP1_PALETE = %exp:cPalete% AND
	ZP1.%notDel%
EndSql

If ZP4->(dbSeek(xFilial()+cPalete))
	RecLock("ZP4",.F.)
	ZP4->ZP4_CONTAD	:= (xAliasCT)->TOTREG
	ZP4->ZP4_CODEST	:= (iif((ZP4_CONTAD == (POSICIONE("SB1", 1, xFilial("SB1") + ZP4->ZP4_PRODUT, "B1_XQTDPAL"))), "1","2"))
	ZP4->(MsUnLock())
	//->Log de Registro
	U_PCPRGLOG(_nTpLog,cPalete,"49")
EndIf

oContado:Refresh()
oEtiquetas:SetArray(aEtiquetas)
oEtiquetas:bLine := {|| {aEtiquetas[oEtiquetas:nAt,1],aEtiquetas[oEtiquetas:nAt,2],aEtiquetas[oEtiquetas:nAt,3],aEtiquetas[oEtiquetas:nAt,4]}}
oEtiquetas:Refresh()
oIdEtiq:SetFocus()
Return


/*
Funcao: bImp
Descriacao: Impress‹o Etiqueta Palete
Por: Infinit
Em: 01/10/2015
*/
Static Function bImp(_cPal,_nPeso,_rimp)
Local _cImp := ""
Local _lContinua := .T.
Local _nPeso := 0
SET CENTURY OFF
If type("_rimp") == "U"
	_rimp := ""
EndIF
If Len(AllTrim(_cPal)) <= 0
	MsgStop("Numero da etiqueta palete invalida.")
	Return
EndIf

ZP4->(dbSetOrder(1))
If !ZP4->(dbSeek(xFilial()+_cPal))
	MsgStop("Pallet não encontrado.")
	Return
EndIf

If ZP4->ZP4_STATUS <> "F"
	MsgStop("Este pallet nao esta fechado.")
	Return
EndIf

SB1->(dbSetOrder(1))
If !SB1->(dbSeek(xFilial("SB1")+ZP4->ZP4_PRODUT))
	MsgStop("Produto apontado no pallet nao apontado.")
	Return
Else
	If Empty(AllTrim(SB1->B1_XDESPAL))
		MsgStop("Produto sem descriÇÂo para etiqueta pallet.")
		Return
	Endif
	_nPeso := SB1->B1_CONV * ZP4->ZP4_CONTAD
Endif

ZP2->(dbSetOrder(1))
ZP2->(dbSeek(xFilial()+"P01"))
//->Indica que etiqueta esta sendo impressa
_cImp 	:= ZP2->ZP2_ETIQ
_cImp 	:= StrTran(_cImp,"%cTpDesc%"			,NoAcento(Iif(_cXOpc=="1","PN - ","PK - ") + AllTrim(SB1->B1_XDESPAL)))
_cImp 	:= StrTran(_cImp,"%cCodProd%"			,NoAcento(AllTrim(ZP4->ZP4_PRODUT)))
_cImp 	:= StrTran(_cImp,"%cQtdUn%"				,NoAcento(StrZero(Iif(_cXOpc=="2", U_ValPalet(1,ZP4->ZP4_PALETE), ZP4->ZP4_CONTAD),4)))
_cImp 	:= StrTran(_cImp,"%cCodPall%"			,NoAcento(ZP4->ZP4_PALETE))
_cImp 	:= StrTran(_cImp,"%cDTEmb%"				,NoAcento(DToC(ZP4->ZP4_DATA)))
_cImp 	:= StrTran(_cImp,"%cPesLiq%"			,NoAcento(Transform(_nPeso,"@E 9,999.99")))
_cImp 	:= StrTran(_cImp,"%cPesBrut%"			,NoAcento(Transform((_nPeso+ZP4->ZP4_PSTREC+ZP4->ZP4_PBASE),"@E 9,999.99")))
_cImp 	:= StrTran(_cImp,"%cOperador%"			,NoAcento(cusername))
_cImp 	:= StrTran(_cImp,"%cDtHrImp%"			,NoAcento(dtoc(ddatabase)+" - "+time()))

MSCBPRINTER("S4M","LPT1",,,.f.,,,,)
MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
MSCBBEGIN(1,4)
MSCBWrite(_cImp)
MSCBEND()
MSCBCLOSEPRINTER()
If  _cOpc # "C"
	U_PCPRGLOG(_nTpLog,_cPal,"06")
Else
	U_PCPRGLOG(_nTpLog,_cPal,"D7")
EndIF
SET CENTURY ON
Return

/*
Funcao: bFiltro
Descricao: Filtro
Por: Infinit
Em: 01/10/2015
*/
Static Function bFiltro()
_cFiltro := BuildExpr("ZP4",,,.T.)
PCP7X(9,"C")
Return

/*
Funcao: bExcl
Descricao: Exclus‹o de Palete
Por: Infinit
Em: 01/10/2015
*/
Static Function bExcl()
                                                                 
//->Valida Enderecamento
If !U_GTOWMSVEE(cPalete)
	cStatus := "Etiqueta enderecada, impossivel movimentacoes."
	Return(.F.)
Endif

If U_PCPVIN3(cPalete)
	cStatus := "Etiqueta inventariada em inventario aberto."
	Return(.F.)
Endif

//->Verifica se alguma caixa ja foi produzida
ZP1->(dbSetOrder(2))
If ZP1->(dbSeek(xFilial("ZP1_FILIAL") + cPalete))
	While !ZP1->(Eof()) .And. ZP1->(ZP1_FILIAL+ZP1_PALETE) == xFilial("ZP1_FILIAL") + cPalete
		If !Empty(AllTrim(ZP1->ZP1_OP))
			cStatus := "Caixa em estoque contabil. Use a rotina de desmontagem."
			Return(.F.)
		Elseif !Empty(AllTrim(ZP1->ZP1_CARGA))
			cStatus := "Exlusao de palete: EXISTEM CAIXAS VINCULADAS AO PALETE QUE JA FORAM EXPEDIDAS."
			Return(.F.)
		Elseif ZP1->ZP1_STATUS='5'
			cStatus := "Exlusao de palete: EXISTEM CAIXAS VINCULADAS AO PALETE QUE JA FORAM EXCLUIDAS DE INVENTARIO."
			Return(.F.)
		Elseif ZP1->ZP1_STATUS='9'
			cStatus := "Exlusao de palete: EXISTEM CAIXAS VINCULADAS AO PALETE QUE ESTAO SUSPENSAS."
			Return(.F.)
		Endif
		ZP1->(dbSkip())
	EndDo
Else
	cStatus := "Exlusao de palete: NAO EXISTEM CAIXAS VINCULADAS AO PALETE."
	Return(.F.)
Endif

If MsgYesNo("Confirma a exclusão do palete?")
	
	ZP1->(dbSetOrder(2))
	If ZP1->(dbSeek(xFilial("ZP1_FILIAL") + cPalete))
		While !ZP1->(Eof()) .And. ZP1->(ZP1_FILIAL+ZP1_PALETE) == xFilial("ZP1_FILIAL") + cPalete
			If ZP1->ZP1_DTATIV == Date()
				RecLock("ZP1",.F.)
				ZP1->ZP1_STATUS	:= ""
				ZP1->ZP1_DTATIV := CTOD("  /  /    ")
				ZP1->ZP1_HRATIV := ""
				ZP1->ZP1_PALETE	:= ""
				ZP1->ZP1_LOCAL	:= ""
				ZP1->(MsUnLock())
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"C5","Palete: "+cPalete)
			Endif
			U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"07","Palete: "+cPalete)
			ZP1->(dbSkip())
		EndDo
	Endif
	
	ZP1->(dbSetOrder(2))
	If !ZP1->(dbSeek(xFilial("ZP1_FILIAL") + cPalete))
		ZP4->(dbSetOrder(1))
		If ZP4->(dbSeek(xFilial()+cPalete))
			RecLock("ZP4",.F.)
			ZP4->(dbDelete())
			ZP4->(MsUnLock())
			U_PCPRGLOG(_nTpLog,cPalete,"17")
		Else
			cStatus := "Exlusao de palete: PALETE NAO ENCONTRADO."
			Return(.F.)
		EndIf
	Else
		cStatus := "Exlusao de palete: EXISTEM ETIQUETAS INSERIDAS NESTE PALETE."
		Return(.F.)
	Endif
	
	oDlgPal:End()
	PCP7X(9,"C")
EndIf
Return

Static Function bMsgStat()
If Len(AllTrim(cStatus)) > 0
	oStatusOK:Hide()
	oStatusER:Show()
	Tone()
	Tone()
	Tone()
Else
	cStatus := "Etiqueta OK"
	oStatusOK:Show()
	oStatusER:Hide()
EndIf
oStatusOK:Refresh()
oStatusER:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetNumEti() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Sem‡foro de etiquetas									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
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
Static Function GetNumPal(_nOpc,_cAlias,_cChave,_nTam)
Local _cValor:=StrZero(1,_nTam)
If _nOpc==1
	ZPD->(dbSetOrder(1))
	If ZPD->(dbSeek(xFilial("ZPD")+_cAlias+_cChave))
		ZPD->(RecLock("ZPD",.F.))
		_cValor:=StrZero(Val(ZPD->ZPD_VALOR) ,_nTam)
		Return(_cValor)
	Else
		RecLock("ZPD",.T.)
		ZPD->ZPD_FILIAL	:=	xFilial("ZPD")
		ZPD->ZPD_ALIAS	:= _cAlias
		ZPD->ZPD_CHAVE	:= _cChave
		ZPD->ZPD_VALOR	:= _cValor
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
±±ºPrograma  ³ GetNumEti2() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Semaforo de etiquetas em sequencia						    º±±
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
Static Function GetNumPa2(_nOpc,_cAlias,_cChave,_nTam)
Local _cValor	:=StrZero(1,_nTam)
Local _cNovVal:=StrZero(1,_nTam)
If _nOpc==1
	ZPD->(dbSetOrder(1))
	If ZPD->(dbSeek(xFilial()+_cAlias+_cChave))
		RecLock("ZPD",.F.)
		_cValor	:= StrZero(Val(ZPD->ZPD_VALOR) ,_nTam)
		_cNovVal	:= cValToChar(Val(_cValor)+1) //Soma1(_cValor,15)
		ZPD->ZPD_VALOR:=_cNovVal
		ZPD->(MsUnLock())
		Return(_cValor)
	Else
		_cNovVal	:=Soma1(_cValor,15)
		RecLock("ZPD",.T.)
		ZPD->ZPD_FILIAL	:= xFilial("ZPD")
		ZPD->ZPD_ALIAS	:= _cAlias
		ZPD->ZPD_CHAVE	:= _cChave
		ZPD->ZPD_VALOR	:= _cNovVal
		ZPD->(MsUnLock())
		Return(_cValor)
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ComNumPal() ºAutor  ³Evandro Gomes    º Data ³  02/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Comita Semaforo											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
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
Static Function ComNumPal(_cAlias,_cChave,_nTam,_cValor)
dbSelectArea("ZPD")
dbSetOrder(1)
If dbSeek(xFilial("ZPD")+_cAlias+_cChave)
	_cValor:=StrZero(Val(_cValor),_nTam)
	If ZPD->(RecLock("ZPD",.F.))
		ZPD->ZPD_VALOR	:= _cValor
		ZPD->(MsUnLock())
	Endif
Endif
Return


/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Barra de Progresso
*/
Static Function PCP7X(_nTipo,_cOpc)
Local _cTitulo:= Iif(_cOpc=="N","Incluindo",Iif(_cOpc=="V","Visualizando",Iif(_cOpc=="A","Alterando",Iif(_cOpc=="E","Excluindo",Iif(_cOpc=="I","Imprimindo",Iif(_cOpc=="L","Consultando...","NAO IDENTIFICADO"))))))
If _nTipo==1 //->Fechar Palete
	oProcess:=MsNewProcess():New( { || bValFrm(_cOpc) } , "Fechando: "+_cTitulo+" Palete." , "Aguarde..." , .F. )
	oProcess:Activate()
ElseIf _nTipo==9 //->Consulta Palets
	oProcess:=MsNewProcess():New( { || fRelPale() } , _cTitulo+" Palete.", "Aguarde..." , .F. )
	oProcess:Activate()
Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descrição: Barra de Progresso
*/
User Function ValPalet(nTipo,_cPal)
Local _cAlias	:= GetNextAlias()
Local xRet
If nTipo==1 //-> Quantidade de etiquetas Lançadas
	xRet := 0
	BeginSql alias _cAlias
		SELECT Count(*) AS QTDETI
		FROM %table:ZP1% ZP1
		WHERE
		ZP1.ZP1_FILIAL= %xfilial:ZP1%
		AND ZP1.ZP1_PALETE=%exp:_cPal%
		AND ZP1.%notDel%
	EndSql
	If !(_cAlias)->(Eof()) .And. !(_cAlias)->(Bof())
		xRet:=(_cAlias)->QTDETI
	Endif
	(_cAlias)->(dbCloseArea())
	If File(_cAlias+GetdbExtension())
		FErase(_cAlias+GetDbExtension())
	Endif
ElseIf nTipo==2 //-> Quantidade de etiquetas Lançadas e ativadas
	xRet := 0
	BeginSql alias _cAlias
		SELECT Count(*) AS QTDETI
		FROM %table:ZP1% ZP1
		WHERE
		ZP1.ZP1_FILIAL= %xfilial:ZP1%
		AND ZP1.ZP1_PALETE=%exp:_cPal%
		AND ZP1.ZP1_STATUS=%exp:'1'%
		AND ZP1.ZP1_DTATIV<>%exp:''%
		AND ZP1.ZP1_HRATIV<>%exp:''%
		AND ZP1.%notDel%
	EndSql
	If !(_cAlias)->(Eof()) .And. !(_cAlias)->(Bof())
		xRet:=(_cAlias)->QTDETI
	Endif
	(_cAlias)->(dbCloseArea())
	If File(_cAlias+GetdbExtension())
		FErase(_cAlias+GetDbExtension())
	Endif
ElseIf nTipo==3 //-> Peso Total por palete
	xRet := 0
	BeginSql alias _cAlias
		SELECT SUM(ZP1_PESO) AS QTDPES
		FROM %table:ZP1% ZP1
		WHERE
		ZP1.ZP1_FILIAL= %xfilial:ZP1%
		AND ZP1.ZP1_PALETE=%exp:_cPal%
		AND ZP1.%notDel%
	EndSql
	If !(_cAlias)->(Eof()) .And. !(_cAlias)->(Bof())
		xRet:=(_cAlias)->QTDPES
	Endif
	(_cAlias)->(dbCloseArea())
	If File(_cAlias+GetdbExtension())
		FErase(_cAlias+GetDbExtension())
	Endif
Endif
Return(xRet)


/*
Por: Flávio Martins
Em: 15/09/18
Descrição: Cadastro da ZZS
*/
User Function CadZZS()
dbSelectArea("ZZS")
dbSetOrder(1)
axcadastro("ZZS","Cadastro de Classificação de Palete")
Return

Static Function FCONTACAIXA(cPALETE)
IF EMPTY(cPALETE)
	Return 0
EndIF
If Select(_cAlias) > 0
	(_cAlias)->(dbCloseArea())
Endif
BeginSql alias _cAlias
	SELECT Count(*) AS QTDETI
	FROM %table:ZP1% ZP1
	WHERE
	ZP1.ZP1_FILIAL= %xfilial:ZP1%
	AND ZP1.ZP1_PALETE=%exp:cPALETE%
	AND ZP1.%notDel%
EndSql
If !(_cAlias)->(Eof()) .And. !(_cAlias)->(Bof())
	xRet:=(_cAlias)->QTDETI
Endif
(_cAlias)->(dbCloseArea())
If xRet > 200
Return 0
EndIF
Return xRet
