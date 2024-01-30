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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP025() ºAutor  ³Evandro Gomes     º Data ³ 02/05/13   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Exclusão de Etiquetas que não sairam do tunel			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Parametro			Tipo			Descrição							  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

*/

User Function PCP025()
	Private oBtnProc
	Private oOk 
	Private oNo 
	Private cProdzp1
	Private cMailImp 
	Private _nTpLog
	Private _lMkpZP1
	Private _cDirErr
	Private _lImpSch
	Private cPerg		
	Private dDtPrdIni
	Private dDtPrdFim
	Private oDlg025
	Private _cFunMrk
	Private _lFecEst
	Private dDataFec
	Private _cPCPAPP
	Private _lProduz
	Private _aFilesEr		:= {} 

	//->Browse de ZPEs
	Private oWBrw025
	Private aWBrw025 		:= {}
	Private cStatus			:= ""
	Private oFntSt 	 
	Private oStatusOK
	Private oStatusER
	Private cStatus 
	Private aErros			:= {}

	//->Parâmetros para interface
	Private _aButts			:= {}
	Private _cTitulo		:= "Limpa Etiq. TCA"
	Private _aCabec			:= {}
	Private _aButts			:= {}
	Private aObjects		:= {}
	Private sDtaProdIni		:= ""
	Private oDtaProdIni
	Private dDtaProdIni		:= CTOD("  /  /    ")
	Private sDtaProdFim		:= ""
	Private oDtaProdFim
	Private dDtaProdFim		:= CTOD("  /  /    ")
	Private sPrdProdIni		:= ""
	Private oPrdProdIni
	Private cPrdProdIni		:= ""
	Private sPrdProdFim		:= ""
	Private oPrdProdFim
	Private cPrdProdFim		:= "ZZZZZZZZZZZZZZZ"
	Private nTpCons			:= 1
	Private aCores			:= {}

	Private _cEnvPer		:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog			:= GetNewPar("MV_PCPTLOG",1)

	cPerg					:= PadR(funname(),10)	
	dDtPrdIni				:= ctod("  /  /    ")
	dDtPrdFim				:= ctod("  /  /    ")
	_cFunMrk				:= ""
	oOk 					:= LoadBitmap( GetResources(), "LBOK")
	oNo 					:= LoadBitmap( GetResources(), "LBNO")
	oFntSt 					:= TFont():New("Tahoma",,026,,.T.,,,,,.F.,.F.)

	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente não homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	If !U_APPFUN01("Z6_EXCETIT")=="S"
		MsgInfo(OemToAnsi("Usuário sem acesso a esta rotina."))
		Return
	Endif

	aCores := 	{ {"BR_VERDE"   , "Nunca Lida"},;
	{"BR_VERMELHO", "Em TCA"}}

	AADD(_aButts,{"", { || ExecBlock("PCP025A",.F.,.F.,{1,.T.,.T.}) },"Filtrar", "Filtrar"})
	AADD(_aButts,{"", { || ExecBlock("PCP025A",.F.,.F.,{2,.F.,.T.}) },"Inverte", "Inverte"})
	AADD(_aButts,{"", { || ExecBlock("PCP025A",.F.,.F.,{3,.F.,.T.}) },"Excluir", "Excluir"})
	_aCabec:={"","","Etiqueta","Produto","Dt Impresao","Hr Impressao","Usuario","Status"}

	ExecBlock("PCP025A",.F.,.F.,{1,.T.,.F.})

	U_OHFUNAP2(aObjects, _aButts, _cTitulo, _aCabec, @aWBrw025, @oDlg025, @oWBrw025, .F., .F., @oStatusOK, @oStatusER, @cStatus, _cFunMrk, .F., , , ,aCores)
Return

/* Executa rotinas */

User Function PCP025A()
	Local _lRet 	:= .T.
	Local nOpc		:= ParamIXB[1]
	Local lPerg		:= ParamIXB[2]

	Private oProcess
	If nOpc==1 //->Lista Produções
		oProcess:=MsNewProcess():New( { || ExecBlock("PCP025B",.F.,.F.,{lPerg}) } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()
		If ParamIXB[3]
			U_OHFUNA21(@oDlg025, @oWBrw025, _aCabec, @aWBrw025, _cFunMrk)
		Endif
	ElseIf nOpc==2 //->Inverte Seleção
		oProcess:=MsNewProcess():New( { || PCP025C(nOpc) } , "Invertendo..." , "Aguarde..." , .F. )
		oProcess:Activate()
		ExecBlock("PCP025A",.F.,.F.,{1,.F.,.T.})
	ElseIf nOpc==3 //->Executa Produções
		oProcess:=MsNewProcess():New( { || PCP025C(nOpc) } , "Gerando Dados..." , "Aguarde..." , .F. )
		oProcess:Activate()    
		ExecBlock("PCP025A",.F.,.F.,{1,.F.,.T.})	
	Endif
Return(_lRet)


/* Lista etiquetas */

User Function PCP025B()
	Local _cQry := ""
	Local lPerg := ParamIXB[1]

	PCP025Z(cPerg) //-> Cria Perguntas

	If !lPerg
		Pergunte(cPerg,.F.)
		MV_PAR01:=dDtaProdIni
		MV_PAR02:=dDtaProdFim
		MV_PAR03:=cPrdProdIni
		MV_PAR04:=cPrdProdFim
		MV_PAR05:=nTpCons
	Else
		If !Pergunte(cPerg,.T.)
			Return .F.
		Else
			dDtaProdIni:= MV_PAR01
			dDtaProdFim:= MV_PAR02
			cPrdProdIni:= MV_PAR03
			cPrdProdFim:= MV_PAR04
			nTpCons:= MV_PAR05
		Endif
	Endif

	_cQry += " SELECT * FROM "
	_cQry += " ( "
	_cQry += " 	SELECT ZP1.ZP1_CODETI, B1_DESC, ZP1.ZP1_DTIMPR, ZP1.ZP1_HRIMPR, ZP1.ZP1_USIMPR "
	_cQry += " 	, CASE WHEN EXISTS ( "
	_cQry += " 		SELECT ZP6_ETIQ "
	_cQry += " 		FROM "+RetSqlName("ZP6") "
	_cQry += " 		WHERE D_E_L_E_T_ = ' ' "
	_cQry += " 		AND ZP6_FILIAL = '"+xFilial("ZP6")+"' "
	_cQry += " 		AND ZP6_ETIQ = ZP1_CODETI "
	_cQry += " 		AND ZP6_DATA >= ZP1_DTIMPR "
	_cQry += " 		GROUP BY ZP6_ETIQ "
	_cQry += " 	) THEN 'EM TUNEL' ELSE 'NUNCA LIDA' END STATUS "
	_cQry += " 	FROM "+RetSqlName("ZP1")+" ZP1 "
	_cQry += " 	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO "
	_cQry += " 	WHERE ZP1.D_E_L_E_T_ = ' ' "
	_cQry += " 	AND ZP1_FILIAL = '"+xFilial("ZP1")+"' "
	_cQry += " 	AND ZP1_STATUS = '' "
	_cQry += " 	AND ZP1_STATUS NOT IN ('1','2','3','5','7','9') "
	_cQry += " 	AND ZP1_CARGA = '' "
	_cQry += " 	AND ZP1_CODPRO BETWEEN '"+cPrdProdIni+"' AND '"+cPrdProdFim+"' "
	_cQry += " 	AND ZP1_DTIMPR BETWEEN '"+DToS(dDtaProdIni)+"' AND '"+DToS(dDtaProdFim)+"' "
	_cQry += " 	AND ZP1_TIPO <> '5' "
	_cQry += " ) A "
	If nTpCons == 2
		_cQry += " WHERE STATUS = 'NUNCA LIDA' "
	ElseIf nTpCons == 1 
		_cQry += " WHERE STATUS = 'EM TUNEL' "
	EndIf
	_cQry += " ORDER BY 2,1 "
	TcQuery _cQry New Alias "QRYE"
	oProcess:SetRegua1(1)
	oProcess:SetRegua2(QRYE->(LastRec()))
	oProcess:IncRegua1("Selecionando....")
	QRYE->(dbGoTop())
	While !QRYE->(EOF())
		oProcess:IncRegua2("Etiq.: "+QRYE->ZP1_CODETI)
		aAdd(aWBrw025,{.T.,IIF(QRYE->STATUS=='NUNCA LIDA',"BR_VERDE","BR_VERMELHO"),QRYE->ZP1_CODETI,QRYE->B1_DESC,DToC(SToD(QRYE->ZP1_DTIMPR)),QRYE->ZP1_HRIMPR,QRYE->ZP1_USIMPR,QRYE->STATUS})
		QRYE->(dbSkip())
	EndDo
	QRYE->(dbCloseArea())
	If Len(aWBrw025) <= 0
		aAdd(aWBrw025,{.F.,"BR_VERMELHO","","","","","",""})
	EndIf
Return

/* 
Process array 
nTipo==1 ->Inverte
nTipo==2 ->Processa
*/

Static Function PCP025C(nTipo)
	Local _I := 0
	Local lRet	:= .T.
	Local aErr	:= {} 
	ZP1->(dbSetOrder(1))
	oProcess:SetRegua1(Len(aWBrw025))
	For _I := 1 To Len(aWBrw025)
		oProcess:IncRegua1("Etiq: "+aWBrw025[_I,3] )
		If nTipo == 2 //->Inverte
			aWBrw025[_I,1] := !aWBrw025[_I,1]
			oWBrw025:aArray[_I][1]:= !oWBrw025:aArray[_I][1]
			oWBrw025:DrawSelect()
			oWBrw025:Refresh()
		ElseIf nTipo == 3 //->Processar
			If aWBrw025[_I,1]
				oProcess:SetRegua2(1)
				If ZP1->(dbSeek(xFilial()+aWBrw025[_I,3]))
					oProcess:IncRegua2("Encontrada...")
					If !ZP1->ZP1_STATUS $ "1/2/3/5/7/9"
						RecLock("ZP1",.F.)
						ZP1->(dbDelete())
						ZP1->(MsUnLock())
						AADD(aErr,{"Etiqueta: "+aWBrw025[_I,3]+" Excluida com sucesso.","Sucesso"})	
						U_PCPRGLOG(_nTpLog,aWBrw025[_I,3],"45")
					Else
						AADD(aErr,{"Etiqueta: "+aWBrw025[_I,3]+".","ERRO"})
					Endif
				Else
					AADD(aErr,{"Etiqueta: "+aWBrw025[_I,3]+" Encontra-se: "+ Iif(ZP1->ZP1_STATUS==" ","Não Paletizada",Iif(ZP1->ZP1_STATUS=="1","Ativa",Iif(ZP1->ZP1_STATUS=="2","Em Carregamento",Iif(ZP1->ZP1_STATUS=="3","Carregada",Iif(ZP1->ZP1_STATUS=="5","Não Inventariada",Iif(ZP1->ZP1_STATUS=="7","Sequestrada",Iif(ZP1->ZP1_STATUS=="9","Suspensa",)))))))+".","ERRO"})
					oProcess:IncRegua2("Não Encontrada...")
				EndIf
			EndIf
		Endif
	Next _I
Return(lRet)

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCP025Z ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ajusta SX1 Perguntas										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________

*/        

Static Function PCP025Z(cPerg)

	U_OHFUNAP3(cPerg,"01","Data De?"			,"","","mv_ch1","D",TAMSX3("D2_EMISSAO")[1],0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data Ate ?"			,"","","mv_ch2","D",TAMSX3("D2_EMISSAO")[1],0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Produto De?"			,"","","mv_ch3","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Produto Ate?"		,"","","mv_ch4","C",TAMSX3("B1_COD")[1],0,0,"G","","SB1","","","MV_PAR04","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Somente C/ Tol?"		,'','',"mv_ch5","N",01,0,1,"C","","","","","MV_PAR05","TUNEL","","","","NUNCA LIDA","","","AMBAS","","","","","","","","","","","")

Return

