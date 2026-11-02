CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    METHODS on_criado FOR ENTITY EVENT
      IMPORTING criados FOR Chamado~ChamadoCriado.

    METHODS on_fechado FOR ENTITY EVENT
      IMPORTING fechados FOR Chamado~ChamadoFechado.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_criado.
    DATA lt_log TYPE TABLE FOR CREATE zr_chamado_log_eag.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT criados INTO DATA(ls_ev).
      APPEND VALUE #( ChamadoUuid = ls_ev-ChamadoUuid
                      Status      = 'A'
                      AlteradoPor = lv_user
                      AlteradoEm  = utclong_current( ) ) TO lt_log.
    ENDLOOP.

    MODIFY ENTITIES OF zr_chamado_log_eag
      ENTITY ChamadoLog
        CREATE AUTO FILL CID
        FIELDS ( ChamadoUuid Status AlteradoPor AlteradoEm )
        WITH lt_log.
  ENDMETHOD.

  METHOD on_fechado.
    DATA lt_log TYPE TABLE FOR CREATE zr_chamado_log_eag.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT fechados INTO DATA(ls_ev).
      APPEND VALUE #( ChamadoUuid = ls_ev-ChamadoUuid
                      Status      = 'F'
                      AlteradoPor = lv_user
                      AlteradoEm  = utclong_current( ) ) TO lt_log.
    ENDLOOP.

    MODIFY ENTITIES OF zr_chamado_log_eag
      ENTITY ChamadoLog
        CREATE AUTO FILL CID
        FIELDS ( ChamadoUuid Status AlteradoPor AlteradoEm )
        WITH lt_log.
  ENDMETHOD.

ENDCLASS.
