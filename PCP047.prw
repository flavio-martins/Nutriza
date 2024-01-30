#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TBICONN.CH"
#include "TbiCode.ch"
#INCLUDE "FILEIO.CH
#INCLUDE "apvt100.ch"
#INCLUDE 'PARMTYPE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCP047   บAutor  ณ Flแvio Martins     บ Data ณ 28/11/18    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reprocesso												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ NUTRIZA S.A.  											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PCP047()
	Local lRet 			:= .T.
	Local nOper			:= 0
	Local cUsSusFif		:= GetNewPar("MV_XUSUFIF",'000000')
	Private _cCodPro	:= ""
	Private _cDesPro	:= ""
	Private _cLote		:= ""
	Private _cPalete	:= ""
	Private _nQuant		:= 0
	Private _cCaixa		:= ""

	If !U_APPFUN01("Z6_ENVREPR")=="S" .And. __cUserId <> '000000'
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	While lRet
		If nOper > 0
			If !MsgBox("Deseja realizar outro reprocesso?","Continua","YESNO")
				Return
			Endif
			_cCodPro	:= ""
			_cDesPro	:= ""
			_cLote		:= ""
			_cPalete	:= ""
			_nQuant		:= 0
			_cCaixa		:= ""		
		Endif
		PCP047E()
		nOper++
	Enddo
Return
/*
Fun็ใo: PCP047E()
Descri็ใo: Wizard de reprocesso
*/
Static Function PCP047E()

	Local _cTitulo		:= "Re-Processo"
	Local _cHeader		:= "Re-Processo de produto"
	Local _cMens		:= ""
	Local _cText		:= ""
	Local _lRet			:= .T.

	Private _oCodEti
	Private _cCodEti	:= CriaVar("ZP1_CODETI")
	Private _oCodPro
	Private _cCodPro	:= CriaVar("ZP1_CODPRO")
	Private _oDesPro
	Private _cDesPro	:= CriaVar("B1_DESC")
	Private _oDtProd
	Private _cDtProd	:= CriaVar("ZP1_DTPROD")
	Private _oLote
	Private _cLote		:= CriaVar("ZP1_LOTE")
	Private _oPalete
	Private _cPalete	:= CriaVar("ZP1_PALETE")
	Private _oCC
	Private _cCC		:= CriaVar("ZPB_CC")
	Private _oTM
	Private _cTM		:= CriaVar("ZPB_TM")
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	    := GetNewPar("MV_PCPTLOG",1)
	Private cUsSusFif	:= GetNewPar("MV_XUSUFIF",'000000')


	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	If !U_APPFUN01("Z6_ENVREPR")=="S" .And. __cUserId <> '000000' .AND. !__cUserId $ cUsSusFif
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif
	*/
	_cMens:= "Este programa tem a finalidade de realizar o reprocesso "
	_cMens+= "de produtos acabados, que tiveram algum tipo de problema, "
	_cMens+= "e que nao podem ser entregues ao cliente, devido ao CONTROLE DE QUALIDADE FRIATO."

	DEFINE WIZARD oWizard TITLE  _cTitulo HEADER _cHeader MESSAGE _cMens TEXT _cText PANEL;
	NEXT {|| PCP047A() } FINISH {|| .T. }  PANEL NOFIRSTPANEL
	@ 010,010 SAY "Data: " SIZE 40,10 OF oWizard:oMPanel[1] PIXEL
	@ 008,025 MSGET oDtaBase Var dDataBase SIZE 40,10 OF oWizard:oMPanel[1] PIXEL WHEN .F.
	@ 025,010 SAY "Etiqueta: " SIZE 60,10 OF oWizard:oMPanel[1] PIXEL
	@ 023,033 MSGET oCodEti Var _cCodEti SIZE 60,10 OF oWizard:oMPanel[1] PIXEL WHEN .T. VALID PCP047A()
	@ 040,010 SAY "Produto: " SIZE 50,10 OF oWizard:oMPanel[1] PIXEL
	@ 038,033 MSGET oCodPro Var _cCodPro SIZE 60,10 OF oWizard:oMPanel[1] PIXEL WHEN .F.
	@ 038,098 MSGET oDesPro Var _cDesPro SIZE 150,10 OF oWizard:oMPanel[1] PIXEL WHEN .F.
	@ 055,010 SAY "Palete: " SIZE 50,10 OF oWizard:oMPanel[1] PIXEL
	@ 053,033 MSGET oPalete Var _cPalete SIZE 40,10 OF oWizard:oMPanel[1] PIXEL WHEN .F.
	@ 070,010 SAY "Lote: " SIZE 50,10 OF oWizard:oMPanel[1] PIXEL
	@ 068,033 MSGET oLote Var _cLote SIZE 40,10 OF oWizard:oMPanel[1] PIXEL WHEN .F.

	CREATE PANEL oWizard HEADER "Informa็๕es complementares." MESSAGE "Entre com as informa็๕es complementares." PANEL;
	BACK {|| .T.} NEXT {|| .T. } FINISH {|| Ctb105CC() .And. !Empty(AllTrim(_cTM)) .And. PCP047B() } EXEC {|| .T.}

	@ 010,010 SAY "C. Custos: " SIZE 40,10 OF oWizard:oMPanel[2] PIXEL
	@ 008,036 MSGET oCC Var _cCC SIZE 40,10 OF oWizard:oMPanel[2] PIXEL WHEN .T. F3 "CTT" VALID Ctb105CC()
	@ 025,010 SAY "Motivo: " SIZE 60,10 OF oWizard:oMPanel[2] PIXEL
	@ 023,036 MSGET oTM Var _cTM SIZE 60,10 OF oWizard:oMPanel[2] PIXEL WHEN .T. F3 "Z8" VALID !Empty(AllTrim(_cTM)) .And. ExistCpo("SX5","Z8"+_cTM)


	ACTIVATE WIZARD oWizard CENTER
Return(_lRet)

/*
Fun็ใo: PCP047A()
Descri็ใo: Valida etiqueta para reprocesso
*/
Static Function PCP047A()
	Local lRet:=.T.

	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
		If ZP1->ZP1_STATUS <> '2'
			MsgStop("Status atual da etiqueta nใo permite reprocesso. ["+ZP1->ZP1_STATUS+"]")
			lRet:=.F.
		ElseIf ZP1->ZP1_REPROC=='S'
			MsgStop("Etiqueta jแ reprocessada. ["+ZP1->ZP1_REPROC+"]")
			lRet:=.F.
		ElseIf !Empty(AllTrim(ZP1->ZP1_CARGA))
			MsgStop("Etiqueta jแ Expedida na carga ["+ZP1->ZP1_CARGA+"].")
			lRet:=.F.
		ElseIf ZP1->ZP1_STATUS $ "5|7|9"
			MsgStop("Etiqueta Baixada em inventแrio, Suspensa ou Sequestrada. ["+ZP1->ZP1_STATUS+"]")
			lRet:=.F.
		Else
			SB1->(dbSetorder(1))
			If SB1->(dbSeek(xFilial("SB1") + ZP1->ZP1_CODPRO))
				_cCodPro:= ZP1->ZP1_CODPRO
				_cDesPro:= SB1->B1_DESC
				_cLote	:= ZP1->ZP1_LOTE
				_cPalete:= ZP1->ZP1_PALETE
				_nQuant	:= ZP1->ZP1_PESO
				_cCaixa := ZP1->ZP1_CODETI			
			Else
				MsgStop("Produto nใo encontrado")
				lRet:=.F.
			Endif
		Endif
	Else
		Alert("Etiqueta nใo encontrada.")
		lRet:=.F.
	Endif
Return(lRet)


/*
Fun็ใo: PCP047B()
Descri็ใo: Valida etiqueta para reprocesso
*/
Static Function PCP047B()
	Local _aAreaZP1 := ZP1->(GetArea())
	Local lRet:=.T.
	Local _CPAL
	BEGIN TRANSACTION
		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
			_CPAL := ZP1->ZP1_PALETE
			If PCP047C()
				RecLock("ZP1",.F.)
				ZP1->ZP1_USEREP := cUserName
				ZP1->ZP1_DTREP := DATE()
				ZP1->ZP1_HRREP := TIME()
				ZP1->ZP1_REPROC	:= "S"
				ZP1->ZP1_ENDWMS	:= ""
				ZP1->ZP1_PALETE	:= ""
				ZP1->(MsUnLock())
				U_PCPRGLOG(_nTpLog,_cCaixa,"10","Pallet nบ: "+_CPAL)

				RecLock("ZPB",.T.)
				REPLACE ZPB_FILIAL WITH XFILIAL("ZPB")
				REPLACE ZPB_CODETI WITH _cCodEti
				REPLACE ZPB_CC WITH _cCC
				REPLACE ZPB_TM WITH _cTM
				ZPB->(MsUnLock())

				RecLock("ZP1",.F.)
				ZP1->(dbDelete())
				ZP1->(MsUnLock())
				U_PCPRGLOG(_nTpLog,_cCaixa,"09","A caixa ["+_cCodEti+"] foi excluํda, e era do Pallet ["+_CPAL+"]")
				if (ZP4->(DBSEEK(XFILIAL("ZP4")+_CPAL)))
					RecLock("ZP4",.F.)
					ZP4_CONTAD	:= ZP4->ZP4_CONTAD-1
					ZP4->(MsUnlock())
					U_PCPRGLOG(_nTpLog,_CPAL,"19","Caixa nบ: "+_cCaixa+" Peso: "+AllTrim(Str(POSICIONE("SB1", 1, xFilial("SB1") + _cCodPro, "B1_CONV")))+", foi retirada do pallet")
				EndIF
			Else
				DisarmTransaction()
				lRet:=.F.
			Endif
		Endif
		RestArea(_aAreaZP1)
	END TRANSACTION
Return lRet

/*
Fun็ใo: PCP047C()
Descri็ใo: Desmonta produto
*/
Static Function PCP047C()
	Local _lRet := .T.
	Local cDoc	:= GetSxENum("SD3","D3_DOC",1)
	Local _cCodFrango := Pad(GetNewPar("MV_XFRVIVO","00665"),15)
	Local _nQtd2 := 0
	Local aAutoCab := {}
	Local aAutoItens := {}
	Local _nQtd := ZP1->ZP1_PESO
	Private lMsErroAuto := .F.

	SB1->(dbsetOrder(1))
	SB1->(dbSeek(xFilial()+_cCodPro))
	_nQtd2	 := ConvUM(_cCodPro, _nQtd, 0, 2)
	aAutoCab := {;
	{"cProduto"   , _cCodPro				, Nil},;
	{"cLocOrig"   , SB1->B1_LOCPAD			, Nil},;
	{"nQtdOrig"   , _nQuant					, Nil},;
	{"nQtdOrigSe" , _nQtd2					, Nil},;
	{"cDocumento" , cDoc					, Nil},;
	{"cNumLote"   , CriaVar("D3_NUMLOTE")	, Nil},;
	{"cLoteDigi"  , CriaVar("D3_LOTECTL")	, Nil},;
	{"dDtValid"   , CriaVar("D3_DTVALID")	, Nil},;
	{"nPotencia"  , CriaVar("D3_POTENCI")	, Nil},;
	{"cLocaliza"  , CriaVar("D3_LOCALIZ")	, Nil},;
	{"cNumSerie"  , CriaVar("D3_NUMSERI")	, Nil}}

	SB1->(dbsetOrder(1))
	_cCodFrango := SB1->B1_XPRDREP // Wendel - Inclusใo da linha 03/12/2018
	SB1->(dbSeek(xFilial()+_cCodFrango))

	aAutoItens := {{;
	{"D3_COD"    , _cCodFrango		, Nil}, ;
	{"D3_LOCAL"  , SB1->B1_LOCPAD	, Nil}, ;
	{"D3_QUANT"  , _nQtd			, Nil}, ; // Wendel - Alterado a variแvel de _nQuant para _nQtd 03/12/2018
	{"D3_QTSEGUM", _nQtd2			, Nil}, ;
	{"D3_RATEIO" , 100				, Nil}}}

	MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)

	If lMsErroAuto
		_lRet := .F.
		Mostraerro()
	Else
		U_PCPRGLOG(_nTpLog,_cCaixa,"12", "Pertencia ao pallet nบ ["+_cPalete+"]" )
	EndIf

Return(_lRet)
