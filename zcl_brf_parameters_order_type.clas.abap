CLASS zcl_brf_parameters_order_type DEFINITION
  PUBLIC
  INHERITING FROM zcl_brf_function_processor
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_brf_parameters_order_type .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_brf_parameters_order_type) TYPE REF TO zif_brf_parameters_order_type .
  PROTECTED SECTION.

    METHODS set_function_name
        REDEFINITION .
  PRIVATE SECTION.

    CLASS-DATA brf_parameters_order_type TYPE REF TO zif_brf_parameters_order_type .
ENDCLASS.

CLASS zcl_brf_parameters_order_type IMPLEMENTATION.

  METHOD get_instance.
    IF brf_parameters_order_type IS NOT BOUND.
      brf_parameters_order_type = NEW zcl_brf_parameters_order_type( ).
    ENDIF.
    r_brf_parameters_order_type = brf_parameters_order_type.
  ENDMETHOD.

  METHOD set_function_name.
    function_name = 'FC_PARAMETERS_ORDER_TYPE'.
  ENDMETHOD.

  METHOD zif_brf_parameters_order_type~process.
* Referenzen für Import- und Exportparameter setzen
    set_parameter_references( EXPORTING i_import_parameter = i_parameters_order_type_in
                              CHANGING  c_result_parameter = r_parameters_order_type_out ).

* Verarbeitung aufrufen
    process_internal( ).
  ENDMETHOD.
ENDCLASS.
