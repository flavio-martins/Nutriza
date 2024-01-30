#include 'protheus.ch'
#include 'parmtype.ch'

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦                                                     
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCPR013 ¦ Autor ¦ Brunno Robson Araujo ¦ Data¦ 21/10/19 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Gera o relatório de rastreamento CIF por lote			  ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ NUTRIZA                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

user function PCPR013()

	LOCAL LF := CHR(13)+CHR(10)

	LOCAL ARET 		:= {} 
	LOCAL APARAMBOX := {}
	Local cQry 		:= ""

	AADD(APARAMBOX,{1,"Data de produção: ",	DDATABASE						,PESQPICT("ZP1", "ZP1_DTPROD"),'.T.',"" ,'.T.', 50, .T.})
	AADD(APARAMBOX,{1,"Cod. Produto: ",		"49975"							,PESQPICT("ZP1", "ZP1_CODPRO"),'.T.',"SB1",'.T.', 50, .F.})
	AADD(APARAMBOX,{1,"Lote: ",			    SPACE(TAMSX3('ZP1_LOTE')[1])	,PESQPICT("ZP1", "ZP1_LOTE")  ,'.T.',"" ,'.T.', 50, .T.})

	IF PARAMBOX(APARAMBOX,"PARAMETROS",@ARET)
	
		// msgInfo("ddatabase - MV_PAR01: " + str(ddatabase - MV_PAR01) )

		// verifico se a data de produção é maior que 2 meses para consultar ZP1_MORTO
		If ddatabase - MV_PAR01 > 60		

			cQry := " SELECT " +LF
			cQry += " ZP1_CODPRO  " +LF //AS 'ZP1_CODPRO'
			cQry += ",B1_DESC " +LF //AS 'B1_DESC'
			cQry += ",ZP1_DTPROD " +LF //AS 'ZP1_DTPROD'
			cQry += ",ZP1_LOTE " +LF //AS 'ZP1_LOTE'		
			cQry += ",iif(ZP1_REPROC='N','NAO','SIM') AS 'ZP1_REPROC' " +LF //AS 'ZP1_REPROC' 
			cQry += ",case when ZP1_STATUS = '1' then ZP1_STATUS + ' - ATIVO' " + LF
			cQry += "	   when ZP1_STATUS = '2' then ZP1_STATUS + ' - EM CARREGAMENTO' " + LF
			cQry += "	   when ZP1_STATUS = '3' then ZP1_STATUS + ' - CARREGADO' " + LF
			cQry += "	   when ZP1_STATUS = '5' then ZP1_STATUS + ' - BAIXA INVENTARIO' " + LF
			cQry += " 	   when ZP1_STATUS = '7' then ZP1_STATUS + ' - SUSP. SEQUESTRO' " + LF
			cQry += "	   when ZP1_STATUS = '9' then ZP1_STATUS + ' - SUSPENSAO' " + LF
			cQry += "	   when ZP1_STATUS = ' ' then ZP1_STATUS + ' - NAO ATIVADA' end as 'ZP1_STATUS'  " + LF //AS 'ZP1_STATUS' 
			cQry += ",ZP1_PEDIDO " +LF //AS 'ZP1_PEDIDO' 
			// cQry += ",ZP1_ENDWMS " +LF //AS 'ZP1_ENDWMS' campo não tem na tabela ZP1_MORTO
			cQry += ",D2_CLIENTE " +LF //AS 'D2_CLIENTE' 
			cQry += ",D2_LOJA " +LF //AS 'D2_LOJA' 
			cQry += ",D2_DOC " +LF //AS 'D2_DOC' 
			cQry += ",D2_SERIE " +LF //AS 'D2_SERIE' 
			cQry += ",D2_EMISSAO " +LF //AS 'D2_EMISSAO' 
			cQry += ",D2_ITEM " +LF //AS 'D2_ITEM' 
			cQry += ",A1_NOME " +LF //AS 'A1_NOME' 
			cQry += ",SUM(ZP1.ZP1_PESO) AS 'ZP1_PESO' " +LF
			cQry += ",SUM(SD2.D2_QTDEFAT) AS 'D2_QTDEFAT' " +LF				
			cQry += " FROM " + RETSQLNAME("ZP1_MORTO") + " ZP1 " +LF		
			cQry += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 ON (SB1.B1_COD=ZP1.ZP1_CODPRO) " +LF
			cQry += " INNER JOIN " + RETSQLNAME("SC9") + " SC9 ON (SC9.C9_PEDIDO=ZP1.ZP1_PEDIDO AND SC9.C9_CARGA=ZP1.ZP1_CARGA AND SC9.C9_PRODUTO=ZP1.ZP1_CODPRO) " +LF 
			cQry += " INNER JOIN " + RETSQLNAME("SD2") + " SD2 ON (SD2.D2_PEDIDO=ZP1.ZP1_PEDIDO AND SD2.D2_FILIAL=SC9.C9_FILIAL AND SD2.D2_DOC=SC9.C9_NFISCAL AND SD2.D2_SERIE=SC9.C9_SERIENF AND SD2.D2_CLIENTE=SC9.C9_CLIENTE AND SD2.D2_LOJA=SC9.C9_LOJA AND SD2.D2_COD=SC9.C9_PRODUTO) " +LF
			cQry += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 ON (SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA) " +LF				
			cQry += " WHERE ZP1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SC9.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' " +LF		
			cQry += " AND ZP1.ZP1_DTPROD = '"+ dtos(MV_PAR01)+"'"+LF
			cQry += " AND ZP1.ZP1_CODPRO = '"+ MV_PAR02 + "'"+LF
			cQry += " AND ZP1.ZP1_LOTE = '"+ alltrim(MV_PAR03) + "'"+LF		
			cQry += " AND SC9.C9_NFISCAL <> '' AND SC9.C9_CARGA <> ''"+LF		
			cQry += " GROUP BY ZP1.ZP1_CODPRO, SB1.B1_DESC, ZP1.ZP1_DTPROD, ZP1.ZP1_LOTE, ZP1.ZP1_STATUS "+LF
			cQry += " 		  ,ZP1.ZP1_REPROC, ZP1.ZP1_CARGA, ZP1.ZP1_PEDIDO,SD2.D2_CLIENTE,SD2.D2_LOJA  "+LF
			cQry += " 		  ,SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_ITEM, SA1.A1_NOME "+LF
			cQry += " ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_DOC "+LF

		Else

			cQry := " SELECT " +LF
			cQry += " ZP1_CODPRO  " +LF //AS 'ZP1_CODPRO'
			cQry += ",B1_DESC " +LF //AS 'B1_DESC'
			cQry += ",ZP1_DTPROD " +LF //AS 'ZP1_DTPROD'
			cQry += ",ZP1_LOTE " +LF //AS 'ZP1_LOTE'		
			cQry += ",iif(ZP1_REPROC='N','NAO','SIM') AS 'ZP1_REPROC' " +LF //AS 'ZP1_REPROC' 
			cQry += ",case when ZP1_STATUS = '1' then ZP1_STATUS + ' - ATIVO' " + LF
			cQry += "	   when ZP1_STATUS = '2' then ZP1_STATUS + ' - EM CARREGAMENTO' " + LF
			cQry += "	   when ZP1_STATUS = '3' then ZP1_STATUS + ' - CARREGADO' " + LF
			cQry += "	   when ZP1_STATUS = '5' then ZP1_STATUS + ' - BAIXA INVENTARIO' " + LF
			cQry += " 	   when ZP1_STATUS = '7' then ZP1_STATUS + ' - SUSP. SEQUESTRO' " + LF
			cQry += "	   when ZP1_STATUS = '9' then ZP1_STATUS + ' - SUSPENSAO' " + LF
			cQry += "	   when ZP1_STATUS = ' ' then ZP1_STATUS + ' - NAO ATIVADA' end as 'ZP1_STATUS'  " + LF //AS 'ZP1_STATUS' 
			cQry += ",ZP1_PEDIDO " +LF //AS 'ZP1_PEDIDO' 
			cQry += ",ZP1_ENDWMS " +LF //AS 'ZP1_ENDWMS' 
			cQry += ",D2_CLIENTE " +LF //AS 'D2_CLIENTE' 
			cQry += ",D2_LOJA " +LF //AS 'D2_LOJA' 
			cQry += ",D2_DOC " +LF //AS 'D2_DOC' 
			cQry += ",D2_SERIE " +LF //AS 'D2_SERIE' 
			cQry += ",D2_EMISSAO " +LF //AS 'D2_EMISSAO' 
			cQry += ",D2_ITEM " +LF //AS 'D2_ITEM' 
			cQry += ",A1_NOME " +LF //AS 'A1_NOME' 
			cQry += ",SUM(ZP1.ZP1_PESO) AS 'ZP1_PESO' " +LF
			cQry += ",SUM(SD2.D2_QTDEFAT) AS 'D2_QTDEFAT' " +LF				
			cQry += " FROM " + RETSQLNAME("ZP1") + " ZP1 " +LF		
			cQry += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 ON (SB1.B1_COD=ZP1.ZP1_CODPRO) " +LF
			cQry += " INNER JOIN " + RETSQLNAME("SC9") + " SC9 ON (SC9.C9_PEDIDO=ZP1.ZP1_PEDIDO AND SC9.C9_CARGA=ZP1.ZP1_CARGA AND SC9.C9_PRODUTO=ZP1.ZP1_CODPRO) " +LF 
			cQry += " INNER JOIN " + RETSQLNAME("SD2") + " SD2 ON (SD2.D2_PEDIDO=ZP1.ZP1_PEDIDO AND SD2.D2_FILIAL=SC9.C9_FILIAL AND SD2.D2_DOC=SC9.C9_NFISCAL AND SD2.D2_SERIE=SC9.C9_SERIENF AND SD2.D2_CLIENTE=SC9.C9_CLIENTE AND SD2.D2_LOJA=SC9.C9_LOJA AND SD2.D2_COD=SC9.C9_PRODUTO) " +LF
			cQry += " INNER JOIN " + RETSQLNAME("SA1") + " SA1 ON (SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA) " +LF				
			cQry += " WHERE ZP1.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND SC9.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' " +LF		
			cQry += " AND ZP1.ZP1_DTPROD = '"+ dtos(MV_PAR01)+"'"+LF
			cQry += " AND ZP1.ZP1_CODPRO = '"+ MV_PAR02 + "'"+LF
			cQry += " AND ZP1.ZP1_LOTE = '"+ alltrim(MV_PAR03) + "'"+LF		
			cQry += " AND SC9.C9_NFISCAL <> '' AND SC9.C9_CARGA <> ''"+LF		
			cQry += " GROUP BY ZP1.ZP1_CODPRO, SB1.B1_DESC, ZP1.ZP1_DTPROD, ZP1.ZP1_LOTE, ZP1.ZP1_STATUS "+LF
			cQry += " 		  ,ZP1.ZP1_REPROC, ZP1.ZP1_CARGA, ZP1.ZP1_PEDIDO, ZP1.ZP1_ENDWMS,SD2.D2_CLIENTE "+LF
			cQry += " 		  ,SD2.D2_LOJA, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_ITEM, SA1.A1_NOME "+LF
			cQry += " ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_DOC "+LF

		EndIf
		
		u_zQry2Excel(cQry)

		MemoWrite("C:\TEMP\PCPR013.SQL",cQry)	

	ENDIF

return