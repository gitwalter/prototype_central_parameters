interface ZIF_BRF_FUNCTION_BUFFER
  public .


  methods CLEAR .
  methods READ
    importing
      !I_IMPORT_PARAMETER type ANY
    exporting
      !E_RESULT_PARAMETER type ANY
    returning
      value(R_FOUND) type ABAP_BOOL .
  methods WRITE
    importing
      !I_IMPORT_PARAMETER type ANY
      !I_RESULT_PARAMETER type ANY .
endinterface.
