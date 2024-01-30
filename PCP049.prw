#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#include "TOPCONN.CH"
#define DS_MODALFRAME   128
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCP049()	 ºAutor  ³Evandro     º Data ³ 02/05/13   	    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta Invent‡rio												º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NUTRIZA							                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCP049()

	Local _aSay			:= {}
	Local _aButton		:= {}
	Local _xCabec			:= {}
	Private cTitulo		:= OemtoAnsi("Ajusta Inventário")
	Private _nOpca		:= 0
	Private cPerg			:= Padr("PCP049",10)
	Private oProcess

	//-> Cria Perguntas
	PCP049Z()
	Pergunte(cPerg,.T.)

	Aadd(_aSay, OemToAnsi('Este programa tem a finalidade de: ') )
	Aadd(_aSay, OemToAnsi('Analisar e Ajustar Inventário') ) 

	Aadd(_aButton, { 5,.T.,{|| Pergunte(cPerg,.T.)} } ) 
	AADD(_aButton, { 1,.T.,{|o| _nOpca:= 1,o:oWnd:End()}} )
	AADD(_aButton, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch(cTitulo, _aSay, _aButton,,, 428)
	If _nOpca == 1
		If MV_PAR02 == 1 .Or. MV_PAR02 == 2
			oProcess := MsNewProcess():New( { || GTOEFD1B() } , "Processando arquivo..." , "Aguarde..." , .F. )
			oProcess:Activate()
		ElseIf MV_PAR02 == 3
			oProcess := MsNewProcess():New( { || GTOEFD1A() } , "Processando arquivo..." , "Aguarde..." , .F. )
			oProcess:Activate()
		Endif
	Endif

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1A ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera Planilha							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function GTOEFD1A()
	Local cArquivo	:= "\System\InvProd\"+AllTrim(MV_PAR01)
	Local nCont   	:= 0	
	Local nHdl		:= nHdlA := 0
	Local nX
	Local nTamFile, nTamLin, cBuffer, nBtLidos
	Local lExiste 	:= .T.
	Local lHabil  	:= .F.
	Local aLinha	:= {}
	Local cLinha	:= ""
	Local nH 
	Local nLin		:= 0
	Local aSaldo	:= {}
	Local oFWMsExcel
	Local oExcel
	Local cArqSai	:= ""
	Private cEOL	:= "CHR(8)"
	/*
	If Empty(cEOL)
	cEOL := CHR(8)
	Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
	Endif
	*/	
	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.	
	EndIf

	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Arquivo aberto por outra aplicação.")
		EndIF
	EndIf

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)

	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	//nTamLinha := AT(cEOL,cBuffer )
	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	nLinhas := FT_FLastRec()
	oProcess:SetRegua1( nLinhas ) //Alimenta a primeira barra de progresso

	//->Planilha: Gera Parametrização
	nPosAt:=AT(".", AllTrim(MV_PAR01))

	cArqSai    := "c:\temp\"+Iif(nPosAt > 0,SubStr(AllTrim(MV_PAR01),1,nPosAt-1),AllTrim(MV_PAR01))+".XML"
	oFWMsExcel := FWMSExcel():New()
	oFWMsExcel:SetFontSize(12)                 //Tamanho Geral da Fonte
	oFWMsExcel:SetFont("Arial")                //Fonte utilizada
	//oFWMsExcel:SetBgGeneralColor("#000000")    //Cor de Fundo Geral
	oFWMsExcel:SetTitleBold(.T.)               //T’tulo Negrito
	oFWMsExcel:SetTitleFrColor("#94eaff")      //Cor da Fonte do t’tulo
	oFWMsExcel:SetLineFrColor("#000000")       //Cor da Fonte da primeira linha
	oFWMsExcel:Set2LineFrColor("#000000")      //Cor da Fonte da segunda linha

	//->Parametriza as Abas
	If MV_PAR03==1
		oFWMsExcel:AddworkSheet("Bloco A") //Nao utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco A","Estoque")
		oFWMsExcel:AddColumn("Bloco A","Estoque","Codigo",1)
		oFWMsExcel:AddColumn("Bloco A","Estoque","Descricao",1)
		oFWMsExcel:AddColumn("Bloco A","Estoque","Armazem",1)
		oFWMsExcel:AddColumn("Bloco A","Estoque","Peso",1)
		oFWMsExcel:AddColumn("Bloco A","Estoque","Caixas",1)
	Endif

	If MV_PAR04==1
		oFWMsExcel:AddworkSheet("Bloco B") //Nao utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco B","Inventario")
		oFWMsExcel:AddColumn("Bloco B","Inventario","Codigo",1)
		oFWMsExcel:AddColumn("Bloco B","Inventario","Descricao",1)
		oFWMsExcel:AddColumn("Bloco B","Inventario","Armazem",1)
		oFWMsExcel:AddColumn("Bloco B","Inventario","Peso",1)
		oFWMsExcel:AddColumn("Bloco B","Inventario","Caixas",1)
	Endif

	If MV_PAR05==1
		oFWMsExcel:AddworkSheet("Bloco C") //Nao utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco C","Diferencas")
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Codigo",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Descricao",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Armazem",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Peso Estoque",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Caixas Estoque",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Peso Inventario",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Caixas Inventario",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Peso Diferenca",1)
		oFWMsExcel:AddColumn("Bloco C","Diferencas","Caixas Diferenca",1)
	Endif

	If MV_PAR06==1
		oFWMsExcel:AddworkSheet("Bloco D") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco D","Paletes Nao Inventariados")
		oFWMsExcel:AddColumn("Bloco D","Paletes Nao Inventariados","Codigo",1)
		oFWMsExcel:AddColumn("Bloco D","Paletes Nao Inventariados","Descricao",1)
		oFWMsExcel:AddColumn("Bloco D","Paletes Nao Inventariados","Armazem",1)
		oFWMsExcel:AddColumn("Bloco D","Paletes Nao Inventariados","Palete",1)
	Endif

	If MV_PAR07==1
		oFWMsExcel:AddworkSheet("Bloco E") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco E","Caixas Nao Inventariadas")
		oFWMsExcel:AddColumn("Bloco E","Caixas Nao Inventariadas","Codigo",1)
		oFWMsExcel:AddColumn("Bloco E","Caixas Nao Inventariadas","Descricao",1)
		oFWMsExcel:AddColumn("Bloco E","Caixas Nao Inventariadas","Armazem",1)
		oFWMsExcel:AddColumn("Bloco E","Caixas Nao Inventariadas","Etiqueta",1)
		oFWMsExcel:AddColumn("Bloco E","Caixas Nao Inventariadas","Peso",1)
	Endif

	If MV_PAR08==1
		oFWMsExcel:AddworkSheet("Bloco F") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco F","Ativacoes")
		oFWMsExcel:AddColumn("Bloco F","Ativacoes","Codigo",1)
		oFWMsExcel:AddColumn("Bloco F","Ativacoes","Descricao",1)
		oFWMsExcel:AddColumn("Bloco F","Ativacoes","Armazem",1)
		oFWMsExcel:AddColumn("Bloco F","Ativacoes","Etiqueta",1)
		oFWMsExcel:AddColumn("Bloco F","Ativacoes","Peso",1)
	Endif

	If MV_PAR09==1
		oFWMsExcel:AddworkSheet("Bloco G") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco G","Inventario x Enderecamento(SintŽtico)")
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Codigo",1)
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Descricao",1)
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Armazem",1)
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Inventario",1)
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Enderecado",1)
		oFWMsExcel:AddColumn("Bloco G","Inventario x Enderecamento(SintŽtico)","Nao Enderecado",1)
	Endif

	If MV_PAR10==1
		oFWMsExcel:AddworkSheet("Bloco H") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco H","Inventario x Enderecamento(Anal’tico)")
		oFWMsExcel:AddColumn("Bloco H","Inventario x Enderecamento(Anal’tico)","Codigo",1)
		oFWMsExcel:AddColumn("Bloco H","Inventario x Enderecamento(Anal’tico)","Descricao",1)
		oFWMsExcel:AddColumn("Bloco H","Inventario x Enderecamento(Anal’tico)","Armazem",1)
		oFWMsExcel:AddColumn("Bloco H","Inventario x Enderecamento(Anal’tico)","Palete",1)
		oFWMsExcel:AddColumn("Bloco H","Inventario x Enderecamento(Anal’tico)","Endereco",1)
	Endif

	If MV_PAR11==1
		oFWMsExcel:AddworkSheet("Bloco I") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco I","Etiquetas Inventariadas")
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Codigo",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Descricao",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Armazem",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Etiqueta",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Palete",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Endereco",1)
		oFWMsExcel:AddColumn("Bloco I","Etiquetas Inventariadas","Peso",1)
	Endif

	If MV_PAR12==1
		oFWMsExcel:AddworkSheet("Bloco Z") //N‹o utilizar nœmero junto com sinal de menos. Ex.: 1-
		oFWMsExcel:AddTable("Bloco Z","Erros")
		oFWMsExcel:AddColumn("Bloco Z","Erros","Codigo",1)
		oFWMsExcel:AddColumn("Bloco Z","Erros","Descricao",1)
		oFWMsExcel:AddColumn("Bloco Z","Erros","Armazem",1)
		oFWMsExcel:AddColumn("Bloco Z","Erros","Caixas",1)
	Endif

	While !FT_FEOF()

		If nCont > nLinhas
			Exit
		Endif

		cLinbRT	:= Alltrim(FT_FReadLn())
		cLinbRT 	:= StrTran(Alltrim(cLinbRT),"|||||","| | | | |")
		cLinbRT 	:= StrTran(Alltrim(cLinbRT),"||||","| | | |")
		cLinbRT 	:= StrTran(Alltrim(cLinbRT),"|||","| | |")
		cLinbRT 	:= StrTran(Alltrim(cLinbRT),"||","| |")
		cLinha		:= cLinbRT
		aLinha 	:= StrTokArr(cLinha,"|")
		nRecno 	:= FT_FRecno() // Retorna a linha corrente

		oProcess:IncRegua1("Processando Bloco: "+Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))+" Linha: "+StrZero(nCont,6))


		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "A" .And. MV_PAR03==1
			oFWMsExcel:AddRow("Bloco A","Estoque",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			Val(Replace(Replace(aLinha[7],".",""),",",".")),;
			Val(Replace(Replace(aLinha[8],".",""),",","."));
			})
		Endif

		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "B" .And. MV_PAR04==1
			oFWMsExcel:AddRow("Bloco B","Inventario",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			Val(Replace(Replace(aLinha[7],".",""),",",".")),;
			Val(Replace(Replace(aLinha[8],".",""),",","."));
			})
		Endif

		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "C" .And. MV_PAR05==1
			oFWMsExcel:AddRow("Bloco C","Diferencas",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			Val(Replace(Replace(aLinha[7],".",""),",",".")),;
			Val(Replace(Replace(aLinha[8],".",""),",",".")),;
			Val(Replace(Replace(aLinha[9],".",""),",",".")),;
			Val(Replace(Replace(aLinha[10],".",""),",",".")),;
			Val(Replace(Replace(aLinha[11],".",""),",",".")),;
			Val(Replace(Replace(aLinha[12],".",""),",","."));
			})
		Endif

		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "D" .And. MV_PAR06==1
			oFWMsExcel:AddRow("Bloco D","Paletes Nao Inventariados",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			aLinha[7];
			})
		Endif

		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "E" .And. MV_PAR07==1
			oFWMsExcel:AddRow("Bloco E","Caixas Nao Inventariadas",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			aLinha[7],;
			Posicione("ZP1",1,xFilial("ZP1")+aLinha[7],"ZP1_PESO");
			})
		Endif

		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "F" .And. MV_PAR08==1
			oFWMsExcel:AddRow("Bloco F","Ativacoes",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			aLinha[7],;
			Posicione("ZP1",1,xFilial("ZP1")+aLinha[7],"ZP1_PESO");
			})
		Endif

		//->Bloco G
		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "G" .And. MV_PAR09==1
			oFWMsExcel:AddRow("Bloco G","Inventario x Enderecamento(SintŽtico)",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			Val(Replace(Replace(aLinha[7],".",""),",",".")),;
			Val(Replace(Replace(aLinha[8],".",""),",",".")),;
			Val(Replace(Replace(aLinha[9],".",""),",","."));
			})
		Endif

		//->Bloco H
		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "H" .And. MV_PAR10==1
			oFWMsExcel:AddRow("Bloco H","Inventario x Enderecamento(Anal’tico)",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			aLinha[7],;
			aLinha[8];
			})
		Endif

		//->Bloco I
		If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "I" .And. MV_PAR11==1
			oFWMsExcel:AddRow("Bloco I","Etiquetas Inventariadas",{;
			aLinha[2],;
			Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC"),;
			aLinha[3],;
			aLinha[7],;
			aLinha[8],;
			aLinha[9],;
			Posicione("ZP1",1,xFilial("ZP1")+aLinha[7],"ZP1_PESO");
			})
		Endif

		FT_FSKIP()  
		nCont++

	EndDo		
	FT_FUSE()
	fClose(nHdl )

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArqSai)

	If MsgBox("Deseja abrir o excel?","Atenção","YESNO")     
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New() //Abre uma nova conex‹o com Excel
		oExcel:WorkBooks:Open(cArqSai) //Abre uma planilha
		oExcel:SetVisible(.T.) //Visualiza a planilha
		oExcel:Destroy() //Encerra o processo do gerenciador de tarefas
	Endif
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1B ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Update em Blocos					 								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function GTOEFD1B()

	Local cArquivo	:= "\System\InvProd\"+AllTrim(MV_PAR01)
	Local nCont   	:= 0	
	Local nHdl		:= nHdlA := 0
	Local nX
	Local nTamFile, nTamLin, cBuffer, nBtLidos
	Local lExiste 	:= .T.
	Local lHabil  	:= .F.
	Local aLinha	:= {}
	Local cLinha	:= ""
	Local nH 
	Local nLin		:= 0
	Local aSaldo	:= {}
	Local oFWMsExcel
	Local oExcel
	Local cArqSai	:= ""
	Local _nErr	:= 0
	Local _aErr	:= {}
	Private cEOL	:= "CHR(8)"
	/*
	If Empty(cEOL)
	cEOL := CHR(8)
	Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
	Endif
	*/	
	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.	
	EndIf

	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Arquivo aberto por outra aplicação.")
		EndIF
	EndIf

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	Begin Transaction

		AADD(_aErr,{'Início do processo de ajuste de inventario:',""})
		AADD(_aErr,{'Data: '+dtoc(date()),""})
		AADD(_aErr,{'Hora: '+time(),""})

		FSEEK(nHdl,0,0 )
		nTamArq:=FSEEK(nHdl,0,2 )
		FSEEK(nHdl,0,0 )
		fClose(nHdl)

		FT_FUse(cArquivo )  //abre o arquivo
		AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Arquivo aberto com sucesso...',""})
		FT_FGoTop()         //posiciona na primeira linha do arquivo
		AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Posiciona na primeira Linha...',""})
		//nTamLinha := AT(cEOL,cBuffer )
		nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
		AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Tamanho da Linha:'+cValToChar(nTamLinha),""})
		FT_FGOTOP()

		nLinhas := FT_FLastRec()
		AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Qtd. Linhas:'+cValToChar(nLinhas),""})
		oProcess:SetRegua1( nLinhas ) //Alimenta a primeira barra de progresso
		_nErr:=0
		While !FT_FEOF()

			If nCont > nLinhas
				Exit
			Endif

			cLinbRT	:= Alltrim(FT_FReadLn())
			cLinbRT 	:= StrTran(Alltrim(cLinbRT),"|||||","| | | | |")
			cLinbRT 	:= StrTran(Alltrim(cLinbRT),"||||","| | | |")
			cLinbRT 	:= StrTran(Alltrim(cLinbRT),"|||","| | |")
			cLinbRT 	:= StrTran(Alltrim(cLinbRT),"||","| |")
			cLinha		:= cLinbRT
			aLinha 	:= StrTokArr(cLinha,"|")
			nRecno 	:= FT_FRecno() // Retorna a linha corrente

			oProcess:IncRegua1("Processando Bloco: "+Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))+" Linha: "+StrZero(nCont,6))

			//->Bloco A
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "A" .And. MV_PAR03==1
			Endif
			//->Bloco B
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "B" .And. MV_PAR04==1
			Endif
			//->Bloco C
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "C" .And. MV_PAR05==1
			Endif

			//->Bloco D
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "D" .And. MV_PAR06==1
				AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Produto: '+aLinha[2]+"-"+AllTrim(Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC")),""})
				If MV_PAR02 == 1 //.And. AllTrim(aLinha[2]) $ '52717/52718/52719' //->Update
					nStatus := TCSqlExec(AllTrim(aLinha[9]))
					If (nStatus < 0)
						_nErr++
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: AJUSTE - Etiqueta Palete: '+aLinha[7]+" -> ERRO AO TENTAR AJUSTAR","ERRO"})
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ERRO: '+TCSQLError(),"ERRO"})
						DisarmTransaction()
						U_MFATA07Z("Log de Processamento.",_aErr)
						Return .F.
					Else
						bBloco := &("{ || "+aLinha[11]+" }")
						EVAL(bBloco)
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: AJUSTE - Etiqueta Palete: '+aLinha[7]+" -> AJUSTE REALIZADO COM SUCEEO.","OK"})
					Endif
				Elseif MV_PAR02==2 //.And. AllTrim(aLinha[2]) $ '52717/52718/52719'//->RoolBack
					nStatus := TCSqlExec(AllTrim(aLinha[10]))
					If (nStatus < 0)
						_nErr++
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: ROLLBACK - Etiqueta Palete: '+aLinha[7]+" -> ERRO AO TENTAR ROLLBACK","ERRO"})
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ERRO: '+TCSQLError(),"ERRO"})
						DisarmTransaction()
						U_MFATA07Z("Log de Processamento.",_aErr)
						Return .F.
					Else
						bBloco := &("{ || "+aLinha[12]+" }")
						EVAL(bBloco)
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: ROLLBACK - Etiqueta Palete: '+aLinha[7]+" -> SUCESSO NO ROLLBACK","OK"})
					Endif
				Endif
			Endif
			//->Bloco E
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "E" .And. MV_PAR07==1
				AADD(_aErr,{'['+dtoc(date())+'-'+time()+']Produto: '+aLinha[2]+"-"+AllTrim(Posicione("SB1",1,xFilial("SB1")+aLinha[2],"B1_DESC")),""})
				If MV_PAR02 == 1 //.And. AllTrim(aLinha[2]) $ '52717/52718/52719'//->Update
					nStatus := TCSqlExec(AllTrim(aLinha[9]))
					If (nStatus < 0)
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: AJUSTE - Etiqueta Caixa: '+aLinha[7]+" -> ERRO AO TENTAR AJUSTE","ERRO"})
						_nErr++
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ERRO: '+TCSQLError(),"ERRO"})
						DisarmTransaction()
						U_MFATA07Z("Log de Processamento.",_aErr)
						Return .F.
					Else
						bBloco := &("{ || "+aLinha[11]+" }")
						EVAL(bBloco)
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: AJUSTE - Etiqueta Caixa: '+aLinha[7]+" -> AJUSTE REALIZADO COM SUCEEO.","OK"})
					Endif
				Elseif MV_PAR02==2 //.And. AllTrim(aLinha[2]) $ '52717/52718/52719'//->RoolBack
					nStatus := TCSqlExec(AllTrim(aLinha[10]))
					If (nStatus < 0)
						_nErr++
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: ROLLBACK - Etiqueta Caixa: '+aLinha[7]+" -> ERRO AO TENTAR ROLLBACK","ERRO"})
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ERRO: '+TCSQLError(),"ERRO"})
						DisarmTransaction()
						U_MFATA07Z("Log de Processamento.",_aErr)
						Return .F.
					Else
						bBloco := &("{ || "+aLinha[12]+" }")
						EVAL(bBloco)
						AADD(_aErr,{'['+dtoc(date())+'-'+time()+']ACAO: ROLLBACK - Etiqueta Caixa: '+aLinha[7]+" -> SUCESSO NO ROLLBACK","OK"})
					Endif

				Endif
			Endif
			//->Bloco F
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "F" .And. MV_PAR08==1
			Endif
			//->Bloco G
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "G" .And. MV_PAR09==1
			Endif
			//->Bloco H
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "H" .And. MV_PAR10==1
			Endif
			//->Bloco I
			If AllTrim(Iif(ValType(aLinha[1])=="N",cValToChar(aLinha[1]),Iif(ValType(aLinha[1])=="D",DToC(aLinha[1]),aLinha[1]))) == "I" .And. MV_PAR11==1
			Endif

			FT_FSKIP()  
			nCont++

		EndDo		
		FT_FUSE()
		fClose(nHdl )
		AADD(_aErr,{'Fim do processo de ajuste de inventario:',""})
		AADD(_aErr,{'Data: '+dtoc(date()),""})
		AADD(_aErr,{'Hora: '+time(),""})
		AADD(_aErr,{'Total de Linhas: '+cvaltochar(nLinhas),""})
		AADD(_aErr,{'Total de Linhas Processadas: '+cvaltochar(nCont),""})
		AADD(_aErr,{'Total de Erros: '+cvaltochar(_nErr),""})
		nCont=-_nErr
		AADD(_aErr,{'Total de Acertos: '+cvaltochar(nCont),""})
	End Transaction

	U_MFATA07Z("Log de Processamento.",_aErr)
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GTOEFD1Z ¦ Autor ¦ Evandro Oliveira Gomes¦ Data ¦16/02/2012¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ajusta SX1 Perguntas										  	¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
_____________________________________________________________________________
*/                                                                           
Static Function PCP049Z()

	U_OHFUNAP3(cPerg,"01","Nome do Arquivo?"	,"","","mv_ch1","C",50,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Operacao?"			,"","","mv_ch2","N",01,0,1,"C","","","","","MV_PAR02","Update","","","","RoolBack","","","Planilha","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"03","Bloco A?"	,"","","mv_ch3","N",01,0,1,"C","","","","","MV_PAR03","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"04","Bloco B?"	,"","","mv_ch4","N",01,0,1,"C","","","","","MV_PAR04","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"05","Bloco C?"	,"","","mv_ch5","N",01,0,1,"C","","","","","MV_PAR05","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"06","Bloco D?"	,"","","mv_ch6","N",01,0,1,"C","","","","","MV_PAR06","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"07","Bloco E?"	,"","","mv_ch7","N",01,0,1,"C","","","","","MV_PAR07","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"08","Bloco F?"	,"","","mv_ch8","N",01,0,1,"C","","","","","MV_PAR08","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"09","Bloco G?"	,"","","mv_ch9","N",01,0,1,"C","","","","","MV_PAR09","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"10","Bloco H?"	,"","","mv_cha","N",01,0,1,"C","","","","","MV_PAR10","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"11","Bloco I?"	,"","","mv_chb","N",01,0,1,"C","","","","","MV_PAR11","Sim","","","","Nao","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"12","Bloco Z?"	,"","","mv_chc","N",01,0,1,"C","","","","","MV_PAR12","Sim","","","","Nao","","","","","","","","","","","","","","")

Return
