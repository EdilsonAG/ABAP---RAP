@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comentário - projeção'
@Metadata.allowExtensions: true
@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AbapCatalog.extensibility: {
  extensible: true,
  allowNewDatasources: false,
  dataSources: ['Comentario'],
  elementSuffix: 'ZEG'
}
define view entity ZC_COMENTARIO_EAG
  as projection on ZR_COMENTARIO_EAG as Comentario   
{
  key ComentarioUuid,
      ChamadoUuid,
      Texto,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,

      _Chamado : redirected to parent ZC_CHAMADO_EAG
}
