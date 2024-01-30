#include 'protheus.ch'
#include 'parmtype.ch'


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦                                                     
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCPR012 ¦ Autor ¦ Matheus Gratão D'Ávila ¦ Data ¦31/07/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ Faz o relatório do controle sobre o gasto de etiquetas.    ¦¦¦
¦¦¦          ¦ 															  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ NUTRIZA                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/


User function PCPR012()
	LOCAL LF := CHR(13)+CHR(10)

	LOCAL ARET 		:= {} 
	LOCAL APARAMBOX := {}
	Local cQry 		:= ""
	Local aCombo1 := {"Tudo","Nao Ativada","Ativo","Em Carregamento","Carregado","Baixado Inv","Sequestro","Suspensão"}
	local cStatus1 

	AADD(APARAMBOX,{1,"Data de:  ",			DDATABASE						,PESQPICT("ZP1", "ZP1_DTPROD"),'.T.',"" ,'.T.', 50, .T.})
	AADD(APARAMBOX,{1,"Data Até: ",			DDATABASE						,PESQPICT("ZP1", "ZP1_DTPROD"),'.T.',"" ,'.T.', 50,  .T.})
	AADD(APARAMBOX,{2,"Status:   ",			1,aCombo1,50,"",.F.})
	AADD(APARAMBOX,{1,"Local:   ",			SPACE(TAMSX3('ZP1_LOCAL')[1])	,PESQPICT("ZP1", "ZP1_LOCAL"),'.T.',"" ,'.T.', 50,  .F.})
	AADD(APARAMBOX,{1,"Cod. Produto: ",		SPACE(TAMSX3('ZP1_CODPRO')[1])	,PESQPICT("ZP1", "ZP1_CODPRO"),'.T.',"" ,'.T.', 50,  .F.})

	IF PARAMBOX(APARAMBOX,"PARÂMETROS",@ARET)

		cQry := " SELECT *" +LF
		cQry += " FROM  ZP1010 " +LF
		cQry += " WHERE D_E_L_E_T_ <> '*' " +LF
		cQry += " AND ZP1_DTPROD BETWEEN '"+ dtos(MV_PAR01)+"' AND '"+ dtos(MV_PAR02)+"' " +LF


		If valtype(MV_PAR03) == 'N'

			DO CASE
				CASE MV_PAR03 = 1
				cStatus1  := ""
				CASE MV_PAR03 = 2
				cStatus1  := ""
				CASE MV_PAR03 = 3
				cStatus1 := "1"
				CASE MV_PAR03 = 4
				cStatus1 := "2"
				CASE MV_PAR03 = 5
				cStatus1 := "3"
				CASE MV_PAR03 = 6
				cStatus1 := "5"	
				CASE MV_PAR03 = 7
				cStatus1 := "7"
				CASE MV_PAR03 = 8
				cStatus1 := "9"
			ENDCASE
			IF !Empty(MV_PAR03) .and.  MV_PAR03 != 1
				cQry += " AND ZP1_STATUS = '"+cStatus1+"' " +LF
			Elseif !Empty(MV_PAR04)
				cQry += " AND ZP1_LOCAL = '"+MV_PAR04+"' " +LF
			Elseif !Empty(MV_PAR05)
				cQry += " AND ZP1_CODPRO = '"+MV_PAR05+"' " +LF
			Endif

		Else
			DO CASE
				CASE MV_PAR03 = "Tudo"
				cStatus1  := ""
				CASE MV_PAR03 = "Nao Ativada"
				cStatus1  := ""
				CASE MV_PAR03 = "Ativo"
				cStatus1 := "1"
				CASE MV_PAR03 = "Em Carregamento"
				cStatus1 := "2"
				CASE MV_PAR03 = "Carregado"
				cStatus1 := "3"
				CASE MV_PAR03 = "Baixado Inv"
				cStatus1 := "5"	
				CASE MV_PAR03 = "Sequestro"
				cStatus1 := "7"
				CASE MV_PAR03 = "Suspensão"
				cStatus1 := "9"
			ENDCASE
			IF !Empty(MV_PAR03) .and. MV_PAR03 != "Tudo"
				cQry += " AND ZP1_STATUS = '"+cStatus1+"' " +LF
			Elseif !Empty(MV_PAR04)
				cQry += " AND ZP1_LOCAL = '"+MV_PAR04+"' " +LF
			Elseif !Empty(MV_PAR05)
				cQry += " AND ZP1_CODPRO = '"+MV_PAR05+"' " +LF
			Endif


		Endif						





		MemoWrite("C:\TEMP\PCPR012.SQL",cQry)

		u_zQry2Excel(cQry)

	ENDIF

RETURN