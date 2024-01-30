/*
LOCALIZA��O: Function MATA340 - Fun��o respons�vel pela chamada do processamento do acerto do invent�rio.
EM QUE PONTO:  O ponto se encontra logo ap�s a tela de confirma��o da gera��o do acerto do invent�rio.
*/
User Function MT340IN
	Local _lRet := .T.
	Local _aAreaB7 := SB7->(GetArea())
	SB7->(dbSetOrder(3))
	If SB7->(dbSeek(xFilial()+MV_PAR12))
		If AllTrim(SB7->B7_ORIGEM) == "PCP023"
			If ZP7->(dbSeek(xFilial()+SB7->B7_DOC))
				If ZP7->ZP7_STATUS <> "F"
					MsgStop("Inventario "+SB7->B7_DOC+" n�o esta fechado na ZP7.")
					_lRet := .F.
				Else
					RecLock("ZP7",.F.)
					ZP7->ZP7_STATUS := "P"
					ZP7->(MsUnLock())
				EndIf
			Else
				MsgStop("Inventario n�o localizado na tabela ZP7.")
				_lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(_aAreaB7)
Return(_lRet)
