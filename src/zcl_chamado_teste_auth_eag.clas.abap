CLASS zcl_chamado_teste_auth_eag DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_chamado_teste_auth_eag IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " SÓ PARA TESTE: muda o criador do chamado nº 2 direto na tabela
    UPDATE zchamado_eag
      SET local_created_by = 'OUTRO_USER'
      WHERE chamado_id = '0000000002'.
    COMMIT WORK.

    out->write( |{ sy-dbcnt } chamado(s) agora pertence(m) ao OUTRO_USER| ).
  ENDMETHOD.
ENDCLASS.
