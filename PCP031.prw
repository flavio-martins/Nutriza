#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#define DS_MODALFRAME   128
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP031()       ³ Autor ³ Evandro Gomes           ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Apontamento através de pesagem									  ³±±
±±³          ³			                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico - Nutriza											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³          Manutencoes efetuadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Função: PCP031X
Data: 29/02/16
Por: Evandor Gomes
Descrição: Seleciona tipo de pesagem pelo recurso
*/
User Function PCP031X()
	Private lAuto := Select('SX2')==0
	If lAuto
		RpcClearEnv()
		RpcSetType(3)
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SH1","SH2","SH3","SH4","SH6","ZPA" USER "aponta01" PASSWORD "l@2017nut" MODULO "PCP"
		U_PCP031(1)
	Else
		U_PCP031(1)
	Endif
Return

/*
Função: PCP031Z
Data: 29/02/16
Por: Evandor Gomes
Descrição: Seleciona Tipo de Pesagem Manual 
*/
User Function PCP031Z()
	Private lAuto := Select('SX2')==0
	If lAuto
		RpcClearEnv()
		RpcSetType(3)
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "SH1","SH2","SH3","SH4","ZPA" USER "aponta01" PASSWORD "l@2017nut" MODULO "PCP"
		U_PCP031(2)
	Else
		U_PCP031(2)
	Endif
Return


/*
Função: PCP031
Data: 29/02/16
Por: Evandor Gomes
Descrição: Interface de pesagem

nTpPes
1=Pesagem assistida Apontamento Produção
2=Pesagem manual Apontamento Produção
3=Pesagem contagem a Cegas
4=Pesagem manual Apontamento Contagem a Cegas
*/
User Function PCP031(_nTpPes,_cCodRec, _cCodPrd, _cCodOp,_cIdent,_nTara,_aRetX)

	Private cSCtr      		:= Space(1)
	Private cSData     		:= Space(1)
	Private cSFer      		:= Space(1)
	Private cSHor      		:= Space(1)
	Private cSRec      		:= Space(1)
	Private cSTara     		:= Space(1)
	Private nGCodRec   		:= Space(06) //-> Código do Recruso
	Private nGDescRec  		:= Space(40) //-> Descrição do Recurso
	Private nGCodOp    		:= Space(02) //-> Código do Operação
	Private nGOper    		:= Space(02) //-> Operação
	Private nGDescOp   		:= Space(40) //-> Descrição` da Operação
	Private nGCodProd  		:= Space(15) //-> Código do Produto
	Private nGDescProd 		:= Space(40) //-> Descrição do Produto
	Private nGData     		:= DATE() //-> Data Corrente da Operação
	Private nGHora     		:= TIME() //-> Hora corrente da operação
	//Private nGPeso     	:= SPACE(16) //-> Peso da Mercadoria
	Private nGPeso     		:= 0 //-> Peso da Mercadoria
	Private nGFerCod   		:= SPACE(06) //-> Código da Ferramente
	Private nGFerDesc  		:= SPACE(40) //-> Descrição da Ferramente
	Private nGStatus		:= SPACE(100) //->Status
	Private nGStErro		:= SPACE(100) //->Status
	Private nGOP   			:= Space(06) //-> Ordem de Produção
	Private oGOP
	Private nGOPLoc  		:= Space(02) //-> Local de ordem de produção
	Private oGOPLoc
	Private oGCodProd
	Private oGDescProd	
	Private oGCodRec
	Private oGDescRec
	Private oGCodOp
	Private oGDescOp
	Private oGFerCod
	Private oGFerDesc
	Private oGData
	Private oGHora
	Private lProsseg   		:= .F.
	Private oGStatus    
	Private oGStusEr
	Private oGFerCod
	Private oGPeso 
	Private nTempo			:= GetNewPar("MV_CONFTMP",500)
	Private cPorta			:= GetNewPar("MV_CONFBAL","COM1:4800,N,7,1")
	Private cTpPeso			:= GetNewPar("MV_PESOMAN",.T.)	//-> Tipo de Peso
	Private lPesMen			:= GetNewPar("MV_PESOENS",.F.)	//-> Mensagem no peso estabilizado
	Private lPesTar			:= GetNewPar("MV_PESOTAR",.T.)	//-> Subtrair tara na tela?
	Private TaraBal			:= 0	//->Tara de Balança
	Private TaraFer			:= 0	//->Tara da Ferramenta
	Private cTipApo			:= "1"
	Private cStaApo			:= "1"
	Private nTpPes			:= 1
	Private nTemDes			:= 0
	Private nTempPad		:= 0 //->Tempo padr‹o para operação
	Private _cItemSC2		:=""
	Private _cSequSC2		:=""
	Private _cIGrdSC2		:=""
	Private lFerFim			:= .F.
	Private _cPictPes		:= "@R 999,999"
	Private cIdent			:= Iif(_cIdent <> Nil ,_cIdent, "")
	Private _nTaraPar		:= Iif(_nTara <> Nil, _nTara, 0) //-> Tara enviada atravŽs do par‰metro

	/*

	cTpPeso
	=======
	1=Pesagem manual
	2=Pesagem
	3=Pesagem Estabilizada

	nTpPes
	======
	1=Pesagem assistida Apontamento Produção
	2=Pesagem manual Apontamento Produção
	3=Pesagem contagem a Cegas
	4=Pesagem manual Apontamento Contagem a Cegas

	Status de Apontamento
	=====================
	1=Apontamento não confirmado
	2=Apontamento confirmado
	*/

	nTpPes 	:= Iif(_nTpPes <> Nil, _nTpPes, 1) 
	cTipApo 	:= cValTochar(nTpPes)
	cStaApo	:= "1" 

	If _cCodRec <> Nil .And. _cCodPrd <> Nil .And. _cCodOp <> Nil
		nGCodRec	:= _cCodRec
		nGCodOp		:= _cCodOp
		nGDescOp	:= ""
		nGCodProd	:= _cCodPrd
		nGDescProd	:= Posicione("SB1",1, XFILIAL("SB1")+_cCodPrd,"B1_DESC")
	Else
		//->Seleciona Balança
		DEFINE MSDIALOG oDlgRec Title "Identificação de Recurso" From 0,0 TO 170,250 Pixel Style DS_MODALFRAME
		oDlgRec:lEscClose:=.F. //--> Nao permite sair ao se pressionar a tecla ESC.
		@ 05,05 Say "Codigo do Recurso: "
		@ 04,60 MSGET oGCodRec VAR nGCodRec SIZE 50,10 Of oDlgRec F3 "SH1"  Valid ;
		PCP031A("SH1",1,xFilial("SH1")+nGCodRec,"H1_FILIAL+H1_CODIGO","Recurso Inválido","","") Pixel
		@ 20,05 Say "Codigo da Operac.: "
		@ 19,60 MSGET oGCodOp VAR nGCodOp SIZE 50,10 Of oDlgRec  F3 "SG2" VALID ;
		PCP031A("SG2",4,xFilial("SG2")+nGCodRec,"G2_FILIAL+G2_RECURSO","Amarraçã recurso x operação Inválida","","SG2->G2_CODIGO=='"+nGCodOp+"'") Pixel
		oBGrv:= TButton():New( 60,30,"&Ok",oDlgRec,{|u|Close(oDlgRec)},037,012,,,,.T.,,"",,,,.F. )
		oBFechar:= TButton():New( 60,72,"&Fechar",oDlgRec,{|u|lProsseg:=.F.,Close(oDlgRec)},037,012,,,,.T.,,"",,,,.F. )
		ACTIVATE MSDIALOG oDlgRec Centered
	Endif

	//->Parâmetros
	dbSelectArea("SH1")
	dbSetOrder(1)
	If dbSeek(xFilial("SH1")+nGCodRec)
		nTempo		:= SH1->H1_PESOSLE
		cPorta		:= AllTrim(SH1->H1_INTEPAR)
		cTpPeso		:= SH1->H1_TPPESO
		lPesMen		:= SH1->H1_PESOMEN=="S"
		TaraBal		:= SH1->H1_TARABAL
		nGDescRec	:= SH1->H1_DESCRI
	Else
		Alert("Recurso nao encontrado. Recurso: ["+nGCodRec+"]")
		Return(0)
	Endif

	//->Caso a interface
	If nTpPes==2 .Or. nTpPes==4 //-> Peso manual
		cTpPeso:="1"
	Endif

	SetPrvt("ofCurReg14","ofCurNeg16","ofCurNeg26","ofCurNeg50","ofCurNeg70","oDlgApto01","oPl01","oSCtr")

	ofCurReg14		:= TFont():New( "Courier New",0,-21,,.F.,0,,400,.F.,.F.,,,,,, )
	ofCurNeg16		:= TFont():New( "Courier New",0,-26,,.T.,0,,700,.F.,.F.,,,,,, )
	ofCurNeg26		:= TFont():New( "Courier New",0,-28,,.T.,0,,700,.F.,.F.,,,,,, )
	ofCurNeg50		:= TFont():New( "Courier New",0,-67,,.T.,0,,700,.F.,.F.,,,,,, )
	ofCurNeg156	:= TFont():New( "Courier New",0,-190,,.T.,0,,700,.F.,.F.,,,,,, )

	nGPeso	:=0
	//->oDlgApto01 := MSDialog():New( 029,287,676,1240,"Apontamento",,,.F.,,,,,,.T.,,,.T. )

	If nTpPes == 3
		SetKey(VK_F12,{|u|U_PCP031P(@_aRetX)}) // Pesar
	Endif


	DEFINE MSDIALOG oDlgApto01 Title "Apontamento de Produção" From 0,0 TO 650,940 Pixel Style DS_MODALFRAME
    oDlgApto01:lEscClose:=.F.
	@ 001,004 SAY oSRec PROMPT "Recurso:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 014,004 MSGET oGCodRec VAR nGCodRec SIZE 062,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL
	@ 014,067 MSGET oGDescRec VAR nGDescRec SIZE 150,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL

	@ 001,225 SAY oSOp PROMPT "Operação" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 014,224 MSGET oGCodOp VAR nGCodOp SIZE 030,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL
	@ 014,255 MSGET oGDescOp VAR nGDescOp SIZE 90,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL

	@ 001,353 SAY oSOpR PROMPT "O.P." OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 014,351 MSGET oGOP VAR nGOP SIZE 62,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL

	@ 001,420 SAY oOPLoc PROMPT "Local" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 014,419 MSGET oGOPLoc VAR nGOPLoc SIZE 40,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL

	@ 041,004 SAY oSProd PROMPT "Produto:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 053,004 MSGET oGCodProd VAR nGCodProd SIZE 107,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!";
	VALID  IIF(nTpPes==3, .T., PCP031L() .And. PCP031M()) F3 'SB1';
	COLORS 0, 16777215 PIXEL WHEN Iif(nTpPes==3,.F.,.T.)
	@ 053,113 MSGET oGDescProd VAR nGDescProd SIZE 355,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215 PIXEL

	@ 078,004 SAY oSFerra PROMPT "Ferramenta:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 090,004 MSGET oGFerCod VAR nGFerCod SIZE 107,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" VALID Iif(nTpPes==3,.T.,PCP031J()) WHEN .T. F3 'SH4' COLORS 0, 16777215 PIXEL
	@ 090,113 MSGET oGFerDesc VAR nGFerDesc SIZE 355,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" WHEN .F. COLORS 0, 16777215  PIXEL

	/*
	@ 041,280 SAY oSData PROMPT "Data:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 053,280 SAY oGData PROMPT nGData SIZE 085,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" COLORS 0, 16777215 PIXEL
	@ 041,395 SAY oSHora PROMPT "Hora:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	@ 053,393 SAY oGHora PROMPT nGHora SIZE 085,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" COLORS 0, 16777215 PIXEL
	*/


	@ 115,004 SAY oSPeso PROMPT "Peso:" OF oDlgApto01 FONT ofCurNeg16 PIXEL
	//->@ 090,113 SAY oGFerDesc PROMPT nGFerDesc SIZE 355,022 OF oDlgApto01 FONT ofCurNeg26 PICTURE "@!" COLORS 0, 16777215  PIXEL
	//PICTURE "@E 999.999"9
	@ 135,004 MSGET oGPeso VAR nGPeso SIZE 464,123 OF oDlgApto01 FONT ofCurNeg156 PICTURE PesqPict("SH6","H6_QTDPROD") COLORS 16777215, 65280 VALID Iif(nTpPes==3, .T., Iif(cTpPeso=="1",PCP031F(),PCP031J()))  WHEN Iif(cTpPeso=="1",.T.,.F.) PIXEL 
	@ 270,004 GET oGStatus VAR nGStatus OF oDlgApto01 MULTILINE SIZE 460, 040 COLORS 0, 265 FONT ofCurNeg16 READONLY HSCROLL PIXEL`
	@ 270,004 GET oGStusEr VAR nGStErro OF oDlgApto01 MULTILINE SIZE 460, 040 COLORS 0, 265 FONT ofCurNeg16 READONLY HSCROLL PIXEL
	oGStatus:SetCSS("QTextEdit{ background-color: rgb(52,133,84); color: rgb(255,255,255);}")
	oGStusEr:SetCSS("QTextEdit{ background-color: rgb(228,22,29); color: rgb(255,255,255);}")
	oGStatus:Hide()
	oGStusEr:Hide()
	lProsseg:=.T.
	//oDlgApto01:Activate(,,,.T.)
	Activate MSDIALOG oDlgApto01 CENTERED 
Return(IIF(nTpPes==3 ,_aRetX, 0)) 

/*
Função: PCP031A
Data: 29/02/16
Por: Evandor Gomes
Descrição: 
*/
Static Function PCP031A(_cTable,_nOrder,_cChave,_cCampos,_cMens,_cCampo,_cFunction)
	Local lRet	:= .F.
	//->Valida Recurso
	(_cTable)->(dbSetOrder(_nOrder))
	If (_cTable)->(dbSeek(_cChave))
		While !(_cTable)->(Eof()) .And. _cChave==(_cTable)->(&_cCampos)
			If !Empty(AllTrim(_cFunction))
				If &_cFunction
					Return .T.
				Endif
			Else
				Return .T.
			Endif
			(_cTable)->(dbSkip())
		Enddo
	Endif

	If !Empty(_cMens) .And. !lRet
		PCP031K(2,OemToAnsi(_cMens))
		If lPesMen
			Alert(_cMens)
		Endif
	Endif
Return lRet

/*
Função: PCP031B
Data: 29/02/16
Por: Evandor Gomes
Descrição: Set variáveis com valores padrão
*/
Static Function PCP031B()
	Local lRet	:= .T.
	nGData:= DATE() //-> Data Corrente da Operação
	nGHora:= TIME() //TIME() //-> Hora corrente da operação
	/*oGData:Refresh()
	oGHora:Refresh()*/
Return lRet

/*
Função: PCP031C
Data: 29/02/16
Por: Evandor Gomes
Descrição: Realiza Peso estabilizado
*/
Static Function PCP031C()
	Local nHand			:= 1
	Local cString		:= ""
	Local cRetVar		:= "-1"
	Local cMens			:= "Deseja repesar?"
	Local bEstab		:= .T.
	Local cStrPes		:= ""
	Local nSomaPes		:= 0
	Local _cPedMlt		:= ""
	Private cPeso		:= ""

	PCP031B() //->Data/Hora de Início da Pesagem

	oGPeso:SetFocus()

	While .T.

		cString		:= ""
		cPeso		:= ""
		aPesos		:= {}
		bEstab		:= .T.

		If MsOpenPort(nHand,cPorta) //-> Abrindo porta
			Sleep(nTempo)           //-> Tempo para capturar os dados

			MSRead(nHand, @cPeso)   //-> Capturando os dados
			MsClosePort(nHand)      //-> Fechando porta

			cStrPes := cPeso		//-> String Enviado pela Balança

			nIni := At(Chr(2), cPeso)
			nFim := Rat(Chr(2), cPeso)-1

			// Irregularidade de conexão ou falta dos caracteres delimitadores
			If (nIni = -1 .or. nFim = -1) // .Or. (nIni = 0 .or. nFim = 0)
				PCP031K(2,OemToAnsi("A balança está desligada ou o cabo está desconectado.("+AllTrim(cStrPes)+"). Porta: "+cPorta+ chr(13)))
				If lPesMen
					cMsg := "A balança está desligada ou o cabo está desconectado ou a" + chr(13)
					cMsg += "conexão informada no parametro MV_CONFBAL ou no cadastro de recursos está errada." + chr(13)
					cMsg += "não foi possível encontrar os caracteres delimitadores." + chr(13)
					cMsg += "Porta: "+cPorta+ chr(13)
					cMsg += OemToAnsi("Deseja fazer uma nova tentativa?")
					If MsgYesNo(cMsg,OemToAnsi('ATENCAO'))
						Loop
					Else
						Exit
					EndIf
				Else
					Loop 
				Endif
			EndIf    

			//-> cPeso 	:= substr(cPeso, nIni, (nFim - nIni) + 1 )

			nGPeso		:=0
			oGPeso:Refresh()
			cPeso 		:= substr(cPeso, nIni + 1,nFim)
			aPesos 		:= PCP031D(Chr(2), cPeso) //->Trata String/Protocolo da Balança
			_cPedMlt 	:= Substr(aPesos[1],4,6) //+ Replicate("0", TamSx3("H6_QTDPROD")[2])
			_cPedMlt	:= Substr(_cPedMlt,1,Len(_cPedMlt)-1)+"."+Substr(_cPedMlt,Len(_cPedMlt),1)
			If lPesTar
				nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //Val(nGPeso)-((TaraBal+TaraFer)*1000)
			Else
				nGPeso 	:= Val(_cPedMlt)
			Endif
			oGPeso:Refresh()

			//-> Poucas Amostras
			If len(aPesos) < 4
				PCP031K(2,OemToAnsi("Não foi possível adquirir o peso devido a poucas amostas. Amostras conseguidas("+cValToChar(Len(aPesos))+")")) 
				If lPesMen
					cMsg := OemToAnsi("Não foi possível adquirir o peso devido a poucas amostas.") + chr(13)
					cMsg += OemToAnsi("Deseja fazer uma nova tentativa?")
					If MsgYesNo(cMsg,OemToAnsi('ATENCAO'))
						Loop
					Else
						Exit
					EndIf
				Else
					Loop
				Endif
			EndIf

			//-> Verificando a Estabilidade
			nSomaPes 	:= 0
			nL			:= 0

			bEstab := .T.
			For x := 1 to len(aPesos)
				nL+=1
				If aPesos[x] != aPesos[1]
					bEstab := .F.
					Exit
				EndIf
				nSomaPes += Val(Substr(aPesos[x], 4, 6))
			Next

			nSomaPes=nSomaPes/nL  

			//->Testa Peso Zerado
			If nSomaPes == 0 .And. nL > 0 .And. bEstab
				PCP031K(2,OemToAnsi("O Peso da balança está zerado.("+ AllTrim(Transform(nSomaPes,PesqPict("SH6","H6_QTDPROD")))+")"))
				If lPesMen
					cMsg := OemToAnsi("O Peso da balança está zerado.("+ AllTrim(Transform(nSomaPes,PesqPict("SH6","H6_QTDPROD")))+")") + chr(13)
					cMsg += OemToAnsi("Deseja fazer uma nova tentativa?")
					If MsgYesNo(cMsg,OemToAnsi('ATENCAO'))
						Loop
					Else
						Exit
					EndIf
				Else
					Loop
				Endif
			Endif

			//->Testa Peso de tara
			If nSomaPes = TaraBal .And. nL > 0 .And. bEstab
				PCP031K(2,OemToAnsi("O Peso da balança está no mesmo peso da tara do Recurso.("+ AllTrim(Transform(nSomaPes,PesqPict("SH6","H6_QTDPROD")))+")"))
				If lPesMen
					cMsg := OemToAnsi("O Peso da balança está no mesmo peso da tara do Recurso.("+ AllTrim(Transform(nSomaPes,PesqPict("SH6","H6_QTDPROD")))+")") + chr(13)
					cMsg += OemToAnsi("Deseja fazer uma nova tentativa?")
					If MsgYesNo(cMsg,OemToAnsi('ATENCAO'))
						Loop
					Else
						Exit
					EndIf
				Else
					Loop
				Endif
			Endif

			//->Verifica se o peso estabilizou
			If !bEstab
				PCP031K(2,OemToAnsi("O peso da balança não está estabilizado.("+ AllTrim(Transform(nGPeso,PesqPict("SH6","H6_QTDPROD")))+")"))
				Loop
			Endif

			// Verificando Peso Negativo
			If asc(substr(aPesos[1], 1, 1)) = 45
				PCP031K(2,OemToAnsi("O peso da balança está NEGATIVO.("+ AllTrim(Transform(nGPeso,PesqPict("SH6","H6_QTDPROD")))+")"))
				Loop
			EndIf

			// Verificando Sobrecarga
			If asc(substr(aPesos[1], 7, 1)) = 32
				PCP031K(2,OemToAnsi("Sobre-carga na Balança.("+ AllTrim(Transform(nGPeso,PesqPict("SH6","H6_QTDPROD")))+")"))
				Loop
			EndIf

			// Balança Zerada
			If substr(aPesos[1], 4, 6) = "000000"
				PCP031K(2,OemToAnsi("Balança sem Carga.("+ AllTrim(Transform(nGPeso,PesqPict("SH6","H6_QTDPROD")))+")"))
				oGStusEr:Refresh()
				Loop
			EndIf

			// Peso Correto
			_cPedMlt 	:= Substr(aPesos[1],4,6) //+ Replicate("0", TamSx3("H6_QTDPROD")[2])
			_cPedMlt	:= Substr(_cPedMlt,1,Len(_cPedMlt)-1)+"."+Substr(_cPedMlt,Len(_cPedMlt),1)
			If lPesTar
				nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //-Val(nGPeso)-((TaraBal+TaraFer)*1000)
			Else
				nGPeso 	:= Val(_cPedMlt)
			Endif
			PCP031K(1,OemToAnsi("Gravando Peso...Peso Bruto: "+cValToChar(nGPeso)+" Tara: "+ AllTrim(Transform((TaraBal+TaraFer),"@E 9999999999.999"))+" Peso Liquido: "+ AllTrim(Transform(nGPeso-(TaraBal+TaraFer),"@E 9999999999.999"))+" -> "+Iif(lPesTar,"SubTrai Tara","Não SubTrai Tara")))
			oGPeso:Refresh()

			If nTpPes <> 3 //-> Não é conferência Cega
				If lFerFim
					PCP031H(1) //->Abre diálogo para identificar a ferramenta
				Else
					PCP031F()
				Endif
				Return .T.
			Else
				Return .T.
			Endif
		Else
			PCP031K(2,OemToAnsi("Não foi possível conectar a porta especificada...["+cPorta+"] - ("+cStrPes+")"))
			If !cTpPeso=="3"
				oGFerCod:SetFocus()
			Endif
			SysRefresh()
			Sleep(100)
			Exit
		EndIf
	EndDo
Return .F.

/*
Função: PCP031D
Data: 29/02/16
Por: Evandor Gomes
Descrição: Realiza Pesagem
*/
Static Function PCP031D(cSeparator, cString)
	Local aRetVar   := {}
	Local cTemp
	Local bExec 	:= .T.
	Local nPos
	While bExec
		nPos 		:= At(cSeparator, cString)
		If nPos = 0 .Or. Len(cString) ==1
			bExec 	:= .F.
			Exit
		EndIf
		cTemp := substr(cString, 1, nPos - 1)
		aadd(aRetVar, AllTrim(cTemp))
		cString := substr(cString, nPos + 1 )
	EndDo
Return aRetVar

/*
Função: PCP031E
Data: 29/02/16
Por: Valida Ferramenta
Descrição: Realiza Pesagem
*/
Static Function PCP031E()
	Local lRet	:= .T.
	If cTpPeso=="1" //-> Manual
		oGPeso:SetFocus()
	ElseIf cTpPeso=="2" //-> Direto
		PCP031G(@nGPeso,@nGStatus)
	Endif
Return lRet


/*
Função: PCP031F
Data: 29/02/16
Por: Evandro Gomes
Descrição: Grava Pesagem
*/
Static Function PCP031F()
	Local lRet			:= .T.
	Local cSql			:= ""
	Local cAliasZPA		:= GetNextAlias()
	Local nOpcM680 		:= 3 //inclus‹o
	Local aMata680		:= {}
	Local cHoraNow		:= Time()
	Local _xCodEti		:= ""
	Private lMsErroAuto := .F.

	If !PCP031L()
		Return(.F.)
	Endif

	//->Valida Ferramente
	SH4->(dbSetOrder(1))
	If !SH4->(dbSeek(xFilial("SH4")+ngFerCod))
		PCP031B()
		PCP031K(2,OemToAnsi("Ferramenta inválida."+nGFerCod+"-"+nGFerDesc))
		oGFerCod:SetFocus()
		SysRefresh()
		Return .F.
	Endif


	If nGPeso > 0

		cTime 	:= ElapTime(nGHora,Time())
		nPos	:= AT(":",cTime)
		cTime	:= SubStr(cTime,nPos+1,Len(cTime))

		_nPeso:= nGPeso

		/*
		Em caso de peso manual a subtração das taras é realizada no momento
		de salvar o registro
		*/
		If cTpPeso=="1" .And. lPesTar //-> Manual	
			_nPeso-= TaraBal
			_nPeso-= TaraFer
		Endif

		//->Insere Registro
		lMsErroAuto := .F.

		Begin Transaction
			aadd(aMata680,{"H6_FILIAL",xFilial("SH6"),NIL})
			aadd(aMata680,{"H6_OP",nGOP+_cItemSC2+_cSequSC2+_cIGrdSC2,NIL})
			aadd(aMata680,{"H6_PRODUTO",nGCodProd,NIL})
			aadd(aMata680,{"H6_OPERAC",nGOper,NIL}) //-> nGCodOp
			aadd(aMata680,{"H6_RECURSO",nGCodRec,NIL})
			aadd(aMata680,{"H6_FERRAM",nGFerCod,NIL})
			aadd(aMata680,{"H6_DATAINI",nGData,NIL})
			aadd(aMata680,{"H6_HORAINI",nGHora,NIL})
			aadd(aMata680,{"H6_DATAFIN",nGData,NIL})
			aadd(aMata680,{"H6_HORAFIN",IncTime(nGHora , 0 , 2 , 10 ),NIL})
			aadd(aMata680,{"H6_QTDPROD",_nPeso,NIL})
			aadd(aMata680,{"H6_QTDPERD",0,NIL})
			aadd(aMata680,{"H6_PT",'P',NIL})
			aadd(aMata680,{"H6_DTAPONT",nGData,NIL})
			aadd(aMata680,{"H6_TEMPO",cTime,NIL})
			//aadd(aMata680,{"H6_DTVALID",nGData,NIL})
			aadd(aMata680,{"H6_OPERADO",AllTrim(cUserName),NIL})
			aadd(aMata680,{"H6_PERDANT",TaraBal+TaraFer,NIL}) //->Tara de Balança + Tara da Ferramenta
			aadd(aMata680,{"H6_QTDPRO2",ConvUm(nGCodProd,_nPeso,0,2),NIL})
			aadd(aMata680,{"H6_RATEIO",100,NIL})
			//Verificar se o produto e pernil, se for buscao o armazem padrao do produto B1_LOCPAD
			If nGCodProd $ ('01827','60405','69780')
			aadd(aMata680,{"H6_LOCAL",'38',NIL})
			Else          
			aadd(aMata680,{"H6_LOCAL",'19',NIL})
	        Endif		
			//aadd(aMata680,{"H6_XETIQ",_xCodEti,NIL})
			aadd(aMata680,{"H6_XHRAPON",nGHora,NIL})
			aadd(aMata680,{"H6_XTARREC",TaraBal,NIL})
			aadd(aMata680,{"H6_XTARFER",TaraFer,NIL})
			MsExecAuto({|x,y|MATA681(x,y)},aMata680,nOpcM680)
			If lMsErroAuto
				MostraErro()
				//MostraErro('\system\','pcp021-1.txt')
				DisarmTransaction()
				PCP031K(2,OemToAnsi("Erro ao incluir o apontamento."))
				nGPeso:=0
				oGCodProd:Refresh()
				oGDescProd	:Refresh()
				oGCodOp:Refresh()
				oGDescOp:Refresh()
				oGFerCod:Refresh()
				oGFerDesc:Refresh()
				oGCodProd:SetFocus()
				Return .F.
			Else
				_xCodEti:='9'+SubStr(nGCodProd,1,5) + "9" + StrZero(SH6->(Recno()),9)
				RecLock("SH6",.F.)
				REPLACE H6_XETIQ WITH _xCodEti
				SH6->(MsUnLock())  
				//->Imprime etiqueta
				/*
				1 - C—digo do produto na descriçao
				2 - Identificador
				3 - Qtd. de embalagens no Palete
				4 - Peso Liquido ( nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //-Val(nGPeso)-((TaraBal+TaraFer)*1000))
				5 - Peso Bruto
				6 - Descrição do Palete
				*/
				iF !(nTpPes == 3)
				U_PCP031N({nGCodProd, _xCodEti, StrZero(0,4), _nPeso, Iif((cTpPeso=="1" .And. lPesTar) .Or. (cTpPeso<>"1" .And. lPesTar), _nPeso+(TaraBal+TaraFer), _nPeso) , SubStr(nGDescProd,1,40),""},"")
				EndIf
			Endif
		End Transaction

		PCP031B()
		PCP031K(1,OemToAnsi("Gravado Ferramenta:"+ AllTrim(nGFerCod) +"/Peso: " + AllTrim(Transform(nGPeso,PesqPict("SH6","H6_QTDPROD")))))

		nGCodProd  	:= Space(15) //-> Código do Produto
		nGDescProd 	:= Space(40) //-> Descrição do Produto
		nGFerCod   	:= SPACE(06) //-> Código da Ferramente
		nGFerDesc  	:= SPACE(40) //-> Descrição da Ferramente
		nGOP   		:= Space(06) //-> Ordem de Produção
		nGPeso			:= 0
		oGCodProd:Refresh()
		oGDescProd	:Refresh()
		oGCodOp:Refresh()
		oGDescOp:Refresh()
		oGFerCod:Refresh()
		oGFerDesc:Refresh()
		oGCodProd:SetFocus()
	Else
		cMsg := OemToAnsi("Impossivel grava. Peso Zerado.") + chr(13)
		PCP031K(2,cMsg)
		If lPesMen
			Alert(cMsg)
		Endif
	Endif	
Return(lRet)

/*
Função: PCP031G
Data: 29/02/16
Por: Evandor Gomes
Descrição: Realiza Peso Direto
*/
Static Function PCP031G()
	PCP031C()
Return

/*
Função: PCP031H
Data: 29/02/16
Por: Evandor Gomes
Descrição: Confirma Pesagem para peso estabilizado
*/
Static Function PCP031H(nTipo)
	Local oBGrv
	Local nGFerCodC	:= SPACE(6)
	Private oGFerCodC
	Private oDlgConf
	DEFINE MSDIALOG oDlgConf Title "Confirma Pesagem" From 0,0 TO 170,250 Pixel Style DS_MODALFRAME
	oDlgConf:lEscClose:=.F. //--> Nao permite sair ao se pressionar a tecla ESC.
	@ 05,05 Say "Cod. Ferramenta: "
	@ 04,60 MSGET oGFerCodC VAR nGFerCodC SIZE 50,10 Of oDlgConf F3 "SH4" VALID Iif(nTipo==1,Iif(PCP031I(nGFerCodC),Close(oDlgConf),.F.),PCP031C(nGFerCodC)) Pixel
	oBFechar := TButton():New( 60,040,"&Fechar",oDlgConf,{|u|Close(oDlgConf),oGFerCod:SetFocus()},037,012,,,,.T.,,"",,,,.F. )
	ACTIVATE MSDIALOG oDlgConf Centered
Return

/*
Função: PCP031I
Data: 29/02/16
Por: Evandor Gomes
Descrição: Confirma Pesagem modelo 2
*/
Static Function PCP031I(nGFerCodC)
	Local lRet	:= .T.

	//-> Caso a ferramenta venha em branco
	If Empty(AllTrim(nGFerCodC))
		Return .F.
	Endif

	//->Cancela a Gravação
	If AllTrim(nGFerCodC)="999999"
		PCP031K(2,OemToAnsi("Inclusão de Pesagem Cancelada..."))
		Close(oDlgConf)
		PCP031J()
		Return .T.
	Endif

	//->Valida ferramenta de finalização de pesagem
	If !PCP031A("SH4",1,xFilial("SH4")+nGFerCodC,"H4_FILIAL+H4_CODIGO",OemToAnsi("Ferramenta informada no final da pesagem Inválida"),"","")
		Return .F.
	ENdif

	//-> Valida Ferramenta
	If nGFerCod <> nGFerCodC
		PCP031K(2,OemToAnsi("Ferramenta informada no início da pesagem diferente da Ferramenta informada no final da pesagem"))
		cMsg := OemToAnsi("Ferramenta informada no início da pesagem diferente") + chr(13)
		cMsg := OemToAnsi("da Ferramenta informada no final da pesagem.") + chr(13)
		cMsg += OemToAnsi("Deseja Prosseguir?")
		If !MsgYesNo(cMsg,OemToAnsi('ATENCAO'))
			Return .F.
		Endif
	Endif

	nGFerCod:=nGFerCodC

	//->Prossegue com a gravação do Peso
	If lRet
		PCP031F()
		oGFerCod:SetFocus()
	Endif


Return(lRet)

/*
Função: PCP031J
Data: 29/02/16
Por: Evandor Gomes
Descrição: Confirma Modelo 1s
*/
Static Function PCP031J()
	Local lRet	:= .F.
	If nTpPes <> 3
		//->Valida Ferramenta para aliementar variáveis
		SH4->(dbSetOrder(1))
		If !SH4->(dbSeek(xFilial("SH4")+ngFerCod))
			PCP031B()
			PCP031K(2,OemToAnsi("Ferramenta Invalida."))
			Return .F.
		Endif
		nGFerDesc	:= AllTrim(SH4->H4_DESCRI)+AllTrim(" (Tara: "+ AllTrim(Transform(SH4->H4_TARA,"@E 9999999999.999"))+")")
		TaraFer	:= SH4->H4_TARA
		oGFerDesc:Refresh()
	Endif
	If cTpPeso=="3" //-> Peso Estabilizado
		//->Valida Ferramenta para aliementar variáveis
		lRet := PCP031C()
	Else //-> Outras Pesagens
		lRet := PCP031E()
	Endif
Return(lRet)

/*
Função: PCP031K
Data: 29/02/16
Por: Evandor Gomes
Descrição: Mensagem 
*/
Static Function PCP031K(nTipo,cMsn)

	If !lProsseg
		Return
	Endif

	If nTipo==1 //->Mensagem
		oGStusEr:Hide()
		oGStatus:Show()
		nGStatus:= OemToAnsi(cMsn)
		oGStatus:Refresh()	
	Elseif nTipo==2 //->Alerta de Erro
		oGStatus:Hide()
		oGStusEr:Show()
		nGStErro:= OemToAnsi(cMsn)
		oGStusEr:Refresh()
	Else
		oGStusEr:Hide()
		nGStErro:=""
		oGStatus:Hide()
		nGStatus:=""
	Endif
	SysRefresh()
Return


/*
Função: PCP031L
Data: 29/02/16
Por: Evandor Gomes
Descrição: Valida produto selecionado 
*/
Static Function PCP031L()
	Local lRet	:= .T.

	SB1->(dbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+nGCodProd))
		PCP031K(2,OemToAnsi("Produto nao contrado."))
		If lPesMen
			cMsg := "Produto nao encontrado." + chr(13)
			Alert(cMsg)
		Endif
		nGPeso:=0
		oGPeso:Refresh()
		Return .F.
	Endif

	cMsg:="Amarracao nao encontrada: Produto+Recurso+Operacao "+Chr(13)
	cMsg+="Produto:["+AllTrim(nGCodProd)+"] - Recurso:["+nGCodRec+"] - Operacao:["+nGCodOp+"]"
	If !PCP031A("SG2",1,xFilial("SG2")+nGCodProd+nGCodOp,"G2_FILIAL+G2_PRODUTO+G2_CODIGO",cMsg,"","SG2->G2_RECURSO=='"+nGCodRec+"'")
		nGPeso:=0
		oGPeso:Refresh()
		Return .F.
	Endif

	nGDescProd	:= Posicione("SB1",1,xFilial("SB1")+nGCodProd,"B1_DESC")

	nGDescOp	:=""
	nGOper		:=""

	SG2->(dbSetOrder(1)) //-> G2_FILIAL+G2_PRODUTO+G2_CODIGO+G2_OPERAC
	If SG2->(dbSeek(xFilial("SG2")+nGCodProd+nGCodOp))
		While !SG2->(Eof()).And. SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) == xFilial("SG2")+nGCodProd+nGCodOp
			If SG2->G2_RECURSO == nGCodRec
				nGOper		:= SG2->G2_OPERAC 
				nGDescOp	:= SG2->G2_DESCRI
				Exit
			Endif
			SG2->(dbSkip())
		Enddo
	Endif

	If Len(AllTrim(nGDescOp)) <= 0
		PCP031K(2,OemToAnsi("Operacao x Recurso nao encontrada."))
		nGPeso:=0
		oGPeso:Refresh()
		oGCodProd:SetFocus()
		Return .F.
	Endif
	nTemDes	:= Posicione("SG2",1,xFilial("SG2")+nGCodProd+nGCodOp,"G2_TEMPDES")

	oGCodProd:Refresh()
	oGCodRec:Refresh()
	oGDescRec:Refresh()
	oGCodOp:Refresh()
	oGDescOp:Refresh()
	oGDescProd:Refresh()
Return(lRet)


/*
Função: PCP031M
Data: 29/02/16
Por: Evandor Gomes
Descrição: Localiza Ordens de Producao em aberto para o produto e data
*/
Static Function PCP031M()
	Local cSql			:= ""
	Local _AliasSC2	:= GetNextAlias()
	Local lRet			:= .F.

	cSql:= "SELECT C2_NUM, C2_LOCAL, C2_ITEM, C2_SEQUEN, C2_ITEMGRD "
	cSql+= "FROM "+RETSQLNAME("SC2")+" SC2 "
	cSql+= "WHERE "
	cSql+= "C2_PRODUTO='"+nGCodProd+"' "
	cSql+= "AND C2_TPOP = 'F' "
	cSql+= "AND C2_EMISSAO >= '"+DTOS(nGData-3)+"' " //ajustado para nao pegar somente o dia atual (apos a meia noite) RQG
 	cSql+= "AND C2_DATRF='' "
	cSql+= "AND C2_QUJE < C2_QUANT " 
	cSql+= "AND SC2.D_E_L_E_T_ = ' ' "

	/*
	cSql+= "AND (SELECT COUNT(*) AS RegSD3 "
	cSql+= "FROM " + RetSqlName('SD3') + " SD3 "
	cSql+= "WHERE D3_FILIAL = '" + xFilial('SD3')+ "' "
	cSql+= "AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD "
	cSql+= "AND D3_ESTORNO <> 'S' "
	cSql+= "AND SD3.D_E_L_E_T_  = ' ') = 0 "

	cSql+= " AND (SELECT COUNT(*) AS RegSH6 "
	cSql+= " FROM " + RetSqlName('SH6') + " SH6 "
	cSql+= " WHERE H6_FILIAL = '" + xFilial('SH6')+ "'"
	cSql+= " AND H6_OP = C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD "
	cSql+= " AND D_E_L_E_T_  = ' ') = 0"
	*/

	cSql:=ChangeQuery(cSql)
	dbUseArea(.T.,"TopConn",TCGenQry(,,cSql),_AliasSC2,.F.,.T.)
	If !(_AliasSC2)->(Eof())
		nGOP:= (_AliasSC2)->C2_NUM
		nGOPLoc:= (_AliasSC2)->C2_LOCAL

		_cItemSC2:=(_AliasSC2)->C2_ITEM
		_cSequSC2:=(_AliasSC2)->C2_SEQUEN
		_cIGrdSC2:=(_AliasSC2)->C2_ITEMGRD

		oGOP:Refresh()
		oGOPLoc:Refresh()
		lRet:= .T.
		PCP031K(1,OemToAnsi("ORDEM DE PRODUCAO ENCONTRADA."))
	Else
		_cItemSC2:=""
		_cSequSC2:=""
		_cIGrdSC2:=""
		PCP031K(2,OemToAnsi("NAO EXISTE OP ABERTA DO PRODUTO PARA ESTA DATA."))
		nGOP:= Space(06) //-> Ordem de Produção
		oGOP:Refresh()
		nGOPLoc:= Space(02) //-> Local da Ordem de Produção
		oGOPLoc:Refresh()
		oGCodProd:SetFocus()
	Endif
	(_AliasSC2)->(dbCloseArea())
	If File(_AliasSC2+GetDBExtension())
		fErase(_AliasSC2+GetDBExtension())
	Endif
Return(lRet)



/*
Função: PCP031N
Data: 29/02/16
Por: Evandor Gomes
Descrição: Imprime Cartão Palete

1 - Código do produto na descrição
2 - Identificador
3 - Qtd. de embalagens no Palete
4 - Peso Liquido ( nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //-Val(nGPeso)-((TaraBal+TaraFer)*1000))
5 - Peso Bruto
6 - Descrição do Palete

*/
User Function PCP031N(aPrtEti)
	Local _cImp	:= ""
	If Len(aPrtEti)==0
		Return
	Endif
	/*
	_cImp += "^XA"+Chr(10)
	_cImp += "^FO261,94^GB0,100,2^FS"+Chr(10)
	_cImp += "^FO505,94^GB0,50,2^FS"+Chr(10)
	_cImp += "^FO382,94^GB0,100,2^FS"+Chr(10)
	_cImp += "^FO142,95^GB0,100,2^FS"+Chr(10)
	_cImp += "^FO630,15^GB0,180,2^FS"+Chr(10)
	_cImp += "^FO143,143^GB488,0,2^FS"+Chr(10)
	_cImp += "^FO13,193^GB618,0,2^FS"+Chr(10)
	_cImp += "^FO12,15^GB0,180,2^FS"+Chr(10)
	_cImp += "^FO13,94^GB618,0,1^FS"+Chr(10)
	_cImp += "^FO13,14^GB618,0,2^FS"+Chr(10)
	_cImp += "^FT530,107^A0N,12,24^FH\^FDKg Total^FS"+Chr(10)
	_cImp += "^FT397,107^A0N,12,24^FH\^FDUsuario^FS"+Chr(10)
	_cImp += "^FT265,159^A0N,12,24^FH\^FD"+ Iif(Len(aPrtEti[7]) > 0, aPrtEti[7], "Qtde Embal.")+ "^FS" +Chr(10)
	_cImp += "^FT178,159^A0N,12,24^FH\^FDF. P.^FS"+Chr(10)
	_cImp += "^FT281,107^A0N,12,24^FH\^FDDta. Imp.^FS"+Chr(10)
	_cImp += "^FT149,107^A0N,12,24^FH\^FDKg Liquido^FS"+Chr(10)
	_cImp += "^FT18,175^A0N,77,50^FH\^FD"+AllTrim(aPrtEti[1])+"^FS"+Chr(10) //->C—digo do produto na descrição
	_cImp += "^BY 3,5,500^FT734,200^BCI,,N,N"+Chr(10)
	_cImp += "^FD>:"+aPrtEti[2]+"^FS"+Chr(10) //-> Identificador
	_cImp += "^FT177,187^A0N,29,50^FH\^FD00^FS"+Chr(10)
	_cImp += "^FT272,187^A0N,29,50^FH\^FD"+aPrtEti[3]+"^FS"+Chr(10) //->Qtd. de embalagens no Palete
	_cImp += "^FT148,137^A0N,29,31^FH\^FD"+Transform(aPrtEti[4],"@E 9,999.99")+"^FS"+Chr(10) //->Peso Liquido ( nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //-Val(nGPeso)-((TaraBal+TaraFer)*1000))
	_cImp += "^FT270,137^A0N,29,31^FH\^FD"+ SubStr(DTOS(Date()),7,2) +"/"+ SubStr(DTOS(Date()),5,2) +"/"+ SubStr(DTOS(Date()),3,2) +"^FS"+Chr(10)
	_cImp += "^FT391,137^A0N,29,31^FH\^FD"+__cUserId+"^FS"+Chr(10)
	_cImp += "^FT516,137^A0N,29,31^FH\^FD"+Transform(aPrtEti[5],"@E 9,999.99")+"^FS"+Chr(10) //->Peso Bruto
	_cImp += "^FT392,190^A0N,56,24^FH\^FD"+aPrtEti[2]+"^FS"+Chr(10) //->C—dido do palete na descrição
	_cImp += "^FT25,86^A0N,91,28^FH\^FD"+AllTrim(aPrtEti[6])+"^FS"+Chr(10) //-> Descrição do Palete
	_cImp += "^XZ"+Chr(10)
    */

	ZP2->(dbSetOrder(1))
	ZP2->(dbSeek(xFilial()+_cEtq))

	//->Indica que etiqueta esta sendo impressa
	_cImp 	:= ZP2->ZP2_ETIQ
	_cImp 	:= StrTran(_cImp,"%cTpDesc%"			,NoAcento(Iif(_cXOpc=="1","PN - ","PK - ") + AllTrim(_cProd)))
	_cImp 	:= StrTran(_cImp,"%cCodProd%"			,NoAcento(AllTrim(_cCod)))
	_cImp 	:= StrTran(_cImp,"%cUN%"				,NoAcento(_cUM))
	_cImp 	:= StrTran(_cImp,"%cCodPall%"			,NoAcento(cCODETIQ))
	_cImp 	:= StrTran(_cImp,"%cDTVal%"				,NoAcento(DToC(_dDtVal)))
	_cImp 	:= StrTran(_cImp,"%cPesLiq%"			,NoAcento(Transform(_nPeso-nTARA,"@E 9,999.99")))
	_cImp 	:= StrTran(_cImp,"%cPesBrut%"			,NoAcento(Transform(_nPeso,"@E 9,999.99")))
	_cImp 	:= StrTran(_cImp,"%cOperador%"			,NoAcento(cusername))
	_cImp 	:= StrTran(_cImp,"%cDtHrImp%"			,NoAcento(dtoc(ddatabase)+" - "+time()))

	IF Isprinter("LPT1")
		MSCBPRINTER("S4M","LPT1",,,.f.,,,,)
		MSCBCHKStatus(.F.) // Não checa o "Status" da impressora - Sem esse comando nao imprime
		MSCBBEGIN(1,4)
		MSCBWrite(_cImp)
		MSCBEND()
		MSCBCLOSEPRINTER()
		//U_PCPRGLOG(_nTpLog,_cPal,"??")
	ELSE
		MsgAlert("A impressora não está ligada, conectada ou está ocupada!")
	ENDIF	
	
Return

User Function PCP031P(_aRetX)
	Local _xCodEti  	:= ""
	Local _aRet		:= {}
	SH4->(dbSetOrder(1))
	If !SH4->(dbSeek(xFilial("SH4")+nGFerCod))
		PCP031B()
		PCP031K(2,OemToAnsi("Ferramenta Invalida."))
		_aRetX:={"",0,0,0}
		Return({"",0,0,0})
	Else
		nGFerDesc	:= AllTrim(SH4->H4_DESCRI)+AllTrim(" (Tara: "+ AllTrim(Transform(SH4->H4_TARA,"@E 9999999999.999"))+")")
		TaraFer:=SH4->H4_TARA
	Endif

	If PCP031J()
		//->Imprime etiqueta
		/*	1 - Código do produto na descrição
		2 - Identificador
		3 - Qtd. de embalagens no Palete
		4 - Peso Liquido ( nGPeso 	:= Val(_cPedMlt)-(TaraBal+TaraFer) //-Val(nGPeso)-((TaraBal+TaraFer)*1000))
		5 - Peso Bruto
		6 - Descrição do Palete*/
		If !(nTpPes == 3)
		U_PCP031N({nGCodProd, cIdent, Transform(Iif(TaraFer>0, TaraFer,_nTaraPar),"@E 999.99"), nGPeso, nGPeso+((TaraBal+TaraFer)), SubStr(nGDescProd,1,40),"Tara"})
		EndIf
		Close(oDlgApto01)
	Else
		oGFerDesc:Refresh()
		_aRetX:={"",0,0,0}
		Return({"",0,0,0})
	Endif
	_aRetX:={nGFerCod,nGPeso,TaraFer,TaraBal}
Return(_aRetX)