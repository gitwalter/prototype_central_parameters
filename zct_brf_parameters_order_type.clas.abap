CLASS zct_brf_parameters_order_type DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS .

  PUBLIC SECTION.

    METHODS:
      a01_many_results_in_table FOR TESTING,
      a02_call_two_functions    FOR TESTING.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      parameters_order_type_in  TYPE zca_parameters_order_type_in,
      parameters_for_program_in TYPE zca_parameters_for_program_in,
      expected_lines            TYPE i.

    METHODS:
      set_existing_order_type_param,

      set_existing_program_param.
ENDCLASS.



CLASS zct_brf_parameters_order_type IMPLEMENTATION.


  METHOD a01_many_results_in_table.

    DO 10000 TIMES.
* given
      IF sy-index MOD 2 = 0.
        set_existing_order_type_param( ).
        expected_lines                 = 10.
      ELSE.
        CLEAR: expected_lines,
               parameters_order_type_in.
      ENDIF.

* when
      TRY.
          DATA(parameter_values) = zcl_brf_parameters_order_type=>get_instance( )->process( parameters_order_type_in ).
        CATCH zcx_brf_function INTO DATA(brf_function_exception).
      ENDTRY.
* then
      cl_abap_unit_assert=>assert_not_bound( brf_function_exception ).

      cl_abap_unit_assert=>assert_equals( act = lines( parameter_values )
                                          exp = expected_lines ).
    ENDDO.
  ENDMETHOD.

  METHOD a02_call_two_functions.
    DATA(brf_parameters_order_type) = zcl_brf_parameters_order_type=>get_instance( ).

    DO 100 TIMES.
* given
      IF sy-index MOD 2 = 0.
        set_existing_order_type_param( ).
        expected_lines                 = 10.
      ELSE.
        CLEAR: expected_lines,
               parameters_order_type_in.
      ENDIF.

      IF sy-index MOD 50 = 0.
        brf_parameters_order_type->clear_buffer( ).
        brf_parameters_order_type->switch_off_buffer( ).
        brf_parameters_order_type->set_trace_mode(
          EXPORTING
            i_trace_mode = if_fdt_constants=>gc_trace_mode_lean
            i_save_trace = abap_true ).
      ELSE.
        brf_parameters_order_type->switch_on_buffer( ).
        brf_parameters_order_type->set_trace_mode(
          EXPORTING
            i_trace_mode = if_fdt_constants=>gc_trace_mode_lean
            i_save_trace = abap_false ).
      ENDIF.

* when
      TRY.
          DATA(parameter_values) = brf_parameters_order_type->process( parameters_order_type_in ).
        CATCH zcx_brf_function INTO DATA(brf_function_exception).
      ENDTRY.
* then
      CL_ABAP_UNIT_ASSERT=>assert_not_bound( brf_function_exception ).

      CL_ABAP_UNIT_ASSERT=>assert_equals( act = lines( parameter_values )
                                           exp = expected_lines ).
    ENDDO.



    DO 10 TIMES.
* given
      IF sy-index MOD 2 = 0.
        set_existing_program_param( ).
        expected_lines = 2.
      ELSE.
        CLEAR: parameters_for_program_in,
               expected_lines.
      ENDIF.
* when
      TRY.
          parameter_values = zcl_brf_parameters_for_program=>get_instance( )->process( parameters_for_program_in ).
        CATCH zcx_brf_function INTO brf_function_exception.
      ENDTRY.
* then
      CL_ABAP_UNIT_ASSERT=>assert_not_bound( brf_function_exception ).

      CL_ABAP_UNIT_ASSERT=>assert_equals( act = lines( parameter_values )
                                          exp = expected_lines ).
    ENDDO.

  ENDMETHOD.


  METHOD set_existing_order_type_param.

    parameters_order_type_in-berch = 'EK'.
    parameters_order_type_in-bsart = 'YB01'.
    parameters_order_type_in-bstyp = 'F'.
    parameters_order_type_in-panam = 'LIFNR_NRTYP'.
    parameters_order_type_in-prgst = 'EXIT_SAPMM06E_006'.

  ENDMETHOD.


  METHOD set_existing_program_param.

    parameters_for_program_in-general_key          = 'FAARTYG70'.
    parameters_for_program_in-area                 = 'FI'.
    parameters_for_program_in-program_control_name = 'FAKTURA'.
    parameters_for_program_in-parameter_name       = 'POSITIONSTYP'.

  ENDMETHOD.

ENDCLASS.
