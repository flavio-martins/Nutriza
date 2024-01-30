#include 'protheus.ch'
#include 'parmtype.ch'

user function MT250TOK()

	Local LRET 		:= .T.
	Local __B2QATU	:=  0
	Local aMsg		:= {}
	Local aArea		:= GetArea()
	Local cMsg		:= ""
	Local LF		:= chr(13)+chr(10)
	Local nProp		:= (M->D3_QUANT / SC2->C2_QUANT)

	SD4->(dbSetOrderO(2))
	SD4->(dbSeek(XFILIAL("SD4")+M->D3_OP))
	Do While SD4->D4_OP = M->D3_OP
		__B2QATU := POSICIONE("SB2",1,XFILIAL("SB2")+SD4->D4_COD+SD4->D4_LOCAL,"B2_QATU")
		If !(SubStr(SB2->B2_COD,1,3) = "MOD")
			IF (__B2QATU - (SD4->D4_QTDEORI * nProp )) < 0
				LRET := .F.
				aadd(aMsg,{SD4->D4_COD,;
				POSICIONE("SB1",1,XFILIAL("SB1")+SD4->D4_COD,"B1_DESC"),;
				__B2QATU,;
				(SD4->D4_QTDEORI * nProp ),;
				(__B2QATU - (SD4->D4_QTDEORI * nProp ))})
			EndIf
		EndIF
		SD4->(dbSkip())
	EndDo
	If !(LRET)
		msg := "O(s) Produto(s) relacionados abaixo,"+LF
		msg += "tiveram a diferen�a como negativa, �"+LF
		msg += "necess�rio sua avalia��o para fechar"+LF
		msg += "a Ordem de Produ��o corretamente."+LF+LF
		msg += "C�digo | Descri��o | Saldo | Solicitado | Diferen�a"+LF+LF
		For nLin := 1 to Len(aMsg)
			msg += aMsg[nLin][1]+" | "+aMsg[nLin][2]+" | "+AllTrim(Str(aMsg[nLin][3]))+" | "+AllTrim(Str(aMsg[nLin][4]))+" | "+AllTrim(Str(aMsg[nLin][5]))+LF
		Next nLin
		MsgAlert(msg,"Ordem de Produ��o")
	EndIF
	RestArea(aArea)
return LRET