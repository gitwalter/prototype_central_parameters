CLASS zcl_brf_function_processor DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_brf_function_processor.

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.

    DATA function_name TYPE if_fdt_types=>name .

    METHODS:
      process_internal
          FINAL
        RAISING
          zcx_brf_function ,
      set_function_name
        ABSTRACT ,
      set_parameter_references
            FINAL
        IMPORTING
          i_import_parameter TYPE any
        CHANGING
          c_result_parameter TYPE any .
  PRIVATE SECTION.

    CLASS-DATA execution_timestamp TYPE timestamp .
    DATA:
      use_buffer                 TYPE abap_bool VALUE abap_true,
      function_id                TYPE if_fdt_types=>id,
      import_parameter_id        TYPE if_fdt_types=>id,
      import_parameter_name      TYPE if_fdt_types=>name,
      import_parameter_reference TYPE REF TO data,
      result_parameter_reference TYPE REF TO data,
      trace_mode                 TYPE fdt_trace_mode VALUE if_fdt_constants=>gc_trace_mode_technical ##NO_TEXT,
      trace_is_to_save           TYPE abap_bool VALUE abap_false.

    METHODS:
      check_parameter_references
        RAISING
          zcx_brf_function ,
      get_import_parameter
        RAISING
          zcx_brf_function ,
      get_metadata
        RAISING
          zcx_brf_function ,
      get_object_id
        IMPORTING
          i_object_name      TYPE if_fdt_types=>name
        RETURNING
          VALUE(r_object_id) TYPE if_fdt_types=>id
        RAISING
          zcx_brf_function ,
      save_trace
        IMPORTING
          i_trace TYPE REF TO if_fdt_trace ,
      build_name_value_table
        RETURNING
          VALUE(r_name_values) TYPE abap_parmbind_tab
        RAISING
          cx_fdt_input,
      call_brf_function
        CHANGING
          c_result_parameter TYPE data
        RAISING
          zcx_brf_function,
      get_buffer
        RETURNING
          VALUE(r_brf_function_buffer) TYPE REF TO zif_brf_function_buffer.
ENDCLASS.



CLASS zcl_brf_function_processor IMPLEMENTATION.

  METHOD build_name_value_table.

    DATA name_value TYPE abap_parmbind.

    cl_fdt_function_process=>move_data_to_data_object( EXPORTING ir_data             = import_parameter_reference
                                                                 iv_function_id      = function_id
                                                                 iv_data_object      = import_parameter_id
                                                                 iv_timestamp        = execution_timestamp
                                                                 iv_trace_generation = abap_false
                                                                 iv_has_ddic_binding = abap_true
                                                       IMPORTING er_data             = name_value-value ).

    name_value-name = import_parameter_name.
    INSERT name_value INTO TABLE r_name_values.

  ENDMETHOD.


  METHOD check_parameter_references.
    IF import_parameter_reference IS NOT BOUND OR
       result_parameter_reference IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_brf_function
        EXPORTING
          textid      = zcx_brf_function=>parameter_references_not_set
          object_name = function_name.
    ENDIF.
  ENDMETHOD.

  METHOD class_constructor.
****************************************************************************************************
* Alle Methodenaufrufe, die innerhalb eines Bearbeitungszyklus dieselbe Funktion aufrufen, müssen denselben Zeitstempel verwenden
* Bei Folgeaufrufen derselben Funktion ist es ratsam, alle Aufrufe mit demselben Zeitstempel auszuführen
* Dies dient zur Verbesserung der System-Performance
****************************************************************************************************
    GET TIME STAMP FIELD execution_timestamp.
  ENDMETHOD.

  METHOD get_import_parameter.

* Alle Kontextobjekte der Funktion ermitteln
    DATA(contextobjectids) = cl_fdt_factory=>get_instance( )->get_function( function_id )->get_context_data_objects( ).

* Es darf nur ein Kontextobjekt zur Funktion, die die Entscheidungstabelle liest, geben
    IF lines( contextobjectids ) <> 1.
      RAISE EXCEPTION TYPE zcx_brf_function
        EXPORTING
          textid                 = zcx_brf_function=>import_parameter_not_found
          context_object_counter = lines( contextobjectids ).
    ENDIF.

    READ TABLE contextobjectids INDEX 1 ASSIGNING FIELD-SYMBOL(<contextobjectid>).

* Instanz holen
    cl_fdt_factory=>get_instance_generic( EXPORTING iv_id         = <contextobjectid>
                                          IMPORTING eo_instance   = DATA(instance) ).

* Namen und ID setzen
    import_parameter_name = instance->get_name( ).
    import_parameter_id   = <contextobjectid>.

  ENDMETHOD.

  METHOD get_metadata.
    IF function_id IS INITIAL.
* SET_FUNCTION_NAME muss in der Verschalungsklasse
* redefiniert werden. Dort muss der Namen der Funktion
* gesetzt werden.
      set_function_name( ).
      function_id = get_object_id( function_name ).
      get_import_parameter( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_object_id.
    DATA text_id TYPE scx_t100key.
    DATA(brf_query) = cl_fdt_factory=>get_instance( )->get_query( ).

    brf_query->get_ids( EXPORTING iv_name       = i_object_name
                        IMPORTING ets_object_id = DATA(brf_object_ids) ).

* Eindeutiger Name?
    CASE lines( brf_object_ids ).
      WHEN 0.
        text_id = zcx_brf_function=>no_object_found.
      WHEN 1.
        r_object_id = brf_object_ids[ 1 ].
        RETURN.
      WHEN OTHERS.
        text_id = zcx_brf_function=>object_name_not_unique.
    ENDCASE.

    RAISE EXCEPTION TYPE zcx_brf_function
      EXPORTING
        textid      = text_id
        object_name = i_object_name.
  ENDMETHOD.

  METHOD process_internal.
* Prüfung, dass Parameterreferenzen gesetzt sind
    check_parameter_references( ).

* Schnittstellenparameter dereferenzieren
    ASSIGN: import_parameter_reference->* TO FIELD-SYMBOL(<import_parameter>),
            result_parameter_reference->* TO FIELD-SYMBOL(<result_parameter>).

* Funktionsnamen, Funktions-ID, Importparameternamen und Importparameter-ID ermitteln
    get_metadata( ).

* Puffer lesen
    DATA(brf_function_buffer) = get_buffer( ).

    IF brf_function_buffer->read( EXPORTING i_import_parameter = <import_parameter>
                                  IMPORTING e_result_parameter = <result_parameter> ).
      RETURN.
    ENDIF.

    call_brf_function( CHANGING c_result_parameter = <result_parameter> ).

* Puffer schreiben
    brf_function_buffer->write( EXPORTING i_import_parameter = <import_parameter>
                                          i_result_parameter = <result_parameter> ).

  ENDMETHOD.

  METHOD save_trace.
    DATA lean_trace TYPE REF TO if_fdt_lean_trace.

    lean_trace ?= i_trace.
    lean_trace->save( ).
  ENDMETHOD.

  METHOD set_parameter_references.
    GET REFERENCE OF i_import_parameter INTO import_parameter_reference.
    GET REFERENCE OF c_result_parameter INTO result_parameter_reference.
  ENDMETHOD.

  METHOD call_brf_function.

    TRY.
* Aufbau Name-Valuetabelle
        DATA(name_values) = build_name_value_table( ).

* Aufruf der Funktion
        cl_fdt_function_process=>process( EXPORTING iv_function_id = function_id
                                                    iv_timestamp   = execution_timestamp
                                                    iv_trace_mode  = trace_mode
                                          IMPORTING ea_result      = c_result_parameter
                                                    eo_trace       = DATA(trace)
                                          CHANGING  ct_name_value  = name_values ).
        IF trace_is_to_save = abap_true.
          save_trace( trace ).
        ENDIF.

      CATCH cx_fdt INTO DATA(fdt_exception).
        RAISE EXCEPTION TYPE zcx_brf_function
          EXPORTING
            textid      = zcx_brf_function=>function_error
            previous    = fdt_exception
            object_name = function_name.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_brf_function_processor~set_trace_mode.
    trace_mode       = i_trace_mode.
    trace_is_to_save = i_save_trace.
  ENDMETHOD.

  METHOD zif_brf_function_processor~switch_off_buffer.
    use_buffer = abap_false.
  ENDMETHOD.

  METHOD zif_brf_function_processor~switch_on_buffer.
    use_buffer = abap_true.
  ENDMETHOD.

  METHOD get_buffer.
    r_brf_function_buffer  = zcl_brf_function_buffer=>get_instance(
                                i_function_name              = function_name
                                i_use_buffer                 = use_buffer
                                i_import_parameter_reference = import_parameter_reference
                                i_result_parameter_reference = result_parameter_reference ).
  ENDMETHOD.

  METHOD zif_brf_function_processor~clear_buffer.
    get_buffer( )->clear( ).
  ENDMETHOD.

ENDCLASS.
