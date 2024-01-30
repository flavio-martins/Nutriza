#include 'topconn.ch'
#Include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP017()	ºAutor  ³Infinit             º Data ³ 02/05/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Transeferencia de carga									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP017(nOpc)

	Private oCarga
	Private cCarga 	:= Space(6)
	Private oDlgT
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _nOpc		:= Iif(nOpc == Nil, 1, nOpc) //-> 1=Amarra Carga Excluida / 2=Transfere caixas de uma carGa paga outra
	Private _cCarAti	:= DAK->DAK_COD
	Private _aAreaDAK	:= DAK->(GetArea())

	DEFINE MSDIALOG oDlgT TITLE "Informe a Carga" FROM 000, 000  TO 080, 170 COLORS 0, 16777215 PIXEL

	@ 010, 012 MSGET oCarga VAR cCarga SIZE 060, 010 OF oDlgT COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 025, 005 TYPE 01 OF oDlgT ENABLE ACTION LjMsgRun( "Processando transferencia, aguarde...", "Tranferencia", {|| bOk() } )
	DEFINE SBUTTON oSButton2 FROM 025, 055 TYPE 02 OF oDlgT ENABLE ACTION oDlgT:End()

	ACTIVATE MSDIALOG oDlgT CENTERED

	Return
	************************************************************************************
Static Function bOk()

	Local _aCGExc 	:= {}
	Local _aCGAtv 	:= {}
	Local ZP1TMP		:= "ZP1TTP"
	Local ZP4TMP		:= "ZP4TTP"
	Local _xRet		:= 0
	Local _aCodEti	:= {}
	Local _aCodPal	:= {}
	Local _nQtdEti	:= 0
	Local _nQtdPal	:= 0
	Local lContinua	:= .T.

	Begin Transaction
		/*
		Em caso de transferência verifica se já houve
		faturamento da carga a ser transferida
		*/
		If _nOpc==2 //->Transferência

			//-> Se carga existe
			DAK->(dbSetOrder(1))
			If DAK->(dbSeek(xFilial("DAK") + cCarga))
				MsgStop("Expedicao de carga a ser transferida ainda está valida. Carga ainda existe.")
				DisarmTransaction()
				Return
			Endif

			//-> Verifica se carga já foi faturada
			lContinua	:= .T.
			_cQry := " SELECT COUNT(*) QTD "
			_cQry += " FROM "+RetSQLName("SF2")+" SF2 "
			_cQry += " WHERE "
			_cQry += " F2_FILIAL = '"+xFilial("SF2")+"'"
			_cQry += " AND F2_CARGA='"+cCarga+"' "
			_cQry += " AND D_E_L_E_T_ <> '*' "
			TcQuery _cQry New Alias "QRYSF2"
			If !QRYSF2->(Eof()) .And. QRYSF2->QTD > 0
				lContinua	:= .F.
			Endif
			QRYSF2->(dbCloseArea())

			If !lContinua
				MsgStop("Expedicao de carga a ser transferida esta faturada.")
				DisarmTransaction()
				Return
			Endif

			//->Verifica se ja existem caixas na carga de destino
			cSql:="SELECT COUNT(*) QTDCX FROM "+RetSqlName("ZP1")+" ZP1 WHERE ZP1_FILIAL = '"+xFilial("ZP1")+"' AND ZP1_CARGA = '"+_cCarAti+"' AND D_E_L_E_T_ <> '*'"
			dbUseArea(.T.,"TOPCONN", TcGenQry(,,cSql),ZP1TMP,.F.,.T.)
			If (ZP1TMP)->QTDCX > 0
				lContinua:=.F.
			Endif
			(ZP1TMP)->(dbCloseArea())

			If !lContinua
				MsgStop("Carga de Destino já está com caixas expedidas.")
				DisarmTransaction()
				Return
			Endif


			fCopyCarg(cCarga,_cCarAti)
			//->Restaura carga selecionada
		Endif
		RestArea(_aAreaDAK)

		If _nOpc==1 //->Amarrar carga67

			_cQry := " SELECT DAI_PEDIDO,DAI_SEQUEN,COUNT(*)  TOTAL,MAX(R_E_C_N_O_) REC"
			_cQry += " FROM "+RetSQLName("DAI")
			_cQry += " WHERE D_E_L_E_T_ = '*'"
			_cQry += " AND DAI_FILIAL = '"+xFilial("DAI")+"'"
			_cQry += " AND DAI_COD = '"+cCarga+"'"
			_cQry += " GROUP BY DAI_PEDIDO,DAI_SEQUEN"

			TcQuery _cQry New Alias "QRYT"
			While !QRYT->(EOF())
				If QRYT->TOTAL = 1
					aAdd(_aCGExc,QRYT->DAI_PEDIDO)
				Else
					//Ajustar item para ajustar a carga excluida
					//MsgInfo("Duplicidade encontrada na Carga/Pedido:" + cCarga + "-" + QRYT->DAI_PEDIDO )
					cQry :="UPDATE " + RetSqlName("DAI")
					cQry +=" SET DAI_FILIAL='Z101' WHERE DAI_COD='"+cCarga+"' AND DAI_PEDIDO='"+QRYT->DAI_PEDIDO+"' AND R_E_C_N_O_ ="+AllTrim(Str(QRYT->REC))+" "
					MeMoWrite("C:\TEMP\PCP017.SQL",cQry)
					TcSqlExec(cQry)
					//MsgInfo("Duplicidade resolvida")  
					aAdd(_aCGExc,QRYT->DAI_PEDIDO)
				Endif
				QRYT->(dbSkip())
			EndDo
			QRYT->(dbCloseArea())

			If Len(_aCGExc) <= 0
				MsgStop("Nao foi possivel localizar a carga excluida informada.")
				DisarmTransaction()
				Return
			EndIf

			_cQry := " SELECT DAI_PEDIDO,DAI_SEQUEN,COUNT(*) TOTAL"
			_cQry += " FROM "+RetSQLName("DAI")
			_cQry += " WHERE D_E_L_E_T_ = ' '"
			_cQry += " AND DAI_FILIAL = '"+xFilial("DAI")+"'"
			_cQry += " AND DAI_COD = '"+DAK->DAK_COD+"'"
			_cQry += " GROUP BY DAI_PEDIDO,DAI_SEQUEN"
			TcQuery _cQry New Alias "QRYT"
			While !QRYT->(EOF())
				aAdd(_aCGAtv,QRYT->DAI_PEDIDO)
				QRYT->(dbSkip())
			EndDo
			QRYT->(dbCloseArea())

			If Len(_aCGExc) <> Len(_aCGAtv)
				MsgStop("PCP017 [DAI] - Pedidos da carga excluída:" +cCarga + " Qtde.: "+ AllTrim(Str(len(_aCGExc)))+" Divergente da carga atual:"+DAK->DAK_COD+" Qtde.:" +AllTrim(Str(Len(_aCGAtv))) )
				DisarmTransaction()
				Return
			Endif                  

			For _I := 1 To Len(_aCGAtv)
				If aScan(_aCGExc,_aCGAtv[_I]) <= 0
					MsgStop("Os pedidos das 2 cargas nao sao os mesmos.")
					DisarmTransaction()
					Return
				EndIf
			Next _I

			For _I := 1 To Len(_aCGExc)
				If aScan(_aCGAtv,_aCGExc[_I]) <= 0
					MsgStop("Os pedidos das 2 cargas nao sao os mesmos.")
					DisarmTransaction()
					Return
				EndIf
			Next _I

			lContinua	:= .F.
			fCopyCarg(cCarga,_cCarAti)
		Endif

		//-> Executa Transferência
		_nQtdEti:= 0
		_nQtdPal:= 0

		//->Etiqueta Caixa
		_aCodEti:={}
		cSql:="SELECT * FROM "+RetSqlName("ZP1")+" ZP1 WHERE ZP1_FILIAL = '"+xFilial("ZP1")+"' AND ZP1_CARGA = '"+cCarga+"' AND D_E_L_E_T_ <> '*'"
		dbUseArea(.T.,"TOPCONN", TcGenQry(,,cSql),ZP1TMP,.F.,.T.)
		While !(ZP1TMP)->(Eof())
			U_PCPRGLOG(_nTpLog,(ZP1TMP)->ZP1_CODETI,"60","Da Carga: "+cCarga+" P/ Carga: "+_cCarAti)
			AADD(_aCodEti,{(ZP1TMP)->ZP1_CODETI,""})
			ZP1->(dbSetOrder(1))
			If ZP1->(dbSeek(xFilial("ZP1") + (ZP1TMP)->ZP1_CODETI ))
				RecLock("ZP1",.F.)
				Replace ZP1_CARGA With _cCarAti
				ZP1->(MsUnLock())
				_nQtdEti++
				U_PCPRGLOG(_nTpLog,(ZP1TMP)->ZP1_CODETI,"47","Da Carga: "+cCarga+" P/ Carga: "+_cCarAti)
			Endif
			(ZP1TMP)->(dbSkip())
		Enddo
		(ZP1TMP)->(dbCloseArea())

		//->Etiqueta Palete
		_aCodPal:={}
		cSql:="SELECT * FROM  "+RetSqlName("ZP4")+" ZP4 WHERE ZP4_FILIAL = '"+xFilial("ZP4")+"' AND ZP4_CARGA = '"+cCarga+"' AND D_E_L_E_T_ <> '*' "
		dbUseArea(.T.,"TOPCONN", TcGenQry(,,cSql),ZP4TMP,.F.,.T.)
		While !(ZP4TMP)->(Eof())
			U_PCPRGLOG(_nTpLog,(ZP4TMP)->ZP4_PALETE,"61","Da Carga: "+cCarga+" P/ Carga: "+_cCarAti)
			AADD(_aCodPal,{(ZP4TMP)->ZP4_PALETE,""})
			ZP4->(dbSetOrder(1))
			If ZP4->(dbSeek(xFilial("ZP4") + (ZP4TMP)->ZP4_PALETE ))
				RecLock("ZP4",.F.)
				Replace ZP4_CARGA With _cCarAti
				ZP4->(MsUnLock())
				_nQtdPal++
				U_PCPRGLOG(_nTpLog,(ZP4TMP)->ZP4_PALETE,"48","Da Carga: "+cCarga+" P/ Carga: "+_cCarAti)
			Endif
			(ZP4TMP)->(dbSkip())
		Enddo
		(ZP4TMP)->(dbCloseArea())

		//->Valida Transferência
		_xRet:=0
		If _nQtdEti <> Len(_aCodEti)
			_xRet:=1
		Endif
		If _nQtdPal <> Len(_aCodPal)
			_xRet:=1
		Endif

		//->Atualiza Interface de vendedores
		ZZK->(dbSetOrder(1))
		If ZZK->(dbSeek(xFilial("ZZK") + cCarga))
			RecLock("ZZK",.F.)
			Replace ZZK_CARNUT With _cCarAti
			ZZK->(MsUnLock())
		Endif

		If _xRet == 0
			/*
			For x:=1 To Len(_aCodEti)
			ZP1->(dbSetOrder(1))
			If ZP1->(dbSeek(xFilial("ZP1") + _aCodEti[x,1] ))
			RecLock("ZP1",.F.)
			Replace ZP1_PEDIDO With ""
			ZP1->(MsUnLock())
			Endif
			Next x
			*/
			//->Restaura carga selecionada
			RestArea(_aAreaDAK)

			MsgInfo("Transferencia realizada com sucesso.")
			oDlgT:End() 
		Else
			For x:=1 To Len(_aCodEti)
				ZP1->(dbSetOrder(1))
				If ZP1->(dbSeek(xFilial("ZP1") + _aCodEti[x,1] ))
					RecLock("ZP1",.F.)
					Replace ZP1_CARGA With cCarga
					ZP1->(MsUnLock())
				Endif
				U_PCPRGLOG(_nTpLog,_aCodEti[x,1],"62","Da Carga: "+_cCarAti+" P/ Carga: "+cCarga)
			Next x
			For x:=1 To Len(_aCodPal)
				ZP4->(dbSetOrder(1))
				If ZP4->(dbSeek(xFilial("ZP4") + _aCodPal[x,1] ))
					RecLock("ZP4",.F.)
					Replace ZP4_CARGA With cCarga
					ZP4->(MsUnLock())
				Endif
				U_PCPRGLOG(_nTpLog,_aCodPal[x,1],"63","Da Carga: "+_cCarAti+" P/ Carga: "+cCarga)
			Next x

			//->Restaura carga selecionada
			RestArea(_aAreaDAK)

			MsgInfo("Erro na quantidade de caixas transferidas")
			DisarmTransaction()
		EndIf
	End Transaction

	Return

	******************************************
//COPIA OS DADOS DA CARGA ANTERIOR PARA A NOVA
Static Function fCopyCarg(cCarga,_cCarAti)

	_cQry := " SELECT *"
	_cQry += " FROM "+RetSQLName("DAK")
	_cQry += " WHERE D_E_L_E_T_ = '*'"
	_cQry += " AND DAK_FILIAL = '"+xFilial("DAK")+"'"
	_cQry += " AND DAK_COD = '"+cCarga+"'"
	TcQuery _cQry New Alias "QRYT"

	If !QRYT->(EOF())
		lContinua	:= .T.

		_cQry := " UPDATE "+RetSQLName("DAK")
		_cQry += " SET    DAK_XSTEXP = '"+QRYT->DAK_XSTEXP+"', DAK_XUSABE = '"+QRYT->DAK_XUSABE+"', DAK_XDTABE = '"+QRYT->DAK_XDTABE+"', "
		_cQry += "		  DAK_XHRABE = '"+QRYT->DAK_XHRABE+"', DAK_XUSFEC = '"+QRYT->DAK_XUSFEC+"', DAK_XDTFEC = '"+QRYT->DAK_XDTFEC+"', "
		_cQry += "		  DAK_XHRFEC = '"+QRYT->DAK_XHRFEC+"', DAK_XLACRE = '"+QRYT->DAK_XLACRE+"', DAK_XUPESE = '"+QRYT->DAK_XUPESE+"', "
		_cQry += "		  DAK_XUPESS = '"+QRYT->DAK_XUPESS+"', DAK_XDTPEE = '"+QRYT->DAK_XDTPEE+"', DAK_XDTPES = '"+QRYT->DAK_XDTPES+"', "
		_cQry += "		  DAK_XHRPEE = '"+QRYT->DAK_XHRPEE+"', DAK_XHRPES = '"+QRYT->DAK_XHRPES+"', DAK_XPESEN = "+str(QRYT->DAK_XPESEN)+", "
		_cQry += "		  DAK_XPESSA = "+str(QRYT->DAK_XPESSA)+", DAK_XPESMA = '"+QRYT->DAK_XPESMA+"', DAK_XBLQCP = '"+QRYT->DAK_XBLQCP+"', "
		_cQry += "		  DAK_VALOR  = "+str(QRYT->DAK_VALOR)+", DAK_PESO   = "+Str(QRYT->DAK_PESO)+", DAK_ROTEIR = '"+QRYT->DAK_ROTEIR+"', "
		_cQry += "		  DAK_CAMINH = '"+QRYT->DAK_CAMINH+"', DAK_MOTORI= '"+QRYT->DAK_MOTORI+"', DAK_TICKET = '"+QRYT->DAK_TICKET+"' "	
		_cQry += " WHERE D_E_L_E_T_ = ''"
		_cQry += " AND DAK_FILIAL = '"+xFilial("DAK")+"'"
		_cQry += " AND DAK_COD = '"+_cCarAti+"'"

		memowrite("C:\temp\UPDATEDAK.SQL",_cQry)

		If TCSqlExec(_cQry) < 0
			MsgAlert("Problemas ao cadastrar dados da carga excluída: "+cCarga+", na nova carga de numero "+_cCarAti+".", "COPIANDO DADOS DA VELHA CARGA...")
			TCSQLError()
			MostraErro()
		EndIf

	Else
		MsgStop("Não foi possivel localizar a carga excluida informada.")
		DisarmTransaction()
		QRYT->(dbCloseArea())
		Return .F.
	EndIf

	QRYT->(dbCloseArea())

Return
