#Include "PROTHEUS.Ch"
#Include "Topconn.ch"    
#Include 'Report.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PCPR009	 �Autor	 | Fl�vio Martins		� Data � 02/04/19 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio para leitura dos pallets e etiquetas excluidos   ���
��� 		 �	no periodo.												  ���
�������������������������������������������������������������������������Ĵ��
���Uso:      � Nutriza S.A.                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PCPR009()
	Private oSection1
	Cal1()
	Return

	**************************************************************************
Static Function Cal1()

	PRIVATE CPERG	   	:= "PCPR009"
	Ajusta(cPerg)
	oReport 			:= ReportDef()
	If VALTYPE( oReport ) == "O"
		oReport :PrintDialog()
	EndIf
	oReport := nil

	Return

	**************************************************************************

Static Function ReportDef()

	Local CREPORT		:= "PCPR009"
	Local CTITULO		:= OemToAnsi('EXCLUSAO DE ETIQUETAS OU PALLETs')
	Local CDESC			:= OemToAnsi('Este programa ira imprimir a listagem da exclus�o de pallets ou etiquetas ')
	CTITULO				:= 'DEMONSTRATIVO DE EXCLUSAO DE PALLETS OU ETIQUETAS


	Pergunte("PCPR009",.f.)
	oReport	:= TReport():New( CREPORT,CTITULO,"PCPR009", { |oReport| ReportPrint( oReport ) }, CDESC )
	oSection1  := TRSection():New( oReport, 'RELACAO DE ETIQUETAS OU PALLET EXCLUIDOS','QRY1',, .F., .F. )

	TRCell():New( oSection1, "A"	,"QRY1"	,'C�digo'	/*Titulo*/,/*Picture*/,4	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "B"	,"QRY1"	,'Data'	/*Titulo*/,/*Picture*/,20	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "C"	,"QRY1"	,'Hora'	/*Titulo*/,/*Picture*/,15	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "D"	,"QRY1"	,'IdUsuario'	/*Titulo*/,/*Picture*/,12	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "E"	,"QRY1"	,'Nome'	/*Titulo*/,/*Picture*/,50	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "F"	,"QRY1"	,'Cod. Etiqueta'	/*Titulo*/,/*Picture*/,30	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   
	TRCell():New( oSection1, "G"	,"QRY1"	,'Historico'	/*Titulo*/,/*Picture*/,100	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)   

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Fl�vio Martins   	� Data � 02/04/19 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Objeto do relat�rio                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

	Private oSection1 	:= oReport:Section(1)

	cQry := " SELECT ZPE_CODIGO,ZPE_DATA, ZPE_HORA, ZPE_USERID, ZPE_NOMUSE, ZPE_CODETI, ZPE_ORIGEM, ZPE_HISTOR " 
	cQry += "	FROM "+RetSqlName("ZPE")
	cQry += "	WHERE (ZPE_CODIGO = 'Z1' OR ZPE_CODIGO = 'Z2') " 
	cQry += "	AND ZPE_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " 
	cQry += "	AND ZPE_ORIGEM = 'PCP056' "
	cQry += " ORDER BY ZPE_DATA, ZPE_HORA "

	If Select("QRY1") > 0
		QRY1->(dbClosearea())
	Endif
	MemoWrite("C:\TEMP\PCPR009.SQL",cQry)
	TcQuery cQry New alias "QRY1"     

	OSECTION1:INIT()
	While QRY1->(!Eof())

		oSection1:Cell("A"):SetValue(QRY1->ZPE_CODIGO)   
		oSection1:Cell("B"):SetValue(DtoC(Stod(QRY1->ZPE_DATA))) 
		oSection1:Cell("C"):SetValue(QRY1->ZPE_HORA)
		oSection1:Cell("D"):SetValue(QRY1->ZPE_USERID) 
		oSection1:Cell("E"):SetValue(QRY1->ZPE_NOMUSE) 
		oSection1:Cell("F"):SetValue(QRY1->ZPE_CODETI)     
		oSection1:Cell("G"):SetValue(QRY1->ZPE_HISTOR)

		oSection1:Printline()
		QRY1->(DbsKip())
	Enddo
	OSECTION1:FINISH()

Return 	

Static Function Ajusta(cPerg)
	U_OHFUNAP3(cPerg,"01","Data de?"		,"","","mv_ch1","D",08,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","")
	U_OHFUNAP3(cPerg,"02","Data ate?"		,"","","mv_ch2","D",08,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","")
Return