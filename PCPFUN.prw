#Include 'Protheus.ch'

/*
Programa  PCPRGLOG    Autor  Evandro Gomes     Data 02/05/13
Desc.     Registra Log
Uso       NUTRIZA
*/

/*
Função que seleciona qual o modo de gração de log
*/
User Function PCPRGLOG(nTpLog,_cCodEti,_cCodigo,_cHistor)
	Local _lPCPULog	:= .T.///GetNewPar("MV_PCPULOG",.T.) //->Define se usa log de registro

	//->Testa se usa Log de Registro
	If !_lPCPULog
		Return
	Endif

	//->Executa funcao de log de registro
	If nTpLog == 1
		U_PCPREGLG(_cCodEti,_cCodigo,_cHistor)
	Else
		U_PCPRGLG2(_cCodEti,_cCodigo,_cHistor)
	Endif
Return

User Function PCPREGLG(_cCodEti,_cCodigo,_cHistor)
	Local cStr	:=""
	Local cPall	:= ""
	If ValType(_cHistor) = "U"
		_cHistor := ""
	EndIF
	If Substr(_cCodEti,1,2) = "90"
		cPall := _cCodEti
	ElseIF At("90",_cHistor)#0
		cPall :=  SubStr(_cHistor,At("90",_cHistor),16)
	EndIF
	RecLock("ZPE",.T.)
	Replace ZPE_FILIAL 	With xFilial("ZPD")
	Replace ZPE_CODIGO	With _cCodigo
	Replace ZPE_DATA	With Date()
	Replace ZPE_HORA	With Time()
	Replace ZPE_USERID	With __cUserId
	Replace ZPE_CODETI	With _cCodEti
	Replace ZPE_HISTOR	With Iif(_cHistor = Nil,Alltrim(GetEnvServer())+"/"+Alltrim(GetComputerName()),_cHistor)
	Replace ZPE_NOMUSE	With Upper(UsrFullName(__cUserId))
	Replace ZPE_ORIGEM	With Upper(AllTrim(FunName()))
	Replace ZPE_CODPAL	With cPall
	ZPE->(MsUnLock())
	dbSelectArea("ZP1")
	dbSetOrder(1)
	If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
		RecLock("ZP1",.F.)
		Replace ZP1_CODZPE	With _cCodigo
		ZP1->(MsUnLock())
	EndIF
Return

User Function PCPRGLG2(_cCodEti,_cCodigo,_cHistor)
	Local cStr		:=""
	Local _lGrv		:= .F.
	Local nRet		:= -1
	Local nRecNo	:= 0
	Local cAliasv	:= "ZPETMP"
	Local _nTbLog	:= GETMV("MV_PCPLGTB")  /*GetNewPar("MV_PCPLGTB",1)*/ //->Define em que tabela sera gravados os logs
	Local cPall 	:= ""
	If ValType(_cHistor) = "U"
		_cHistor := ""
	EndIF
	If Substr(_cCodEti,1,2) = "90"
		cPall := _cCodEti
	ElseIF At("90",_cHistor)#0
		cPall :=  SubStr(_cHistor,At("90",_cHistor),16)
	EndIF
	While !_lGrv

		If _nTbLog==1 //->Grava log na tabela padrao
			BeginSql Alias cAliasv
				SELECT MAX(R_E_C_N_O_)+1 AS RECNO
				FROM %Table:ZPE% ZPE
				WHERE ZPE.%notdel%
			EndSql
			nRecNo:=(cAliasv)->RECNO
			If Select(cAliasv) > 0
				(cAliasv)->(dbCloseArea())
				If File(cAliasv+GetDBExtension())
					fErase(cAliasv+GetDBExtension())
				Endif
			Endif

			cStr	:="INSERT INTO ZPE010 "
			cStr	+="(ZPE_FILIAL, ZPE_CODIGO, ZPE_DATA, ZPE_HORA "
			cStr	+=",ZPE_USERID, ZPE_CODETI, ZPE_HISTOR, ZPE_NOMUSE "
			cStr	+=",ZPE_ORIGEM,D_E_L_E_T_,R_E_C_N_O_,ZPE_CODPAL) "
			cStr	+="VALUES "
			cStr	+="('"+xFilial("ZPD")+"','"+_cCodigo+"','"+DTOS(Date())+"','"+Time()+"' "
			cStr	+=",'"+__cUserId+"','"+_cCodEti+"','"+Iif(_cHistor = Nil,"",_cHistor)+"' "
			cStr	+=",'"+ Upper(UsrFullName(__cUserId)) +"','"+Upper(AllTrim(FunName()))+"' "
			//cStr	+=",' ', (SELECT MAX(R_E_C_N_O_)+1 FROM ZPE010 WHERE D_E_L_E_T_ <> '*') )"
			cStr	+=",' ', "+cValToChar(nRecNo)+",'"+cPall+"' )"

		ElseIf _nTbLog==2 //->Grava log na tabela transita

			cStr	:="INSERT INTO LOGPCP "
			cStr	+="(LOG_FILIAL, LOG_CODIGO, LOG_DATA, LOG_HORA "
			cStr	+=",LOG_USERID, LOG_CODETI, LOG_HISTOR, LOG_NOMUSE "
			cStr	+=",LOG_ORIGEM,D_E_L_E_T_,LOG_PCP) "
			cStr	+="VALUES "
			cStr	+="('"+xFilial("ZPD")+"','"+_cCodigo+"','"+DTOS(Date())+"','"+Time()+"' "
			cStr	+=",'"+__cUserId+"','"+_cCodEti+"','"+Iif(_cHistor = Nil,"",_cHistor)+"' "
			cStr	+=",'"+ Upper(UsrFullName(__cUserId)) +"','"+Upper(AllTrim(FunName()))+"' "
			cStr	+=",' ','"+cPall+"')"

		Endif
		A:=1
		nRet := TCSQLExec(cStr)
		If nRet == 0
			dbSelectArea("ZP1")
			dbSetOrder(1)
			If ZP1->(dbSeek(xFilial("ZP1")+_cCodEti))
				RecLock("ZP1",.F.)
				Replace ZP1_CODZPE	With _cCodigo
				ZP1->(MsUnLock())
			EndIF
			_lGrv:=.T.
		EndIf

	Enddo
Return(_lGrv)

/*
Programa  PCPPRDVC() Autor  Evandro Gomes     Data  02/05/13
Desc.     Tratamento FIFO
Uso       NUTRIZA
*/
User Function PCPPRDVC(_cCodEti,_cCodigo)
	Local lRet	:= .T.
Return(lRet)

/*

Programa  PCPVIN1()
Autor  Evandro Gomes     Data 02/05/13
Desc.     Retorna se armazem está com inventário aberto
Uso       NUTRIZA

*/
User Function PCPVIN1(_cLocal)
	Local lRet	:= .F.
	ZP7->(dbSetOrder(3))
	If ZP7->(dbSeek(xFilial("ZP7") + "A" + _cLocal))
		lRet:=.T.
	Endif
Return(lRet)

/*

Programa  PCPVIN2() Autor  Evandro Gomes      Data  02/05/13
Desc.   Retorna se etiqueta foi inventariada para permitir o
enderecamento em caso de inventario aberto para o armazem
Uso       NUTRIZA

*/
User Function PCPVIN2(_cLocal, _cCodEti, lAcd)
	Local lRet	:= .T.
	ZP7->(dbSetOrder(3))
	If ZP7->(dbSeek(xFilial("ZP7") + "A" + _cLocal))
		ZP9->(dbSetOrder(1))
		If !ZP9->(dbSeek(xFilial()+ZP7->ZP7_DOC+_cCodEti))
			lRet:=.F.
		Endif
	Endif
Return(lRet)

/*

Programa  PCPVIN2() Autor  Evandro Gomes     Data 02/05/13
Desc.     Retorna .T. de etiqueta está inventáriada em algum
Inventário aberto.
Uso       NUTRIZA

*/
User Function PCPVIN3(_cCodEti)
	Local lRet	:= .T.
	Local aAreaZP7:=GetArea("ZP7")
	ZP7->(dbSetOrder(3))
	If ZP7->(dbSeek(xFilial("ZP7") + "A"))
		While !ZP7->(Eof()) .And. ZP7->(ZP1_FILIAL+ZP7_STATUS)==xFilial("ZP7") + "A"
			ZP9->(dbSetOrder(1))
			If ZP9->(dbSeek(xFilial()+ZP7->ZP7_DOC+_cCodEti))
				Return .T.
			Endif
			ZP7->(dbSeek())
		Enddo
	Endif
	RestArea(aAreaZP7)
Return(.F.)

/*

Programa  PCPVIN4() Autor  Evandro Gomes     Data 02/05/13
Desc.     Retorna se produto está sendo inventariado
Uso       NUTRIZA

*/
User Function PCPVIN4(_cCodProd)
	Local lRet		:= .T.
	Local _cSql	:= ""
	Local _cAZP8	:= GetNextAlias()
	_cSql:= "SELECT COUNT(*) REG"
	_cSql+= " FROM "+RetSqlName("ZP8")+" ZP8"
	_cSql+= " INNER JOIN "+RetSqlName("ZP7")+" ZP7"
	_cSql+= " ON ZP7_DOC=ZP8_DOC "
	_cSql+= " AND ZP7_STATUS='A' "
	_cSql+= " AND ZP7.D_E_L_E_T_='' "
	_cSql+= " WHERE "
	_cSql+= " ZP8_PRODUT='"+_cCodProd+"' "
	_cSql+= " ZP8.D_E_L_E_T_='' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql),_cAZP8,.T.,.F.)
	If (_cAZP8)->REG > 0
		lRet:=.F.
	Endif
	If Select(_cAZP8) > 0
		(_cAZP8)->(dbCloseArea())
		If File(_cAZP8+GetDBExtension())
			fErase(_cAZP8+GetDBExtension())
		Endif
	Endif
Return(lRet)



/*

Programa  PCPVET01() Autor  Evandro Gomes     Data 02/05/13
Desc.     Retorna se log já foi registrado
Uso       NUTRIZA

*/
User Function PCPVET01(_CodEti, _cCodigo)
	Local lRet			:= .F.
	Local aArea		:= GetArea()
	Local _cAliasZP	:= GetNextAlias()
	Local _nReg		:= 0
	_cSql:= " SELECT COUNT(*) QTD_REG "
	_cSql+= " FROM "+RetSqlName("ZPE")+" ZPE WITH (NOLOCK)"
	_cSql+= " WHERE "
	_cSql+= " ZPE_CODETI='"+_CodEti+"' "
	_cSql+= " AND ZPE_CODIGO IN ("+_cCodigo+") "
	_cSql+= " AND ZPE.D_E_L_E_T_='' "
	_cSql+= " UNION ALL "
	_cSql+= " SELECT COUNT(*) QTD_REG "
	_cSql+= " FROM LOGPCP LOG WITH (NOLOCK)"
	_cSql+= " WHERE "
	_cSql+= " LOG_CODETI='"+_CodEti+"' "
	_cSql+= " AND LOG_CODIGO IN ("+_cCodigo+") "
	_cSql+= " AND LOG.D_E_L_E_T_='' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql),_cAliasZP,.T.,.F.)
	While !(_cAliasZP)->(Eof())
		_nReg+=(_cAliasZP)->QTD_REG
		(_cAliasZP)->(dbSkip())
	Enddo
	If Select(_cAliasZP) > 0
		(_cAliasZP)->(dbCloseArea())
		If File(_cAliasZP+GetDBExtension())
			fErase(_cAliasZP+GetDBExtension())
		Endif
	Endif
	If _nReg > 0
		lRet:=.T.
	Endif
	RestArea(aArea)
Return(lRet)
