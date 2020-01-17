INTERFACE zif_brf_parameters_order_type
  PUBLIC .

  INTERFACES zif_brf_function_processor.

  METHODS process
    IMPORTING
      !i_parameters_order_type_in        TYPE zca_parameters_order_type_in
    RETURNING
      VALUE(r_parameters_order_type_out) TYPE zca_t_parameter_order_type_out
    RAISING
      zcx_brf_function .

  ALIASES:
           clear_buffer      FOR zif_brf_function_processor~clear_buffer,
           switch_on_buffer  FOR zif_brf_function_processor~switch_on_buffer,
           switch_off_buffer FOR zif_brf_function_processor~switch_off_buffer,
           set_trace_mode    FOR zif_brf_function_processor~set_trace_mode.
ENDINTERFACE.
