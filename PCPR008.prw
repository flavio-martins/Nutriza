#include 'protheus.ch'
#include 'parmtype.ch'

//RELATORIO DE DEMONSTRATIVO DE STATUS DE ETIQUETA -  CRIADO POR FLAVIO

USER FUNCTION PCPR008()

	PRIVATE OREPORT
	PRIVATE LF := CHR(13)+CHR(10)

	/*
	MV_PAR01 - Produto de
	MV_PAR02 - Produto até
	MV_PAR03 - Etiqueta de
	MV_PAR04 - Etiqueta até
	MV_PAR05 - Dt. Impres. de
	MV_PAR06 - Dt. Impres. até
	MV_PAR07 - Dt. Ativa. de
	MV_PAR08 - Dt. Ativa. Até
	MV_PAR09 - Status tipo
	*/

	PRIVATE MV_PAR01 := SPACE(TAMSX3('ZP1_CODPRO')[1])
	PRIVATE MV_PAR02 := REPL('Z',TAMSX3('ZP1_CODPRO')[1])
	PRIVATE MV_PAR03 := SPACE(TAMSX3('ZP1_CODETI')[1])
	PRIVATE MV_PAR04 := REPL('Z',TAMSX3('ZP1_CODETI')[1])
	PRIVATE MV_PAR05 := ctod("")
	PRIVATE MV_PAR06 := DATE()
	PRIVATE MV_PAR07 := ctod("")
	PRIVATE MV_PAR08 := DATE()
	PRIVATE MV_PAR09 := 1

	PARAMETROS()

	SET CENTURY OFF

	If ValType(MV_PAR09) == 'N'
		MV_PAR09 := "00"
	EndIf

	OREPORT := REPORTDEF()
	OREPORT:PRINTDIALOG()

	SET CENTURY ON

RETURN

STATIC FUNCTION REPORTDEF()
	PRIVATE OSECTION1

	OREPORT := TREPORT():NEW("PCPR008","STATUS DE ETIQUETA",/*{|OREPORT| PARAMETROS() }*/,{|OREPORT| PRINTREPORT(OREPORT)},"STATUS DE ETIQUETA")
	OREPORT:SETLANDSCAPE()

	OSECTION1 := TRSECTION():NEW(OREPORT,"STATUS DE ETIQUETA",{"QRY"},NIL , .F., .T.)
	//OSECTION1:

	A := TRCELL():NEW(OSECTION1,"A","QRY","Etiqueta"	,PESQPICT('ZP1','ZP1_CODETI')	,TAMSX3('ZP1_CODETI')[1]+4	)
	B := TRCELL():NEW(OSECTION1,"B","QRY","Cod."		,PESQPICT('ZP1','ZP1_CODPRO')	,TAMSX3('ZP1_CODPRO')[1]	)
	C := TRCELL():NEW(OSECTION1,"C","QRY","Produto"	,PESQPICT('SB1','B1_DESC')		,TAMSX3('B1_DESC')[1]		)
	D := TRCELL():NEW(OSECTION1,"D","QRY","Peso"		,PESQPICT('ZP1','ZP1_PESO')		,TAMSX3('ZP1_PESO')[1]		)
	E := TRCELL():NEW(OSECTION1,"E","QRY","Pallet"		,PESQPICT('ZP1','ZP1_PALETE')	,TAMSX3('ZP1_PALETE')[1]+4	)
	F := TRCELL():NEW(OSECTION1,"F","QRY","Cod."		,PESQPICT('ZPE','ZPE_CODIGO')	,TAMSX3('ZPE_CODIGO')[1]	)
	G := TRCELL():NEW(OSECTION1,"G","QRY","Status"		,PESQPICT('SX5','X5_DESCRI')	,TAMSX3('X5_DESCRI')[1]		)
	H := TRCELL():NEW(OSECTION1,"H","QRY","Data"		,PESQPICT('ZPE','ZPE_DATA')		,TAMSX3('ZPE_DATA')[1]		)
	I := TRCELL():NEW(OSECTION1,"I","QRY","Hora"		,PESQPICT('ZPE','ZPE_HORA')		,TAMSX3('ZP4_ENDWMS')[1]	)
	J := TRCELL():NEW(OSECTION1,"J","QRY","Usuário"	,PESQPICT('ZPE','ZPE_NOMUSE')	,TAMSX3('ZPE_NOMUSE')[1]	)
	//K := TRCELL():NEW(OSECTION1,"K","QRY","Historico"	,PESQPICT('ZPE','ZPE_HISTOR')	,TAMSX3('ZP4_ENDWMS')[1]	)

	A:SetAlign("Left")
	B:SetAlign("Left")
	C:SetAlign("Left")
	D:SetAlign("Left")
	E:SetAlign("Left")
	F:SetAlign("Left")
	G:SetAlign("Left")
	H:SetAlign("Left")
	I:SetAlign("Left")
	J:SetAlign("Left")
	//K:SetAlign("Left")

	OREPORT:SETTOTALINLINE(.F.)

RETURN OREPORT

STATIC FUNCTION PRINTREPORT(OREPORT)
	LOCAL OSECTION1 := OREPORT:SECTION(1)
	LOCAL NQTREG	:= 0
	LOCAL XALIAS	:= GETNEXTALIAS()


	_cQry := "	SELECT ZP1_CODETI, ZP1_CODPRO, B1_DESC, ZP1_PESO, ZP1_PALETE, ZP1_CODZPE, X5_DESCRI,  "+LF
	_cQry += "		CASE WHEN ZPE_DATA <> NULL THEN ZPE_DATA ELSE LOG_DATA END AS DATA,  "+LF
	_cQry += "		CASE WHEN ZPE_HORA <> NULL THEN ZPE_HORA ELSE LOG_HORA END AS HORA, "+LF
	_cQry += "		CASE WHEN ZPE_NOMUSE <> NULL THEN ZPE_NOMUSE ELSE LOG_NOMUSE END AS NOMUSE, "+LF
	_cQry += "		CASE WHEN ZPE_HISTOR <> NULL THEN ZPE_HISTOR ELSE LOG_HISTOR END AS HISTOR "+LF
	_cQry += "	FROM ZP1010 A "+LF
	_cQry += "		LEFT JOIN ZPE010 B ON  B.ZPE_CODETI = A.ZP1_CODETI AND B.ZPE_CODIGO = A.ZP1_CODZPE AND B.D_E_L_E_T_ <> '*' "+LF
	_cQry += "		LEFT JOIN SB1010 C ON  C.B1_COD = A.ZP1_CODPRO AND C.D_E_L_E_T_  <> '*' "+LF
	_cQry += "		LEFT JOIN SX5010 D ON  D.X5_TABELA = 'Z3' AND D.X5_CHAVE = A.ZP1_CODZPE AND D.D_E_L_E_T_  <> '*' "+LF
	_cQry += "		LEFT JOIN LOGPCP E ON  E.LOG_CODETI = A.ZP1_CODETI AND E.LOG_CODIGO = A.ZP1_CODZPE AND E.D_E_L_E_T_ <> '*' "+LF
	_cQry += "	WHERE ZP1_CODETI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+LF
	_cQry += "		AND A.ZP1_CODPRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+LF
	_cQry += "		AND A.ZP1_DTIMPR BETWEEN '"+dtos((MV_PAR05))+"' AND '"+dtos((MV_PAR06))+"' "+LF
	_cQry += "		AND A.ZP1_DTATIV BETWEEN '"+dtos(MV_PAR07)+"' AND '"+dtos(MV_PAR08)+"' "+LF
	_cQry += "		AND A.D_E_L_E_T_ <> '*' "+LF
	If MV_PAR09 # "00"
		_cQry += "		AND B.ZPE_CODIGO = '"+SubStr(MV_PAR09,1,2)+"' "+LF
	EndIf
	_cQry += "	ORDER BY ZP1_CODETI , ZPE_DATA,ZPE_HORA "+LF

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

		OSECTION1:CELL("A"):SETVALUE((XALIAS)->ZP1_CODETI)
		OSECTION1:CELL("B"):SETVALUE((XALIAS)->ZP1_CODPRO)
		OSECTION1:CELL("C"):SETVALUE((XALIAS)->B1_DESC)
		OSECTION1:CELL("D"):SETVALUE((XALIAS)->ZP1_PESO)
		OSECTION1:CELL("E"):SETVALUE((XALIAS)->ZP1_PALETE)
		OSECTION1:CELL("F"):SETVALUE((XALIAS)->ZP1_CODZPE)
		OSECTION1:CELL("G"):SETVALUE((XALIAS)->X5_DESCRI)
		OSECTION1:CELL("H"):SETVALUE(Dtoc(Stod((XALIAS)->DATA)))
		OSECTION1:CELL("I"):SETVALUE((XALIAS)->HORA)
		OSECTION1:CELL("J"):SETVALUE((XALIAS)->NOMUSE)
		//	OSECTION1:CELL("K"):SETVALUE((XALIAS)->HISTOR)

		OSECTION1:PRINTLINE()
		(XALIAS)->(DBSKIP())

	ENDDO

	(XALIAS)->(DBCLOSEAREA())

	OSECTION1:FINISH()

RETURN(.T.)

//PARAMETROS DO RELATÓRIO
STATIC FUNCTION PARAMETROS()

	LOCAL APARAM 	:= {}
	LOCAL ARET 		:= {}

	dbSelectArea("SX5")
	dbSetOrder(1)
	SX5->(dbSeek(xFilial("SX5")+"Z3"+"01"))
	cTbl := SX5->X5_TABELA
	aCombo := {}
	aadd(aCombo,"00 - Todos")
	Do While cTbl == SX5->X5_TABELA
		aadd(aCombo,Alltrim(SX5->X5_CHAVE)+" - "+Alltrim(SX5->X5_DESCRI))
		SX5->(dbSkip())
	EndDo

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

	AADD(APARAM,{1,"Produto de:"			,SPACE(TAMSX3('ZP1_CODPRO')[1])		,PESQPICT('ZP1', 'ZP1_CODPRO'),'.T.'	,"SB1",'.T.', 50, .F.})
	AADD(APARAM,{1,"Produto até:"			,REPL('Z',TAMSX3('ZP1_CODPRO')[1])	,PESQPICT('ZP1', 'ZP1_CODPRO'),'.T.'	,"SB1",'.T.', 50,	.F.})
	AADD(APARAM,{1,"Etiqueta de:"			,SPACE(TAMSX3('ZP1_CODETI')[1])		,PESQPICT('ZP1', 'ZP1_CODETI'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Etiqueta até:"			,REPL('Z',TAMSX3('ZP1_CODETI')[1])	,PESQPICT('ZP1', 'ZP1_CODETI'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Impres. de:"		,ctod("")							,PESQPICT('ZP4', 'ZP4_DTABER'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Impres. até:"		,DATE()	 							,PESQPICT('ZP4', 'ZP4_DTABER'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Ativa. de:"	    	,ctod("")							,PESQPICT('ZP4', 'ZP4_DTFECH'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Ativa. Até:"		,DATE()								,PESQPICT('ZP4', 'ZP4_DTFECH'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{2,"Staus tipo:"			,1									,aCombo		,150	,""	,.F.})

	IF !PARAMBOX(APARAM,"PARÂMETROS",@ARET)
		RETURN .F.
	ENDIF

RETURN .T.
