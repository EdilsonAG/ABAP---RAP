@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Prioridade'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_PRIORIDADE_VH_EAG
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZD_PRIORIDADE_EAG' )
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @UI.hidden: true
  key language,
      
      @EndUserText.label: 'Prioridade'
      @ObjectModel.text.element: ['Descricao']
      @UI.textArrangement: #TEXT_FIRST
      value_low as Prioridade,
      @Semantics.text: true
      @EndUserText.label: 'Descrição'
      text      as Descricao
}
where language = $session.system_language
