#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
 Programa |MTA650L    Autor |Evandro Gomes       | Data | 20/05/09    
-----------------------------------------------------------------------------
 Desc.    | Valida aCols de Empenho							             
-----------------------------------------------------------------------------
 Uso      | Especifico                                                 
-----------------------------------------------------------------------------
�� Acols: [01] Codigo do produto                                          ��
��        [02] Quantidade empenho                                         ��
��        [03] Almoxarifado padrao do Empenho                             ��
��        [04] Sequencia da estrutura                                     ��
��        [05] Sub-Lote                                                   ��
��        [06] Lote                                                       ��
��        [07] Data de Validade do Lote                                   ��
��        [08] Localiza��o                                                ��
��        [09] Numero de Seria                                            ��
��        [10] 1a Unidade de Medida                                       ��
��        [11] Quantidade 2a. Unidade de Medida                           ��
��        [12] 2a. Unidade de medida                                      ��
��        [13] Logico (.t./.f.) Indica se a linha foi deletada            ��
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/
User Function MTA650L()
	Local _lRet		:= .T.
Return(_lRet)