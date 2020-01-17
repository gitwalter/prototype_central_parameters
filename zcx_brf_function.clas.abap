class ZCX_BRF_FUNCTION definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of NO_OBJECT_FOUND,
      msgid type symsgid value 'ZBRF_MESSAGES',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_OBJECT_FOUND .
  constants:
    begin of OBJECT_NAME_NOT_UNIQUE,
      msgid type symsgid value 'ZBRF_MESSAGES',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OBJECT_NAME_NOT_UNIQUE .
  constants:
    begin of FUNCTION_ERROR,
      msgid type symsgid value 'ZBRF_MESSAGES',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FUNCTION_ERROR .
  constants:
    begin of IMPORT_PARAMETER_NOT_FOUND,
      msgid type symsgid value 'ZBRF_MESSAGES',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'CONTEXT_OBJECT_COUNTER',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of IMPORT_PARAMETER_NOT_FOUND .
  constants:
    begin of PARAMETER_REFERENCES_NOT_SET,
      msgid type symsgid value 'ZBRF_MESSAGES',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PARAMETER_REFERENCES_NOT_SET .
  data OBJECT_NAME type IF_FDT_TYPES=>NAME .
  data CONTEXT_OBJECT_COUNTER type I .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !OBJECT_NAME type IF_FDT_TYPES=>NAME optional
      !CONTEXT_OBJECT_COUNTER type I optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_BRF_FUNCTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->OBJECT_NAME = OBJECT_NAME .
me->CONTEXT_OBJECT_COUNTER = CONTEXT_OBJECT_COUNTER .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
