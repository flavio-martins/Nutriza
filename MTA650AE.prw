#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//LIMPA NUMERO DA OP NA ZP1, APOS A EXCLUSÃO DA SC2.
//NUTRIZA - 26-10-2016 E.L.O. 

USER FUNCTION MTA650AE()
	LOCAL COP			:= PARAMIXB[1]
	LOCAL CSQL			:= ""
	Local _nPos		:= 0
	Local _nImp		:= 0
	Local _nImpCx		:= 0
	Local cAliasZP1	:= GetNextAlias()
	Local _aCodAnt	:= {}
	Local _nPosAnt	:= 0
	Local _nRep 		:= 0
	Local _nRepCx		:= 0
	Local aAnal		:= {}
	Local _nTpLog		:= GetNewPar("MV_PCPTLOG",1)
	Local _aArea		:= GetArea()

	/*
	CSQL:="UPDATE "+RETSQLNAME("ZP1")+" "
	CSQL+="SET "
	CSQL+="ZP1_OP= '"+SPACE(11)+"' "
	CSQL+="WHERE "
	CSQL+="ZP1_FILIAL='"+XFILIAL('ZP1')+"' "
	CSQL+="AND ZP1_OP='"+COP+"' "
	CSQL+="AND D_E_L_E_T_ <> '*' "
	TCSQLEXEC(CSQL)
	*/

	If SubStr(COP,7,5)='01001'
		cSql := " SELECT "
		cSql += " * "
		cSql += " FROM "+RetSQLName("ZP1")+" ZP1 WITH (NOLOCK) "
		cSql += " WHERE ZP1.D_E_L_E_T_ = ' '"
		cSql += " AND ZP1_OP = '"+SubStr(COP,1,6)+"'"
		cSql += " ORDER BY ZP1_CODETI "
		dbUseArea(.T.,"TopConn",TCGenQry(,,cSql),cAliasZP1,.F.,.T.)
		(cAliasZP1)->(dbGoTop())
		While !(cAliasZP1)->(EOF())
			ZP1->(dbSetOrder(1))
			If ZP1->(dbSeek(xFilial("ZP1")+(cAliasZP1)->ZP1_CODETI))
				RecLock("ZP1",.F.)
				ZP1->ZP1_OP := Space(TamSx3('ZP1_OP')[1]) 
				ZP1->(MsUnLock())
				U_PCPRGLOG(_nTpLog,(cAliasZP1)->ZP1_CODETI,"D5","OP: "+SubStr(COP,1,6))
			Endif
			(cAliasZP1)->(dbSkip())
		EndDo
		(cAliasZP1)->(dbCloseArea())
	Endif
	RestArea(_aArea)
RETURN