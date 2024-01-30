#INCLUDE "rwmake.ch"
#include 'fileio.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A650LEMP º Autor ³ Flávio Martins     º Data ³  14/08/18       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada no momento do empenho do produto na           º±±
±±º          ³ Gravação da OP                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ MV_ARMZEMP -> Numero do armazém que será incluído no           º±±
±±º          ³               empenho, caso B1_APROPRI == "D".                 º±±
±±º          ³ MV_650EMPP -> Grupos de Produtos que utilizará armazem empenho º±±
±±º          ³                                                                º±±
±±º          ³ MV_650EMPF -> Prod. filho que ñ utilizarão armazem emprenho    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA S.A.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
