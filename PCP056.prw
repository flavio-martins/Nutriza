#INCLUDE 'PARMTYPE.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function PCP056()

	Local 	 cIdUser := GetNewPar( "ESP_UPCP56","000709")
	Private oGet1
	Private cGet1	:= Space(TamSX3("ZP1_CODETI")[1])
	Private oGet2
	Private cGet2	:= Space(TamSX3("ZP1_PALETE")[1])
	Private oGet3
	Private cGet3	:= 0
	Private oSButton1
	Private oSButton2
	Private OWBROW	
	Private aItens := {{"","","","","","","",""}}
	Private OOK 	:= LOADBITMAP( GETRESOURCES(), "LBOK")
	Private ONO 	:= LOADBITMAP( GETRESOURCES(), "LBNO")
	Private nGetUse := 0
	Static oDlg
	If !(__cUserId $ cIdUser)
		MsgStop("Usuario não habilitado para esta função")
		Return
	EndIF

	DEFINE MSDIALOG oDlg TITLE "Exclusão de etiquetas" FROM 000, 000  TO 300, 800 COLORS 0, 16777215 PIXEL
	@ 008, 017 SAY oSay1 PROMPT "Pallet:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 187 SAY oSay2 PROMPT "Etiqueta:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 016, 017 MSGET oGet1 VAR cGet1 SIZE 090, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "ZP4" VALID IIF(!EMPTY(cGet1),PESQPALL(cGet1),NIL)
	@ 016, 187 MSGET oGet2 VAR cGet2 SIZE 090, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "ZP1" VALID IIF(!EMPTY(cGet2),PESQETIQ(cGet2),NIL)
	@ 036, 018 LISTBOX OWBROW FIELDS HEADER "Etiqueta","Produto","Descrição","Peso","Fabricação","Lote","Status","Pallet" SIZE 354, 080 OF oDlg COLORS 0, 16777215 PIXEL  COLSIZES 50,50    
	@ 124, 017 MSGET oGet3 VAR cGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 126, 292 TYPE 03 OF oDlg ENABLE ACTION bExclui(iif(nGetUse#0,iif(nGetUse=1,cGet1,cGet2),MsgAlert("É Preciso Digitar em um dos campos, Etiqueta ou Pallet")))
	DEFINE SBUTTON oSButton2 FROM 125, 344 TYPE 02 OF oDlg ENABLE ACTION oDlg:End() 
	OWBROW:SETARRAY(aItens)
	OWBROW:BLINE := {|| {;
	aItens[OWBROW:NAT,1],;
	aItens[OWBROW:NAT,2],;
	aItens[OWBROW:NAT,3],;
	aItens[OWBROW:NAT,4],;
	aItens[OWBROW:NAT,5],;
	aItens[OWBROW:NAT,6],;
	aItens[OWBROW:NAT,7],;
	aItens[OWBROW:NAT,8]}}
	OWBROW:REFRESH()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

STATIC FUNCTION PESQPALL(cPalet)
	cQuery := " SELECT ZP1_CODETI, ZP1_CODPRO, B1_DESC, ZP1_PESO, " 
	cQuery += " ZP1_DTPROD, ZP1_LOTE, ZP1_PALETE, ZP1_STATUS "
	cQuery += " FROM ZP1010 A " 
	cQuery += " INNER JOIN SB1010 ON B1_COD = ZP1_CODPRO "
	cQuery += " WHERE ZP1_PALETE = '"+cPalet+"' "
	cQuery += " AND A.D_E_L_E_T_ <> '*' "		

	aItens := Qry2Arr(cQuery)

	OWBROW:SETARRAY(aItens)
	OWBROW:BLINE := {|| {;
	aItens[OWBROW:NAT,1],;
	aItens[OWBROW:NAT,2],;
	aItens[OWBROW:NAT,3],;
	aItens[OWBROW:NAT,4],;
	aItens[OWBROW:NAT,5],;
	aItens[OWBROW:NAT,6],;
	aItens[OWBROW:NAT,7],;	
	aItens[OWBROW:NAT,8]}}
	OWBROW:REFRESH()
	nGetUse := 1

	cGet2 := Space(TamSX3("ZP1_PALETE")[1])
	oGet2:REFRESH()
	cGet3 := Len(aItens)
	oGet3:REFRESH()

RETURN

STATIC FUNCTION PESQETIQ(cEtiq)
	cQuery := " SELECT ZP1_CODETI, ZP1_CODPRO, B1_DESC, ZP1_PESO, " 
	cQuery += " ZP1_DTPROD, ZP1_LOTE, ZP1_PALETE, ZP1_STATUS "
	cQuery += " FROM ZP1010 A" 
	cQuery += " INNER JOIN SB1010 ON B1_COD = ZP1_CODPRO "
	cQuery += " WHERE ZP1_CODETI = '"+cEtiq+"' "
	cQuery += " AND A.D_E_L_E_T_ <> '*' "

	aItens := Qry2Arr(cQuery)
	OWBROW:SETARRAY(aItens)
	OWBROW:BLINE := {|| {;
	aItens[OWBROW:NAT,1],;
	aItens[OWBROW:NAT,2],;
	aItens[OWBROW:NAT,3],;
	aItens[OWBROW:NAT,4],;
	aItens[OWBROW:NAT,5],;
	aItens[OWBROW:NAT,6],;
	aItens[OWBROW:NAT,7],;	
	aItens[OWBROW:NAT,8]}}
	OWBROW:REFRESH()
	nGetUse := 2

	cGet1 := Space(TamSX3("ZP1_CODETI")[1])
	oGet1:REFRESH()
	cGet3 := Len(aItens)
	oGet3:REFRESH()	

RETURN


Static Function bExclui(cCodBar)
	Local nStat := 0
	if nGetUse=1
		cAcao := "o Pallet"
		ctab  := "ZP4"          

	Else
		cAcao := "a Etiqueta"
		ctab  := "ZP1"

	EndIf

	if MsgYesNo("Deseja realmente excluir "+cAcao+" de numero "+cCodBar+"?")
		Begin Transaction
			(ctab)->(dbSetOrder(1))
			If (ctab)->(dbseek(xFilial(ctab)+cCodBar))
				If ctab = "ZP4"
					lCond := ((ctab)->ZP4_ENDWMS = " " .AND. (ctab)->ZP4_CARGA = " " .AND. (ctab)->ZP4_STATUS = "F")
					cMsg  := "Pallet não permitido"+chr(13)+chr(10)+chr(13)+chr(10)+"Status: "+(ctab)->ZP4_STATUS+;
					chr(13)+chr(10)+"Carga: "+(ctab)->ZP4_CARGA+chr(13)+chr(10)+"Endereço: "+(ctab)->ZP4_ENDWMS
				Else
					lCond := (!((ctab)->ZP1_STATUS $ " |3|5") .AND. (ctab)->ZP1_ENDWMS = " " .AND. (ctab)->ZP1_PALETE = " " .AND. (ctab)->ZP1_CARGA = " ")
					cMsg  := "Etiqueta não permitida"+chr(13)+chr(10)+chr(13)+chr(10)+"Carga: "+(ctab)->ZP1_CARGA+;
					chr(13)+chr(10)+"Status:"+(ctab)->ZP1_STATUS+chr(13)+chr(10)+"Pallet: "+(ctab)->ZP1_PALETE+;
					chr(13)+chr(10)+"Endereço: "+(ctab)->ZP1_ENDWMS
				EndIF 
				IF lCond
					RecLock(ctab,.f.)
					(ctab)->(dbDelete())
					MsUnlock()
					nStat += 0
					if nGetUse=1
						U_PCPRGLOG(1,cCodBar,"Z1","Excluído "+cAcao+" - "+cCodBar)
					Else
						U_PCPRGLOG(1,cCodBar,"Z2","Excluída "+cAcao+" - "+cCodBar)
					EndIF
				Else
					MsgStop(cMsg)
					nStat += -1
					DisarmTransaction()
				EndIF
			Else
				nStat += -1
				DisarmTransaction()
			EndIF
			if nGetUse = 1 .and. nStat = 0
				For i := 1 to Len(aItens)
					If ZP1->(dbseek(xFilial("ZP1")+aItens[I][1]))
						RecLock("ZP1",.f.)
						ZP1->(dbDelete())
						MsUnlock()
						nStat += 0
						U_PCPRGLOG(1,aItens[I][1],"Z2","Excluída etiqueta do pallet "+cCodBar)
					Else
						MsgStop("Problema ao localizar a etiqueta "+aItens[I][1]+"do pallet "+cCodBar+chr(13)+chr(10)+"Verificar o motivo de não encontra-la no banco.")
						nStat += -1
						DisarmTransaction()
					EndIF
				Next i
			EndIf
			If nStat >= 0
				MsgAlert("Excluído com sucesso!")
			Else
				MsgStop("Etiqueta ou Pallet não permitido!")
				DisarmTransaction()
			EndIf
		End Transaction 
		LimpaVar()
	EndIf
Return

Static Function Qry2Arr(cQuery)

	Local aRet    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0
	Local i		   := 0
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "_TRB" , .F. , .T. )

	dbSelectArea("_TRB")
	aStr 	:= _TRB->(dbStruct())
	aRet0	:= Array(Len(aStr))
	aRet1   := Array(Fcount())
	nRegAtu := 1
	For i := 1 to Len(aStr)
		aRet0[i] := aStr[i][1]
	Next
	//	Aadd(aRet,aclone(aRet0))   //cabeçalho com rotulos de campos

	While !Eof()

		For x:=1 To Fcount()
			aRet1[x] := FieldGet(x)
		Next
		Aadd(aRet,aclone(aRet1))

		dbSkip()
		nRegAtu += 1
	Enddo

	dbSelectArea("_TRB")
	_TRB->(DbCloseArea())

Return(aRet)

Static Function LimpaVar()

	nGetUse := 0
	aItens := {{"","","","","","","",""}}
	OWBROW:SETARRAY(aItens)
	OWBROW:BLINE := {|| {;
	aItens[OWBROW:NAT,1],;
	aItens[OWBROW:NAT,2],;
	aItens[OWBROW:NAT,3],;
	aItens[OWBROW:NAT,4],;
	aItens[OWBROW:NAT,5],;
	aItens[OWBROW:NAT,6],;
	aItens[OWBROW:NAT,7],;	
	aItens[OWBROW:NAT,8]}}
	OWBROW:REFRESH()
	cGet1 := Space(TamSX3("ZP1_CODETI")[1])
	cGet2 := Space(TamSX3("ZP1_PALETE")[1])
	cGet3 := 0
	oGet1:REFRESH()
	oGet2:REFRESH()
	oGet3:REFRESH()
Return