INTERFACE zif_brf_function_processor
  PUBLIC .
  METHODS:
    set_trace_mode
      IMPORTING
        i_trace_mode TYPE fdt_trace_mode
        i_save_trace TYPE abap_bool ,
    switch_on_buffer,
    switch_off_buffer,
    clear_buffer.

ENDINTERFACE.
