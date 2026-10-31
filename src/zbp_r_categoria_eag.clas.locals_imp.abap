CLASS lhc_Categoria DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Categoria RESULT result.

    METHODS create FOR MODIFY
       entities FOR CREATE Categoria.

    METHODS update FOR MODIFY
       entities FOR UPDATE Categoria.

    METHODS delete FOR MODIFY
       keys FOR DELETE Categoria.

    METHODS read FOR READ
       keys FOR READ Categoria RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Categoria.

ENDCLASS.

CLASS lhc_Categoria IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

    METHOD create.
    LOOP AT entities INTO DATA(ls_ent).
      DATA(ls_categ) = CORRESPONDING zcateg_eag( ls_ent MAPPING FROM ENTITY ).
      DATA(lv_erro)  = zcl_categ_api_eag=>create( ls_categ ).

      IF lv_erro IS INITIAL.
        APPEND VALUE #( %cid = ls_ent-%cid  CategoriaId = ls_ent-CategoriaId ) TO mapped-categoria.
      ELSE.
        APPEND VALUE #( %cid = ls_ent-%cid  CategoriaId = ls_ent-CategoriaId ) TO failed-categoria.
        APPEND VALUE #( %cid = ls_ent-%cid  CategoriaId = ls_ent-CategoriaId
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = lv_erro ) ) TO reported-categoria.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_ent).
      DATA(ls_categ) = CORRESPONDING zcateg_eag( ls_ent MAPPING FROM ENTITY ).

      " %control (#01/#00) → estrutura legada ('X'/' ')
      DATA(ls_x) = VALUE zcl_categ_api_eag=>ty_categx(
        descricao = COND #( WHEN ls_ent-%control-Descricao = if_abap_behv=>mk-on THEN 'X' )
        ativo     = COND #( WHEN ls_ent-%control-Ativo     = if_abap_behv=>mk-on THEN 'X' ) ).

      DATA(lv_erro) = zcl_categ_api_eag=>update( is_categ = ls_categ is_categx = ls_x ).

      IF lv_erro IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_ent-%tky ) TO failed-categoria.
        APPEND VALUE #( %tky = ls_ent-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = lv_erro ) ) TO reported-categoria.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      DATA(lv_erro) = zcl_categ_api_eag=>delete( ls_key-CategoriaId ).
      IF lv_erro IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-categoria.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = lv_erro ) ) TO reported-categoria.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_categ) = zcl_categ_api_eag=>read( ls_key-CategoriaId ).

      IF ls_categ IS INITIAL.
        APPEND VALUE #( %tky        = ls_key-%tky
                        %fail-cause = if_abap_behv=>cause-not_found ) TO failed-categoria.
      ELSE.
        " legado → entidade, + ETag calculado igual à CDS
        APPEND CORRESPONDING #( ls_categ MAPPING TO ENTITY ) TO result
               ASSIGNING FIELD-SYMBOL(<ls_res>).
        <ls_res>-AllElements = |{ ls_categ-descricao }{ ls_categ-ativo }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    " Legado real: CALL FUNCTION 'ENQUEUE_EZ...'. Aqui sem lock object, fica vazio.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_CATEGORIA_EAG DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_CATEGORIA_EAG IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

   METHOD save.
    zcl_categ_api_eag=>save( ).
  ENDMETHOD.

  METHOD cleanup.
    zcl_categ_api_eag=>cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    zcl_categ_api_eag=>cleanup( ).
  ENDMETHOD.

ENDCLASS.
