User Function PCP014
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif
	U_PCP008()
Return