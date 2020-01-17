INTERFACE zif_brf_parameters_for_program
  PUBLIC .

  INTERFACES:
    zif_brf_function_processor.

  METHODS process
    IMPORTING
      i_parameters_for_program_in    TYPE zca_parameters_for_program_in
    RETURNING
      VALUE(r_parameter_value_table) TYPE zca_parameter_value_table
    RAISING
      zcx_brf_function .

  ALIASES:
    clear_buffer      FOR zif_brf_function_processor~clear_buffer,
    switch_on_buffer  FOR zif_brf_function_processor~switch_on_buffer,
    switch_off_buffer FOR zif_brf_function_processor~switch_off_buffer,
    set_trace_mode    FOR zif_brf_function_processor~set_trace_mode.
ENDINTERFACE.
