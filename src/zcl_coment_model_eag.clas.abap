CLASS zcl_coment_model_eag DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS create IMPORTING is_coment  TYPE zcoment_eag.
    METHODS update IMPORTING is_coment  TYPE zcoment_eag
                             is_comentx TYPE ZCOMENT_X_EAG.
    METHODS delete IMPORTING iv_uuid    TYPE sysuuid_x16.
ENDCLASS.

CLASS zcl_coment_model_eag IMPLEMENTATION.

  METHOD create.
    INSERT zcoment_eag FROM @is_coment.
  ENDMETHOD.

  METHOD update.
    " Lê o atual e aplica só os campos marcados com 'X'
    SELECT SINGLE * FROM zcoment_eag
      WHERE comentario_uuid = @is_coment-comentario_uuid
      INTO @DATA(ls_atual).
    CHECK sy-subrc = 0.

    IF is_comentx-texto                 = 'X'. ls_atual-texto                 = is_coment-texto.                 ENDIF.
    IF is_comentx-local_last_changed_by = 'X'. ls_atual-local_last_changed_by = is_coment-local_last_changed_by. ENDIF.
    IF is_comentx-local_last_changed_at = 'X'. ls_atual-local_last_changed_at = is_coment-local_last_changed_at. ENDIF.

    UPDATE zcoment_eag FROM @ls_atual.
  ENDMETHOD.

  METHOD delete.
    DELETE FROM zcoment_eag WHERE comentario_uuid = @iv_uuid.
  ENDMETHOD.

ENDCLASS.
