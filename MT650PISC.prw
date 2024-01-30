/*
Localiza��o..: Function A650OpBatch - Define se mostra ou n�o a pergunta de confirma��o:
               "A OP informada n�o teve as OPs intermedi�rias criadas. Deseja mesmo produzi-la?" 
Finalidade...: Utilizado para controlar a geracao de OPs intermedi�rias.
*/

User Function MT650PISC
	Local _lRet := .T.
	// Inibe a mensagem "A OP informada nao teve OPs intermediarias criadas. Deseja mesmo produzi-la?"
	If "PCP006" $ AllTrim(Upper(FunName()))
		_lRet := .F.
	EndIf
Return(_lRet)
