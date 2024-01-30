#include 'protheus.ch'
#include 'parmtype.ch'

//RELATORIO DE REMONTAGEM DE PALETE - CRIADO POR FLAVIO

USER FUNCTION PCPR007()

	PRIVATE OREPORT
	PRIVATE LF := CHR(13)+CHR(10)
	MV_PAR01 := date()
	MV_PAR02 := date()
	MV_PAR03 := "00:00:00"
	MV_PAR04 := "23:59:59"
	MV_PAR05 := SPACE(TAMSX3('ZP1_CODPRO')[1])
	MV_PAR06 := REPL('Z',TAMSX3('ZP1_CODPRO')[1])
	MV_PAR07 := SPACE(TAMSX3('ZP1_PALETE')[1])
	MV_PAR08 := REPL('Z',TAMSX3('ZP1_PALETE')[1])
	MV_PAR09 := 1
	MV_PAR10 := 1

	/*
	MV_PAR01 - Data de:
	MV_PAR02 - Data Até:
	MV_PAR03 - Hora de:
	MV_PAR04 - Hora Até:
	MV_PAR05 - Produto de:
	MV_PAR06 - Produto até:
	MV_PAR07 - Palete de:
	MV_PAR08 - Palete até:
	MV_PAR09 - Tipo de Pallet {"Normal","Picking","Ambos"}
	MV_PAR10 - Tipo de Relatório? {"Remontagem palete","Carregamento dia"}
	*/

	MV_PAR03 := '00:00:00'
	MV_PAR04 := '23:59:59'
	PARAMETROS()

	If valtype(MV_PAR09) # "N"
		If SubStr(MV_PAR09,1,1) == "N"
			MV_PAR09 := 1
		ElseIf SubStr(MV_PAR09,1,1) == "P"
			MV_PAR09 := 2
		Else
			MV_PAR09 := 3
		EndIf
	EndIF

	If valtype(MV_PAR10) # "N"
		If SubStr(MV_PAR10,1,1) == "R"
			MV_PAR10 := 1
		Else
			MV_PAR10 := 2
		EndIf
	EndIF

	set century off

	OREPORT := REPORTDEF()
	If MV_PAR10 = 1
		OREPORT:SetPortrait()
	EndIF
	OREPORT:PRINTDIALOG()
	set century on
RETURN

STATIC FUNCTION REPORTDEF()
	PRIVATE OSECTION1

	OREPORT := TREPORT():NEW("PCPR007",iif(MV_PAR10 = 2,"Carregamento Dia","Remontagem Palete (Produtos em Carregamento)"),/*{|OREPORT| PARAMETROS() }*/,{|OREPORT| PRINTREPORT(OREPORT)},iif(MV_PAR10 = 2,"Remontagem Palete (Produtos em Carregamento)","Remontagem Palete (Produtos em Carregamento)"))
	OREPORT:SETLANDSCAPE()

	OSECTION1 := TRSECTION():NEW(OREPORT,iif(MV_PAR10 = 2,"Carregamento Dia","Remontagem Palete"),{"QRY"},NIL , .F., .T.)
	//OSECTION1:
	If  MV_PAR10 = 2
		A := TRCELL():NEW(OSECTION1,"A","QRY","Etiq. Caixa"		,PESQPICT('ZP1','ZP1_CODETI')	,TAMSX3('ZP1_CODETI')[1]+4	)
	EndIF
	A1:= TRCELL():NEW(OSECTION1,"A1","QRY","Codigo"			,PESQPICT('SB1','B1_COD')		,TAMSX3('B1_COD')[1]		)
	B := TRCELL():NEW(OSECTION1,"B","QRY","Descrição"			,PESQPICT('SB1','B1_DESC')		,TAMSX3('B1_DESC')[1]		)

	If MV_PAR10 = 1
		//  D := TRCELL():NEW(OSECTION1,"D","QRY","Data Val."		,"@E"/*PESQPICT('ZP1','ZP1_DTVALI')*/	,TAMSX3('ZP1_DTVALI')[1]	)
		//	E := TRCELL():NEW(OSECTION1,"E","QRY","Tolerância"		,PESQPICT('SB1','B1_XTOLVEN')	,TAMSX3('B1_XTOLVEN')[1]	)
		//	F := TRCELL():NEW(OSECTION1,"F","QRY","Dias"			,"999"							,8							)
		//	G := TRCELL():NEW(OSECTION1,"G","QRY","Perc. Toler."	,"999.99%"						,10							)
		//	H := TRCELL():NEW(OSECTION1,"H","QRY","Vida Util"		,PESQPICT('SB1','B1_PRVALID')	,TAMSX3('B1_PRVALID')[1]	)
		I := TRCELL():NEW(OSECTION1,"I","QRY","Palete"			,PESQPICT('ZP1','ZP1_PALETE')	,TAMSX3('ZP1_PALETE')[1]+4	)
		I1:= TRCELL():NEW(OSECTION1,"I1","QRY","Armazém"			,PESQPICT('ZP1','ZP1_LOCAL')	,TAMSX3('ZP1_LOCAL')[1]+1	)	
		J := TRCELL():NEW(OSECTION1,"J","QRY","Tipo Pallet"	,"@!"							,8	)
		K := TRCELL():NEW(OSECTION1,"K","QRY","Total"			,"@R 9,999"	,5	)
		L := TRCELL():NEW(OSECTION1,"L","QRY","Peso."			,"@E 999,999.999"	,TAMSX3('ZP1_PESO')[1]	)
		L:SetAlign("Left")
	ElseIf MV_PAR10 = 2
		C := TRCELL():NEW(OSECTION1,"C","QRY","Data Prod."			,"@E"/*PESQPICT('ZP1','ZP1_DTPROD')*/	,TAMSX3('ZP1_DTPROD')[1]	)
		D := TRCELL():NEW(OSECTION1,"D","QRY","Carga"			,PESQPICT('DAK','DAK_COD')		,TAMSX3('DAK_COD')[1]+2		)
		E := TRCELL():NEW(OSECTION1,"E","QRY","Dt Fech."		,PESQPICT('DAK','DAK_XDTFEC')	,TAMSX3('DAK_XDTFEC')[1]		)
		F := TRCELL():NEW(OSECTION1,"F","QRY","Hr Fech."		,PESQPICT('DAK','DAK_XHRFEC')	,TAMSX3('DAK_XHRFEC')[1]		)
		G := TRCELL():NEW(OSECTION1,"G","QRY","Pedido"			,PESQPICT('ZP1','ZP1_PEDIDO')	,10	)
		H := TRCELL():NEW(OSECTION1,"H","QRY","Palete"			,PESQPICT('ZP1','ZP1_PALETE')	,TAMSX3('ZP1_PALETE')[1]+4	)
		I := TRCELL():NEW(OSECTION1,"I","QRY","Peso Caixa"		,PESQPICT('ZP1','ZP1_PESO')		,TAMSX3('ZP1_PESO')[1]		)
		J := TRCELL():NEW(OSECTION1,"J","QRY","Usuario Abr."	,PESQPICT('DAK','DAK_XUSABE')	,TAMSX3('DAK_XUSABE')[1]	)
		K := TRCELL():NEW(OSECTION1,"K","QRY","Usuario Fch."	,PESQPICT('DAK','DAK_XUSFEC')	,TAMSX3('DAK_XUSFEC')[1]	)
	EndIf


	A1:SetAlign("Left")
	B:SetAlign("Left")

	If MV_PAR10 = 2
		A:SetAlign("Left")
		C:SetAlign("Left")
		D:SetAlign("Left")
		E:SetAlign("Left")
		F:SetAlign("Left")
		G:SetAlign("Left")
		H:SetAlign("Left")
	Else
		I1:SetAlign("Left")
	EndIf
	I:SetAlign("Left")
	J:SetAlign("Left")
	K:SetAlign("Left")


	OREPORT:SETTOTALINLINE(.F.)

RETURN OREPORT

STATIC FUNCTION PRINTREPORT(OREPORT)
	LOCAL OSECTION1 := OREPORT:SECTION(1)
	LOCAL NQTREG	:= 0
	LOCAL XALIAS	:= GETNEXTALIAS()

	/*
	MV_PAR01 - Data de:
	MV_PAR02 - Data Até:
	MV_PAR03 - Hora de:
	MV_PAR04 - Hora Até:
	MV_PAR05 - Produto de:
	MV_PAR06 - Produto até:
	MV_PAR07 - Palete de:
	MV_PAR08 - Palete até:
	MV_PAR10 - Tipo de Relatório?
	*/


	If MV_PAR10 = 1
		_cQry := "	SELECT B1_COD, B1_DESC,  ZP1_PALETE, ZP4_CODEST, COUNT(ZP1_CODETI) AS TOTAL, SUM(ZP1_PESO) AS PESO, ZP1_LOCAL " +LF  ///ZP1_DTPROD, ZP1_DTVALI, B1_XTOLVEN, DATEDIFF(day,CONVERT(date, ZP1_DTPROD, 112),CONVERT(date, GETDATE(), 112)) AS DIAS, ((DATEDIFF(day,CONVERT(date, ZP1_DTPROD, 112),CONVERT(date, GETDATE(), 112))/B1_XTOLVEN)*100) AS PERC, B1_PRVALID,
	ElseIf MV_PAR10 = 2
		_cQry := "	SELECT ZP1_CODETI, B1_COD, B1_DESC, ZP1_DTPROD, ZP1_CODETI, DAK_XDTFEC, DAK_XHRFEC, DAK_COD, ZP1_PALETE, ZP1_PEDIDO, ZP1_PESO, DAK_XUSABE, DAK_XUSFEC " +LF
	EndIf

	_cQry += "		FROM "+RetSqlName("ZP1")+" A " +LF
	_cQry += "		INNER JOIN "+RetSqlName("SB1")+" B ON B.B1_COD = A.ZP1_CODPRO AND B.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		LEFT  JOIN "+RetSqlName("ZP4")+" C ON C.ZP4_PALETE = A.ZP1_PALETE AND C.D_E_L_E_T_ <> '*' " +LF

	If MV_PAR10 = 1
		_cQry += "		LEFT JOIN "+RetSqlName("ZZS")+" D ON D.ZZS_COD = C.ZP4_CODCLA AND D.D_E_L_E_T_ <> '*' " +LF
	ElseIf MV_PAR10 = 2
		_cQry += "		INNER JOIN "+RetSqlName("DAK")+" D ON D.DAK_COD = A.ZP1_CARGA AND D.D_E_L_E_T_ <> '*' " +LF
	EndIf
	_cQry += "	WHERE " +LF
	_cQry += "	B1_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +LF
	_cQry += "	AND ZP1_PALETE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +LF
	_cQry += "	AND ZP1_LOCAL = '10' " +LF
	_cQry += "	AND A.D_E_L_E_T_ <> '*' " +LF
	If MV_PAR10 = 2
		_cQry += "	AND DAK_XDTFEC BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' " +LF
		_cQry += "	AND DAK_XHRFEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " +LF
		_cQry += "	AND DAK_XSTEXP = 'F'  " +LF
		_cQry += "	AND ZP1_STATUS = '3'  " +LF
		_cQry += "	AND ZP1_CARGA <> ''	 " +LF

	ElseIf MV_PAR10 = 1
		/*1=Ativa;2=Em carga;3=Faturada;4=Bloqueada;5=Baixada Inventario;9=Suspensa*/
		_cQry += "	AND ZP1_CARGA  = ''	 " +LF
		_cQry += "	AND ZP1_STATUS in ('2','7','9') " +LF
		If MV_PAR09 = 1
			/*1=NORMAL;2=PIKING*/
			_cQry += "	AND ZP4_CODEST = '1' " +LF
		ElseIf MV_PAR09 = 2
			/*1=NORMAL;2=PIKING*/
			_cQry += "	AND ZP4_CODEST = '2' " +LF
		EndIF
		_cQry += "	GROUP BY B1_COD, B1_DESC,  ZP1_PALETE, ZP4_CODEST, ZP1_LOCAL " +LF
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
	cB1COD := ''
	WHILE !(XALIAS)->(EOF())

		OREPORT:INCMETER()

		IF OREPORT:CANCEL()
			EXIT
		ENDIF
		If MV_PAR10 = 2
			OSECTION1:CELL("A"):SETVALUE((XALIAS)->ZP1_CODETI)
		EndIF
		/*
		OSECTION1:CELL("A1"):SETVALUE(iif(cB1COD <> (XALIAS)->B1_COD,(XALIAS)->B1_COD,""))
		OSECTION1:CELL("B"):SETVALUE(iif(cB1COD <> (XALIAS)->B1_COD,(XALIAS)->B1_DESC,""))
		*/
		OSECTION1:CELL("A1"):SETVALUE((XALIAS)->B1_COD)
		OSECTION1:CELL("B"):SETVALUE((XALIAS)->B1_DESC)

		cB1COD := (XALIAS)->B1_COD
		If MV_PAR10 = 2
			OSECTION1:CELL("C"):SETVALUE(Dtoc(Stod((XALIAS)->ZP1_DTPROD)))
			OSECTION1:CELL("D"):SETVALUE(IIF(MV_PAR10 == 1,Dtoc(Stod((XALIAS)->ZP1_DTVALI)), (XALIAS)->DAK_COD))
			OSECTION1:CELL("E"):SETVALUE(Dtoc(Stod((XALIAS)->DAK_XDTFEC)))
			OSECTION1:CELL("F"):SETVALUE( (XALIAS)->DAK_XHRFEC )
			OSECTION1:CELL("G"):SETVALUE( (XALIAS)->ZP1_PEDIDO )
			OSECTION1:CELL("H"):SETVALUE( (XALIAS)->ZP1_PALETE )
		EndIf

		OSECTION1:CELL("I"):SETVALUE(IIF(MV_PAR10 == 1,(XALIAS)->ZP1_PALETE,(XALIAS)->ZP1_PESO ))
		If MV_PAR10 = 1
			OSECTION1:CELL("I1"):SETVALUE((XALIAS)->ZP1_LOCAL )
		EndIf
		OSECTION1:CELL("J"):SETVALUE(IIF(MV_PAR10 == 1, IIF((XALIAS)->ZP4_CODEST=='1',"nomal","picking"),(XALIAS)->DAK_XUSABE ))
		OSECTION1:CELL("K"):SETVALUE(IIF(MV_PAR10 == 1,(XALIAS)->TOTAL,(XALIAS)->DAK_XUSFEC))
		If MV_PAR10 = 1
			OSECTION1:CELL("L"):SETVALUE((XALIAS)->PESO)
		EndIf
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
	LOCAL aCombo	:= {"Remontagem palete","Carregamento dia"}
	LOCAL aCombo1	:= {"Normal","Picking","Ambos"}

	AADD(APARAM,{1,"Data de:"				,date()							,PESQPICT('ZP1', 'ZP1_DTPROD'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Data Até:"				,date()							,PESQPICT('ZP1', 'ZP1_DTPROD'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Hora de:"				,"00:00:00"							,"99:99:99"					   ,'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Hora Até:"				,"23:59:59"							,"99:99:99"					   ,'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Produto de:"			,SPACE(TAMSX3('ZP1_CODPRO')[1])		,PESQPICT('ZP1', 'ZP1_CODPRO'),'.T.'	,"SB1",'.T.', 50, .F.})
	AADD(APARAM,{1,"Produto até:"			,REPL('Z',TAMSX3('ZP1_CODPRO')[1])	,PESQPICT('ZP1', 'ZP1_CODPRO'),'.T.'	,"SB1",'.T.', 50,.F.})
	AADD(APARAM,{1,"Palete de:"				,SPACE(TAMSX3('ZP1_PALETE')[1])		,PESQPICT('ZP1', 'ZP1_PALETE'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Palete até:"			,REPL('Z',TAMSX3('ZP1_PALETE')[1])	,PESQPICT('ZP1', 'ZP1_PALETE'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{2,"Tipo de Pallet?"	    ,1									,aCombo1,50	,""	,.F.})
	AADD(APARAM,{2,"Tipo de Relatório?"	    ,1									,aCombo	,70	,""	,.F.})

	IF !PARAMBOX(APARAM,"PARÂMETROS",@ARET)
		RETURN .F.
	ENDIF

RETURN .T.
