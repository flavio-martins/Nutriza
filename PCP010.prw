User Function PCP010
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif
	U_PCP005("Impressao etiquetas de reprocesso")
Return
