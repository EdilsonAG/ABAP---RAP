@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comentário - extension include view'
 @AbapCatalog.extensibility: {
  extensible: true,
  allowNewDatasources: false,
  dataSources: ['Comentario'],
  elementSuffix: 'ZEG'
}
define view entity ZE_COMENTARIO_EAG as select from zcoment_eag as Comentario
{
    key comentario_uuid as ComentarioUuid
    
}
