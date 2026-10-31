@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chamado - Projeção'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_CHAMADO_EAG
provider contract transactional_query
as projection on ZR_CHAMADO_EAG
{
    key ChamadoUuid,
    @Search.defaultSearchElement: true
    ChamadoId,
    @Search.defaultSearchElement: true
    Titulo,
    Descricao,
    
          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_PRIORIDADE_VH_EAG', element: 'Prioridade' } }]
      Prioridade,
    Status,
    @Search.defaultSearchElement: true
    Solicitante,
    DataAbertura,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    StatusTexto,
    
    _Comentarios : redirected to composition child ZC_COMENTARIO_EAG
}
