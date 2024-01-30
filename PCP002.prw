#INCLUDE "rwmake.ch"


User Function PCP002
	Local cVldAlt := ".T." 
	Local cVldExc := ".T." 

	Private cString := "ZP3"

	dbSelectArea("ZP3")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Equipes de Apanha",cVldExc,cVldAlt)

Return
