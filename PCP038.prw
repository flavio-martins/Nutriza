#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP038()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Ativação para Etiquetas n‹o inventariadas			  					³±±
±±³          ³			                                                        ³±±
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
User Function PCP038()
	Private oDlgREN
	Private oCodEti
	Private cCodEti := Space(16)
	Private oProduto 
	Private cProduto := Space(15)
	Private oDescPro 
	Private cDescPro := Space(40)
	Private oStatusOK
	Private oStatusEr
	Private cStatus := ""
	Private oGrava
	Private oFecha
	Private oFntSt := TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private oWBrwREN
	Private aWBrwREN 	:= {}
	Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Private nContEti	:= 0
	Private oContEti
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)

	//->Testa ambientes que podem ser usados
	/*If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
	Alert("Ambiente nao homologado para o uso desta rotina!!!")
	Return .F.
	Endif*/

	If !U_APPFUN01("Z6_ENVREPR")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif


	DEFINE MSDIALOG oDlgREN TITLE "Re-identicacao de Invetario"  FROM 005,000 TO 600,1000 PIXEL	
	@ 006, 002 SAY oSay1 PROMPT "Etiqueta:" SIZE 025, 007 OF oDlgREN COLORS 0, 16777215 PIXEL
	@ 005, 025 MSGET oCodEti VAR cCodEti SIZE 100, 010 OF oDlgREN COLORS 0, 16777215 When .T. Valid PCP038A() PIXEL
	@ 006, 135 SAY oSay6 PROMPT "Produto:" SIZE 025, 007 OF oDlgREN COLORS 0, 16777215 PIXEL
	@ 005, 160 MSGET oProduto VAR cProduto SIZE 050, 010 OF oDlgREN COLORS 0, 16777215 When .F. PIXEL
	@ 005, 215 MSGET oDescPro VAR cDescPro SIZE 200, 010 OF oDlgREN COLORS 0, 16777215 When .F. PIXEL
	@ 006, 430 SAY oSay6 PROMPT "Contador:" SIZE 025, 007 OF oDlgREN COLORS 0, 16777215 PIXEL
	@ 005, 455 MSGET onContEti VAR nContEti SIZE 050, 010 OF oDlgREN COLORS 0, 16777215 When .F. PIXEL
	@ 020, 002 LISTBOX oWBrwREN Fields HEADER;
	"", OemToAnsi("Etiqueta"), OemToAnsi("C—digo"), OemToAnsi("Produto"), OemToAnsi("Status");
	SIZE 500, 200 OF oDlgREN PIXEL ColSizes 10,60,40,150,80
	nPosV	:=230
	nPosLf	:= 465
	oBntFec:= TButton():New( nPosV,nPosLf,"&Fechar",oDlgREN,{|u|Close(oDlgREN)},035,012,,,,.T.,,"",,,,.F. )
	nPosLf	-=35
	oBntLib:= TButton():New( nPosV,nPosLf,"&Gravar",oDlgREN,{|u|PCP038A()},035,012,,,,.T.,,"",,,,.F. )
	@ 270, 000 GET oStatusOK VAR cStatus OF oDlgREN MULTILINE SIZE 080, 055 COLORS 0, 32768 FONT oFntSt READONLY HSCROLL PIXEL
	@ 270, 000 GET oStatusER VAR cStatus OF oDlgREN MULTILINE SIZE 080, 055 COLORS 0, 255 FONT oFntSt READONLY HSCROLL PIXEL
	oStatusER:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oStatusOK:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")

	oStatusOK:Align := CONTROL_ALIGN_BOTTOM
	oStatusER:Align := CONTROL_ALIGN_BOTTOM

	oStatusOK:Hide()
	oStatusER:Hide()

	PCP038C(0)

	ACTIVATE MSDIALOG oDlgREN CENTERED 

Return

/*
Função:PCP038A()
Descrição: Ativa Etiqueta para RENing
*/
Static Function PCP038A()
	Local _cQry			:= ""
	Local cAliasZP1		:= "ZP1TMP"
	Local aMovEst			:= {} 
	Local aSalEst			:= {}
	Local cReproc			:= ""
	Private lMsErroAuto	:= .F.

	Begin Transaction

		If Len(AllTrim(cCodEti))=0
			DisarmTransaction()
			Return .F.
		Endif

		cStatus := OemToAnsi("")
		PCP038B()

		ZP1->(dbSetOrder(1))
		If ZP1->(dbSeek(xFilial("ZP1")+cCodEti))
			If ZP1->ZP1_STATUS $ "7/9"
				DisarmTransaction()
				cStatus := OemToAnsi("Error: Etiqueta Suspensa")
				PCP038B()
				oCodEti:SetFocus()
				Return .F.
			Endif
			SB1->(dbSetorder(1))
			If SB1->(dbSeek(XFILIAL("SB1") + AllTrim(ZP1->ZP1_CODPRO) ))
				cProduto := ZP1->ZP1_CODPRO
				cDescPro := SB1->B1_DESC
				oDlgREN:Refresh()
				SB2->(dbSetOrder(1))
				If !SB2->(dbSeek(xFilial("SB2") + AllTrim(ZP1->ZP1_CODPRO)))
					cStatus := OemToAnsi("Error: Custo para movimentacao interna nao encontrado na SB2.["+ZP1->ZP1_CODPRO+"] - "+XFILIAL("SB1"))
					PCP038B()
					oCodEti:SetFocus()
					DisarmTransaction()
					Return .F.
				Else
					AADD(aSalEst,SB2->B2_QATU)
					AADD(aSalEst,SB2->B2_CM1)
				Endif	
			Else
				cStatus := OemToAnsi("Error: Produto N‹o encontrado.["+ZP1->ZP1_CODPRO+"] - "+XFILIAL("SB1"))
				PCP038B()
				oCodEti:SetFocus()
				DisarmTransaction()
				Return .F.
			Endif

			If !Empty(Alltrim(ZP1->ZP1_PALETE))
				cStatus := OemToAnsi("Error: Etiqueja ja Paletizada.["+ZP1->ZP1_PALETE+"]")
				PCP038B()
				oCodEti:SetFocus()
				DisarmTransaction()
				Return .F.
			Endif

			/*If !Empty(Alltrim(ZP1->ZP1_OP))
			cStatus := OemToAnsi("Error: Etiqueja ja com OP.["+ZP1->ZP1_PALETE+"]")
			PCP038B()
			oCodEti:SetFocus()
			DisarmTransaction()
			Return .F.
			Endif*/

			If ZP1->ZP1_STATUS == "5" .Or. ZP1->ZP1_REPROC == 'S'
				cProduto := ZP1->ZP1_CODPRO
				cDescPro := SB1->B1_DESC
			Else
				cStatus := OemToAnsi("Error: Etiqueta invalida para este tipo de processo.["+ZP1->ZP1_CODETI+"]")
				PCP038B()
				oCodEti:SetFocus()
				DisarmTransaction()
				Return .F.
			Endif

			cReproc:= ZP1->ZP1_REPROC

			aadd( aMovEst, { "D3_TM"     	, '003'				, NIL } )				
			aadd( aMovEst, { "D3_COD"    	, ZP1->ZP1_CODPRO		, NIL } )
			aadd( aMovEst, { "D3_UM"     	, SB1->B1_UM			, NIL } )
			aadd( aMovEst, { "D3_QUANT"  	, ZP1->ZP1_PESO		, NIL } )
			aadd( aMovEst, { "D3_OP"   		, ''					, NIL } )
			aadd( aMovEst, { "D3_CUSTO1" 	, aSalEst[2]			, NIL } )				
			aadd( aMovEst, { "D3_LOCAL"  	, SB1->B1_LOCPAD		, NIL } )
			aadd( aMovEst, { "D3_EMISSAO"	, dDataBase			, NIL } )
			aadd( aMovEst, { "D3_FILIAL"	, xFilial("SD3")		, NIL } )
			//aadd( aMovEst, { "AUTPRTOTAL"	, 'N'				, NIL } )
			lMsErroAuto :=.F.
			MSExecAuto( { |x,y| MATA240( x , y ) }, aMovEst, 3 )
			If lMsErroAuto
				DisarmTransaction()
				cStatus := OemToAnsi("Error: Problemas na Movimentacao Interna.")
				PCP038B()
				MostraErro()
				oCodEti:SetFocus()
				Return .F.
			Endif

			RecLock("ZP1",.F.)
			ZP1->ZP1_STATUS := "1"
			ZP1->ZP1_REPROC := "N"
			If Empty(AllTrim(ZP1->ZP1_OP)) .And. Empty(AllTrim(DTOS(ZP1->ZP1_DTATIV))) 
				ZP1->ZP1_DTATIV := Date()
				ZP1->ZP1_HRATIV := Time()
			Endif
			ZP1->(MsUnLock())

			cStatus := ""
			PCP038B()
			If cReproc <> 'S'
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"89")
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"93")
			Else
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"94")
				U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"95")
			Endif
			PCP038C(1,ZP1->ZP1_CODETI,ZP1->ZP1_CODPRO,SB1->B1_DESC, cStatus)
			cCodEti	:= Space(16)
			cProduto	:= Space(15)
			cDescPro	:= Space(40)
			oCodEti:SetFocus()
		Else
			_cQry := " SELECT "
			_cQry += " * "
			_cQry += " FROM ZP1010_MORTO ZP1"
			_cQry += " WHERE "
			_cQry += " ZP1_CODETI='"+cCodEti+"'"
			_cQry += " AND ZP1.D_E_L_E_T_ <> '*' "
			_cQry:=ChangeQuery(_cQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasZP1,.T.,.F.)
			If !(cAliasZP1)->(Eof()) .And. !(cAliasZP1)->(Bof())
				cStatus := OemToAnsi("Error: (001) Etiqueta em arquivo morto, consulte o LOG.")
			Else
				cStatus := OemToAnsi("Error: (002) Etiqueja n‹o encontrada.")
			Endif
			If Select(cAliasZP1) > 0
				(cAliasZP1)->(dbCloseArea())
				If File(cAliasZP1+GetDBExtension())
					fErase(cAliasZP1+GetDBExtension())
				Endif
			Endif
			PCP038B()
			DisarmTransaction()
			cCodEti	:= Space(16)
			cProduto	:= Space(15)
			cDescPro	:= Space(40)
			oDlgREN:Refresh()
			oCodEti:SetFocus()
			Return .F.
		Endif
	End Transaction
Return(.T.)

/*
Função:PCP038B()
Descrição: Ativa Barra de Status
*/
Static Function PCP038B()
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
		Tone()
		Tone()
		Tone()
	EndIf
	oStatusOK:Refresh()
	oStatusER:Refresh()
	oDlgREN:Refresh()
Return

/*
Função:PCP038C()
Descrição: Add Grid
*/
Static Function PCP038C(nTipo,_cCodEti,_cCodPro,_cDesPro, _cStatus)
	If nTipo==1 //->Add Etiqueta
		If Len(aWBrwREN)>0
			If aWBrwREN[Len(aWBrwREN),1]
				aWBrwREN:={}
			Endif
		Endif
		AADD(aWBrwREN,{.F., _cCodEti,_cCodPro,_cDesPro, _cStatus })
	Endif
	If 	Len(aWBrwREN) <= 0
		aWBrwREN:={}
		AADD(aWBrwREN,{;
		.T.,;
		"",;
		"",;
		"",;
		""})
	Endif

	oWBrwREN:SetArray(aWBrwREN)
	oWBrwREN:bLine := {|| {;
	IIf(aWBrwREN[oWBrwREN:nAT,1],oOk,oNo),;
	aWBrwREN[oWBrwREN:nAt,2],;
	aWBrwREN[oWBrwREN:nAt,3],;
	aWBrwREN[oWBrwREN:nAt,4],;
	aWBrwREN[oWBrwREN:nAt,5]}}
	oWBrwREN:Refresh()
	nContEti:=Len(aWBrwREN)
	oDlgREN:Refresh()
Return
