@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comentário - projeção'
@Metadata.allowExtensions: true
define view entity ZC_COMENTARIO_EAG
  as projection on ZR_COMENTARIO_EAG
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
