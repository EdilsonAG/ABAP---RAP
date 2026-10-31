CLASS zcl_categ_api_eag DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_categx,            " estrutura de controle estilo BAPI
             descricao TYPE c LENGTH 1,
             ativo     TYPE c LENGTH 1,
           END OF ty_categx,
           tt_categ TYPE STANDARD TABLE OF zcateg_eag WITH EMPTY KEY.

    CLASS-METHODS create IMPORTING is_categ       TYPE zcateg_eag
                         RETURNING VALUE(rv_erro) TYPE string.
    CLASS-METHODS update IMPORTING is_categ       TYPE zcateg_eag
                                   is_categx      TYPE ty_categx
                         RETURNING VALUE(rv_erro) TYPE string.
    CLASS-METHODS delete IMPORTING iv_id          TYPE zcateg_eag-categoria_id
                         RETURNING VALUE(rv_erro) TYPE string.
    CLASS-METHODS read   IMPORTING iv_id           TYPE zcateg_eag-categoria_id
                         RETURNING VALUE(rs_categ) TYPE zcateg_eag.
    CLASS-METHODS save.
    CLASS-METHODS cleanup.

  PRIVATE SECTION.
    CLASS-DATA: gt_create TYPE tt_categ,   " ← o buffer da "API legada"
                gt_update TYPE tt_categ,
                gt_delete TYPE tt_categ.
ENDCLASS.

CLASS zcl_categ_api_eag IMPLEMENTATION.

  METHOD read.
    " 1. Apagado nesta transação → não existe
    IF line_exists( gt_delete[ categoria_id = iv_id ] ).
      RETURN.
    ENDIF.
    " 2. Buffer tem prioridade sobre o banco
    IF line_exists( gt_create[ categoria_id = iv_id ] ).
      rs_categ = gt_create[ categoria_id = iv_id ].
      RETURN.
    ENDIF.
    IF line_exists( gt_update[ categoria_id = iv_id ] ).
      rs_categ = gt_update[ categoria_id = iv_id ].
      RETURN.
    ENDIF.
    " 3. Banco
    SELECT SINGLE * FROM zcateg_eag WHERE categoria_id = @iv_id INTO @rs_categ.
  ENDMETHOD.

  METHOD create.
    IF is_categ-categoria_id IS INITIAL.
      rv_erro = 'Categoria é obrigatória'.
      RETURN.
    ENDIF.
    IF read( is_categ-categoria_id ) IS NOT INITIAL.
      rv_erro = |Categoria { is_categ-categoria_id } já existe|.
      RETURN.
    ENDIF.
    APPEND is_categ TO gt_create.
  ENDMETHOD.

  METHOD update.
    DATA(ls_atual) = read( is_categ-categoria_id ).
    IF ls_atual IS INITIAL.
      rv_erro = |Categoria { is_categ-categoria_id } não existe|.
      RETURN.
    ENDIF.

    " Aplica só os campos marcados com 'X' (padrão BAPI)
    IF is_categx-descricao = 'X'. ls_atual-descricao = is_categ-descricao. ENDIF.
    IF is_categx-ativo     = 'X'. ls_atual-ativo     = is_categ-ativo.     ENDIF.

    " Criado nesta mesma transação? Atualiza o próprio create
    READ TABLE gt_create ASSIGNING FIELD-SYMBOL(<ls_new>)
         WITH KEY categoria_id = ls_atual-categoria_id.
    IF sy-subrc = 0.
      <ls_new> = ls_atual.
      RETURN.
    ENDIF.

    DELETE gt_update WHERE categoria_id = ls_atual-categoria_id.
    APPEND ls_atual TO gt_update.
  ENDMETHOD.

  METHOD delete.
    DATA(ls_atual) = read( iv_id ).
    IF ls_atual IS INITIAL.
      rv_erro = |Categoria { iv_id } não existe|.
      RETURN.
    ENDIF.

    " Criado e apagado na mesma transação → nunca vai ao banco
    DELETE gt_create WHERE categoria_id = iv_id.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    DELETE gt_update WHERE categoria_id = iv_id.
    APPEND ls_atual TO gt_delete.
  ENDMETHOD.

  METHOD save.
    IF gt_create IS NOT INITIAL. INSERT zcateg_eag FROM TABLE @gt_create. ENDIF.
    IF gt_update IS NOT INITIAL. UPDATE zcateg_eag FROM TABLE @gt_update. ENDIF.
    IF gt_delete IS NOT INITIAL. DELETE zcateg_eag FROM TABLE @gt_delete. ENDIF.
    " sem COMMIT: quem faz é o RAP
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: gt_create, gt_update, gt_delete.
  ENDMETHOD.

ENDCLASS.
