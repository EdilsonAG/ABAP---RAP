CLASS zcl_chamado_eml_2_eag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_chamado_eml_2_eag IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    MODIFY ENTITIES OF zr_chamado_eag
      ENTITY Chamado
      " CREATE FIELDS ( " TODO 1: liste os campos que vai enviar (NÃO inclua ChamadoUuid))
        CREATE FIELDS ( ChamadoId Titulo Descricao Solicitante )
        WITH VALUE #( ( %cid = 'novo1'
                        " TODO 2: Campo = valor, para CADA campo listado no TODO 1
                        ChamadoId = 40
                        Titulo = 'OLA MONKEY'
                        Descricao = 'teste de descricao'
                        Solicitante = lv_user
                        Prioridade = 'X'
                      )

                      )

      MAPPED   DATA(ls_mapped)
      FAILED   DATA(ls_failed_cre)
      REPORTED DATA(ls_reported_cre).

      IF ls_failed_cre IS NOT INITIAL.
      ROLLBACK ENTITIES.
      out->write( 'Erro imediato no MODIFY' ).
      RETURN.
    ENDIF.

          " SÓ PARA TESTE: grava direto na tabela (pula o BO) para simular outro criador
    COMMIT ENTITIES RESPONSE OF zr_chamado_eag
      FAILED   DATA(ls_failed_commit)
      REPORTED DATA(ls_reported_commit).


    IF ls_failed_commit IS NOT INITIAL.
      out->write( 'Erro no SAVE (validation):' ).
      LOOP AT ls_reported_commit-chamado INTO DATA(ls_rep).
        out->write( ls_rep-%msg->if_message~get_text( ) ).
      ENDLOOP.
      RETURN.
    ENDIF.

    out->write( |Criado! UUID: { ls_mapped-chamado[ 1 ]-ChamadoUuid }| ).

    " 3. SÓ PARA TESTE: simular outro criador direto na tabela (agora o registro já existe no banco)
   " UPDATE zchamado_eag
   ""   SET local_created_by = 'OUTRO_USER'
   "   WHERE chamado_uuid = @lv_uuid.
   " COMMIT WORK.
  "  out->write( |{ sy-dbcnt } chamado alterado para OUTRO_USER| ).

  ENDMETHOD.

ENDCLASS.
