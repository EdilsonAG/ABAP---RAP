CLASS zcl_comentario_eml_eag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_comentario_eml_eag IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
        SELECT SINGLE ChamadoUuid FROM zr_chamado_eag
      WHERE ChamadoId = '0000000001' INTO @DATA(lv_uuid).

    MODIFY ENTITIES OF zr_chamado_eag
      ENTITY Chamado
        CREATE BY \_Comentarios
        FIELDS ( Texto )
        WITH VALUE #( ( ChamadoUuid = lv_uuid
                        %target = VALUE #( ( %cid  = 'c1'
                                             Texto = 'Primeiro comentário via EML' ) ) ) )
      MAPPED DATA(ls_mapped) FAILED DATA(ls_failed) REPORTED DATA(ls_reported).

    COMMIT ENTITIES RESPONSE OF zr_chamado_eag
      FAILED DATA(ls_failed_c) REPORTED DATA(ls_reported_c).

    IF ls_failed IS INITIAL AND ls_failed_c IS INITIAL.
      out->write( |Comentário criado: { ls_mapped-comentario[ 1 ]-ComentarioUuid }| ).
    ELSE.
      out->write( 'Erro ao criar comentário' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
