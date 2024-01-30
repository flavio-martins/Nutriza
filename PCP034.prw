#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'rwmake.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP034()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Ativação para Piking									  					³±±
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
User Function PCP034()
	Private oDlgPik
	Private oCodEti
	Private cCodEti 	:= Space(16)
	Private oProduto 
	Private cProduto 	:= Space(15)
	Private oDescPro 
	Private cDescPro 	:= Space(40)
	Private oStatusOK
	Private oStatusEr
	Private cStatus 	:= ""
	Private oGrava
	Private oFecha
	Private oFntSt 	:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)
	Private oWBrwPIK
	Private aWBrwPIK 	:= {}
	Private oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Private nContEti	:= 0
	Private oContEti
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lToneHab	:= GetNewPar("MV_TONEHABI",.F.) //->Habilita Tone
	Private _cToneDir	:= GetNewPar("MV_TONEDIR",GetClientDir()) //->Arquivo de Tone
	Private showBar 	:= GetNewPar("MV_TONESBAR",.F.) //->Barra de Aœdio
	Private isMute 	:= GetNewPar("MV_TONEMULT",.F.) //->Sem Som
	Private nVolume 	:= GetNewPar("MV_TONEVOLU",100) //->Volume
	Private aSom		:= {}
	Private oMedia

	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	If !U_APPFUN01("Z6_PIKING")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	If _lToneHab

		SetStyle(5)

		U_GTOSNDA(@aSom) //->Copia arquivos de ‡udio
		If Len(aSom) <=0 
			MsgInfo(OemToAnsi("Arquivos de Som nao encontrados"))
			Return
		Endif

		If !File(_cToneDir+aSom[1,1])
			MsgInfo(OemToAnsi("Arquivo de audio nao encontrado."))
			Return
		Endif

	Endif

	nPosV	:=230
	nPosLf	:= 465

	DEFINE MSDIALOG oDlgPIK TITLE "Envio para Piking"  FROM 005,000 TO 600,1000 PIXEL	
	@ 006, 002 SAY oSay1 PROMPT "Etiqueta:" SIZE 025, 007 OF oDlgPIK COLORS 0, 16777215 PIXEL
	@ 005, 025 MSGET oCodEti VAR cCodEti SIZE 100, 010 OF oDlgPIK COLORS 0, 16777215 When .T. Valid PCP034A() PIXEL
	@ 006, 135 SAY oSay6 PROMPT "Produto:" SIZE 025, 007 OF oDlgPIK COLORS 0, 16777215 PIXEL
	@ 005, 160 MSGET oProduto VAR cProduto SIZE 050, 010 OF oDlgPIK COLORS 0, 16777215 When .F. PIXEL
	@ 005, 215 MSGET oDescPro VAR cDescPro SIZE 200, 010 OF oDlgPIK COLORS 0, 16777215 When .F. PIXEL
	@ 006, 430 SAY oSay6 PROMPT "Contador:" SIZE 025, 007 OF oDlgPIK COLORS 0, 16777215 PIXEL
	@ 005, 455 MSGET onContEti VAR nContEti SIZE 040, 010 OF oDlgPIK COLORS 0, 16777215 When .F. PIXEL
	@ 020, 002 LISTBOX oWBrwPIK Fields HEADER "", OemToAnsi("Etiqueta"), OemToAnsi("C—digo"), OemToAnsi("Produto"), OemToAnsi("Status") SIZE 500, 200 OF oDlgPIK PIXEL ColSizes 10,60,40,150,80

	oBntFec:= TButton():New( nPosV,nPosLf,"&Fechar",oDlgPIK,{|u|Close(oDlgPIK)},035,012,,,,.T.,,"",,,,.F. )
	nPosLf	-=35
	oBntLib:= TButton():New( nPosV,nPosLf,"&Gravar",oDlgPIK,{|u| PCP034A() },035,012,,,,.T.,,"",,,,.F. )
	nPosLf	-=35
	If _lToneHab    
		oMedia := TMediaPlayer():New(1,1,1,1,oDlgPIK,"",nVolume,showBar)
	Endif

	@ 270, 000 GET oStatusOK VAR cStatus OF oDlgPIK MULTILINE SIZE 080, 055 COLORS 0, 32768 FONT oFntSt READONLY HSCROLL PIXEL
	@ 270, 000 GET oStatusER VAR cStatus OF oDlgPIK MULTILINE SIZE 080, 055 COLORS 0, 255 FONT oFntSt READONLY HSCROLL PIXEL
	oStatusER:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oStatusOK:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")

	oStatusOK:Align := CONTROL_ALIGN_BOTTOM
	oStatusER:Align := CONTROL_ALIGN_BOTTOM

	oStatusOK:Hide()
	oStatusER:Hide()

	PCP034C(0)

	ACTIVATE MSDIALOG oDlgPik CENTERED 

Return

/*
Função:PCP034A()
Descrição: Ativa Etiqueta para Piking
*/
Static Function PCP034A()
	Local _cQry		:= ""
	Local cAliasZP1	:= "ZP1TMP"

	If Len(AllTrim(cCodEti))=0
		Return .F.
	Endif
	cStatus := OemToAnsi("")
	PCP034B()

	ZP1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial("ZP1")+cCodEti))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+ZP1->ZP1_CODPRO))
		cProduto := ZP1->ZP1_CODPRO
		cDescPro := SB1->B1_DESC
		oDlgPik:Refresh()

		If ZP1->ZP1_STATUS $ "7/9"
			cStatus := OemToAnsi("Error: Etiqueta Suspensa")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If ZP1->ZP1_REPROC == "S"
			cStatus := OemToAnsi("Error: Etiqueta Reprocessada")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If !Empty(ZP1->ZP1_CARGA)
			cStatus := OemToAnsi("Error: Etiqueta Ja expedida")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If !Empty(Alltrim(ZP1->ZP1_PALETE))
			cStatus := OemToAnsi("Error: Etiqueja ja Paletizada")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If ZP1->ZP1_STATUS == "1"
			cStatus := OemToAnsi("Error: Etiqueja Ja em Piking")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If !Empty(Alltrim(ZP1->ZP1_OP))
			cStatus := OemToAnsi("Error: Etiqueta ja com OP")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If ZP1->ZP1_STATUS == "5"
			cStatus := OemToAnsi("Error: Etiqueja Exlcuida de inventario")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		If !Empty(AllTrim(DToS(ZP1->ZP1_DTATIV)))
			cStatus := OemToAnsi("Error: Etiqueja ja ativada inventario")
			PCP034B()
			oCodEti:SetFocus()
			Return .F.
		Endif

		RecLock("ZP1",.F.)
		ZP1->ZP1_STATUS 	:= "1"
		ZP1->ZP1_LOCAL 	:= "10"
		ZP1->ZP1_DTATIV 	:= Date()
		ZP1->ZP1_HRATIV 	:= Time()
		ZP1->(MsUnLock())

		cStatus := ""
		PCP034B()

		U_PCPRGLOG(_nTpLog,ZP1->ZP1_CODETI,"08")
		PCP034C(1,ZP1->ZP1_CODETI,ZP1->ZP1_CODPRO,SB1->B1_DESC, cStatus)
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
			cStatus := OemToAnsi("Error: Etiqueta em arquivo morto, consulte o LOG.")
		Else
			cStatus := OemToAnsi("Error: Etiqueja n‹o encontrada.")
			If !Empty(AllTrim(cCodEti))
				U_PCPRGLOG(_nTpLog,cCodEti,"69","Erro na Tentativa de Picking")
			Endif
		Endif
		If Select(cAliasZP1) > 0
			(cAliasZP1)->(dbCloseArea())
			If File(cAliasZP1+GetDBExtension())
				fErase(cAliasZP1+GetDBExtension())
			Endif
		Endif
		PCP034B()
		cCodEti	:= Space(16)
		cProduto	:= Space(15)
		cDescPro	:= Space(40)
		oDlgPik:Refresh()
		oCodEti:SetFocus()
		Return .F.
	Endif

Return(.T.)

/*
Função:PCP034B()
Descrição: Ativa Barra de Status
*/
Static Function PCP034B()
	If Len(AllTrim(cStatus)) > 0
		cStatus+=" - Ultima etiqueta Lida:["+cCodEti+"]"
		oStatusOK:Hide()
		oStatusER:Show()
		If _lToneHab
			oCodEti:lReadOnly := .T.
			oCodEti:Refresh()
			oMedia:openFile( _cToneDir+aSom[1,1] )
			oCodEti:lReadOnly := .F.
			oCodEti:Refresh()
		Else
			Tone()
		Endif
	Else
		cStatus := "Etiqueta OK"
		oStatusOK:Show()
		oStatusER:Hide()
	EndIf
	oStatusOK:Refresh()
	oStatusER:Refresh()
	oDlgPik:Refresh()
Return

/*
Função:PCP034C()
Descrição: Add Grid
*/
Static Function PCP034C(nTipo,_cCodEti,_cCodPro,_cDesPro, _cStatus)
	If nTipo==1 //->Add Etiqueta
		If Len(aWBrwPIK)>0
			If aWBrwPIK[Len(aWBrwPIK),1]
				aWBrwPIK:={}
			Endif
		Endif
		AADD(aWBrwPIK,{.F., _cCodEti,_cCodPro,_cDesPro, _cStatus })
	Endif
	If 	Len(aWBrwPIK) <= 0
		aWBrwPIK:={}
		AADD(aWBrwPIK,{;
		.T.,;
		"",;
		"",;
		"",;
		""})
	Endif

	oWBrwPIK:SetArray(aWBrwPIK)
	oWBrwPIK:bLine := {|| {;
	IIf(aWBrwPIK[oWBrwPIK:nAT,1],oOk,oNo),;
	aWBrwPIK[oWBrwPIK:nAt,2],;
	aWBrwPIK[oWBrwPIK:nAt,3],;
	aWBrwPIK[oWBrwPIK:nAt,4],;
	aWBrwPIK[oWBrwPIK:nAt,5]}}
	oWBrwPIK:Refresh()
	nContEti:=Len(aWBrwPIK)
	oDlgPIK:Refresh()
Return
