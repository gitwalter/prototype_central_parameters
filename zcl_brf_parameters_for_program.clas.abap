CLASS zcl_brf_parameters_for_program DEFINITION
  PUBLIC
  INHERITING FROM zcl_brf_function_processor
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zif_brf_parameters_for_program .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_brf_parameters_for_program) TYPE REF TO zif_brf_parameters_for_program .
  PROTECTED SECTION.

    METHODS set_function_name
        REDEFINITION .
  PRIVATE SECTION.

    CLASS-DATA brf_parameters_for_program TYPE REF TO zif_brf_parameters_for_program .
ENDCLASS.



CLASS zcl_brf_parameters_for_program IMPLEMENTATION.
  METHOD get_instance.
    IF brf_parameters_for_program IS NOT BOUND.
      brf_parameters_for_program = NEW zcl_brf_parameters_for_program( ).
    ENDIF.
    r_brf_parameters_for_program = brf_parameters_for_program.
  ENDMETHOD.


  METHOD set_function_name.
    function_name = 'FC_PARAMETERS_FOR_PROGRAM'.
  ENDMETHOD.


  METHOD zif_brf_parameters_for_program~process.
* Referenzen für Import und Exportparameter setzen
    set_parameter_references( EXPORTING i_import_parameter = i_parameters_for_program_in
                              CHANGING  c_result_parameter = r_parameter_value_table ).

* Verarbeitung aufrufen
    process_internal( ).

  ENDMETHOD.
ENDCLASS.
