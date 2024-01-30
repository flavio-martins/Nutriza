#include 'protheus.ch'
#include 'parmtype.ch'

//RELATORIO DE Carga Expedição - CRIADO POR FLAVIO

USER FUNCTION PCPR006()

	PRIVATE OREPORT
	PRIVATE LF := CHR(13)+CHR(10)

	MV_PAR01 := SPACE(TAMSX3('ZP1_DTPROD')[1])
	MV_PAR02 := "Etiqueta"

	PARAMETROS()  //FORÇA A EXIBIÇÃO DOS PARAMETROS EM TELA, ANTES DE ABRIR O RELATORIO

	OREPORT := REPORTDEF()
	OREPORT:PRINTDIALOG()

RETURN



STATIC FUNCTION REPORTDEF()
	PRIVATE OSECTION1

	//Ajuste pois o combo quando em inicialização, ele usa numerico.
	If ValType(MV_PAR02) == 'N'
		Iif(MV_PAR02=2,MV_PAR02:="Dt. Produção","Etiqueta")
	EndIf

	OREPORT := TREPORT():NEW("PCPR006","Carga Expedição",/*{|OREPORT| PARAMETROS() }*/,{|OREPORT| PRINTREPORT(OREPORT)},"Carga Expedição") //LIBERANDO COLOCA OS PARAMETROS NO BOTÃO DA JANELA

	//***** Orientação da página ****
	//OREPORT:SETLANDSCAPE()
	OREPORT:SetPortrait()
	//******************************

	OSECTION1 := TRSECTION():NEW(OREPORT,"Carga Expedição",{"QRY"},NIL , .F., .T.)

	A := TRCELL():NEW(OSECTION1,"A","QRY","Dt. Produc."		,PESQPICT('ZP1','ZP1_DTVALI')	,TAMSX3('ZP1_DTVALI')[1]	)
	If MV_PAR02 = "Etiqueta"
		B := TRCELL():NEW(OSECTION1,"B","QRY","Etiqueta"		,PESQPICT('ZP1','ZP1_CODETI')	,TAMSX3('ZP1_CODETI')[1]	)
	EndIF
	C := TRCELL():NEW(OSECTION1,"C","QRY","Dt. Validad."		,PESQPICT('ZP1','ZP1_DTVALI')	,TAMSX3('ZP1_DTVALI')[1]	)
	D := TRCELL():NEW(OSECTION1,"D","QRY","Cod. Produt."		,PESQPICT('ZP1','ZP1_CODPRO')	,TAMSX3('ZP1_CODPRO')[1]	)
	E := TRCELL():NEW(OSECTION1,"E","QRY","Descrição"			,PESQPICT('SB1','B1_DESC')		,TAMSX3('B1_DESC')[1]		)
	F := TRCELL():NEW(OSECTION1,"F","QRY","Peso"				,PESQPICT('ZP1','ZP1_PESO')		,TAMSX3('ZP1_PESO')[1]		)
	G := TRCELL():NEW(OSECTION1,"G","QRY","Carga"				,PESQPICT('ZP1','ZP1_CARGA')	,TAMSX3('ZP1_CARGA')[1]		)
	If MV_PAR02 = "Dt. Produção"
		H := TRCELL():NEW(OSECTION1,"H","QRY","Qtd. Caixas"	,PESQPICT('ZP1','ZP1_CARGA')	,15							)
	EndIF
	A:SetAlign("Left")
	If MV_PAR02 = "Etiqueta"
		B:SetAlign("Left")
	EndIF
	C:SetAlign("Left")
	D:SetAlign("Left")
	E:SetAlign("Left")
	F:SetAlign("Right")
	G:SetAlign("Left")
	If MV_PAR02 = "Dt. Produção"
		H:SetAlign("Right")
	EndIf

	OREPORT:SETTOTALINLINE(.F.)

RETURN OREPORT



STATIC FUNCTION PRINTREPORT(OREPORT)
	LOCAL OSECTION1 := OREPORT:SECTION(1)
	LOCAL NQTREG	:= 0
	LOCAL XALIAS	:= GETNEXTALIAS()

	If ValType(MV_PAR02) == 'N'
		Iif(MV_PAR02=2,MV_PAR02:="Dt. Produção","Etiqueta")
	EndIf

	_cQry := "	SELECT "+iif(MV_PAR02="Dt. Produção", "COUNT(ZP1_DTPROD) AS CAIXAS,","ZP1_CODETI,")+" ZP1_DTPROD, ZP1_DTVALI, ZP1_CODPRO, B1_DESC, ZP1_PESO, ZP1_CARGA  " +LF
	_cQry += "		FROM "+RetSqlName("ZP1")+" A " +LF
	_cQry += "		INNER JOIN "+RetSqlName("SB1")+" B ON B1_COD = A.ZP1_CODPRO AND B.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		WHERE A.ZP1_CARGA = '"+MV_PAR01+"' " +LF
	_cQry += "		AND A.D_E_L_E_T_ <> '*' " +LF
	_cQry := "	union " +LF
	_cQry := "	SELECT "+iif(MV_PAR02="Dt. Produção", "COUNT(ZP1_DTPROD) AS CAIXAS,","ZP1_CODETI,")+" ZP1_DTPROD, ZP1_DTVALI, ZP1_CODPRO, B1_DESC, ZP1_PESO, ZP1_CARGA  " +LF
	_cQry += "		FROM ZP1010_MORTO C " +LF
	_cQry += "		INNER JOIN "+RetSqlName("SB1")+" D ON B1_COD = C.ZP1_CODPRO AND D.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		WHERE C.ZP1_CARGA = '"+MV_PAR01+"' " +LF
	_cQry += "		AND C.D_E_L_E_T_ <> '*' " +LF
	If MV_PAR02 = "Etiqueta"
		_cQry += "  order by ZP1_CODETI " +LF
	Else
		_cQry += "  GROUP BY ZP1_DTPROD, ZP1_DTVALI, ZP1_CODPRO, B1_DESC, ZP1_PESO, ZP1_CARGA " +LF
		_cQry += "  order by ZP1_DTPROD " +LF
	EndIf

	MemoWrite("C:\Temp\"+AllTrim(Funname())+".Sql",_cQry)

	If Select(XALIAS) > 0
		(XALIAS)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),XALIAS,.F.,.T.)

	COUNT TO NQTREG
	(XALIAS)->(DBGOTOP())

	OREPORT:SETMETER(NQTREG)

	OSECTION1:INIT()

	WHILE !(XALIAS)->(EOF())

		OREPORT:INCMETER()

		IF OREPORT:CANCEL()
			EXIT
		ENDIF

		OSECTION1:CELL("A"):SETVALUE(DtoC(StoD((XALIAS)->ZP1_DTPROD)))
		If MV_PAR02 = "Etiqueta"
			OSECTION1:CELL("B"):SETVALUE((XALIAS)->ZP1_CODETI)
		EndIF
		OSECTION1:CELL("C"):SETVALUE(DtoC(StoD((XALIAS)->ZP1_DTVALI)))
		OSECTION1:CELL("D"):SETVALUE((XALIAS)->ZP1_CODPRO)
		OSECTION1:CELL("E"):SETVALUE((XALIAS)->B1_DESC)
		OSECTION1:CELL("F"):SETVALUE((XALIAS)->ZP1_PESO)
		OSECTION1:CELL("G"):SETVALUE((XALIAS)->ZP1_CARGA)
		If MV_PAR02 = "Dt. Produção"
			OSECTION1:CELL("H"):SETVALUE((XALIAS)->CAIXAS)
		EndIF

		OSECTION1:PRINTLINE()
		(XALIAS)->(DBSKIP())

	ENDDO

	(XALIAS)->(DBCLOSEAREA())

	OSECTION1:FINISH()

RETURN(.T.)

//PARAMETROS DO RELATÓRIO
STATIC FUNCTION PARAMETROS()
	//aAdd(aParamBox,{1,"Data"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	// Tipo 1 -> MsGet()
	//           [2]-Descricao
	//           [3]-String contendo o inicializador do campo
	//           [4]-String contendo a Picture do campo
	//           [5]-String contendo a validacao
	//           [6]-Consulta F3
	//           [7]-String contendo a validacao When
	//           [8]-Tamanho do MsGet
	//           [9]-Flag .T./.F. Parametro Obrigatorio ?

	//aAdd(aParamBox,{2,"Informe o mês",1,aCombo,50,"",.F.})
	// Tipo 2 -> Combo
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do combo
	//           [4]-Array contendo as opcoes do Combo
	//           [5]-Tamanho do Combo
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	// Cuidado, há um problema nesta opção quando selecionado a 1ª opção.

	LOCAL APARAM 	:= {}
	LOCAL ARET 		:= {}
	LOCAL aCombo	:= {"Etiqueta","Dt. Produção"}

	AADD(APARAM,{1,"Carga:"				,SPACE(TAMSX3('ZP1_CARGA')[1])		,PESQPICT('ZP1', 'ZP1_CARGA'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{2,"Ordenar?"			,2,aCombo,50,"",.F.})

	IF !PARAMBOX(APARAM,"PARÂMETROS",@ARET)
		RETURN .F.
	ENDIF

RETURN .T.
