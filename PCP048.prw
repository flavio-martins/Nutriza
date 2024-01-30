#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "apwizard.ch"
#INCLUDE "FILEIO.CH

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP048   ºAutor  ³Evandro Gomes     º Data ³ 02/05/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importa atualização de indice de peso real					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA - PCP 													 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP048()
	Private oDlgImp
	Private oPatFil
	Private cPatFil	:= SPACE(100)
	Private oBntImp
	Private oBntFec

	//->Validação do Usuário
	If !U_APPFUN01("Z6_PESROMA")=="S" .And. __cUserId <> '000000'
		MsgInfo(OemToAnsi("Usuario sem acesso a esta rotina."))
		Return .F.
	Endif

	DEFINE MSDIALOG oDlgImp Title "Importa Peso Real" From 0,0 TO 100,400 Style DS_MODALFRAME Pixel
	@ 05,05 Say "Arquivo: "
	@ 04,27 MSGET oPatFil VAR cPatFil SIZE 170,10 Of oDlgImp When .F. Pixel
	oBntImp:= TButton():New( 25,040,"&Arquivo",oDlgImp,{|u| PCP048A() },037,012,,,,.T.,,"",,,,.F. )
	oBntFec:= TButton():New( 25,082,"&OK",oDlgImp,{|u| PCP048B()},037,012,,,,.T.,,"",,,,.F. )
	oBntFec:= TButton():New( 25,122,"&Fechar",oDlgImp,{|u| Close(oDlgImp)},037,012,,,,.T.,,"",,,,.F. )
	ACTIVATE MSDIALOG oDlgImp Centered
Return

/*
Função: PCP048A()
Data: 29/02/16
Por: Evandor Gomes
Descrição: Seleciona Arquivo
*/
Static Function PCP048A()
	Local lRet	:= .F.
	cPatFil:= cGetFile('Arquivo *|*.*|Arquivo CSV|*.CSV','Todos as Unidades',0,'C:\',.T.,,.F.)
	If File(cPatFil)
		lRet:=.T.
	Else
		cPatFil	:= SPACE(100)
		MsgStop("Arquivo N‹o Encontrado","PCP048A")
	Endif
	oPatFil:Refresh()
Return(lRet)

/*
Função: MFATA06F
Data: 29/02/16
Por: Evandor Gomes
Descrição: Importa arquivo de metas
*/
Static Function PCP048B()
	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados  	:= {}
	Local aErro 		:= {}
	Local nLin			:= 0
	Local nLinNi		:= 0
	Local aLin			:= {}
	Local lImporta	:= .T.
	Local nPos			:= 0
	Local lGrava		:= .T.	
	Private _cCodPro	:= ""
	Private _nQtd		:= 0

	If !File(cPatFil)
		AADD(aErro, {"Erro 006: O arquivo " + cPatFil + " nao foi encontrado. A importacao sera abortada!",cValToChar(nLin)})
		lImporta:= .F.
	EndIf

	If lImporta
		FT_FUSE(cPatFil)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()

			IncProc("Lendo arquivo texto de importação...")
			nLin++

			cLinha := FT_FREADLN()

			If Empty(cLinha)
				AADD(aErro, {"Erro 01: Linha em branco.",cValToChar(nLin)})
			Else
				//aLin := Strtokarr(cLinha,";") //->Separa(cLinha,";",.T.)
				aLin := Separa(cLinha,";",.T.)
				If Len(aLin) < 0
					AADD(aErro, {"Erro 02: Erro de estrutura na linha.",cValToChar(nLin)})
				ElseIf Len(aLin) == 1
					AADD(aErro, {"Erro 05: Linha com um campo somente.",cValToChar(nLin)})
				Else
					SB1->(dbSetOrder(1))
					If !SB1->(dbSeek(xFilial("SB1")+StrZero(Val(aLin[1]),5)))
						AADD(aErro, {"Erro 02: Produto nao encontrado: "+aLin[1]+".",cValToChar(nLin)})
					Else
						If Type(aLin[2]) <> "N"
							AADD(aErro, {"Erro 03: Valor nao e numerico.",cValToChar(nLin)})
						Elseif Val(aLin[2]) == 0
							AADD(aErro, {"Erro 04: Quantidade n‹o pode ser igual a 0 ",cValToChar(nLin)})
						Else
							aLin[2]:= cValToChar(aLin[2])
							aLin[2]:= StrTran(aLin[2],".","")
							aLin[2]:= StrTran(aLin[2],",",".")
							aLin[2]:= Val(aLin[2])
							RecLock("SB1", .F.)
							REPLACE B1_XPESROM WITH aLin[2]
							SB1->(MsUnLock())
							AADD(aErro, {"Sucesso: Linha processada com sucesso ",cValToChar(nLin)})
						Endif
					Endif
				Endif
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
		If nLin == 0
			AADD(aErro, {"Erro 99: Dados nao encontrados.",cValToChar(nLin)})
		Endif
	Endif

	If Len(aErro)==0
		AADD(aErro, {"Aviso 01: Arquivo importador com sucesso",cValToChar(nLin)})
	Endif
	U_MFATA07Z("Importacao de peso real",aErro)
Return

