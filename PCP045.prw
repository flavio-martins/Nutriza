#Include 'Protheus.ch'

#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCP045() ³ Autor ³ Evandro Gomes                 ³ Data ³ 15/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Relatório Etiquetas Por Palete			                          ³±±
±±³          ³			                            	                          ³±±
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
User Function PCP045()
	Local oReport
	Local cTitulo := "Relatorio Caixa Por Paletes"
	Private aWBrwPCP	:= {}
	Private cPerg		:= PADR("PCP045",10)
	Private _cEnvPer	:= GetNewPar("MV_ENVPER","PCP")
	Private _nTpLog	:= GetNewPar("MV_PCPTLOG",1)
	Private _lLog		:= .F.
	Private cAliasZP	:= "ZP1"

	PARAMETROS()
	Set century off
	oReport:=TReport():New("PCP045",cTitulo, , {|oReport| PCP045A(0,oReport)},cTitulo)
	oReport:SetPortrait(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintDialog()
	Set century on
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Executa Funcoes
*/
Static Function PCP045A(nOpc,oReport)
	If nOpc==0 //-> Seleciona
		oProcess := MsNewProcess():New( { || PCP045B(oReport) } , "Imprimindo..." , "Aguarde..." , .F. )
		oProcess:Activate()
	Endif
Return

/*
Por: Evandro Gomes
Em: 01/05/16
Descricao: Processa arquivo selecionado
ZP1_TIPO
1-Normal(Entrouesaiu do tunel)
2-Re-identicacao paletizacao(Saiu do tunel sem identificacao)
3-Re-Identificacao
4-Re-Identificacao Rotatividade
*/
Static Function PCP045B(oReport)
	Local lf := chr(13)+chr(10)
	Local cSql	:=""
	Local aInfoBen
	Local _cAliasZP	:= GetNextAlias()
	Local _cStatus	:= ""
	Local _nTipo
	Local _GrpAnt		:= ""

	aWBrwPCP:={}

	_nTipo:= MV_PAR08
	oProcess:SetRegua1(2)

	oSection1:= TRSection():New(oReport,"",{"Palete"})
	oSection1:SetTotalInLine(.F.)
	oSection1:ShowHeader()
	TRCell():New(oSection1,"A",cAliasZP,OemToAnsi("Palete"),PesqPict('ZP1',"ZP1_PALETE"),TamSx3("ZP1_PALETE")[1]+1)
	oSection1:SetLeftMargin(2)
	oSection1:SetPageBreak(.F.)
	oSection1:SetTotalText(" ")

	oSection2:= TRSection():New(oReport,"",{"Etiquetas"})
	oSection2:SetTotalInLine(.F.)
	oSection2:ShowHeader()
	TRCell():New(oSection2,"A",cAliasZP,OemToAnsi("Codigo"),PesqPict('SB1',"B1_COD"),5+1)
	TRCell():New(oSection2,"B",cAliasZP,OemToAnsi("Produto"),PesqPict('SB1',"B1_DESC"),TamSx3("B1_DESC")[1]+1)
	TRCell():New(oSection2,"C",cAliasZP,OemToAnsi("Etiqueta"),PesqPict('ZP1',"ZP1_CODETI"),TamSx3("ZP1_CODETI")[1]+1)
	TRCell():New(oSection2,"D",cAliasZP,OemToAnsi("Dta.Ativ"),PesqPict('ZP1',"ZP1_DTATIV"),TamSx3("ZP1_DTATIV")[1]+1)
	TRCell():New(oSection2,"E",cAliasZP,OemToAnsi("Dta.Fabr"),PesqPict('ZP1',"ZP1_DTPROD"),TamSx3("ZP1_DTPROD")[1]+1)
	TRCell():New(oSection2,"F",cAliasZP,OemToAnsi("Dta.Venc"),PesqPict('ZP1',"ZP1_DTVALI"),TamSx3("ZP1_DTVALI")[1]+1)
	TRCell():New(oSection2,"G",cAliasZP,OemToAnsi("R"),PesqPict('ZP1',"ZP1_REPROC"),TamSx3("ZP1_REPROC")[1]+1)
	TRCell():New(oSection2,"H",cAliasZP,OemToAnsi("Status"),PesqPict('ZP1',"ZP1_STATUS"),20+1)
	TRCell():New(oSection2,"I",cAliasZP,OemToAnsi("Carga"),PesqPict('ZP1',"ZP1_CARGA"),20+1)
	oSection2:SetLeftMargin(2)
	oSection2:SetPageBreak(.F.)
	oSection2:SetTotalText(" ")

	cSql := " 	SELECT ZP1_PALETE, ZP1_CODPRO, B1_DESC, ZP1_CODETI, ZP1_DTATIV, ZP1_DTPROD, ZP1_DTVALI, ZP1_STATUS, ZP1_REPROC, ZP1_CARGA "+lf
	cSql += " 	FROM "+RETSQLNAME("ZP1")+" ZP1  "+lf
	cSql += " 	INNER JOIN "+RETSQLNAME("SB1")+" SB1  "+lf
	cSql += "		ON B1_COD=ZP1_CODPRO  "+lf
	cSql += " 	WHERE "+lf
	cSql += " 	ZP1_PALETE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+lf
	If Empty(Alltrim(MV_PAR01)) .AND. Empty(Alltrim(MV_PAR02))
		cSql += " 	AND ZP1_STATUS IN ('2')  "+lf
		cSql += " 	AND ZP1_LOCAL = '10'  "+lf
		cSql += " 	AND ZP1_CARGA ='' "+lf
	Else
		cSql += " 	AND ZP1_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+lf
		cSql += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+lf
	Endif
	/*
	If Empty(Alltrim(MV_PAR01)) .AND. Empty(Alltrim(MV_PAR02)) .and.;
	!(MV_PAR08 .or. MV_PAR09 .or. MV_PAR10 .or. MV_PAR11 .or. MV_PAR12 .or. MV_PAR13 .or. MV_PAR14)
	cSql += " 	AND ZP1_STATUS IN ('2','1','9','7')  "+lf
	Else
	_cAux :="("
	do case
	case MV_PAR08
	_cAux +="'1',"
	case MV_PAR09
	_cAux +="'2',"
	case MV_PAR10
	_cAux +="'3',"
	case MV_PAR11
	_cAux +="'4',"
	case MV_PAR12
	_cAux +="'5',"
	case MV_PAR13
	_cAux +="'7',"
	case MV_PAR14
	_cAux +="'9',"
	EndCase
	_cAux := SubStr(_cAux,1,len(_cAux)-1)+")"
	cSql += " 	AND ZP1_STATUS IN "+_cAux+" "+lf
	EndIF
	If  !MV_PAR07
	cSql += " 	AND ZP1_CARGA ='' "+lf
	EndIF
	*/
	cSql += " 	AND ZP1.D_E_L_E_T_ <>'*' "+lf
	cSql += " ORDER BY ZP1_PALETE, ZP1_CODPRO, ZP1_CODETI "+lf

	cSql:=ChangeQuery(cSql)
	MemoWrite("c:\temp\"+funname()+"_Seleciona.sql",cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAliasZP,.T.,.F.)

	oProcess:IncRegua1("Selecionando...")
	oProcess:SetRegua2((_cAliasZP)->(LastRec()))
	(_cAliasZP)->(dbGoTop())

	While !(_cAliasZP)->(Eof())

		If (_cAliasZP)->ZP1_STATUS=="1"
			_cStatus:="1-ATIVADA"
		ElseIf (_cAliasZP)->ZP1_STATUS=="2"
			_cStatus:="2-EM CARREGAMENTO"
		ElseIf (_cAliasZP)->ZP1_STATUS=="3"
			_cStatus:="3-CARREGADA"
		ElseIf (_cAliasZP)->ZP1_STATUS=="4"
			_cStatus:="4-ROTATIVIDADE"
		ElseIf (_cAliasZP)->ZP1_STATUS=="5"
			_cStatus:="5-NAO INVENTARIADA"
		ElseIf (_cAliasZP)->ZP1_STATUS=="7"
			_cStatus:="7-SEQUESTRADA"
		ElseIf (_cAliasZP)->ZP1_STATUS=="9"
			_cStatus:="9-SUSPENSA"
		Else
			_cStatus:=(_cAliasZP)->ZP1_STATUS
		Endif

		AADD(aWBrwPCP,{;
		(_cAliasZP)->ZP1_PALETE,;
		(_cAliasZP)->ZP1_CODPRO,;
		(_cAliasZP)->B1_DESC,;
		(_cAliasZP)->ZP1_CODETI,;
		DTOC(STOD((_cAliasZP)->ZP1_DTATIV)),;
		DTOC(STOD((_cAliasZP)->ZP1_DTPROD)),;
		DTOC(STOD((_cAliasZP)->ZP1_DTVALI)),;
		(_cAliasZP)->ZP1_REPROC,;
		_cStatus,;
		(_cAliasZP)->ZP1_CARGA;
		})

		oProcess:IncRegua2("Produto: "+(_cAliasZP)->B1_DESC)

		(_cAliasZP)->(dbSkip())
	Enddo

	If Select(_cAliasZP) > 0
		(_cAliasZP)->(dbCloseArea())
		If File(_cAliasZP+GetDBExtension())
			fErase(_cAliasZP+GetDBExtension())
		Endif
	Endif

	//->Preenche dados do Browse
	If Len(aWBrwPCP) <= 0
		ASIZE(aWBrwPCP,0)
		aAdd(aWBrwPCP,{"","","","","","","","","","","","","","","","","","","","","",""})
	Endif

	oProcess:IncRegua1("Imprimindo...")
	oProcess:SetRegua2(Len(aWBrwPCP))

	For _I := 1 To Len(aWBrwPCP)

		If _GrpAnt <> aWBrwPCP[_I,1]
			If !Empty(_GrpAnt)
				oReport:ThinLine() //-- Impressao de Linha Simples
				oReport:SkipLine() //-- Salta linha
			Endif
			oSection2:Finish()
			oSection1:Cell("A"):SetValue(aWBrwPCP[_I,1])
			oSection1:PrintLine()
			_GrpAnt:=aWBrwPCP[_I,1]
			oSection2:Init()
		Endif

		oSection2:Cell("A"):SetValue(aWBrwPCP[_I,2])
		oSection2:Cell("B"):SetValue(aWBrwPCP[_I,3])
		oSection2:Cell("C"):SetValue(aWBrwPCP[_I,4])
		oSection2:Cell("D"):SetValue(CTOD(aWBrwPCP[_I,5]))
		oSection2:Cell("E"):SetValue(CTOD(aWBrwPCP[_I,6]))
		oSection2:Cell("F"):SetValue(CTOD(aWBrwPCP[_I,7]))
		oSection2:Cell("G"):SetValue(aWBrwPCP[_I,8])
		oSection2:Cell("H"):SetValue(aWBrwPCP[_I,9])
		oSection2:Cell("I"):SetValue(aWBrwPCP[_I,10])
		oSection2:PrintLine()

		oProcess:IncRegua2("Produto: "+aWBrwPCP[_I,3])

	Next _I
	oSection2:Finish()
	oSection1:Finish()

Return

/*
Por: Flávio Martins
Em: 06/12/18
Descricao: Cria Perguntas
*/

STATIC FUNCTION PARAMETROS()
	LOCAL APARAMBOX := {}
	LOCAL ARET 		:= {}

	AADD(APARAMBOX,{1,"Palete de    ?"		,SPACE(TAMSX3('ZP1_PALETE')[1]),PESQPICT("ZP1", "ZP1_PALETE"),'.T.',"" ,'.T.', 50, })
	AADD(APARAMBOX,{1,"Palete ate   ?"		,SPACE(TAMSX3('ZP1_PALETE')[1]),PESQPICT("ZP1", "ZP1_PALETE"),'.T.',"" ,'.T.', 50, })
	AADD(APARAMBOX,{1,"Do Armazém   ?"		,SPACE(TAMSX3('B1_LOCPAD')[1]),PESQPICT("SB1", "B1_LOCPAD"),'.T.',"NNR" ,'.T.', 50, })
	AADD(APARAMBOX,{1,"Até o Armazém?"		,SPACE(TAMSX3('B1_LOCPAD')[1]),PESQPICT("SB1", "B1_LOCPAD"),'.T.',"NNR" ,'.T.', 50, })
	AADD(APARAMBOX,{1,"Produto de   ?"		,SPACE(TAMSX3('ZP1_CODPRO')[1]),PESQPICT("ZP1", "ZP1_CODPRO"),'.T.',"SB1" ,'.T.', 50, })
	AADD(APARAMBOX,{1,"Produto ate  ?"		,SPACE(TAMSX3('ZP1_CODPRO')[1]),PESQPICT("ZP1", "ZP1_CODPRO"),'.T.',"SB1" ,'.T.', 50, })
	/*
	AADD(APARAMBOX,{4,"Sel. inclusive:"		,.F.,"Com carga",50,,.F.})
	AADD(APARAMBOX,{4,"1-ATIVADA"			,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"2-EM CARREGAMENTO"	,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"3-CARREGADA"			,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"4-ROTATIVIDADE"		,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"5-NAO INVENTARIADA"	,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"7-SEQUESTRADA"		,.F.,"",50,,.F.})
	AADD(APARAMBOX,{4,"9-SUSPENSA"			,.F.,"",50,,.F.})
	*/
	IF !PARAMBOX(APARAMBOX,"PARÂMETROS",@ARET)
		RETURN .F.
	ENDIF
RETURN .T.
