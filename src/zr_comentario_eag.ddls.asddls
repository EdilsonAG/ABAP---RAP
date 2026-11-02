@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comentário do chamado'

@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AbapCatalog.extensibility: {
  extensible: true,
  allowNewDatasources: false,
  dataSources: ['_Extension'],
  elementSuffix: 'ZEG'
}


define view entity ZR_COMENTARIO_EAG as select from zcoment_eag
association to parent ZR_CHAMADO_EAG as _Chamado
    on $projection.ChamadoUuid= _Chamado.ChamadoUuid
association [1..1] to ZE_COMENTARIO_EAG as _Extension
    on $projection.ComentarioUuid = _Extension.ComentarioUuid
{
    key comentario_uuid as ComentarioUuid,
    chamado_uuid as ChamadoUuid,
    texto as Texto,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    
    _Chamado, 
    _Extension 
}
