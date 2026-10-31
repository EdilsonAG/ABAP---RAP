@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chamado - BO base'
define root view entity ZR_CHAMADO_EAG
  as select from zchamado_eag
  composition [0..*] of ZR_COMENTARIO_EAG as _Comentarios 
{
  key chamado_uuid          as ChamadoUuid,
      chamado_id            as ChamadoId,
      titulo                as Titulo,
      descricao             as Descricao,
      prioridade            as Prioridade,
      status                as Status,
      solicitante           as Solicitante,
      @EndUserText.label: 'Data de abertura'
      data_abertura         as DataAbertura,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
    
      case status
        when 'A' then cast( 'Aberto' as abap.char(20) )
        when 'E' then 'Em andamento'
        when 'F' then 'Fechado'
        else 'Desconhecido'
      end                   as StatusTexto,
      
    _Comentarios  
}
