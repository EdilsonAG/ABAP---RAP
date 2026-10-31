CLASS zcl_chamado_eml_eag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_chamado_eml_eag IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    " 1. Descobrir a chave (UUID) do chamado nº 1
    SELECT SINGLE ChamadoUuid FROM zr_chamado_eag
      WHERE ChamadoId = '0000000001'
      INTO @DATA(lv_uuid).


    " 2. LER via EML
     READ ENTITIES OF zr_chamado_eag
      ENTITY Chamado
        ALL FIELDS WITH VALUE #( ( ChamadoUuid = lv_uuid ) )
      RESULT DATA(lt_chamados)
      FAILED DATA(ls_failed_read).

      IF ls_failed_read IS NOT INITIAL.
      out->write( 'Chamado não encontrado' ).
      RETURN.
    ENDIF.
    out->write( lt_chamados ).

     " 3. ALTERAR via EML
    MODIFY ENTITIES OF zr_chamado_eag
      ENTITY Chamado
        UPDATE FIELDS ( Titulo )
        WITH VALUE #( ( ChamadoUuid = lv_uuid
                        Titulo      = 'Impressora - alterado via EML' ) )
      FAILED   DATA(ls_failed_upd)
      REPORTED DATA(ls_reported_upd).

      " 4. GRAVAR ou DESCARTAR
    IF ls_failed_upd IS INITIAL.
      COMMIT ENTITIES.
      out->write( 'Atualizado com sucesso!' ).
    ELSE.
      ROLLBACK ENTITIES.
      out->write( 'Erro na atualização' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
