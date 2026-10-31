CLASS zcl_chamado_dados_eag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_chamado_dados_eag IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_chamados TYPE STANDARD TABLE OF zchamado_eag.
    DATA lv_ts      TYPE timestampl.
    DATA lv_user    TYPE sy-uname.

    GET TIME STAMP FIELD lv_ts.
    lv_user = cl_abap_context_info=>get_user_technical_name( ).
    "lv_user = sy-uname.

    TRY.

      lt_chamados = VALUE #(
      local_created_by      = lv_user
      local_created_at      = lv_ts
      local_last_changed_by = lv_user
      local_last_changed_at = lv_ts
      last_changed_at       = lv_ts
      ( chamado_uuid  = cl_system_uuid=>create_uuid_x16_static( )
        chamado_id    = '0000000001'
        titulo        = 'Impressora não imprime'
        prioridade    = 'M'
        status        = 'A'
        solicitante   = 'Ana'
        data_abertura = '20261010' )
      " TODO: linha 2 (Bruno)
      " TODO: linha 3 (Carla)
    ).

    CATCH CX_UUID_ERROR INTO DATA(lx_erro).
        out->write( |Erro ao gerar UUID: { lx_erro->get_text( ) }| ).
        RETURN. " importante por o return se não da erro
    ENDTRY.

    DELETE FROM zchamado_eag.
    INSERT zchamado_eag FROM TABLE @lt_chamados.

    IF sy-subrc = 0.
      out->write( |{ sy-dbcnt } chamados inseridos.| ).
    ELSE.
      out->write( |Erro ao inserir. sy-subrc = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
