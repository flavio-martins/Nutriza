/*
Localização..: Function A650OpBatch - Define se mostra ou não a pergunta de confirmação:
               "A OP informada não teve as OPs intermediárias criadas. Deseja mesmo produzi-la?" 
Finalidade...: Utilizado para controlar a geracao de OPs intermediárias.
*/

User Function MT650PISC
	Local _lRet := .T.
	// Inibe a mensagem "A OP informada nao teve OPs intermediarias criadas. Deseja mesmo produzi-la?"
	If "PCP006" $ AllTrim(Upper(FunName()))
		_lRet := .F.
	EndIf
Return(_lRet)
