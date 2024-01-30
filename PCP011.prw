#Include "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP011() 	 ºAutor  ³Evandro Gomes     º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Re-Impressão de Etiquetas										º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descrição
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/ 
User Function PCP011()
	Private oDescr
	Private cDescr := ""
	Private oDtProd
	Private dDtProd := Date()
	Private oEtiq
	Private cEtiq := Space(17)
	Private oLote
	Private cLote := ""
	Private oProduto
	Private cProduto := ""
	Private oDlg
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _cTipo	:='3' //->  1-Normal(Entrouesaiu do tunel) 2-Re-identicacao paletizacao(Saiu do tunel sem identificacao) 3-Re-Identificacao 4-Re-Identificacao Rotatividade

	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	If !U_APPFUN01("Z6_REIMETI")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE "Reimpressão de Etiquetas" FROM 000, 000  TO 150, 500 COLORS 0, 16777215 PIXEL

	@ 002, 002 SAY oSay2 PROMPT "Etiqueta" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 002 MSGET oEtiq VAR cEtiq SIZE 070, 010 OF oDlg COLORS 0, 16777215 VALID bValEtiq() PIXEL
	@ 026, 002 SAY oSay1 PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 051, 002 SAY oSay3 PROMPT "Data Produção" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 050, 065 SAY oSay4 PROMPT "Lote" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 036, 002 MSGET oProduto VAR cProduto SIZE 060, 010 OF oDlg PICTURE "@!" COLORS 0, 16777215 READONLY PIXEL
	@ 036, 065 MSGET oDescr VAR cDescr SIZE 180, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 061, 002 MSGET oDtProd VAR dDtProd SIZE 060, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	@ 061, 065 MSGET oLote VAR cLote SIZE 030, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
	DEFINE SBUTTON oSButton1 FROM 061, 168 TYPE 01 OF oDlg ENABLE ACTION bImp()
	DEFINE SBUTTON oSButton2 FROM 061, 207 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED 

Return

Static function bImp()
	Local cPorta	:= "LPT1"
	Begin Transaction
		While !IsPrinter(cPorta) 
			If !MsgYESNO("Impressora Zebra (Etiqueta) nao esta pronta, A Porta " + cPorta + " nÃo estÁ Respondendo! Deseja continuar?" ,"Atencao","YESNO")
				DisarmTransaction()
				Return .F. 
			Endif 
		Enddo
		If ZP1->ZP1_STATUS $ "7/9"
			DisarmTransaction()
			MsgStop("Etiqueta Suspensa ou sequestrada.")
			Return(.F.)
		Endif
		_dDtValid := ZP1->ZP1_DTVALI
		_cCodEti := ZP1->ZP1_CODETI
		_cStrEtiq := ZP2->ZP2_ETIQ
		_cStrEtiq := StrTran(_cStrEtiq,"%cEan14%"		,NoAcento(SB1->B1_XEAN14))
		_cStrEtiq := StrTran(_cStrEtiq,"%cDesc01%"		,NoAcento(SB1->B1_XDESCE1))
		_cStrEtiq := StrTran(_cStrEtiq,"%cDesc02%"		,NoAcento(SB1->B1_XDESCE2))
		_cStrEtiq := StrTran(_cStrEtiq,"%cDesc03%"		,NoAcento(SB1->B1_XDESCE3))
		_cStrEtiq := StrTran(_cStrEtiq,"%cDTFab%"		,NoAcento(DToC(dDtProd)))
		_cStrEtiq := StrTran(_cStrEtiq,"%cDtValidade%"	,NoAcento(DToC(_dDtValid)))
		_cStrEtiq := StrTran(_cStrEtiq,"%cLote%"		,NoAcento(cLote)+" (R)")
		_cStrEtiq := StrTran(_cStrEtiq,"%cPeso%"		,NoAcento(AllTrim(Str(SB1->B1_CONV)))+" "+SB1->B1_UM)
		_cStrEtiq := StrTran(_cStrEtiq,"%cCodEtiq%"		,NoAcento(_cCodEti))
		_cStrEtiq := StrTran(_cStrEtiq,"%cAcond01%"		,NoAcento(SB1->B1_XACOND1))
		_cStrEtiq := StrTran(_cStrEtiq,"%cAcond02%"		,NoAcento(SB1->B1_XACOND2))
		_cStrEtiq := StrTran(_cStrEtiq,"%cSIF%"			,NoAcento(SB1->B1_XSIF))
		_cStrEtiq := StrTran(_cStrEtiq,"%cTipoEmb01%"	,NoAcento(SB1->B1_XTPEMB1))
		_cStrEtiq := StrTran(_cStrEtiq,"%cTipoEmb02%"	,NoAcento(SB1->B1_XTPEMB2))
		_cStrEtiq := StrTran(_cStrEtiq,"%cCodProd%"		,NoAcento(SB1->B1_COD))

		MSCBPRINTER("S4M",cPorta,,,.f.,,,,)
		MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
		MSCBWrite(_cStrEtiq)
		MSCBEND()
		MSCBCLOSEPRINTER()

		U_PCPRGLOG(_nTpLog,_cCodEti,IIF(_cTipo='1',"42",IIF(_cTipo='2',"43","44")))

		cProduto := Space(15)
		dDtProd := CToD("//")
		cLote := Space(3)
		cDescr := ""
		cEtiq := Space(17)
		oEtiq:Refresh()
		oProduto:Refresh()
		oLote:Refresh()
		oDtProd:Refresh()
		oDescr:Refresh()
		oEtiq:SetFocus()
	End Transaction
Return


Static Function bValEtiq()
	Local _lRet := .T.
	cEtiq := Upper(cEtiq)
	ZP1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	If ZP1->(dbSeek(xFilial()+SubStr(cEtiq,1,16))) .AND. SB1->(dbSeek(xFilial()+ZP1->ZP1_CODPRO))
		If ZP1->ZP1_STATUS $ "7/9"
			MsgStop("Etiqueta Suspensa ou sequestrada.")
			Return(.F.)
		Endif
		ZP2->(dbSetOrder(1))
		If Len(AllTrim(SB1->B1_XMODETI)) <= 0 .OR. !ZP2->(dbSeek(xFilial()+SB1->B1_XMODETI))
			MsgStop("Produto sem modelo de etiqueta informado.")
			_lRet := .F.
		Else
			cProduto := ZP1->ZP1_CODPRO
			cLote := ZP1->ZP1_LOTE
			dDtProd := ZP1->ZP1_DTPROD
			cDescr := SB1->B1_DESC
			oProduto:Refresh()
			oLote:Refresh()
			oDtProd:Refresh()
			oDescr:Refresh()
		EndIf
	Else
		_lRet := .F.
		MsgStop("Etiqueta inválida!")
	EndIf
Return(_lRet)

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
