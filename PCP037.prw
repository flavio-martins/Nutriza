#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "rwmake.ch"

//RELATำRIO DE ORDEM DE PRODUวรO (ZP1)	- IMPORTADOS/NรO IMPORTADOS 
User Function PCP037()   
	Local cEspaco    := chr(13)+chr(10)
	Local aItem
	Local nX                          
	Local aCabExcel :={}
	Local aItensExcel :={}

	////////////////////// FONTES PARA SEREM UTILIZADAS NO RELATORIO ///////////////////////////

	Private oFont6		:= TFONT():New("Arial",,6,.T.,.F.,5,.T.,5,.T.,.F.	) //Fonte 6 Normal
	Private oFont6N 	:= TFONT():New("Arial",,6,,.T.,,,,.T.,.F.			) //Fonte 6 Negrito
	Private oFont8		:= TFONT():New('Arial',,8,,.F.,,,,.F.,.F.		) //Fonte 9 Normal
	Private oFont8N		:= TFONT():New('Arial',,8,,.T.,,,,.F.,.F.		) //Fonte 9 Negrito
	Private oFont9N		:= TFONT():New('Arial',,9,,.T.,,,,.F.,.F.		) //Fonte 9 Negrito
	Private oFont10		:= TFONT():New('Arial',,10,,.F.,,,,.F.,.F.	) //Fonte 10 Normal
	Private oFont10N	:= TFONT():New('Arial',,10,,.T.,,,,.F.,.F.	) //Fonte 10 Negrito
	Private oFont16N	:= TFONT():New('Arial',,16,,.T.,,,,.F.,.F.	) //Fonte 13 Negrito

	////////////////////////////////////////////////////////////////////////////////////////////
	Private cStartPath
	Private nLin 		:= 50
	Private oPrint		:= TMSPRINTER():New("")
	Private nPag		:= 1
	Private _Emp
	Private ncont 		:= 1
	Private aDados 		:={}
	Private cDtEmiDe 	:= ""
	Private cDtEmiAte 	:= ""
	Private cPerg 		:= "PCP037"
	Private lSeguranca 	:= .F.
	Private lPerguntaOK := .F.
	Private nStatus
	Private cProdzp1	:= GetMv('MV_XPRDZP1')    
	Private nTotPeso	:= 0

	CriaPerguntas() // cria as perguntas para gerar o relat๓rio

	///////////////////// DEFINE O TAMANHO DO PAPEL /////////////////////////
	#define DMPAPER_A4 9 //Papel A4
	oPrint:setPaperSize( DMPAPER_A4 )
	oPrint:setup()
	/////////////////// DEFINE A ORIENTAวรO DO PAPEL ////////////////////////
	oPrint:SetPortrait()///Define a orientacao da impressao como retrato
	//oPrint:SetLandscape() ///Define a orientacao da impressao como paisagem

	LjMsgRun( "Recuperando registros, aguarde...", "Ordem de produ็ใo", {|| CorpoTexto() } )
	// preenche os dados do relat๓rio

	procregua(len(adados))

	if lSeguranca

		Cabecalho()
		nlin+=50
		nCont := 1
		while ncont <= Len(aDados)

			Incproc('Imprimindo...')
			if nLin > 3000 // delimita o fim da pagina			
				Rod()
				NovaPagina()
				nLin+= 50
			endif      

			//	oPrint:Say(nLin, 150, DTOC(STOD(aDados[nCont,1])),oFont8)  
			oPrint:Say(nLin, 450, aDados[nCont,1],oFont8) 
			oPrint:Say(nLin, 750, aDados[nCont,2],oFont8)  
			oPrint:Say(nLin, 2070, transform(aDados[nCont,3],pesqpict('ZP1','ZP1_PESO')),oFont8) 

			//nTotPeso	+= aDados[nCont,4]
			nTotPeso	+= aDados[nCont,3]

			nlin+=40                 
			nCont := nCont +1

		enddo

		nlin+=40
		oPrint:Say(nLin, 1900, "_______________________________",oFont8)
		nlin+=40	
		oPrint:Say(nLin, 2070, transform(nTotPeso,pesqpict('ZP1','ZP1_PESO')),oFont8)

		Rod()
		oPrint:Preview()

	endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELATORIO1บAutor  ณWellington Gon็alvesบ Data ณ  01/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o babe็alho do relatorio                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function Cabecalho()
	Set Date to British
	oPrint:StartPage() // Inicia uma nova pagina
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	nLin+=100
	oPrint:Box(nLin,150,nLin+150,2050)
	oPrint:Box(nLin,2050,nLin+150,2300)
	oPrint:SayBitmap(nLin+20, 200, cStartPath + "lgrl01.bmp", 150, 120)///Impressao da Logo
	nLin+=50
	oPrint:Say(nLin, 750, "RELAวรO DE ORDENS DE PRODUวรO", oFont16N)      
	nLin+=20
	oPrint:Say(nLin, 2070, "Pagina: " + strzero(nPag,3), oFont8) 
	nLin+=40
	oPrint:Say(nLin, 750, "Periodo: " + dtoc(cDtemiDe) + " เ " + dtoc(cDtemiAte), oFont8N) 
	if  nStatus = 1
		oPrint:Say(nLin,1300, "Status: Importada", oFont8N)
	endif  
	if  nStatus = 2
		oPrint:Say(nLin,1300, "Status: Nใo Importada", oFont8N)
	endif  

	nLin+=50
	//oPrint:Say(nLin,  150, "Data" 							, oFont10N)
	oPrint:Say(nLin,  450, "Cod. Produto"					, oFont10N)
	oPrint:Say(nLin,  750, "Descri็ใo"  		  		    , oFont10N)   
	oPrint:Say(nLin, 2070, "Peso" 					        , oFont10N)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELATORIO1บAutor  ณWellington Gon็alvesบ Data ณ  01/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Fun็ใo para criar o rodap้ do relatorio                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Rod()

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	nLin:=3200
	oPrint:Line (nLin, 150, nLin, 2300)
	nLin+=20
	oPrint:SayBitmap(nLin, 150, cStartPath + "logo_totvs.gif", 228, 050)///Impressao da Logo
	oPrint:Say(nLin, 150, FUNNAME(), oFont10N)
	oPrint:Say(nLin, 2000, dtoc(ddatabase)+' - '+TIME(), oFont8N)
	nLin+=50
	oPrint:Line (nLin, 150, nLin, 2300)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELATORIO1บAutor  ณWellington Gon็alvesบ Data ณ  01/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para preencher o relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CorpoTexto()
	Local cEspaco := chr(13)+chr(10)
	Local _cQry	:= ""

	//_cQry := " SELECT ZP1_DTATIV,ZP1_CODPRO, B1_DESC, COUNT(DISTINCT ZP1_CODETI) CAIXAS, SUM(ZP1_PESO) PESO"
	_cQry := " SELECT ZP1_CODPRO, B1_DESC, COUNT(DISTINCT ZP1_CODETI) CAIXAS, SUM(ZP1_PESO) PESO"
	_cQry += " FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " AND ZP1_STATUS = '1'"
	_cQry += " AND ZP1.ZP1_REPROC <> 'S'"
	_cQry += " AND (ZP1.ZP1_EDATA <> 'S' OR ZP1_OP = 'TUNEDATA' OR ZP1_OP = 'RETEDATA')"
	//_cQry += " AND ZP1_DTATIV >= '"+DToS(mv_par01)+"'"
	//_cQry += " AND ZP1_DTATIV <= '"+DToS(mv_par02)+"'"

	_cQry += " AND ZP1_DTPROD >= '"+DToS(mv_par01)+"'"
	_cQry += " AND ZP1_DTPROD <= '"+DToS(mv_par02)+"'"
	_cQry += " AND ZP1_HRATIV <> 'INVENTAR'"
	_cQry += " AND ZP1_CODPRO NOT IN "+cProdZP1
	_cQry += " AND SB1.B1_TIPO <> 'ME' "

	IF nStatus = 1
		_cQry += " AND EXISTS ("
		_cQry += " 	SELECT D3_COD"
		_cQry += " 	FROM "+RetSQLName("SD3")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND D3_TM = '103'"
		_cQry += " 	AND D3_ESTORNO = ''"
		_cQry += " 	AND D3_COD = ZP1_CODPRO"
		//		_cQry += " 	AND D3_EMISSAO = ZP1_DTATIV"
		_cQry += " 	AND D3_EMISSAO = ZP1_DTPROD"
		_cQry += " 	GROUP BY D3_COD"
		_cQry += " )"
	Else
		_cQry += " AND NOT EXISTS ("
		_cQry += " 	SELECT D3_COD"
		_cQry += " 	FROM "+RetSQLName("SD3")
		_cQry += " 	WHERE D_E_L_E_T_ = ' '"
		_cQry += " 	AND D3_TM = '103'"
		_cQry += " 	AND D3_ESTORNO = ''"
		_cQry += " 	AND D3_COD = ZP1_CODPRO"
		//_cQry += " 	AND D3_EMISSAO = ZP1_DTATIV"
		_cQry += " 	AND D3_EMISSAO = ZP1_DTPROD"		
		_cQry += " 	GROUP BY D3_COD"
		_cQry += " )"
	Endif
	//_cQry += " GROUP BY ZP1_DTATIV,ZP1_CODPRO,B1_DESC"
	_cQry += " GROUP BY ZP1_CODPRO,B1_DESC"	
	_cQry += " ORDER BY ZP1_CODPRO"

	/*	
	_cQry := " 	SELECT SUBSTRING(BM_DESC,1,15) BM_DESC, ZP1_CODPRO, B1_DESC"
	_cQry += " 	, COUNT(DISTINCT ZP1_CODETI) QTDCAIXA, SUM(ZP1_PESO) PESO"
	_cQry += " 	FROM ("
	_cQry += " 		SELECT"
	_cQry += " 		  ZP1_DTPROD DATAPROD"
	_cQry += " 		, CASE "
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('001','002','005','006','007') THEN '001'"
	_cQry += " 			WHEN REPLICATE('0',3-LEN(LTRIM(ZP1_LOTE)))+LTRIM(ZP1_LOTE) IN ('003','004','008','009','010') THEN '002'"
	_cQry += " 		  END TURNO"
	_cQry += " 		, BM_DESC,ZP1_CODPRO, B1_DESC"
	_cQry += " 		, ZP1_CODETI, ZP1_PESO"
	_cQry += " 		FROM ("
	_cQry += " 			SELECT  ZP1_DTPROD, BM_DESC,ZP1_CODPRO, B1_DESC, ZP1_LOTE"
	_cQry += " 			, ZP6_HORA"
	_cQry += " 			, ZP1_CODETI, ZP1_PESO"
	_cQry += " 			FROM "+RetSQLName("ZP1")+" ZP1"
	_cQry += " 			INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZP1_CODPRO"
	_cQry += " 			INNER JOIN "+RetSQLName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO"
	_cQry += " 			LEFT JOIN "+RetSQLName("ZP6")+" ZP6 ON ZP6.D_E_L_E_T_ = ' ' AND ZP6_FILIAL = ZP1_FILIAL AND ZP6_ETIQ = ZP1_CODETI"
	_cQry += " 			WHERE ZP1.D_E_L_E_T_ = ' '"
	_cQry += " 			AND ZP1_FILIAL = '"+xFilial("ZP1")+"'"
	_cQry += " 			AND (ZP1_OP <> 'ESTEDATA' AND ZP1_OP <> 'TUNEDATA' AND ZP1_OP <> 'RETEDATA')"
	_cQry += " 			AND (ZP1_STATUS = '1' OR ZP6_HORA IS NOT NULL )"
	_cQry += " 			AND ZP1.ZP1_REPROC <> 'S'"
	_cQry += " 			AND ZP1.ZP1_DTATIV <> ''"
	_cQry += " 	AND 	B1_GRUPO = '0003' "	
	_cQry += " 		) A"
	_cQry += " 	) B"
	_cQry += " 	WHERE DATAPROD BETWEEN '"+DToS(MV_PAR01)+"' AND '"+DToS(MV_PAR02)+"'"
	_cQry += " 	AND ZP1_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	_cQry += " 	AND TURNO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cQry += " 	GROUP BY BM_DESC, ZP1_CODPRO, B1_DESC"
	_cQry += " ORDER BY 1,2"
	TcQuery _cQry New Alias "QRY"

	*/

	MemoWrite(gettemppath()+"pcp037.txt",_cQry)
	_cQry := ChangeQuery(_cQry)
	TcQuery _cQry New Alias "QRY" // Cria uma nova area com o resultado do query                 

	While QRY->(!EoF())
		//	Aadd (aDados , {QRY->ZP1_DTATIV,QRY->ZP1_CODPRO, QRY->B1_DESC, QRY->CAIXAS} )
		//		Aadd (aDados , {QRY->ZP1_CODPRO, QRY->B1_DESC, QRY->CAIXAS} )
		Aadd (aDados , {QRY->ZP1_CODPRO, QRY->B1_DESC, QRY->PESO} )
		QRY->(DbSkip())
	EndDo

	if Empty(aDados)    

		Aviso ("" , "Sem dados para esses parโmetros" , {"OK"} , 1)
		lSeguranca := .F.

	else

		lSeguranca := .T.

	endif

	Qry->(dbCloseArea()) 


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELATORIO1บAutor  ณWellington Gon็alvesบ Data ณ  01/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para criar as perguntas do relatorio                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaPerguntas()

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}


	//////////////// DATA DE EMBARQUE  ////////////////////
	PutSx1( cPerg, "01","Data de ?","Data de ?","Data de abertura De?","cDtEmiDe","D",8,0,0,"G","","","","",;
	"mv_par01"," ","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	PutSx1( cPerg, "02","Data Ate?","Data Ate?","Data de abertura Ate?","cDtEmiAte","D",8,0,0,"G","","","","",;
	"mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa) 

	////////////// status  /////////////////
	PutSx1( cPerg, "03","Status:","Status:","Status:","","N",1,0,0,"C","","","","",;
	"mv_par03","Importadas","","","","Nใo Importadas","",""," ","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	if pergunte(cPerg,.T.) //Chama a tela de parametros

		cDtEmiDe 	:= mv_par01
		cDtEmiAte 	:= mv_par02  
		nStatus  	:= mv_par03
		lPerguntaOK := .T.

	else

		lPerguntaOK := .F.

	endif


Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELATORIO1บAutor  ณWellington Gon็alvesบ Data ณ  01/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria uma nova pแgina                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function NovaPagina()  // fun็ใo que cria uma nova pแgina montando o cabe็alho

	oPrint:endPage()
	nLin := 50
	nPag += 1
	Cabecalho()

Return