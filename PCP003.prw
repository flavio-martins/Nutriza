#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} PCP003
Description

@param xParam Parameter Description
@return xRet Return Description
@author Fabrício Ferreira Santos - fabriciofs@gmail.com
@since 08/09/2015
/*/
//--------------------------------------------------------------
User Function PCP003()

	Private oAnimMort
	Private nAnimMort := 0
	Private oDtAbate
	Private dDtAbate := CToD("//")
	Private oDtFimPen
	Private dDtFimPen := CToD("//")
	Private oDtIniPen
	Private dDtIniPen := CToD("//")
	Private oEstacao
	Private nEstacao := 1
	Private oFntGet := TFont():New("Tahoma",,018,,.F.,,,,,.F.,.F.)
	Private oFntLbl := TFont():New("Tahoma",,018,,.T.,,,,,.F.,.F.)
	Private oHrFimPen
	Private cHrFimPen := Space(5)
	Private oHrIniPen
	Private cHrIniPen := Space(5)
	Private oTotAnim
	Private nTotAnim := 0
	Private oEntradas
	Private aEntradas := {}
	Private oDlg
	Private _aDados := {}
	Private _nLinAnt := 1
	Private aVldAmb 	:= U_GTOMTEC2("Registro da Pendura["+FunName()+"]",.T.)
	Private lExecSP 	:= aVldAmb[1] .And. aVldAmb[2] == "P" //-> Se executa stored procedure

	If !aVldAmb[1]
		Return .F.
	Endif

	DEFINE MSDIALOG oDlg TITLE "Registro da Pendura" FROM 000, 000  TO 475, 500 COLORS 0, 16777215 PIXEL

	@ 005, 005 SAY oSay1 PROMPT "Data Abate" SIZE 050, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 015, 005 MSGET oDtAbate VAR dDtAbate SIZE 060, 012 OF oDlg VALID bValDt() COLORS 0, 16777215 FONT oFntGet PIXEL
	@ 005, 068 SAY oSay2 PROMPT "Estação de Pendura" SIZE 075, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 015, 068 MSCOMBOBOX oEstacao VAR nEstacao ITEMS {"Pendura Um - Direita","Pendura Dois - Esquerda"} SIZE 100, 012 OF oDlg COLORS 0, 16777215 FONT oFntGet PIXEL

	aAdd(aEntradas,{"","","",""})
	aAdd(_aDados,{CToD("//"),"",CToD("//"),"",0,0})
	@ 032, 005 LISTBOX oEntradas Fields HEADER "Data Entrada","Placa","Cod. Entrada","Transportador" SIZE 240, 150 OF oDlg PIXEL ColSizes 25,50
	oEntradas:SetArray(aEntradas)
	oEntradas:bLine := {|| {aEntradas[oEntradas:nAt,1],aEntradas[oEntradas:nAt,2],aEntradas[oEntradas:nAt,3],aEntradas[oEntradas:nAt,4]}}
	oEntradas:bChange := {|| {bMudaLinha()}}

	@ 185, 005 SAY oSay3 PROMPT "Data Inicio Pendura" SIZE 075, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 210, 005 SAY oSay4 PROMPT "Data Final Pendura" SIZE 075, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 185, 075 SAY oSay5 PROMPT "Hora Inicio Pendura" SIZE 075, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 210, 075 SAY oSay6 PROMPT "Hora Final Pendura" SIZE 075, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 185, 145 SAY oSay7 PROMPT "Total Animais Contados" SIZE 085, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL
	@ 210, 145 SAY oSay8 PROMPT "Total Animais Mortos" SIZE 085, 007 OF oDlg FONT oFntLbl COLORS 0, 16777215 PIXEL


	@ 195, 005 MSGET oDtIniPen VAR dDtIniPen SIZE 060, 012 OF oDlg COLORS 0, 16777215 VALID fValDat(dDtIniPen,1) FONT oFntGet PIXEL
	@ 195, 075 MSGET oHrIniPen VAR cHrIniPen SIZE 060, 012 OF oDlg PICTURE "@R 99:99" COLORS 0, 16777215 VALID fValHor(cHrIniPen) FONT oFntGet PIXEL
	@ 220, 005 MSGET oDtFimPen VAR dDtFimPen SIZE 060, 012 OF oDlg COLORS 0, 16777215 VALID fValDat(dDtFimPen,2)FONT oFntGet PIXEL
	@ 220, 075 MSGET oHrFimPen VAR cHrFimPen SIZE 060, 012 OF oDlg PICTURE "@R 99:99" COLORS 0, 16777215 VALID fValHor(cHrFimPen) FONT oFntGet PIXEL
	@ 195, 145 MSGET oTotAnim VAR nTotAnim SIZE 060, 012 OF oDlg PICTURE "@E 99,999,999" COLORS 0, 16777215 FONT oFntGet PIXEL
	@ 220, 145 MSGET oAnimMort VAR nAnimMort SIZE 060, 010 OF oDlg PICTURE "@E 99,999,999" COLORS 0, 16777215 FONT oFntGet PIXEL

	DEFINE SBUTTON oSButton1 FROM 012, 179 TYPE 01 OF oDlg ENABLE ACTION bOk()
	DEFINE SBUTTON oSButton2 FROM 012, 216 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function bOk()
	Local _I := 0
	bMudaLinha()
	For _I := 1 To Len(aEntradas)
		ZP0->(dbSetOrder(1))
		If ZP0->(dbSeek(xFilial()+aEntradas[_I,3]))
			RecLock("ZP0",.F.)
			ZP0->ZP0_DINIPE := _aDados[_I,1]
			ZP0->ZP0_HINIPE := _aDados[_I,2]// subsTr( _aDados[_I,2],1,2) +":"+subsTr( _aDados[_I,2],3,2) // Quintais
			ZP0->ZP0_DFIMPE := _aDados[_I,3]
			ZP0->ZP0_HFIMPE := _aDados[_I,4]//subsTr( _aDados[_I,4],1,2)+":"+ subsTr( _aDados[_I,4],3,2) //Quintais
			ZP0->ZP0_TOTANI := _aDados[_I,5]
			ZP0->ZP0_ANIMOR := _aDados[_I,6]
			ZP0->ZP0_USRPEN := cUserName
			ZP0->(MsUnLock())
			ZP0->(dbSkip())
		EndIf
	Next _I

	If lExecSP
		_nRet := TCSPExec('MTECH_EAV_01')
		MsgStop(_nRet)
	Endif

	oDlg:End()
Return

Static Function bValDt()
	Local _lRet := .T.
	ZP0->(dbSetOrder(3))
	If ZP0->(dbSeek(xFilial()+DToS(dDtAbate)))
		aEntradas := {}
		_aDados := {}
		While !ZP0->(EOF()) .AND. ZP0->ZP0_FILIAL == xFilial("ZP0") .AND. ZP0->ZP0_DTABAT == dDtAbate
			aAdd(aEntradas,{ZP0->ZP0_DTPESB,ZP0->ZP0_PLACA,ZP0->ZP0_NENTR,ZP0->ZP0_TRANSP})
			aAdd(_aDados,{ZP0->ZP0_DINIPE,ZP0->ZP0_HINIPE,ZP0->ZP0_DFIMPE,ZP0->ZP0_HFIMPE,ZP0->ZP0_TOTANI,ZP0->ZP0_ANIMOR})
			ZP0->(dbSkip())
		EndDo

		dDtIniPen	:= _aDados[_nLinAnt,1]
		cHrIniPen	:= _aDados[_nLinAnt,2]
		dDtFimPen	:= _aDados[_nLinAnt,3]
		cHrFimPen	:= _aDados[_nLinAnt,4]
		nTotAnim	:= _aDados[_nLinAnt,5]
		nAnimMort	:= _aDados[_nLinAnt,6]

		oEntradas:SetArray(aEntradas)
		oEntradas:bLine := {|| {aEntradas[oEntradas:nAt,1],aEntradas[oEntradas:nAt,2],aEntradas[oEntradas:nAt,3],aEntradas[oEntradas:nAt,4]}}
		oEntradas:Refresh()
	Else
		_lRet := .F.
		MsgStop("Data de abate não localizada no arquivo de pesagens.")
	EndIf
Return(_lRet)

Static Function bMudaLinha()
	_aDados[_nLinAnt,1] := dDtIniPen
	_aDados[_nLinAnt,2] := cHrIniPen
	_aDados[_nLinAnt,3] := dDtFimPen
	_aDados[_nLinAnt,4] := cHrFimPen
	_aDados[_nLinAnt,5] := nTotAnim
	_aDados[_nLinAnt,6] := nAnimMort
	_nLinAnt	:= oEntradas:nAt
	dDtIniPen	:= _aDados[_nLinAnt,1]
	cHrIniPen	:= _aDados[_nLinAnt,2]
	dDtFimPen	:= _aDados[_nLinAnt,3]
	cHrFimPen	:= _aDados[_nLinAnt,4]
	nTotAnim	:= _aDados[_nLinAnt,5]
	nAnimMort	:= _aDados[_nLinAnt,6]
	oDtIniPen:Refresh()
	oHrIniPen:Refresh()
	oDtFimPen:Refresh()
	oHrFimPen:Refresh()
	oTotAnim:Refresh()
	oAnimMort:Refresh()
Return

/*
Tratamento para Ano e Data
*/
Static Function fValDat(_cCampo, _tp)

	Local lRet		:= .T.

	if Substr( DTOS(dDatabase),1,4) <> Substr ( DTOS(_cCampo),1,4) //20180101
		MsgStop("Ano é diferente do Ano atual!")
		Return .F.
	Endif

	If _tp == 1 .AND. !_cCampo >= dDtAbate 
		MsgStop("Data inicio Pendura incorreto, a data não pode ser menor que a data do abate!")
		Return .F.
	Endif

	If _tp == 2 .AND. !_cCampo >= dDtIniPen 
		MsgStop("Data fim da Pendura não pode ser menor que a data Inicio!")
		Return .F.
	Endif

Return lRet

/*
Tratamento de horas
*/
Static Function fValHor(_cCampo)

	Local lRet		:= .T.
	Local _cHora	:= Iif(At(':',_cCampo) > 0, SubStr(_cCampo,1,2) + SubStr(_cCampo,4,2),_cCampo)

	For x:=1 To Len(AllTrim(_cHora))
		If !SubStr(AllTrim(_cHora),x,1) $ "0123456789" .And. x <= Len(AllTrim(_cHora)) 
			MsgStop("Existem caractres que nao sao numericos na hora digitada. Caracter: ["+SubStr(_cHora,x,1)+"] Hora Digitada: "+_cHora)
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