#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCP036() 	 �Autor  �Evandro Gomes     � Data � 02/05/13    ���
�������������������������������������������������������������������������͹��
���Desc.     �  Re-Impress�o etiqueta perdida estoque���
�������������������������������������������������������������������������͹��
���Uso       � NUTRIZA							                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
User Function PCP036()
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente n�o homologado para o uso desta rotina!!!")
		Return .F.
	Endif
	If !U_APPFUN01("Z6_RIETIPE")=="S"
		MsgInfo(OemToAnsi("Usu�rio sem acesso a esta rotina."))
		Return
	Endif
	U_PCP005("Re-Identifi��o de Etiqueta Perdida Estoque")
Return

