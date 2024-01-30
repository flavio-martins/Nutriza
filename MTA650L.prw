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
北 Acols: [01] Codigo do produto                                          北
北        [02] Quantidade empenho                                         北
北        [03] Almoxarifado padrao do Empenho                             北
北        [04] Sequencia da estrutura                                     北
北        [05] Sub-Lote                                                   北
北        [06] Lote                                                       北
北        [07] Data de Validade do Lote                                   北
北        [08] Localiza玢o                                                北
北        [09] Numero de Seria                                            北
北        [10] 1a Unidade de Medida                                       北
北        [11] Quantidade 2a. Unidade de Medida                           北
北        [12] 2a. Unidade de medida                                      北
北        [13] Logico (.t./.f.) Indica se a linha foi deletada            北
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/
User Function MTA650L()
	Local _lRet		:= .T.
Return(_lRet)