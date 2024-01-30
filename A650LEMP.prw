#INCLUDE "rwmake.ch"
#include 'fileio.ch'
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � A650LEMP � Autor � Fl�vio Martins     � Data �  14/08/18       ���
�����������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada no momento do empenho do produto na           ���
���          � Grava��o da OP                                                 ���
�����������������������������������������������������������������������������͹��
���Parametro � MV_ARMZEMP -> Numero do armaz�m que ser� inclu�do no           ���
���          �               empenho, caso B1_APROPRI == "D".                 ���
���          � MV_650EMPP -> Grupos de Produtos que utilizar� armazem empenho ���
���          �                                                                ���
���          � MV_650EMPF -> Prod. filho que � utilizar�o armazem emprenho    ���
�����������������������������������������������������������������������������͹��
���Uso       � NUTRIZA S.A.                                                   ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/

User Function A650LEMP()

	Local aAreaEMP	:= GetArea()
	Local aLinCol	   := aClone(PARAMIXB)
	Local cRetLocal	:= aLinCol[3]
	Local cAPROPRI	:= POSICIONE("SB1", 1, xFilial("SB1") + aLinCol[1], "B1_APROPRI")
	Local cPai		       := AllTrim(POSICIONE("SC2",1,xFilial("SC2")+SC2->C2_NUM+"01001","C2_PRODUTO"))

	If  POSICIONE("SB1", 1, xFilial("SB1") + cPai , "B1_GRUPO") $ GETMV("MV_650EMPP")

		If cAPROPRI = "D"
			If !(Alltrim(aLinCol[1]) $ getmv("MV_650EMPF"))
				cRetLocal := GetNewPar( "MV_ARMZEMP", '81' )
			EndIF
		EndIf
	EndIF
	RestArea(aAreaEMP)

Return cRetLocal
