CLASS lhc_comentario DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validarTexto FOR VALIDATE ON SAVE
      keys FOR Comentario~validarTexto.
    METHODS atualizarStatusChamado FOR DETERMINE ON SAVE
      keys FOR Comentario~atualizarStatusChamado.

ENDCLASS.

CLASS lhc_comentario IMPLEMENTATION.

  METHOD validarTexto.
    CONSTANTS c_area TYPE string VALUE `VALIDAR_TEXTO`.

    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Comentario
        FIELDS ( ChamadoUuid Texto ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_coment).

    LOOP AT lt_coment INTO DATA(ls_coment).

      " limpa a mensagem antiga
      APPEND VALUE #( %tky        = ls_coment-%tky
                      %state_area = c_area ) TO reported-comentario.

      IF strlen( condense( ls_coment-Texto ) ) < 5.
        APPEND VALUE #( %tky = ls_coment-%tky ) TO failed-comentario.
        APPEND VALUE #( %tky        = ls_coment-%tky
                        %state_area = c_area
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = 'Comentário deve ter pelo menos 5 caracteres' )
                        %element-Texto = if_abap_behv=>mk-on
                        %path-chamado  = CORRESPONDING #( ls_coment ) )   " ← caminho até o pai
               TO reported-comentario.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD atualizarStatusChamado.
  READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Comentario BY \_Chamado
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).

    " 2. Só os chamados ainda Abertos
    DELETE lt_chamados WHERE Status <> 'A'.

    " 3. Remove chamados repetidos (vários comentários do mesmo chamado)
    SORT lt_chamados BY %tky.
    DELETE ADJACENT DUPLICATES FROM lt_chamados COMPARING %tky.

    CHECK lt_chamados IS NOT INITIAL.

    " 4. Atualiza o pai
    MODIFY ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR ls_ch IN lt_chamados
                      ( %tky = ls_ch-%tky  Status = 'E' ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Chamado DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Chamado RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Chamado RESULT result.

    METHODS fechar FOR MODIFY
      keys FOR ACTION Chamado~fechar RESULT result.
    METHODS validarTitulo FOR VALIDATE ON SAVE
      keys FOR Chamado~validarTitulo.
    METHODS validarSolicitante FOR VALIDATE ON SAVE
      keys FOR Chamado~validarSolicitante.
    METHODS validarPrioridade FOR VALIDATE ON SAVE
      keys FOR Chamado~validarPrioridade.
    METHODS determinarStatus FOR DETERMINE ON MODIFY
      keys FOR Chamado~determinarStatus.
    METHODS determinarChamadoId FOR DETERMINE ON SAVE
      keys FOR Chamado~determinarChamadoId.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Chamado RESULT result.

ENDCLASS.

CLASS lhc_Chamado IMPLEMENTATION.

  METHOD get_instance_authorizations.

     " 1. Ler quem criou cada chamado
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        FIELDS ( LocalCreatedBy ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    " 2. Bloquear quem NÃO é o criador
    LOOP AT lt_chamados INTO DATA(ls_chamado).
      IF ls_chamado-LocalCreatedBy <> lv_user.
        APPEND VALUE #( %tky           = ls_chamado-%tky
                        %update        = if_abap_behv=>auth-unauthorized
                        %delete        = if_abap_behv=>auth-unauthorized
                        %action-fechar = if_abap_behv=>auth-unauthorized
                        %action-Edit   = if_abap_behv=>auth-unauthorized )
               TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.


  ENDMETHOD.

  METHOD fechar.
    " 1. Ler os chamados que o usuário selecionou (keys = selecionados)
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
        ENTITY Chamado
            Fields ( Status ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_chamados).



    LOOP AT lt_chamados INTO DATA(ls_chamado).

        IF ls_chamado-Status = 'F'.
             " 2a. Já está fechado → marca como falha + mensagem
            APPEND VALUE #( %tky = ls_chamado-%tky ) TO failed-chamado.
            APPEND VALUE #( %tky = ls_chamado-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Chamado já está fechado' ) )
               TO reported-chamado.
         ELSE.
         " 2b. Fecha o chamado
        MODIFY ENTITIES OF zr_chamado_eag IN LOCAL MODE
          ENTITY Chamado
            UPDATE FIELDS ( Status )
            WITH VALUE #( ( %tky = ls_chamado-%tky  Status = 'F' ) ).
         ENDIF.
    ENDLOOP.

        " 3. Devolver os chamados atualizados para a tela/API
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_atualizados).

    result = VALUE #( FOR ls_atu IN lt_atualizados
                      ( %tky = ls_atu-%tky  %param = ls_atu ) ).
  ENDMETHOD.

    METHOD validarTitulo.
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        FIELDS ( Titulo ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).

    LOOP AT lt_chamados INTO DATA(ls_chamado).

      " 1. Apaga a mensagem antiga DESTA validation (só %tky + %state_area)
      APPEND VALUE #( %tky        = ls_chamado-%tky
                      %state_area = 'VALIDAR_TITULO' )
             TO reported-chamado.

      " 2. Checa de novo
      IF ls_chamado-Titulo IS INITIAL.
        APPEND VALUE #( %tky = ls_chamado-%tky ) TO failed-chamado.
        APPEND VALUE #( %tky        = ls_chamado-%tky
                        %state_area = 'VALIDAR_TITULO'
                        %msg        = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = 'Título é obrigatório' )
                        %element-Titulo = if_abap_behv=>mk-on )
               TO reported-chamado.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validarSolicitante.
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
    FIELDS ( Solicitante ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).

    LOOP AT lt_chamados INTO DATA(ls_chamado) WHERE Solicitante IS INITIAL.
      APPEND VALUE #( %tky = ls_chamado-%tky ) TO failed-chamado.
      APPEND VALUE #( %tky = ls_chamado-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Solicitante é obrigatório' )
                      %element-Solicitante = if_abap_behv=>mk-on )
             TO reported-chamado.
    ENDLOOP.
  ENDMETHOD.

  METHOD validarPrioridade.
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
    FIELDS ( Prioridade ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).



    LOOP AT lt_chamados INTO DATA(ls_chamado)

      WHERE Prioridade <> 'A' AND Prioridade <> 'M' AND Prioridade <> 'B'.
      APPEND VALUE #( %tky = ls_chamado-%tky ) TO failed-chamado.
      APPEND VALUE #( %tky = ls_chamado-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'Prioridade inválida. Use A, M ou B' )
                      %element-Prioridade = if_abap_behv=>mk-on )
             TO reported-chamado.

    ENDLOOP.

  ENDMETHOD.

  METHOD determinarStatus.
    " 1. Ler o status dos chamados criados
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).

     " 2. Só os que ainda não têm status
    DELETE lt_chamados WHERE Status IS NOT INITIAL.
    CHECK lt_chamados IS NOT INITIAL.

    " 3. Preencher Status = 'A'
    MODIFY ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR ls_chamado IN lt_chamados
                      ( %tky = ls_chamado-%tky  Status = 'A' ) )
      REPORTED DATA(ls_reported).

    reported = CORRESPONDING #( DEEP ls_reported ).

  ENDMETHOD.

  METHOD determinarChamadoId.
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        FIELDS ( ChamadoId ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados).
      DELETE lt_chamados WHERE ChamadoId IS NOT INITIAL.
    CHECK lt_chamados IS NOT INITIAL.

      " Maior número já usado
    SELECT SINGLE FROM zchamado_eag
      FIELDS MAX( chamado_id )
      INTO @DATA(lv_max).

      MODIFY ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        UPDATE FIELDS ( ChamadoId )
        WITH VALUE #( FOR ls_chamado IN lt_chamados INDEX INTO lv_idx
                      ( %tky = ls_chamado-%tky  ChamadoId = lv_max + lv_idx ) ).
  ENDMETHOD.

    METHOD get_instance_features.
    " 1. Ler o status de cada chamado pedido
    READ ENTITIES OF zr_chamado_eag IN LOCAL MODE
      ENTITY Chamado
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_chamados)
      FAILED failed.

    " 2. Uma linha de resultado por chamado
    result = VALUE #( FOR ls_chamado IN lt_chamados
      ( %tky = ls_chamado-%tky

        " Edit: desabilitado se fechado
        %update = COND #( WHEN ls_chamado-Status = 'F'
                          THEN if_abap_behv=>fc-o-disabled
                          ELSE if_abap_behv=>fc-o-enabled )

        " Botão Fechar: desabilitado se já fechado
        %action-fechar = COND #( WHEN ls_chamado-Status = 'F'
                                 THEN if_abap_behv=>fc-o-disabled
                                 ELSE if_abap_behv=>fc-o-enabled )

        " Prioridade: obrigatória se Aberto, senão somente leitura
        %field-Prioridade = COND #( WHEN ls_chamado-Status = 'A'
                                    THEN if_abap_behv=>fc-f-mandatory
                                    ELSE if_abap_behv=>fc-f-read_only )

        %action-Edit = COND #( WHEN ls_chamado-Status = 'F'
                               THEN if_abap_behv=>fc-o-disabled
                               ELSE if_abap_behv=>fc-o-enabled )
                               )
       ).


  ENDMETHOD.

ENDCLASS.
