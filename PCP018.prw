
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCP018()	 �Autor  �Evandro Gomes     � Data � 02/05/13   	 ���
�������������������������������������������������������������������������͹��
���Desc.     � Re-Impressao etiqueta Tunel  									���
�������������������������������������������������������������������������͹��
���Uso       � NUTRIZA							                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
User Function PCP018
Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	//->Testa ambientes que podem ser usados

	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente n�o homologado para o uso desta rotina!!!")
		Return .F.
	Endif
	
If !U_APPFUN01("Z6_REIMEPT")=="S"
	MsgInfo(OemToAnsi("Usu�rio sem acesso a esta rotina."))
	Return
Endif

U_PCP005("Re-Identificacao de Etiqueta Perdida Tunel")
Return