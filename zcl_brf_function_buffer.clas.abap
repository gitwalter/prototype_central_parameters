CLASS zcl_brf_function_buffer DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES:
      zif_brf_function_buffer .

    METHODS:
      constructor
        IMPORTING
          i_import_parameter_reference TYPE REF TO data OPTIONAL
          i_result_parameter_reference TYPE REF TO data OPTIONAL .
    CLASS-METHODS:
      get_instance
        IMPORTING
          i_function_name              TYPE fdt_name
          i_import_parameter_reference TYPE REF TO data
          i_result_parameter_reference TYPE REF TO data
          i_use_buffer                 TYPE abap_bool DEFAULT 'X'
        RETURNING
          VALUE(r_brf_function_buffer) TYPE REF TO zif_brf_function_buffer .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      brf_function_buffer_pool TYPE zca_t_brf_function_buffer.
    CLASS-METHODS:
      add_buffer_to_pool
        IMPORTING
          i_function_name       TYPE fdt_name
          i_brf_function_buffer TYPE REF TO zif_brf_function_buffer,
      get_buffer_from_pool
        IMPORTING
          i_function_name              TYPE fdt_name
        RETURNING
          VALUE(r_brf_function_buffer) TYPE REF TO zif_brf_function_buffer,
      get_null_buffer
        RETURNING
          VALUE(r_brf_function_buffer) TYPE REF TO zif_brf_function_buffer,
      get_function_buffer
        IMPORTING
          i_result_parameter_reference TYPE REF TO data
          i_import_parameter_reference TYPE REF TO data
          i_function_name              TYPE fdt_name
        RETURNING
          VALUE(r_brf_function_buffer) TYPE REF TO zif_brf_function_buffer.

    DATA:
      import_result_structure TYPE REF TO data,
      import_result_buffer    TYPE REF TO data.

    CONSTANTS:
      component_name_import TYPE string VALUE 'IMPORT' ##NO_TEXT,
      component_name_result TYPE string VALUE 'RESULT' ##NO_TEXT.
ENDCLASS.

CLASS zcl_brf_function_buffer IMPLEMENTATION.

  METHOD constructor.
    DATA: structure_component  TYPE LINE OF cl_abap_structdescr=>component_table,
          structure_components TYPE         cl_abap_structdescr=>component_table,
          key_description      TYPE abap_keydescr,
          key_descriptions     TYPE abap_keydescr_tab.

* Importparameter zu Struktur hinzufügen
    structure_component-name = component_name_import.
    ASSIGN i_import_parameter_reference->* TO FIELD-SYMBOL(<import_parameter>).
    structure_component-type ?= cl_abap_typedescr=>describe_by_data( <import_parameter> ).
    INSERT structure_component INTO TABLE structure_components.

* Ergebnisparameter zu Struktur hinzufügen
    structure_component-name = component_name_result.
    ASSIGN i_result_parameter_reference->* TO FIELD-SYMBOL(<result_parameter>).
    structure_component-type ?= cl_abap_typedescr=>describe_by_data( <result_parameter> ).
    INSERT structure_component INTO TABLE structure_components.

    DATA(import_result_description) = cl_abap_structdescr=>get( structure_components ).

* Pufferstruktur erzeugen
    CREATE DATA import_result_structure TYPE HANDLE import_result_description.

    key_description-name = component_name_import.
    INSERT key_description INTO TABLE key_descriptions.

    DATA(input_output_buffer_descr) = cl_abap_tabledescr=>get(
                                                 p_line_type  = import_result_description
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_hashed
                                                 p_unique     = abap_true
                                                 p_key        = key_descriptions ).

*  Puffertabelle erzeugen
    CREATE DATA import_result_buffer TYPE HANDLE input_output_buffer_descr.

  ENDMETHOD.


  METHOD get_instance.
    DATA: brf_function_buffer_line TYPE zca_brf_function_buffer.


    IF i_use_buffer = abap_false.
      r_brf_function_buffer = get_null_buffer( ).
      RETURN.
    ENDIF.

    r_brf_function_buffer = get_function_buffer(
          i_result_parameter_reference = i_result_parameter_reference
          i_import_parameter_reference = i_import_parameter_reference
          i_function_name              = i_function_name ).
  ENDMETHOD.


  METHOD zif_brf_function_buffer~read.
    FIELD-SYMBOLS <import_result_buffer> TYPE HASHED TABLE.

    r_found = abap_false.

    ASSIGN import_result_buffer->* TO <import_result_buffer>.

    IF <import_result_buffer> IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE <import_result_buffer>
         ASSIGNING FIELD-SYMBOL(<import_result_structure>)
         WITH TABLE KEY (component_name_import) = i_import_parameter.

    IF <import_result_structure> IS ASSIGNED.
      ASSIGN COMPONENT component_name_result OF  STRUCTURE <import_result_structure> TO FIELD-SYMBOL(<output>).
      e_result_parameter = <output>.
      r_found = abap_true.
    ELSE.
      CLEAR e_result_parameter.
      r_found = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_brf_function_buffer~write.
    FIELD-SYMBOLS <import_result_buffer> TYPE HASHED TABLE.

    ASSIGN: import_result_structure->*     TO FIELD-SYMBOL(<import_result_structure>),
            import_result_buffer->*        TO <import_result_buffer>.

    ASSIGN COMPONENT component_name_import OF  STRUCTURE <import_result_structure> TO FIELD-SYMBOL(<import>).
    <import> = i_import_parameter.

    ASSIGN COMPONENT component_name_result OF  STRUCTURE <import_result_structure> TO FIELD-SYMBOL(<result>).
    <result> = i_result_parameter.

    INSERT <import_result_structure> INTO TABLE <import_result_buffer>.
  ENDMETHOD.

  METHOD add_buffer_to_pool.
    DATA brf_function_buffer_line TYPE zca_brf_function_buffer.
    brf_function_buffer_line-function_name       = i_function_name.
    brf_function_buffer_line-brf_function_buffer = i_brf_function_buffer.
    INSERT brf_function_buffer_line INTO TABLE brf_function_buffer_pool.
  ENDMETHOD.


  METHOD get_buffer_from_pool.

    READ TABLE brf_function_buffer_pool
              WITH TABLE KEY function_name = i_function_name
              ASSIGNING FIELD-SYMBOL(<brf_function_buffer_line>).
    IF <brf_function_buffer_line> IS ASSIGNED.
      r_brf_function_buffer = <brf_function_buffer_line>-brf_function_buffer.
    ENDIF.

  ENDMETHOD.


  METHOD get_null_buffer.

* Keine Pufferung verwenden->Nullobjekt erzeugen
    r_brf_function_buffer = get_buffer_from_pool( space ).
    IF r_brf_function_buffer IS NOT BOUND.
      r_brf_function_buffer = NEW zcl_brf_function_buffer_null( ).
      add_buffer_to_pool(
        EXPORTING
          i_function_name       = space
          i_brf_function_buffer = r_brf_function_buffer ).
    ENDIF.

  ENDMETHOD.


  METHOD get_function_buffer.
* Puffer schon vorhanden?
    r_brf_function_buffer = get_buffer_from_pool( i_function_name ).
    IF r_brf_function_buffer IS NOT BOUND.
* Puffer erzeugen
      r_brf_function_buffer = NEW zcl_brf_function_buffer( i_import_parameter_reference = i_import_parameter_reference
                                                           i_result_parameter_reference = i_result_parameter_reference ).

      add_buffer_to_pool(
       EXPORTING
         i_function_name            = i_function_name
         i_brf_function_buffer      = r_brf_function_buffer ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_brf_function_buffer~clear.
    ASSIGN import_result_buffer->* TO FIELD-SYMBOL(<import_result_buffer>).
    CLEAR <import_result_buffer>.
  ENDMETHOD.

ENDCLASS.
