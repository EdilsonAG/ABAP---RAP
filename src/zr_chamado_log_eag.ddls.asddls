@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log do chamado'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_CHAMADO_LOG_EAG as select from zchamado_log_eag
 {
    key log_uuid as LogUuid,
    chamado_uuid as ChamadoUuid,
    status as Status,
    alterado_por as AlteradoPor,
    alterado_em as AlteradoEm  
}
