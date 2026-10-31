@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Categoria - BO unmanaged'
define root view entity ZR_CATEGORIA_EAG as select from zcateg_eag
{
    key categoria_id as CategoriaId,
    descricao as Descricao,
    ativo as Ativo,
    
     // ETag sem timestamp: concatena todos os campos que não são chave
      concat( descricao, ativo ) as AllElements
}
