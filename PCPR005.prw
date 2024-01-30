#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"

//RELATORIO DE DEMONSTRATIVO DE STATUS DE PALETE - CRIADO POR FLAVIO
//MV_PCPEML ---> Parametro para colocar o e-mail que vai receber o relatorio

USER FUNCTION PCPR005(lSched)

	PRIVATE OREPORT
	PRIVATE __cArquivo
	PRIVATE COUNT
	PRIVATE XALIAS	:= GETNEXTALIAS()
	PRIVATE LF := CHR(13)+CHR(10)
	PRIVATE dados64 := {}
	PRIVATE dados65 := {}
	PRIVATE dados21 := {} 
	PRIVATE oProcess
	Private lSched  := lSched

	If ValType(lSched) == "U"
		lSched  := .F.
	EndIF
	/*
	MV_PAR01 - Produto de:
	MV_PAR02 - Produto até:
	MV_PAR03 - Endereço de:
	MV_PAR04 - Endereço até:
	MV_PAR05 - Apenas não carregados?
	MV_PAR06 - Apenas com Status?
	MV_PAR07 - Dt. Abert. de:
	MV_PAR08 - Dt. Abert. até:
	MV_PAR09 - Consd. Dt./Hr.Fecham.?
	MV_PAR10 - Dt. Fechm. de:
	MV_PAR11 - Dt. Fechm. Até:
	MV_PAR12 - Hr. Fechm. de:
	MV_PAR13 - Hr. Fechm. Aé:
	MV_PAR14 - Palete de:
	MV_PAR15 - Palete até:
	*/

	MV_PAR01 := SPACE(TAMSX3('ZP4_PRODUT')[1])
	MV_PAR02 := REPL('Z',TAMSX3('ZP4_PRODUT')[1])
	MV_PAR03 := SPACE(TAMSX3('ZP4_ENDWMS')[1])
	MV_PAR04 := REPL('Z',TAMSX3('ZP4_ENDWMS')[1])
	MV_PAR05 := "Sim"
	MV_PAR06 := "Todos"
	MV_PAR07 := Ctod("01/01/2017")
	MV_PAR08 := ddatabase
	MV_PAR09 := "Não"
	MV_PAR10 := Ctod(Space(8))
	MV_PAR11 := ddatabase
	MV_PAR12 := "05:00:00"
	MV_PAR13 := "04:59:59"
	MV_PAR14 := SPACE(TAMSX3('ZP4_PALETE')[1])
	MV_PAR15 := REPL('Z',TAMSX3('ZP4_PALETE')[1])

	If lSched
		//	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101' USER 'Administrador' PASSWORD '' TABLES 'ZP4,SB1,ZP1,ZZS' MODULO "PCP"
		FAZCSV(lSched)
		//	RESET ENVIRONMENT
	Else
		If MSGYESNO("Você deseja gerar a planilha Excel?","Friato")
			//		MsgRun ( "Criando a planilha de Excel."+chr(13)+chr(10)+"Por Favor, aguarde...","Frito", FAZCSV(lSched) )		
			//		FWMsgRun(, FAZCSV(lSched) , "Friato", "Criando a planilha de Excel."+chr(13)+chr(10)+"Por Favor, aguarde...")
			FAZCSV(lSched)
		Else
			PARAMETROS()
			OREPORT := REPORTDEF()
			OREPORT:PRINTDIALOG()
		EndIF
	EndIF

RETURN

STATIC FUNCTION FAZCSV(lSched)

	LOCAL NQTREG	:= 0

	If ValType(MV_PAR05) == 'N'
		Iif(MV_PAR05=1,MV_PAR05:="Sim",MV_PAR05:="Não")
	EndIf
	If ValType(MV_PAR09) == 'N'
		Iif(MV_PAR09=2,MV_PAR09:="Não",MV_PAR09:="Sim")
	EndIf
	If ValType(MV_PAR06) == 'N'
		Iif(MV_PAR06=6,MV_PAR06:="Todos",nil)
	EndIf

	//ZP4_STATUS --> M=Montando;S=Suspenso;F=Fechado;C=Carregado;E=Expedido
	/*
	MV_PAR01 - Produto de:
	MV_PAR02 - Produto até:
	MV_PAR03 - Endereço de:
	MV_PAR04 - Endereço até:
	MV_PAR05 - Apenas não carregados?
	MV_PAR06 - Apenas com Status?
	MV_PAR07 - Dt. Abert. de:
	MV_PAR08 - Dt. Abert. até:
	MV_PAR09 - Consd. Dt./Hr.Fecham.?
	MV_PAR10 - Dt. Fechm. de:
	MV_PAR11 - Dt. Fechm. Até:
	MV_PAR12 - Hr. Fechm. de:
	MV_PAR13 - Hr. Fechm. Aé:
	MV_PAR14 - Palete de:
	MV_PAR15 - Palete até:
	*/
	_cQry := "	SELECT ZP4_PALETE, ZP1_DTPROD, ZP4_DTFECH, ZP4_HRFECH, ZP4_USFECH, ZP4_PRODUT, B1_DESC, ZP4_STATUS, ZP1_STATUS,  ZP4_ENDWMS, ZP4_CARGA, ZZS_DESCRI, COUNT(ZP1_CODPRO) AS QTD, SUM(ZP1_PESO) AS PESO, ZP4_CODEST, ZP1_LOCAL " +LF
	_cQry += "		FROM "+RetSqlName("ZP4")+" A " +LF
	_cQry += "		INNER JOIN "+RetSqlName("SB1")+" B ON B1_COD = ZP4_PRODUT AND B.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		INNER JOIN "+RetSqlName("ZP1")+" C ON ZP1_PALETE = ZP4_PALETE AND  C.D_E_L_E_T_ <> '*' AND ZP1_STATUS NOT IN ('',' ','3') " +LF
	_cQry += "		LEFT  JOIN "+RetSqlName("ZZS")+" D ON ZZS_COD = ZP4_CODCLA  AND D.D_E_L_E_T_ <> '*'  " +LF
	_cQry += "		WHERE ZP4_PALETE BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' " +LF
	_cQry += "		AND ZP4_DTABER BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' " +LF

	If MV_PAR09 == "Sim"
		_cQry += "		AND ZP4_DTFECH BETWEEN '"+DtoS(MV_PAR10)+"' AND '"+DtoS(MV_PAR11)+"' " +LF
		_cQry += "		AND ZP4_HRFECH BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' " +LF
	ElseIf MV_PAR09 == "Abertos"
		_cQry += "		AND ZP4_DTFECH = '' " +LF
	EndIF
	If MV_PAR05 == "Sim"
		_cQry += "		AND ZP4_CARGA = '' " +LF
	EndIf
	_cQry += "		AND ZP4_ENDWMS BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " +LF
	_cQry += "		AND ZP4_PRODUT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +LF
	Do Case
		Case MV_PAR06 = "Montando"
		_cQry += "		AND ZP4_STATUS = 'M' " +LF
		Case MV_PAR06 = "Suspenso"
		_cQry += "		AND ZP4_STATUS = 'S' " +LF
		Case MV_PAR06 = "Fechado"
		_cQry += "		AND ZP4_STATUS = 'F' " +LF
		Case MV_PAR06 = "Carregado"
		_cQry += "		AND ZP4_STATUS = 'C' " +LF
		Case MV_PAR06 = "Expedido"
		_cQry += "		AND ZP4_STATUS = 'E' " +LF
	EndCase

	_cQry += "		AND A.D_E_L_E_T_ <> '*' " +LF
	_cQry += "	GROUP BY ZP4_PALETE, ZP1_DTPROD, ZP4_PRODUT, B1_DESC, ZP4_STATUS, ZP1_STATUS, ZP4_USABER, ZP4_DTABER, ZP4_HRABER, ZP4_USFECH, ZP4_DTFECH, ZP4_HRFECH, ZP4_ENDWMS, ZP4_CARGA, ZZS_DESCRI, ZP4_CODEST, ZP1_LOCAL " +LF

	MemoWrite("C:\Temp\"+AllTrim(Funname())+".Sql",_cQry)

	If Select(XALIAS) > 0
		(XALIAS)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),XALIAS,.F.,.T.)

	COUNT TO NQTREG
	(XALIAS)->(DBGOTOP())

	If lSched
		fMontaCSV(NQTREG, lSched)
	Else
		oProcess:=MsNewProcess():New( { || fMontaCSV(NQTREG, lSched) } , "Gerando Relatorio " , "Aguarde..." , .F. )
		oProcess:Activate()
	EndIF
Return


Static Function fMontaCSV(NQTREG,lSched)
	LOCAL __cArquivo	:= "\PCPR005-"+LogUserName()+".CSV"
	LOCAL TBLAUX		:= GETNEXTALIAS()
	LOCAL nHandle		:= FCREATE(__cArquivo) //FWTimeStamp(1,,)
	//Endereçamento
	DATA64 := ""
	HORA64 := ""
	USER64 := ""
	//Desendereçamento
	DATA65 := ""
	HORA65 := ""
	USER65 := ""
	//Carregamento
	DATA21 := ""
	HORA21 := ""
	USER21 := ""
	If nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else
		IF !lSched
			oProcess:SetRegua1(NQTREG)
		EndIf
		FWrite(nHandle,"Código;Produto;Palete;Dt Produção; Dt Peletiz.; Hr Paletz.;	Status Pallet;Status Caixa;Usuár. Fechou;Dt. Ender.;Hr. Ender.;Dt. Desender..;Hr. Desender.;Usr. Desender.;Dt.Carreg.; Hr.Carreg.;Caixas;Peso;Endereço;Carga;Classificação;Tipo;Armazém" +LF)
		WHILE !(XALIAS)->(EOF())
			IF !lSched
				oProcess:IncRegua1(OemToAnsi("Estruturando arquivo texto..."))
			EndIF
			//ZP4_STATUS --> M=Montando;S=Suspenso;F=Fechado;C=Carregado;E=Expedido
			Do Case
				Case (XALIAS)->ZP4_STATUS == 'M'
				_cStatus := "Montando"
				Case (XALIAS)->ZP4_STATUS == 'S'
				_cStatus := "Suspenso"
				Case (XALIAS)->ZP4_STATUS == 'F'
				_cStatus := "Fechado"
				Case (XALIAS)->ZP4_STATUS == 'C'
				_cStatus := "Carregando"
				Case (XALIAS)->ZP4_STATUS == 'E'
				_cStatus := "Expedido"
				Otherwise
				_cStatus := "- x -"
			EndCase

			Do Case
				Case (XALIAS)->ZP1_STATUS == '1'
				_cStatcx := "Ativa"
				Case (XALIAS)->ZP1_STATUS == '2'
				_cStatcx := "Em carregamento"
				Case (XALIAS)->ZP1_STATUS == '3'
				_cStatcx := "Carregado"
				Case (XALIAS)->ZP1_STATUS == '4'
				_cStatcx := "Bloqueado"
				Case (XALIAS)->ZP1_STATUS == '5'
				_cStatcx := "Baixado em inventário"
				Case (XALIAS)->ZP1_STATUS == '7'
				_cStatcx := "Suspenso (qualidade)"
				Case (XALIAS)->ZP1_STATUS == '9'
				_cStatcx := "Suspenso (padrão)"
				Otherwise
				_cStatcx := "- x -"
			EndCase

			Do Case
				Case (XALIAS)->ZP4_CODEST == '1'
				_cTipoP := "Normal"
				Case (XALIAS)->ZP4_CODEST == '2'
				_cTipoP := "Picking"
				Otherwise
				_cTipoP := "- x -"
			EndCase

			//64 - ENDEREÇAMENTO

			_cQry := "	SELECT LOG_DATA AS DATA, LOG_HORA AS HORA, LOG_NOMUSE AS NOMUSE, LOG_DATA + LOG_HORA AS ORD FROM LOGPCP  E WHERE E.LOG_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.LOG_CODIGO = '64' " +LF
			_cQry += "	union " +LF
			_cQry += "	SELECT ZPE_DATA AS DATA, ZPE_HORA AS HORA, ZPE_NOMUSE AS NOMUSE, ZPE_DATA + ZPE_HORA AS ORD FROM ZPE010  E WHERE E.ZPE_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.ZPE_CODIGO = '64' " +LF
			_cQry += "	 ORDER BY ORD " +LF

			If Select(TBLAUX) > 0
				(TBLAUX)->(dbCloseArea())
			Endif

			dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),TBLAUX,.F.,.T.)

			Do while (TBLAUX)->(!EOF())
				aadd(dados64,{ (TBLAUX)->(DATA), (TBLAUX)->(HORA), (TBLAUX)->(NOMUSE) })
				(TBLAUX)->(DBSKIP())
			EndDo
			if len(dados64) <= 0
				dados64 := { {'','',''} }
			EndIF
			/*
			aSort(dados64,,, { |x,y| x[2] < y[2] })
			aSort(dados64,,, { |x,y| x[1] < y[1] })
			*/
			DATA64 := dados64[1][1]
			HORA64 := dados64[1][2]
			USER64 := dados64[1][3]

			//65 - DESENDEREÇAMETNO

			_cQry := "	SELECT LOG_DATA AS DATA, LOG_HORA AS HORA, LOG_NOMUSE AS NOMUSE, LOG_DATA + LOG_HORA AS ORD FROM LOGPCP  E WHERE E.LOG_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.LOG_CODIGO = '65' " +LF
			_cQry += "	union " +LF
			_cQry += "	SELECT ZPE_DATA AS DATA, ZPE_HORA AS HORA, ZPE_NOMUSE AS NOMUSE, ZPE_DATA + ZPE_HORA AS ORD FROM ZPE010  E WHERE E.ZPE_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.ZPE_CODIGO = '65' " +LF
			_cQry += "	ORDER BY ORD DESC " +LF

			If Select(TBLAUX) > 0
				(TBLAUX)->(dbCloseArea())
			Endif

			dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),TBLAUX,.F.,.T.)

			Do while (TBLAUX)->(!EOF())
				aadd(dados65,{ (TBLAUX)->(DATA), (TBLAUX)->(HORA), (TBLAUX)->(NOMUSE) })
				(TBLAUX)->(DBSKIP())
			EndDo
			if len(dados65) <= 0
				dados65 := { {'','',''} }
			EndIF
			/*
			aSort(dados65,,, { |x,y| x[1] > y[1] })
			aSort(dados65,,, { |x,y| x[2] > y[2] })		
			*/
			DATA65 := dados65[1][1]
			HORA65 := dados65[1][2]
			USER65 := dados65[1][3]

			// 21-22-27 - CARREGAMENTO

			_cQry := "	SELECT LOG_DATA AS DATA, LOG_HORA AS HORA, LOG_NOMUSE AS NOMUSE, LOG_DATA + LOG_HORA AS ORD  FROM LOGPCP  E WHERE E.LOG_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.LOG_CODIGO = '21' " +LF
			_cQry += "	union " +LF
			_cQry += "	SELECT ZPE_DATA AS DATA, ZPE_HORA AS HORA, ZPE_NOMUSE AS NOMUSE, ZPE_DATA + ZPE_HORA AS ORD FROM ZPE010  E WHERE E.ZPE_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.ZPE_CODIGO = '21' " +LF
			_cQry += "	UNION " +LF
			_cQry += "	SELECT LOG_DATA AS DATA, LOG_HORA AS HORA, LOG_NOMUSE AS NOMUSE, LOG_DATA + LOG_HORA AS ORD  FROM LOGPCP  E WHERE E.LOG_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.LOG_CODIGO = '22' " +LF
			_cQry += "	union " +LF
			_cQry += "	SELECT ZPE_DATA AS DATA, ZPE_HORA AS HORA, ZPE_NOMUSE AS NOMUSE, ZPE_DATA + ZPE_HORA AS ORD FROM ZPE010  E WHERE E.ZPE_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.ZPE_CODIGO = '22' " +LF
			_cQry += "	UNION
			_cQry += "	SELECT LOG_DATA AS DATA, LOG_HORA AS HORA, LOG_NOMUSE AS NOMUSE, LOG_DATA + LOG_HORA AS ORD  FROM LOGPCP  E WHERE E.LOG_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.LOG_CODIGO = '27' " +LF
			_cQry += "	union
			_cQry += "	SELECT ZPE_DATA AS DATA, ZPE_HORA AS HORA, ZPE_NOMUSE AS NOMUSE, ZPE_DATA + ZPE_HORA AS ORD FROM ZPE010  E WHERE E.ZPE_CODETI = '"+(XALIAS)->ZP4_PALETE+"' AND E.ZPE_CODIGO = '27' " +LF
			_cQry += "	ORDER BY ORD DESC " +LF

			If Select(TBLAUX) > 0
				(TBLAUX)->(dbCloseArea())
			Endif

			dbUseArea(.T.,"TopConn",TCGenQry(,,_cQry),TBLAUX,.F.,.T.)

			Do while (TBLAUX)->(!EOF())
				aadd(dados21,{ (TBLAUX)->(DATA), (TBLAUX)->(HORA), (TBLAUX)->(NOMUSE) })
				(TBLAUX)->(DBSKIP())
			EndDo
			if len(dados21) <= 0
				dados21 :={ {'','',''} }
			EndIF
			/*
			aSort(dados21,,, { |x,y| x[1] > y[1] })
			aSort(dados21,,, { |x,y| x[2] > y[2] })		
			*/
			DATA21 := dados21[1][1]
			HORA21 := dados21[1][2]
			USER21 := dados21[1][3]

			FWrite(nHandle,"'"+(XALIAS)->ZP4_PRODUT+";"+(XALIAS)->B1_DESC+";'"+(XALIAS)->ZP4_PALETE+";"+Dtoc(Stod((XALIAS)->ZP1_DTPROD))+;
			";"+Dtoc(Stod((XALIAS)->ZP4_DTFECH))+";"+(XALIAS)->ZP4_HRFECH+";"+_cStatus+";"+_cStatcx+";"+(XALIAS)->ZP4_USFECH+;
			";"+Dtoc(Stod(DATA64))+";"+HORA64+";"+Dtoc(Stod(DATA65))+";"+HORA65+";"+USER65+";"+Dtoc(Stod(DATA21))+;
			";"+HORA21+";"+Transform((XALIAS)->QTD,"@E 9,999.99")+";"+Transform((XALIAS)->PESO,"@E 9,999.99")+";"+(XALIAS)->ZP4_ENDWMS+;
			";"+(XALIAS)->ZP4_CARGA+";"+(XALIAS)->ZZS_DESCRI+";"+_cTipoP+";"+(XALIAS)->ZP1_LOCAL +LF)


			(XALIAS)->(DBSKIP())
			DATA64 := ""
			HORA64 := ""
			USER64 := ""
			dados64:={}
			DATA65 := ""
			HORA65 := ""
			USER65 := ""
			dados65:={}
			DATA21 := ""
			HORA21 := ""
			USER21 := ""
			dados21:={}
		ENDDO
		FClose(nHandle)
	EndIF
	(XALIAS)->(DBCLOSEAREA())
	If lSched
		EnvMail()
	Else
		If CpyS2T(__cArquivo, "C:\TEMP" )
			MsgInfo("Arquivo copiado com sucesso para C:\TEMP"+__cArquivo,"Concluído!")
			//WaitRun("excel c:\temp\pcpr005.csv", 3 )
			shellExecute("Open", "c:\temp"+__cArquivo, " ", "C:\temp\", 3 )
		Else
			MsgStop("Ocorreu algum erro ao copiar o arquivo do server para o terminal","Friato")
		EndIF
	EndIf
	//Send Mail - Envio de e-mail - conexão SMTPFROM <cFrom>TO <aTo,...> [ CC <aCC,...> ] [ BCC <aCC,...> ]SUBJECT<cSubject>BODY <cBody> [ FORMAT TEXT ] [ ATTACHMENT <aFiles,...> ] [ IN SERVER <oRpcSrv> ] [ RESULT <lResult> ]

	//msgAlert("Relatório criado em: "+"c:\temp\PCPR005.CSV")
RETURN


STATIC FUNCTION REPORTDEF()
	PRIVATE OSECTION1

	OREPORT := TREPORT():NEW("PCPR005","Demonstrativo Paletes",/*{;OREPORT; PARAMETROS() }*/,{|OREPORT| PRINTREPORT(OREPORT)},"Demonstrativo Paletes")
	OREPORT:SETLANDSCAPE()

	OSECTION1 := TRSECTION():NEW(OREPORT,"Demonstrativo Paletes",{"QRY"},NIL , .F., .T.)
	//OSECTION1:

	A := TRCELL():NEW(OSECTION1,"A","QRY","Palete"				,PESQPICT('ZP4','ZP4_PALETE')	,39							)
	B := TRCELL():NEW(OSECTION1,"B","QRY","Data"				,								,30							)
	B1:= TRCELL():NEW(OSECTION1,"B1","QRY","Código"			,								,30							)
	C := TRCELL():NEW(OSECTION1,"C","QRY","Produto"			,PESQPICT('SB1','B1_DESC')		,TAMSX3('B1_DESC')[1]		)
	D := TRCELL():NEW(OSECTION1,"D","QRY","Status Pallet"		,"@!"							,40							)
	D1:= TRCELL():NEW(OSECTION1,"D1","QRY","Status Caixa"		,"@!"							,40							)
	E := TRCELL():NEW(OSECTION1,"E","QRY","Usuár. Abert."		,"@!"							,45							)

	//F := TRCELL():NEW(OSECTION1,"F","QRY","Dt. Ender."		,								,40							)
	//F1:= TRCELL():NEW(OSECTION1,"F1","QRY","Hr. Ender."		,								,40							)
	//G := TRCELL():NEW(OSECTION1,"G","QRY","Dt. Entr. Exp."	,								,45							)
	//H := TRCELL():NEW(OSECTION1,"H","QRY","Hr. Entr. Exp."	,								,40							)
	//H0:= TRCELL():NEW(OSECTION1,"H1","QRY","Dt. Carreg."		,								,40							)
	//H1:= TRCELL():NEW(OSECTION1,"H1","QRY","Hr. Carreg."		,								,40							)

	H2:= TRCELL():NEW(OSECTION1,"H2","QRY","Caixas"			,								,30							)
	H3:= TRCELL():NEW(OSECTION1,"H3","QRY","Peso"				,								,30							)
	I := TRCELL():NEW(OSECTION1,"I","QRY","Endereço"			,PESQPICT('ZP4','ZP4_ENDWMS')	,TAMSX3('ZP4_ENDWMS')[1]	)
	J := TRCELL():NEW(OSECTION1,"J","QRY","Carga"				,PESQPICT('ZP4','ZP4_CARGA')	,TAMSX3('ZP4_CARGA')[1]	)
	K := TRCELL():NEW(OSECTION1,"K","QRY","Classificação"		,PESQPICT('ZP4','ZP4_CARGA')	,TAMSX3('ZP4_CARGA')[1]	)
	L := TRCELL():NEW(OSECTION1,"L","QRY","Tipo"				,"@!"							,40							)
	M := TRCELL():NEW(OSECTION1,"M","QRY","Armazém"			,"@!"							,8							)


	A:SetAlign("Left")
	B:SetAlign("Left")
	B1:SetAlign("Left")
	C:SetAlign("Left")
	D:SetAlign("Left")
	D1:SetAlign("Left")
	E:SetAlign("Left")
	//F:SetAlign("Left")
	//F1:SetAlign("Left")
	//G:SetAlign("Left")
	//H:SetAlign("Left")
	//H0:SetAlign("Left")
	//H1:SetAlign("Left")
	H2:SetAlign("Left")
	H3:SetAlign("Left")
	I:SetAlign("Left")
	J:SetAlign("Left")
	K:SetAlign("Left")
	L:SetAlign("Left")
	M:SetAlign("Left")

	OREPORT:SETTOTALINLINE(.F.)

RETURN OREPORT

STATIC FUNCTION PRINTREPORT(OREPORT)
	LOCAL OSECTION1 := OREPORT:SECTION(1)
	LOCAL NQTREG	:= 0
	LOCAL XALIAS	:= GETNEXTALIAS()

	If ValType(MV_PAR05) == 'N'
		Iif(MV_PAR05=1,MV_PAR05:="Sim",MV_PAR05:="Não")
	EndIf
	If ValType(MV_PAR09) == 'N'
		Iif(MV_PAR09=2,MV_PAR09:="Não",MV_PAR09:="Sim")
	EndIf
	If ValType(MV_PAR06) == 'N'
		Iif(MV_PAR06=6,MV_PAR06:="Todos",nil)
	EndIf

	//ZP4_STATUS --> M=Montando;S=Suspenso;F=Fechado;C=Carregado;E=Expedido
	/*
	MV_PAR01 - Produto de:
	MV_PAR02 - Produto até:
	MV_PAR03 - Endereço de:
	MV_PAR04 - Endereço até:
	MV_PAR05 - Apenas não carregados?
	MV_PAR06 - Apenas com Status?
	MV_PAR07 - Dt. Abert. de:
	MV_PAR08 - Dt. Abert. até:
	MV_PAR09 - Consd. Dt./Hr.Fecham.?
	MV_PAR10 - Dt. Fechm. de:
	MV_PAR11 - Dt. Fechm. Até:
	MV_PAR12 - Hr. Fechm. de:
	MV_PAR13 - Hr. Fechm. Aé:
	MV_PAR14 - Palete de:
	MV_PAR15 - Palete até:
	*/
	_cQry := "	SELECT ZP4_PALETE, ZP4_DATA, ZP4_PRODUT, B1_DESC, ZP4_STATUS, ZP1_STATUS, ZP4_USABER, ZP4_DTABER, ZP4_HRABER, ZP4_USFECH, ZP4_DTFECH, ZP4_HRFECH, ZP4_ENDWMS, ZP4_CARGA, ZZS_DESCRI, COUNT(ZP1_CODPRO) AS QTD, SUM(ZP1_PESO) AS PESO, ZP4_CODEST, ZP1_LOCAL " +LF
	_cQry += "		FROM "+RetSqlName("ZP4")+" A " +LF
	_cQry += "		INNER JOIN "+RetSqlName("SB1")+" B ON B1_COD = ZP4_PRODUT AND B.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		INNER JOIN "+RetSqlName("ZP1")+" C ON ZP1_PALETE = ZP4_PALETE AND  C.D_E_L_E_T_ <> '*' " +LF
	_cQry += "		LEFT  JOIN "+RetSqlName("ZZS")+" D ON ZZS_COD = ZP4_CODCLA  AND D.D_E_L_E_T_ <> '*'  " +LF
	_cQry += "		WHERE ZP4_PALETE BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' " +LF
	_cQry += "		AND ZP4_DTABER BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' " +LF

	If MV_PAR09 == "Sim"
		_cQry += "		AND ZP4_DTFECH BETWEEN '"+DtoS(MV_PAR10)+"' AND '"+DtoS(MV_PAR11)+"' " +LF
		_cQry += "		AND ZP4_HRFECH BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' " +LF
	ElseIf MV_PAR09 == "Abertos"
		_cQry += "		AND ZP4_DTFECH = '' " +LF
	EndIF
	If MV_PAR05 == "Sim"
		_cQry += "		AND ZP4_CARGA = '' " +LF
	EndIf
	_cQry += "		AND ZP4_ENDWMS BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " +LF
	_cQry += "		AND ZP4_PRODUT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +LF
	Do Case
		Case MV_PAR06 = "Montando"
		_cQry += "		AND ZP4_STATUS = 'M' " +LF
		Case MV_PAR06 = "Suspenso"
		_cQry += "		AND ZP4_STATUS = 'S' " +LF
		Case MV_PAR06 = "Fechado"
		_cQry += "		AND ZP4_STATUS = 'F' " +LF
		Case MV_PAR06 = "Carregado"
		_cQry += "		AND ZP4_STATUS = 'C' " +LF
		Case MV_PAR06 = "Expedido"
		_cQry += "		AND ZP4_STATUS = 'E' " +LF
	EndCase

	_cQry += "		AND A.D_E_L_E_T_ <> '*' " +LF
	_cQry += "	GROUP BY ZP4_PALETE, ZP4_DATA, ZP4_PRODUT, B1_DESC, ZP4_STATUS, ZP1_STATUS, ZP4_USABER, ZP4_DTABER, ZP4_HRABER, ZP4_USFECH, ZP4_DTFECH, ZP4_HRFECH, ZP4_ENDWMS, ZP4_CARGA, ZZS_DESCRI, ZP4_CODEST, ZP1_LOCAL " +LF

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

		//ZP4_STATUS --> M=Montando;S=Suspenso;F=Fechado;C=Carregado;E=Expedido
		Do Case
			Case (XALIAS)->ZP4_STATUS == 'M'
			_cStatus := "Montando"
			Case (XALIAS)->ZP4_STATUS == 'S'
			_cStatus := "Suspenso"
			Case (XALIAS)->ZP4_STATUS == 'F'
			_cStatus := "Fechado"
			Case (XALIAS)->ZP4_STATUS == 'C'
			_cStatus := "Carregando"
			Case (XALIAS)->ZP4_STATUS == 'E'
			_cStatus := "Expedido"
			Otherwise
			_cStatus := "- x -"
		EndCase

		Do Case
			Case (XALIAS)->ZP1_STATUS == '1'
			_cStatcx := "Ativa"
			Case (XALIAS)->ZP1_STATUS == '2'
			_cStatcx := "Em carregamento"
			Case (XALIAS)->ZP1_STATUS == '3'
			_cStatcx := "Carregado"
			Case (XALIAS)->ZP1_STATUS == '4'
			_cStatcx := "Bloqueado"
			Case (XALIAS)->ZP1_STATUS == '5'
			_cStatcx := "Baixado em inventário"
			Case (XALIAS)->ZP1_STATUS == '7'
			_cStatcx := "Suspenso (qualidade)"
			Case (XALIAS)->ZP1_STATUS == '9'
			_cStatcx := "Suspenso (padrão)"
			Otherwise
			_cStatcx := "- x -"
		EndCase

		Do Case
			Case (XALIAS)->ZP4_CODEST == '1'
			_cTipoP := "Nornal"
			Case (XALIAS)->ZP4_CODEST == '2'
			_cTipoP := "Pickng"
			Otherwise
			_cTipoP := "- x -"
		EndCase

		OSECTION1:CELL("A"):SETVALUE((XALIAS)->ZP4_PALETE)
		OSECTION1:CELL("B"):SETVALUE(Dtoc(Stod((XALIAS)->ZP4_DATA)))
		OSECTION1:CELL("B1"):SETVALUE((XALIAS)->ZP4_PRODUT)
		OSECTION1:CELL("C"):SETVALUE((XALIAS)->B1_DESC)
		OSECTION1:CELL("D"):SETVALUE(_cStatus)
		OSECTION1:CELL("D1"):SETVALUE(_cStatcx)
		OSECTION1:CELL("E"):SETVALUE((XALIAS)->ZP4_USABER)
		//	OSECTION1:CELL("F"):SETVALUE(Dtoc(Stod((XALIAS)->ZP4_DTABER)))
		//	OSECTION1:CELL("F1"):SETVALUE((XALIAS)->ZP4_HRABER)
		//	OSECTION1:CELL("G"):SETVALUE((XALIAS)->ZP4_USFECH)
		//	OSECTION1:CELL("H"):SETVALUE(Dtoc(Stod((XALIAS)->ZP4_DTFECH)))
		//	OSECTION1:CELL("H0"):SETVALUE(Dtoc(Stod((XALIAS)->ZP4_DTFECH)))
		//	OSECTION1:CELL("H1"):SETVALUE((XALIAS)->ZP4_HRFECH)
		OSECTION1:CELL("H2"):SETVALUE((XALIAS)->QTD)
		OSECTION1:CELL("H3"):SETVALUE((XALIAS)->PESO)
		OSECTION1:CELL("I"):SETVALUE((XALIAS)->ZP4_ENDWMS)
		OSECTION1:CELL("J"):SETVALUE((XALIAS)->ZP4_CARGA)
		OSECTION1:CELL("K"):SETVALUE((XALIAS)->ZZS_DESCRI)
		OSECTION1:CELL("L"):SETVALUE(_cTipoP)
		OSECTION1:CELL("M"):SETVALUE((XALIAS)->ZP1_LOCAL)

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
	LOCAL aCombo	:= {"Sim","Não","Abertos"}
	LOCAL aCombo1	:= {"Sim","Não"}
	LOCAL aCombo2	:= {"Montando","Suspenso","Fechado","Carregado","Expedido","Todos"}

	AADD(APARAM,{1,"Produto de:"			,SPACE(TAMSX3('ZP4_PRODUT')[1])		,PESQPICT('ZP4', 'ZP4_PRODUT'),'.T.'	,"SB1",'.T.', 50, .F.})
	AADD(APARAM,{1,"Produto até:"			,REPL('Z',TAMSX3('ZP4_PRODUT')[1])	,PESQPICT('ZP4', 'ZP4_PRODUT'),'.T.'	,"SB1",'.T.', 50,	.F.})
	AADD(APARAM,{1,"Endereço de:"			,SPACE(TAMSX3('ZP4_ENDWMS')[1])		,PESQPICT('ZP4', 'ZP4_ENDWMS'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Endereço até:"			,SPACE(TAMSX3('ZP4_ENDWMS')[1])		,PESQPICT('ZP4', 'ZP4_ENDWMS'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{2,"Apenas não carregados"	,1									,aCombo1	,50	,""	,.F.})
	AADD(APARAM,{2,"Apenas com Status?"		,6									,aCombo2	,50	,""	,.F.})
	AADD(APARAM,{1,"Dt. Abert. de:"			,ctod("")							,PESQPICT('ZP4', 'ZP4_DTABER'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Abert. até:"		,ctod("")							,PESQPICT('ZP4', 'ZP4_DTABER'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{2,"Consd. Dt./Hr.Fecham."	,2									,aCombo		,50	,""	,.F.})
	AADD(APARAM,{1,"Dt. Fechm. de:"	    	,ctod("")							,PESQPICT('ZP4', 'ZP4_DTFECH'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Dt. Fechm. Até:"		,ctod("")							,PESQPICT('ZP4', 'ZP4_DTFECH'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Hr. Fechm. de:"	    	,"05:00:00"							,"99:99:99"					   ,'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Hr. Fechm. Até:"		,"04:59:59"							,"99:99:99"					   ,'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Palete de:"				,SPACE(TAMSX3('ZP4_PALETE')[1])		,PESQPICT('ZP4', 'ZP4_PALETE'),'.T.'	, 	,'.T.', 50, .F.})
	AADD(APARAM,{1,"Palete até:"			,REPL('Z',TAMSX3('ZP4_PALETE')[1])	,PESQPICT('ZP4', 'ZP4_PALETE'),'.T.'	, 	,'.T.', 50, .F.})

	IF !PARAMBOX(APARAM,"PARÂMETROS",@ARET)
		RETURN .F.
	ENDIF

RETURN .T.


Static Function EnvMail()


	Local _cMsg		:= ""

	Local _nVlrTot	:= 0

	Local _nDesc	:= 0

	Local cEol		:= ""


	_cMsg += ' <html>'+cEol

	_cMsg += ' <head>'+cEol

	_cMsg += '     <title>CADASTRO DE PRODUTOS</title>'+cEol

	_cMsg += ' </head>'+cEol

	_cMsg += ' <body bgcolor="#FFFFFF">'+cEol

	_cMsg += '     <table width="100%">'+cEol

	_cMsg += '         <tr>'+cEol

	_cMsg += '             <td align="left" width="30%">'+cEol

	_cMsg += '                 <img src="'+IIF(cEmpAnt=='04','http://friato.com.br/images/olvego.jpg','http://friato.com.br/images/friato.png')+'" width="261" height="194" />'+cEol

	_cMsg += '             </td>'+cEol

	_cMsg += '             <td align="center" width="70%">'+cEol

	_cMsg += '                 <font color="blue" size="10" face="Arial"><strong>Você está recebendo o relatório DEMONSTRATIVO DE STATUS DE PALETE</strong></font>'+cEol

	_cMsg += '             </td>'+cEol

	_cMsg += '         </tr>'+cEol

	_cMsg += '         <tr>'+cEol

	_cMsg += '             <td colspan="4">'+cEol

	_cMsg += '                 <font size="3" color="red" face="Arial"><strong>Favor verificar se os dados estão corretos.</strong></font><br>'
	_cMsg += '             </td>'+cEol

	_cMsg += '         </tr>'+cEol

	_cMsg += '     </table>'+cEol

	_cMsg += ' </body>'+cEol

	_cMsg += ' </html>'+cEol



	oMail := SendMail():new()

	oMail:SetTo( GetNewPar( "MV_PCPEML","flavio.martins@friato.com.br") )
	oMail:SetFrom(Alltrim(GetMv("MV_RELFROM",," ")))

	oMail:SetSubject("[FRIATO] DEMONSTRATIVO DE STATUS DE PALETE")


	oMail:SetAttachment("\PCPR005.CSV")
	oMail:SetBody(_cMsg)

	oMail:SetShedule(.f.)

	oMail:SetEchoMsg(.f.)

	oMail:Send()


Return
