CLASS zcl_brf_function_buffer_null DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE

  GLOBAL FRIENDS zcl_brf_function_buffer .

  PUBLIC SECTION.

    INTERFACES zif_brf_function_buffer .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_brf_function_buffer_null IMPLEMENTATION.


  METHOD zif_brf_function_buffer~read.
    CLEAR: r_found,
           e_result_parameter.
  ENDMETHOD.


  METHOD zif_brf_function_buffer~write.
    RETURN.
  ENDMETHOD.
  METHOD zif_brf_function_buffer~clear.
    RETURN.
  ENDMETHOD.

ENDCLASS.
