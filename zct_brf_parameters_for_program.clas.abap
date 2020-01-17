CLASS zct_brf_parameters_for_program DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS .

  PUBLIC SECTION.

    METHODS a01_two_results_in_table
        FOR TESTING .
    METHODS a02_get_object_id
        FOR TESTING .
    METHODS a03_get_application_id
        FOR TESTING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zct_brf_parameters_for_program IMPLEMENTATION.


  METHOD a01_two_results_in_table.
    DATA parameters_for_program_in TYPE zca_parameters_for_program_in.

* given
    parameters_for_program_in-general_key          = 'FAARTYG70'.
    parameters_for_program_in-area                 = 'FI'.
    parameters_for_program_in-program_control_name = 'FAKTURA'.
    parameters_for_program_in-parameter_name       = 'POSITIONSTYP'.

* when
    TRY.
        DATA(parameter_values) = zcl_brf_parameters_for_program=>get_instance( )->process( parameters_for_program_in ).
      CATCH zcx_brf_function INTO DATA(brf_function_exception).
    ENDTRY.
* then
    cl_abap_unit_assert=>assert_not_bound( brf_function_exception ).

    cl_abap_unit_assert=>assert_equals( act = lines( parameter_values )
                                        exp = 2 ).

  ENDMETHOD.


  METHOD a02_get_object_id.
    DATA brf_query TYPE REF TO if_fdt_query.
    DATA brf_object_ids TYPE if_fdt_types=>ts_object_id.

    DATA(fdt_factory) = cl_fdt_factory=>get_instance( iv_application_id = '005056B14FC11EDA84B8CB8407C332BF' ).

    brf_query = fdt_factory->get_query( ).

    brf_query->get_ids(
    EXPORTING iv_name = 'I_PARAMETERS_FOR_PROGRAM_IN'
    IMPORTING ets_object_id = brf_object_ids ).

* Eindeutigkeit des Namens absichern
    cl_abap_unit_assert=>assert_equals( act = lines( brf_object_ids )
                                        exp = 1 ).

    cl_abap_unit_assert=>assert_equals( act = brf_object_ids[ 1 ]
                                        exp = '005056B14FC11EDA84B8E4E65BA812BF' ).


    brf_query->get_ids(
    EXPORTING iv_name = 'FC_PARAMETERS_FOR_PROGRAM'
    IMPORTING ets_object_id = brf_object_ids ).

* Eindeutigkeit des Namens absichern
    cl_abap_unit_assert=>assert_equals( act = lines( brf_object_ids )
                                        exp = 1 ).

    cl_abap_unit_assert=>assert_equals( act = brf_object_ids[ 1 ]
                                        exp = '005056B14FC11EDA84B8DEA9C12112BF' ).

  ENDMETHOD.


  METHOD a03_get_application_id.
    DATA(fdt_factory) = cl_fdt_factory=>get_instance( ).

    DATA(brf_query) = fdt_factory->get_query( ).

    brf_query->get_ids( EXPORTING iv_name       = 'AP_PROTOTYP_CENTRAL_PARAMETERS'
                        IMPORTING ets_object_id = DATA(brf_object_ids) ).

* Eindeutigkeit des Namens absichern
    cl_abap_unit_assert=>assert_equals( act = lines( brf_object_ids )
                                        exp = 1 ).

    cl_abap_unit_assert=>assert_equals( act = brf_object_ids[ 1 ]
                                        exp = '005056B14FC11EDA84B8CB8407C332BF' ).
  ENDMETHOD.
ENDCLASS.
