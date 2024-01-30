#INCLUDE "rwmake.ch"

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o    � COM_004()       � Autor � Evandro Gomes          � Data � 15/04/15 ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao � Modelo de Etiqueta														 ���
���          �			                                                         ���
���������������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico - Nutriza											      	 ���
���������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ���
���������������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �          Manutencoes efetuadas                 ���
���������������������������������������������������������������������������������Ĵ��
���              �        �      �                                                ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
User Function PCP004
	Local cVldAlt := ".T." 
	Local cVldExc := ".T." 
	Private cString := "ZP2"
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	//->Testa ambientes que podem ser usados
	If !Upper(AllTrim(GetEnvServer())) $ _cEnvPer
		Alert("Ambiente nao homologado para o uso desta rotina!!!")
		Return .F.
	Endif

	//->Valiza se usu�rio pode acessar esta rotina
	If !U_APPFUN01("Z6_MODEETI")=="S"
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return
	Endif

	dbSelectArea("ZP2")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Modelos de Etiqueta",cVldExc,cVldAlt)

Return
