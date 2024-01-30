#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} PCP001
Description

@param xParam Parameter Description
@return xRet Return Description
@author Fabrício Ferreira Santos - fabriciofs@gmail.com
@since 03/09/2015
/*/
//--------------------------------------------------------------

User Function PCP001()

	Local oFntGet1 := TFont():New("Tahoma",,028,,.T.,,,,,.F.,.F.)
	Local oFntGet2 := TFont():New("Tahoma",,020,,.T.,,,,,.F.,.F.)
	Local oFntGet3 := TFont():New("Tahoma",,032,,.T.,,,,,.F.,.F.)
	Local oFntGet4 := TFont():New("Tahoma",,044,,.T.,,,,,.F.,.F.)
	Local oFntLbl1 := TFont():New("Tahoma",,024,,.T.,,,,,.F.,.F.)
	Local oFntLbl2 := TFont():New("Tahoma",,020,,.T.,,,,,.F.,.F.)
	Private oDtAbate
	Private dDtAbate := CtoD("//")
	Private oDtPesoB
	Private dDtPesoB := CtoD("//")
	Private oDtSaida
	Private dDtSaida := CtoD("//")
	Private oDtTara
	Private dDtTara := CtoD("//")
	Private oEquipeA
	Private cEquipeA := ""
	Private aEquipeA := {}

	Private oUltEnt
	Private cUltEnt := " "
	Private aUltEnt := {" =   ","S=Sim","N=Nao"}

	Private oForn
	Private cForn := Space(6)
	Private oGroup1
	Private oGroup2
	Private oGroup3
	Private oGroup4
	Private oGTA
	Private cGTA := Space(10)
	Private oHrPesoB
	Private cHrPesoB := Space(5)
	Private oHrSaida
	Private cHrSaida := Space(5)
	Private oHrTara
	Private cHrTara := Space(5)
	Private oIdade
	Private nIdade := 0
	Private oLoja
	Private cLoja := Space(3)
	Private oLote
	Private cLote := Space(10)
	Private oMotor
	Private cMotor := Space(6)
	Private oNEntrada
	Private cNEntrada := Space(6)
	Private oNmForn
	Private cNmForn := ""
	Private oNmMotor
	Private cNmMotor := ""
	Private oNota
	Private cNota := Space(9)
	Private oPesoBal
	Private nPesoBal := 0
	Private lPesoMan := .F.
	Private oPesoBruto
	Private nPesoBruto := 0
	Private oPesoLiq
	Private nPesoLiq := 0
	Private oPlaca
	Private cPlaca := Space(8)
	Private oQtCAb
	Private nQtCAb := 0
	Private oTara
	Private nTara := 0
	Private oTpAnimal
	Private cTpAnimal := ""
	Private aTpAnimal := {}
	Private oTransp
	Private cTransp := ""
	Private oDlg
	Private lEntrada := .T.
	Private aVarGrv := bMntGrv() //Monta array com a relacao de variaveis utilziada na gravacao
	Private lManut := "PCP026" $ Upper(Funname())

	aAdd(aEquipeA, "")
	ZP3->(dbSetOrder(1))
	ZP3->(dbSeek(xFilial()))
	While !ZP3->(EOF()) .AND. ZP3->ZP3_FILIAL == xFilial("ZP3")
		aAdd(aEquipeA, ZP3->ZP3_COD)
		ZP3->(dbSkip())
	EndDo

	aAdd(aTpAnimal, "")
	SX5->(dbSetOrder(1))
	SX5->(dbSeek(xFilial()+"Z6"))
	While !SX5->(EOF()) .AND. SX5->X5_FILIAL == xFilial("SX5") .AND. SX5->X5_TABELA == "Z6"
		aAdd(aTpAnimal, Alltrim(SX5->X5_CHAVE)+"="+SX5->X5_DESCRI)
		SX5->(dbSkip())
	EndDo


	If lManut
		bVarMan()
	EndIf


	DEFINE MSDIALOG oDlg TITLE "Entrada de Animais Vivos" FROM 000, 000  TO 440, 1000 COLORS 0, 15527148 PIXEL

	@ 009, 005 SAY oSay1 PROMPT "Placa:" SIZE 035, 012 OF oDlg FONT oFntLbl1 COLORS 7143425, 15527148 PIXEL
	@ 006, 037 MSGET oPlaca VAR cPlaca SIZE 065, 020 OF oDlg PICTURE "@R XXX-XXXX" VALID bValPlaca() COLORS 16777215, 16776993 FONT oFntGet1 WHEN lEntrada .AND. !lManut PIXEL
	oPlaca:SetCSS("QLineEdit{ background-color: rgb(33,255,255); color: rgb(255,255,255);}")

	@ 005, 123 SAY oSay2 PROMPT "Transportador" SIZE 075, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 015, 124 MSGET oTransp VAR cTransp SIZE 150, 013 OF oDlg COLORS 16777215, 8796681 FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL
	@ 005, 280 SAY oSay3 PROMPT "Motorista" SIZE 075, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 015, 280 MSGET oMotor VAR cMotor SIZE 045, 013 OF oDlg VALID bValMotor() COLORS 0, 16777215 FONT oFntGet2 F3 "DA4" WHEN lEntrada .AND. !lManut PIXEL
	@ 015, 327 MSGET oNmMotor VAR cNmMotor SIZE 100, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 READONLY HASBUTTON PIXEL
	@ 005, 432 SAY oSay4 PROMPT "Data Abate" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 015, 432 MSGET oDtAbate VAR dDtAbate SIZE 060, 013 OF oDlg COLORS 0, 8796681 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL
	@ 035, 005 SAY oSay5 PROMPT "N. Entrada" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 005 MSGET oNEntrada VAR cNEntrada SIZE 045, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 READONLY PIXEL
	@ 035, 055 SAY oSay6 PROMPT "Data Saída" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 055 MSGET oDtSaida VAR dDtSaida SIZE 065, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL
	@ 035, 125 SAY oSay7 PROMPT "Hora Saída" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 125 MSGET oHrSaida VAR cHrSaida SIZE 045, 013 OF oDlg PICTURE "@R 99:99" COLORS 0, 16777215 VALID fValHor(cHrSaida)FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL
	@ 035, 175 SAY oSay8 PROMPT "Nota Fiscal" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 175 MSGET oNota VAR cNota SIZE 045, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL
	@ 035, 225 SAY oSay9 PROMPT "N. GTA" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 225 MSGET oGTA VAR cGTA SIZE 045, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL
	@ 035, 275 SAY oSay10 PROMPT "Lote Composto" SIZE 065, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 275 MSGET oLote VAR cLote SIZE 065, 013 OF oDlg VALID bValLote() COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL
	@ 035, 345 SAY oSay11 PROMPT "Equipe Apanha" SIZE 065, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 045, 345 MSCOMBOBOX oEquipeA VAR cEquipeA ITEMS aEquipeA SIZE 140, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL
	@ 065, 005 SAY oSay12 PROMPT "Fornecedor/Integrado" SIZE 150, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 075, 005 MSGET oForn VAR cForn SIZE 040, 013 OF oDlg COLORS 0, 8796681 FONT oFntGet2 READONLY PIXEL
	@ 075, 047 MSGET oLoja VAR cLoja SIZE 025, 013 OF oDlg COLORS 0, 8796681 FONT oFntGet2 READONLY PIXEL
	@ 075, 075 MSGET oNmForn VAR cNmForn SIZE 182, 013 OF oDlg COLORS 0, 8796681 FONT oFntGet2 READONLY PIXEL
	@ 065, 262 SAY oSay13 PROMPT "Qtde. Cabeças" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 075, 262 MSGET oQtCAb VAR nQtCAb SIZE 060, 013 OF oDlg PICTURE "@E 999999" COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL
	@ 065, 327 SAY oSay14 PROMPT "Idade (dias)" SIZE 050, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 075, 327 MSGET oIdade VAR nIdade SIZE 050, 013 OF oDlg PICTURE "@E 999999" COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL
	@ 065, 382 SAY oSay15 PROMPT "Tipo Animal X Linhagem" SIZE 102, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 075, 382 MSCOMBOBOX oTpAnimal VAR cTpAnimal ITEMS aTpAnimal SIZE 102, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .AND. !lManut PIXEL


	@ 100, 400 SAY oSay15 PROMPT "Ult. Ent. Lote" SIZE 102, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 110, 400 MSCOMBOBOX oUltEnt VAR cUltEnt ITEMS aUltEnt SIZE 80, 013 OF oDlg COLORS 0, 16777215 FONT oFntGet2 WHEN lEntrada .OR. lManut PIXEL


	@ 095, 005 GROUP oGroup1 TO 217, 115 PROMPT "Peso Bruto" OF oDlg COLOR 0, 15527148 PIXEL

	@ 105, 010 SAY oSay16 PROMPT "Data" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 115, 010 MSGET oDtPesoB VAR dDtPesoB SIZE 100, 023 OF oDlg COLORS 65535, 0 FONT oFntGet3 READONLY PIXEL
	oDtPesoB:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(255,255,0);}")

	@ 142, 010 SAY oSay17 PROMPT "Hora" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 152, 010 MSGET oHrPesoB VAR cHrPesoB SIZE 100, 023 OF oDlg PICTURE "@R 99:99" COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oHrPesoB:SetContentAlign(1)
	oHrPesoB:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(255,255,0);}")

	@ 180, 010 SAY oSay18 PROMPT "Peso" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 190, 010 MSGET oPesoBruto VAR nPesoBruto SIZE 100, 023 OF oDlg PICTURE "@E 999,999.99" COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oPesoBruto:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(255,255,0);}")

	@ 095, 122 GROUP oGroup2 TO 217, 232 PROMPT "Tara" OF oDlg COLOR 0, 15527148 PIXEL

	@ 105, 127 SAY oSay19 PROMPT "Data" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 115, 127 MSGET oDtTara VAR dDtTara SIZE 100, 023 OF oDlg COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oDtTara:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(33,255,255);}")

	@ 142, 127 SAY oSay20 PROMPT "Hora" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 152, 127 MSGET oHrTara VAR cHrTara SIZE 100, 023 OF oDlg PICTURE "@R 99:99" COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oHrTara:SetContentAlign(1)
	oHrTara:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(33,255,255);}")

	@ 180, 127 SAY oSay21 PROMPT "Peso" SIZE 060, 012 OF oDlg FONT oFntLbl2 COLORS 0, 15527148 PIXEL
	@ 190, 127 MSGET oTara VAR nTara SIZE 100, 023 OF oDlg PICTURE "@E 999,999.99" COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oTara:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(33,255,255);}")

	@ 177, 237 GROUP oGroup3 TO 217, 347 PROMPT "Peso Liquido" OF oDlg COLOR 0, 15527148 PIXEL

	@ 190, 242 MSGET oPesoLiq VAR nPesoLiq SIZE 100, 023 OF oDlg PICTURE "@E 999,999.99" COLORS 0, 0 FONT oFntGet3 READONLY PIXEL
	oPesoLiq:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(0,255,0);}")

	@ 095, 237 GROUP oGroup4 TO 135, 315 PROMPT "Pesagem Manual" OF oDlg COLOR 0, 15527148 PIXEL
	@ 113, 256 BUTTON oBtnPesMan PROMPT "Ativar" SIZE 037, 012 OF oDlg ACTION bPesMan() WHEN !lManut PIXEL
	@ 097, 317 BUTTON oButton1 PROMPT "Peso" SIZE 078, 038 OF oDlg FONT oFntLbl1 ACTION bGetPeso() WHEN !lManut PIXEL

	@ 142, 237 MSGET oPesoBal VAR nPesoBal SIZE 157, 033 OF oDlg PICTURE "@E 999,999.99" COLORS 65280, 0 FONT oFntGet4 Valid bValPMan() When lPesoMan .AND. !lManut PIXEL
	oPesoBal:SetCSS("QLineEdit{ background-color: rgb(0,0,0); color: rgb(0,255,0);}")

	@ 160, 402 BUTTON oButton2 PROMPT "Gravar" SIZE 090, 025 OF oDlg FONT oFntLbl1 ACTION bGrava() PIXEL
	@ 190, 402 BUTTON oButton3 PROMPT "Fechar" SIZE 090, 025 OF oDlg FONT oFntLbl1 ACTION oDlg:End() PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function bGrava()
	Local _I := 0

	//Primeiro faz a validação dos Campos
	For _I := 1 To Len(aVarGrv)
		If aVarGrv[_I,1] .AND. &(aVarGrv[_I,4])
			If Len(AllTrim(aVarGrv[_I,5])) > 0 .AND. !(&(aVarGrv[_I,5]))
				MsgStop(aVarGrv[_I,6])
				Return
			EndIf
		EndIf
	Next _I

	Begin Transaction
		If lManut
			RecLock("ZP0",.F.)
		Else
			RecLock("ZP0",lEntrada)
		EndIf
		For _I := 1 To Len(aVarGrv)
			If &(aVarGrv[_I,4])
				If aVarGrv[_I,2] == "ZP0_LOTECO"
					ZP0->(FieldPut(FieldPos(aVarGrv[_I,2]), AllTrim ( &(aVarGrv[_I,3]) )))
				Else  
					ZP0->(FieldPut(FieldPos(aVarGrv[_I,2]),&(aVarGrv[_I,3])))
				EndIf
			EndIf
		Next _I
		ZP0->(MsUnLock())
		If !lEntrada .AND. !lManut
			If !bGeraNota()
				DisarmTransaction()
				Return
			EndIf
		EndIf
	End Transaction
	If lManut
		oDlg:End()
	Else
		bLimpaTela()
	EndIf
Return

Static Function bValPlaca()

	Local _lRet := .T.
	Local _I := 0
	cPlaca := Upper(cPlaca)
	If Len(AllTrim(cPlaca)) <= 0
		Return(_lRet)
	EndIf
	DA3->(dbSetOrder(3))
	If DA3->(dbSeek(xFilial()+SubStr(cPlaca,1,7)))
		SA4->(dbsetOrder(1))
		If SA4->(dbSeek(xFilial()+DA3->DA3_XCODTR))
			cTransp := SA4->A4_COD+"-"+SA4->A4_NOME
			oTransp:Refresh()
			If Len(AllTrim(DA3->DA3_MOTORI)) > 0
				cMotor := DA3->DA3_MOTORI
				oMotor:Refresh()
				bValMotor()
			EndIf
		Else
			MsgStop("Veículo sem transportadora amarrada.")
			_lRet := .F.
		EndIf
	Else
		MsgStop("Veículo não cadastrado.")
		_lRet := .F.
	EndIf

	If _lRet
		ZP0->(dbSetOrder(2))
		If ZP0->(dbSeek(xFilial()+cPlaca+DToS(CToD("//"))))
			For _I := 1 To Len(aVarGrv)
				If aVarGrv[_I,1] .AND. &(aVarGrv[_I,4])
					&(aVarGrv[_I,3]) := ZP0->(FieldGet(FieldPos(aVarGrv[_I,2])))
					_oTmp := "o"+SubStr(aVarGrv[_I,3],2)
					_oTmp := &_oTmp
					_oTmp:Refresh()
				EndIf
			Next _I
			oHrPesoB:SetContentAlign(1)
			oHrTara:SetContentAlign(1)
			lEntrada := .F.
		Else
			cNEntrada := bGetNxtEnt()
			oNEntrada:Refresh()
		EndIf
	EndIf
Return(_lRet)

Static Function bValMotor()

	Local _lRet := .T.
	DA4->(dbSetOrder(1))
	If DA4->(dbSeek(xFilial()+cMotor))
		cNmMotor := DA4->DA4_NOME
		oNmMotor:Refresh()
	Else
		MsgStop("Codigo Inválido.")
		_lRet := .F.
	EndIf
Return(_lRet)

Static Function bValLote()

	Local _lRet := .T.
	Local _cQry := ""

	_cQry += " SELECT * "
	_cQry += " FROM LOTES_MTECH"
	_cQry += " WHERE LOTE  = '"+AllTrim(cLote)+"'"
	TcQuery _cQry New Alias "QRYLOT"
	If !QRYLOT->(EOF())
		cForn := QRYLOT->A2_COD
		cLoja := QRYLOT->A2_LOJA
		cNmForn := QRYLOT->A2_NOME
		oForn:Refresh()
		oLoja:Refresh()
		oNmForn:Refresh()
	Else
		MsgStop("Lote inválido.")
		_lRet := .F.
	EndIf
	QRYLOT->(dbCloseArea())
Return(_lRet)

Static Function bGetPeso()

	Local cCfg := ("COM1"+":4800,n,8,1")
	Local cFirst := "", cT := "", nH := 0, nRet := 0, nLoop := 5000
	Local cPeso, xPeso, nPeso := -1, aHexa := {,,,,,,,,,"A","B","C","D","E","F"}

	//lPesoMan := .F.

	If lPesoMan  //.T.
		If lEntrada
			nPeso := 24000
		Else
			nPeso := 10000
		EndIf
	Else
		If msOpenPort(@nH,cCfg)

			WHILE nLoop > 0
				msRead(nH,@cT)

				IF len(cT) > 0
					Exit
				ENDIF

				nLoop--
			ENDDO

			msClosePort(nH)
		EndIf

		If Len(cT) <= 0
			Return(nPeso)
		EndIf

		cPeso := subStr(cT,5,6)
		xPeso := ""

		WHILE len(cPeso) > 0
			cChar := left(cPeso,1)
			cPeso := subStr(cPeso,2)
			nChar := asc(cChar)

			nModu := mod(nChar,16)
			nChar := noRound(nChar / 16,0)

			cChar := IIF(nChar > 10,aHexa[nChar],allTrim(str(nChar)))
			cChar += IIF(nModu > 10,aHexa[nModu],allTrim(str(nModu)))

			xPeso += subStr(cChar,2,1)
		ENDDO

		nPeso := val(xPeso)
	EndIf
	nPesoBal := nPeso
	oPesoBal:Refresh()
	bAtuPeso()
Return

Static Function bValPMan()
	Local _lRet := .T.
	If nPesoBal < 0
		MsgStop("Informe um peso válido.")
		_lRet := .F.
	Else
		bAtuPeso()
	EndIf
Return(_lRet)

Static Function bPesMan
	If lPesoMan
		oBtnPesMan:SetText("Ativar")
	Else
		oBtnPesMan:SetText("Desativar")
	EndIf
	lPesoMan := !lPesoMan
	nPesoBal := 0
	bAtuPeso()
	oPesoBal:Refresh()
Return

Static Function bAtuPeso
	Local _dData := CToD("//")
	Local _cHora := Space(5)
	Local _nPeso := 0

	If nPesoBal > 0
		_dData := Date()
		_cHora := SubStr(Time(),1,5)
		_nPeso := nPesoBal
	EndIf

	If lEntrada
		dDtPesoB := _dData
		cHrPesoB := _cHora
		nPesoBruto := _nPeso
		nPesoLiq := 0
	Else
		dDtTara := _dData
		cHrTara := _cHora
		nTara := _nPeso
		If nTara > 0
			nPesoLiq := nPesoBruto - nTara
		EndIf
	EndIf
	oDtPesoB:Refresh()
	oHrPesoB:Refresh()
	oPesoBruto:Refresh()
	oDtTara:Refresh()
	oHrTara:Refresh()
	oTara:Refresh()
	oPesoLiq:Refresh()
	oHrPesoB:SetContentAlign(1)
	oHrTara:SetContentAlign(1)
Return


/*
ALTER VIEW LOTES_MTECH AS
SELECT CL.NoCompostoLote LOTE, A2_COD, A2_LOJA, A2_NOME
FROM integracao.dbo.CadLote CL
INNER JOIN integracao.dbo.CadFazenda CF ON SUBSTRING(CL.NoCompostoLote,1,5) = CF.CodFazenda
INNER JOIN SA2010 A2 ON A2.D_E_L_E_T_ = ' ' AND A2_COD+A2_LOJA = CF.CodFor
WHERE Ativo = 1
*/

Static Function bMntGrv
	Local _aRet := {}
	/*
	Colunas
	1-Variaval de tela
	2-Campo tabela ZP0
	3-Conteudo para preenchimento/Variavel de Tela
	4-Condicional para gravacao
	5-Validacao
	6-Mensagem de erro validacao
	7-Conteudo padrao
	*/
	aAdd(_aRet,{.F.,"ZP0_FILIAL"	,"xFilial('ZP0')"		,"lEntrada"	, ""							, ""								,})
	aAdd(_aRet,{.T.,"ZP0_PLACA"		,"cPlaca"				,"lEntrada"	, "Len(AllTrim(cPlaca)) > 0"	, "Informe a Placa"					,Space(8)})
	aAdd(_aRet,{.T.,"ZP0_TRANSP"	,"cTransp"				,"lEntrada"	, ""							, ""								,Space(6)})
	aAdd(_aRet,{.T.,"ZP0_MOTOR"		,"cMotor"				,"lEntrada"	, "Len(AllTrim(cMotor)) > 0"	, "Informe o Motorista"				,Space(6)})
	aAdd(_aRet,{.T.,"ZP0_NMMOTO"	,"cNmMotor"				,"lEntrada"	, ""							, ""								,""})
	aAdd(_aRet,{.T.,"ZP0_DTABAT"	,"dDtAbate"				,"lEntrada"	, "!Empty(dDtAbate)"			, "Informe a Data do Abate"			,CToD("//")})
	aAdd(_aRet,{.T.,"ZP0_NENTR"		,"cNEntrada"			,"lEntrada"	, ""							, ""								,Space(6)})
	aAdd(_aRet,{.T.,"ZP0_DTSAID"	,"dDtSaida"				,"lEntrada"	, "!Empty(dDtSaida)"			, "Informe a Data de Saída"			,CToD("//")})
	aAdd(_aRet,{.T.,"ZP0_HRSAID"	,"cHrSaida"				,"lEntrada"	, "Len(AllTrim(cHrSaida)) > 0"	, "Informe a Hora de Saida"			,Space(5)})
	aAdd(_aRet,{.T.,"ZP0_NFISCA"	,"cNota"				,"lEntrada"	, "Len(AllTrim(cNota)) > 0"		, "Informe a Nota Fiscal"			,Space(9)})
	aAdd(_aRet,{.T.,"ZP0_GTA"		,"cGTA"					,"lEntrada"	, "Len(AllTrim(cGTA)) > 0"		, "Informe a GTA"					,Space(20)})
	aAdd(_aRet,{.T.,"ZP0_LOTECO"	,"cLote"				,"lEntrada"	, "Len(AllTrim(cLote)) > 0"		, "Informe o Lote"					,Space(20)})
	aAdd(_aRet,{.T.,"ZP0_EQUIPA"	,"cEquipeA"				,"lEntrada"	, "Len(AllTrim(cEquipeA)) > 0"	, "Informe a Equipe de Apanhe"		,Space(20)})
	aAdd(_aRet,{.T.,"ZP0_FORNEC"	,"cForn"				,"lEntrada"	, ""							, ""								,Space(6)})
	aAdd(_aRet,{.T.,"ZP0_LOJA"		,"cLoja"				,"lEntrada"	, ""							, ""								,Space(3)})
	aAdd(_aRet,{.T.,"ZP0_NMFOR"		,"cNmForn"				,"lEntrada"	, ""							, ""								,""})
	aAdd(_aRet,{.T.,"ZP0_QTCAB"		,"nQtCAb"				,"lEntrada"	, "nQtCAb > 0"					, "Informe a quantidade de cabeças"	,0})
	aAdd(_aRet,{.T.,"ZP0_IDADE"		,"nIdade"				,"lEntrada"	, "nIdade > 0"					, "Informe a idade"					,0})
	aAdd(_aRet,{.T.,"ZP0_LINHAG"	,"cTpAnimal"			,"lEntrada"	, "Len(AllTrim(cTpAnimal)) > 0"	, "Informe a Linhagem"				,Space(20)})
	aAdd(_aRet,{.T.,"ZP0_DTPESB"	,"dDtPesoB"				,"lEntrada"	, ""							, ""								,CToD("//")})
	aAdd(_aRet,{.T.,"ZP0_HRPESB"	,"cHrPesoB"				,"lEntrada"	, ""							, ""								,Space(5)})
	aAdd(_aRet,{.T.,"ZP0_PESOB"		,"nPesoBruto"			,"lEntrada"	, "nPesoBruto > 0"				, "Informe o Peso"					,0})
	aAdd(_aRet,{.F.,"ZP0_TPPESB"	,"If(lPesoMan,'M','B')"	,"lEntrada"	, ""							, ""								,})
	aAdd(_aRet,{.F.,"ZP0_USRPES"	,"cUserName"			,"lEntrada"	, ""							, ""								,})
	aAdd(_aRet,{.T.,"ZP0_DTPEST"	,"dDtTara"				,"!lEntrada", ""							, ""								,CToD("//")})
	aAdd(_aRet,{.T.,"ZP0_HRPEST"	,"cHrTara"				,"!lEntrada", ""							, ""								,Space(5)})
	aAdd(_aRet,{.T.,"ZP0_PESOT"		,"nTara"				,"!lEntrada", "nTara > 0"					, "Informe o Peso"					,0})
	aAdd(_aRet,{.T.,"ZP0_PESOL"		,"nPesoLiq"				,"!lEntrada", ""							, ""								,0})
	aAdd(_aRet,{.F.,"ZP0_TPPEST"	,"If(lPesoMan,'M','B')"	,"!lEntrada", ""							, ""								,})
	aAdd(_aRet,{.F.,"ZP0_ULTENT"	,"cUltEnt"	            ,"lEntrada" , "Len(AllTrim(cUltEnt)) > 0"	, "Informe se é Ult. Entr. do Lote"	,Space(1)})

Return(_aRet)

Static Function bGetNxtEnt
	Local _cQry := "SELECT MAX(ZP0_NENTR) ZP0_NENTR FROM "+RetSqlName("ZP0")+" WHERE ZP0_FILIAL = '"+xFilial("ZP0")+"'"
	Local _cRet := "000000"
	TcQuery _cQry New Alias "QRYSEQ"
	If !QRYSEQ->(EOF())
		_cRet := QRYSEQ->ZP0_NENTR
	EndIf
	QRYSEQ->(dbCloseArea())
	_cRet := Soma1(_cRet)
Return(_cRet)

Static Function bLimpaTela
	Local _I := 0
	lEntrada := .T.
	For _I := 1 To Len(aVarGrv)
		If aVarGrv[_I,1] .AND. aVarGrv[_I,7] <> Nil
			&(aVarGrv[_I,3]) := aVarGrv[_I,7]
			_oTmp := "o"+SubStr(aVarGrv[_I,3],2)
			_oTmp := &_oTmp
			_oTmp:Refresh()
		EndIf
	Next _I
	nPesoBal := 0
	oPesoBal:Refresh()
	oHrPesoB:SetContentAlign(1)
	oHrTara:SetContentAlign(1)
Return

Static Function bGeraNota
	Local _lRet 		:= .T.
	Local _cFornece 	:= cForn
	Local _cLoja 		:= cLoja
	Local _cDocEFV 	:= CriaVar("F1_DOC",.F.)
	Local _cSerieEFV 	:= GetNewPar("MV_XSERPEG","005")
	Local _dEmissao 	:= dDataBase
	Local _nPrcUnit	:= GetNewPar("MV_XPRPEGA",1.8203)
	Local _cNotaPro 	:= cNota
	Local _nQtdEFV 	:= nPesoLiq
	Local _nTotEFV 	:= Round(_nPrcUnit * _nQtdEFV,TamSX3("D1_TOTAL")[2])
	Local _aCabecEFV 	:= {}
	Local _aItemEFV 	:= {} //Nota de entrada Frango Vivo
	Local _aItem 		:= {}
	Local _cDataAb 	:= dDtAbate
	Local _cRefMTech 	:= cLote
	Local _cNumNfe	:="" 
	Private _cDocPRN

	Begin Transaction
		_cTipoCtr:= AllTrim(GetNewPar("MV_TPNRNFS","3"))
		If _cTipoCtr <> "3"
			_cDocEFV 	:= NxtSX5Nota( "005",,SuperGetMv("MV_TPNRNFS"),.F. )
			_cNumNfe	:= _cDocEFV
		Else
			_cDocEFV 	:= ""
			_cNumNfe	:= _cDocEFV
		Endif

		aAdd(_aItem,{"D1_FILIAL"		, xFilial("SD1")     	,NIL})  // INF. PED.
		aAdd(_aItem,{"D1_DOC"		, _cDocEFV             	,NIL})
		aAdd(_aItem,{"D1_SERIE"		, _cSerieEFV           	,NIL})
		aAdd(_aItem,{"D1_FORNECE"	, _cFornece          	,NIL})
		aAdd(_aItem,{"D1_LOJA"		, _cLoja            	,NIL})
		aAdd(_aItem,{"D1_ITEM"		, StrZero(Len(_aItemEFV)+1,4) ,NIL})
		aAdd(_aItem,{"D1_COD"		, "00665"			    ,NIL})
		aAdd(_aItem,{"D1_QUANT"		, _nQtdEFV           	,NIL})
		aAdd(_aItem,{"D1_VUNIT"		, _nPrcUnit				,NIL})
		aAdd(_aItem,{"D1_TOTAL"		, Round(_nPrcUnit * _nQtdEFV,TamSX3("D1_TOTAL")[2]) ,NIL})
		aAdd(_aItem,{"D1_TES"		, "115"           		,NIL})
		aAdd(_aItemEFV, aClone(_aItem))

		aAdd(_aCabecEFV,{"F1_FILIAL"      ,xFilial("SF1")		,Nil})
		aAdd(_aCabecEFV,{"F1_TIPO"        ,"N"					,Nil})
		aAdd(_aCabecEFV,{"F1_FORMUL"       ,"S"					,Nil})
		aAdd(_aCabecEFV,{"F1_DOC"         ,_cDocEFV				,Nil})
		aAdd(_aCabecEFV,{"F1_SERIE"       ,_cSerieEFV			,Nil})
		aAdd(_aCabecEFV,{"F1_EMISSAO"     ,_dEmissao			,Nil})
		aAdd(_aCabecEFV,{"F1_FORNECE"     ,_cFornece			,Nil})
		aAdd(_aCabecEFV,{"F1_LOJA"        ,_cLoja				,Nil})
		aAdd(_aCabecEFV,{"F1_ESPECIE"     ,"SPED"				,Nil})
		aAdd(_aCabecEFV,{"F1_DTDIGIT"     ,dDataBase			,Nil})
		aAdd(_aCabecEFV,{"F1_EST"         ,Posicione("SA2",1,xFilial("SA2")+_cFornece+_cLoja,"A2_EST")	,Nil})
		aAdd(_aCabecEFV,{"F1_HORA"        ,SubStr(Time(),1,5)	,Nil})
		aAdd(_aCabecEFV,{"F1_MENNOTA"     ,"Referente nota serie 005 de numero " + ALLTRIM(_cNotaPro)	+ "/  Data abate: " + ALLTRIM(_cDataAb) + "/  LOTE: " + ALLTRIM(_cRefMTech),Nil})
		If SF1->(FieldPos("F1_XMTECH")) > 0
			aAdd(_aCabecEFV,{"F1_XMTECH"      ,_cRefMTech			,Nil})
		EndIf
		lMsErroAuto := .F.
		_cDocPRN := _cDocEFV
		MsgRun("Gerando Nota Entrada Frango Vivo...",,{|| MSExecAuto({|x,y,z,r| MATA103(x,y,z,r)},_aCabecEFV,_aItemEFV,3,.F. )})		
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return .F.
		Else
			_cNumNfe:=SF1->F1_DOC
			RecLock("ZP0",.F.)
			ZP0->ZP0_NUMNFE := _cNumNfe
			ZP0->ZP0_SERNFE := _cSerieEFV
			ZP0->(MsUnLock())

			Alert("Nota Gerada:"+_cNumNfe)
			/* -- Transmite a nota automaticamente para Sefaz --
			Parametros AutoNfeEnv:
			cEmpresa,
			cFilial,
			cEspera,
			cAmbiente (1=producao,2=Homologcao) Muito cuidado.
			cSerie
			cDoc.Inicial
			cDoc.Final
			*/
			If cEmpAnt=="01"
				AutoNfeEnv(cEmpAnt, cFilAnt, "0", "1", _cSerieEFV, _cDocEFV, _cDocEFV)
				//MsgStop("Gerada a nota "+ZP0->ZP0_NENTR)
				u_ImpTkt(ZP0->ZP0_NENTR)
			Endif
		EndIf
	End Transaction
Return(_lRet)


Static Function bVarMan
	Local _I := 0
	For _I := 1 To Len(aVarGrv)
		If aVarGrv[_I,1]
			&(aVarGrv[_I,3]) := ZP0->(FieldGet(FieldPos(aVarGrv[_I,2])))
		EndIf
	Next _I
Return

/*
Tratamento de horas
*/
Static Function fValHor(_cCampo)

	Local lRet		:= .T.
	Local _cHora	:= Iif(At(':',_cCampo) > 0, SubStr(_cCampo,1,2) + SubStr(_cCampo,4,2),_cCampo)

	For x:=1 To Len(AllTrim(_cHora))
		If !SubStr(AllTrim(_cHora),x,1) $ "0123456789" .And. x <= Len(AllTrim(_cHora)) 
			MsgStop("Existem caracters que não são numericos na hora digitada. Caracter: ["+SubStr(_cHora,x,1)+"] Hora Digitada: "+_cHora)
			Return .F.
		Endif
	Next x

	If Val(SubStr(_cHora,1,2)) > 23
		MsgStop("Formato incorreto para o tipo Hora!!")
		Return .F.
	Endif

	If Val(SubStr(_cHora,3,2)) > 59
		MsgStop("Formato incorreto para o tipo Minuto!!")
		Return .F.
	Endif

Return lRet

User Function ImpTkt(_cDocEFV)

///msgalert("entrou com os dados do doc  --->" + _cDocEFV+" --- "+aLLTRIM(STR(RECNO())))
Local nLin			:= 1
Local cLin			:= ""
Local nErr			:= 0
Local lEdita		:= .F.
Local lPs1			:= .F.
Local lPs2			:= .F.
Local _nDesc		:= 0
Local cPictPeso		:= "@E 9,999,999.999"
Local cImpTela		:= ""
Private aReturn		:= { "", 1, "" , 2, 1, "LPT1" , "",IndexOrd() }
Private cWrel		:= ""
Private aHstTxt		:= {}

ZP0->(dbSetOrder(1))
If !(ZP0->(dbSeek(xFilial("ZP0")+_cDocEFV )))
	MsgStop("Não existem pesagens a serem impressas.")
	Return .F.
Endif

//->Inicia Impressão
cWrel		:= SetPrint(Alias(),"","","",,,,.F.,,,,,,,'EPSON.DRV',.T.,,"LPT1")
if nLastKey == 27
	Return (.F.)
EndIf
SetDefault(aReturn,Alias())
SetPrc(0,0)
SetPgEject( .F. )


aadd(aHstTxt, {chr(15) + chr(27)+ chr(87)+ chr(1) + chr(27)+ chr(69), AllTrim(SM0->M0_NOMECOM) , chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)}  )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), AllTrim(SM0->M0_ENDCOB), chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)}   )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{ chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB, chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)}   )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), 'CEP: '+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3) , chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)}   )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{ chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), 'PABX/FAX: '+SM0->M0_TEL , chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0) }  )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{ chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), 'CNPJ: '+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2) , chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)}   )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 1

aadd(aHstTxt,{chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69), 'I.E.: '+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3) , chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0) }  )

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,001,cLin,)
nLin+= 2

aadd(aHstTxt,{ chr(15) , "Emissao: " +dToC(Date())+ SPACE(20) + "Hora: "+Time(),""})

cLin:= aHstTxt[len(aHstTxt),1]+aHstTxt[len(aHstTxt),2]+aHstTxt[len(aHstTxt),3]
PrintOut(nLin,005,cLin,)
nLin+= 2

	//->Imprime Ticket
	ZP0->(dbSetOrder(1))
	If ZP0->(dbSeek(xFilial("ZP0") + _cDocEFV))
		cLin:= "ENTRADA: ["+_cDocEFV+"]"
		cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ cLin + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
		PrintOut(nLin,010,cLin,)
		nLin+= 2

		cLin:="PLACA: " + ZP0->ZP0_PLACA
		cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ cLin + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
		PrintOut(nLin,005,cLin,)
		nLin+= 1
	
		If FieldPos(AllTrim("ZP0_MOTOR")) > 0
			cLin:="MOTORISTA: " + ZP0->ZP0_MOTOR +"-"+SubStr(PCP001U(2,ZP0->ZP0_MOTOR),1,35)
			//cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ cLin + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
			PrintOut(nLin,005,cLin,)
			nLin+= 1
		Endif
		cLin:= chr(15) + "Pesagem Inicial: "+dToC(ZP0->ZP0_DTPESB)
		PrintOut(nLin,005,cLin,)
		nLin+= 1
		cLin:= chr(15) + "Hora Inicial: "+ZP0->ZP0_HRPESB
		PrintOut(nLin,005,cLin,)
		nLin+= 1
		If ZP0->ZP0_PESOT > 0
			cLin:= chr(15) + "Pesagem Final: "+dToC(ZP0->ZP0_DTPEST)
			PrintOut(nLin,005,cLin,)
			nLin+= 1
			cLin:= chr(15) + "Hora Final: "+ZP0->ZP0_HRPEST
			PrintOut(nLin,005,cLin,)
			nLin+= 1
		Endif
		
		cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69) +  "Peso Inicial:"+Transform(ZP0->ZP0_PESOB,cPictPeso) + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
		PrintOut(nLin,005,cLin,)
		nLin+= 1
		
		If ZP0->ZP0_PESOT > 0
			cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+"Peso Final..:"+Transform(ZP0->ZP0_PESOT,cPictPeso) + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
			PrintOut(nLin,005,cLin,)
			nLin+= 2
			If ZP0->ZP0_PESOB > ZP0->ZP0_PESOT
				cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ "Peso Liquido:"+Transform(ZP0->ZP0_PESOB-ZP0->ZP0_PESOT,cPictPeso) + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
				PrintOut(nLin,005,cLin,)
				nLin+= 1
			Else
				cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ "Peso Liquido:"+Transform(ZP0->ZP0_PESOT-ZP0->ZP0_PESOB,cPictPeso) + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
				PrintOut(nLin,005,cLin,)
				nLin+= 1
			Endif
			nLin+= 1
			
			nLin+= 1
			cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ "Usuario Pesagem:" + chr(27)+ chr(70) + chr(27)+ chr(87)+ chr(0)
			PrintOut(nLin,005,cLin,)
			nLin+= 1
			cLin:= chr(15) + chr(27)+ chr(87)+ chr(1)+chr(27)+ chr(69)+ ZP0->ZP0_USRPES + " - " +SubStr(Upper(UsrFullName(ZP0->ZP0_USRPES)),1,20)+ chr(70) + chr(27)+ chr(87)+ chr(0)
			PrintOut(nLin,005,cLin,)
			nLin+= 1

		Endif
	EndIf
	//->Imprime Histórico de Pesagens

nLin+= 3
cLin:= chr(15) + Padc(Replicate(".",30),55)
PrintOut(nLin,005,cLin,)
nLin+= 1
cLin:= chr(15) + Padc("Visto do Supervisor da Balanca",55)
PrintOut(nLin,005,cLin,)
nLin+= 10
cLin:= chr(15) + " "
PrintOut(nLin,001,cLin,)

Set Printer To
dbCommitAll()
ms_Flush()

Return


/*
Função: PCP001U
Data: 29/02/16
Por: Evandor Gomes
Descrição: Retorna nome do motorista
nTipo == 1 -> Valida Motorista
nTipo == 2 -> Retorna Nome do Motorista
*/
Static Function PCP001U(nTipo,_cCodMot)
Local lRet	:= .F.
DA4->(dbSetOrder(1))
If DA4->(dbSeek(xFilial("DA4")+_cCodMot))
	_cNMotor:=DA4->DA4_NOME
	lRet:=.T.
Else
	_cCodMot:=""
	_cNMotor:=""
Endif
Return(Iif(nTipo==1,lRet,_cNMotor))