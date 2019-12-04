"! <p class="shorttext synchronized" lang="en">Analysis for Office Util</p>
CLASS zcl_sat_query_monitor_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized" lang="en">Creates Analysis for Office launcher for Query</p>
    CLASS-METHODS create_sapaox_launcher
      IMPORTING
        iv_query_ddlname              TYPE viewname
      RETURNING
        VALUE(rv_serialized_launcher) TYPE xstring.
    "! <p class="shorttext synchronized" lang="en">Open query in Analysis for Office</p>
    CLASS-METHODS open_in_analyis_for_office
      IMPORTING
        iv_query_ddlname TYPE viewname.
    "! <p class="shorttext synchronized" lang="en">Open query in Query Monitor (RSRT)</p>
    CLASS-METHODS open_in_query_monitor
      IMPORTING
        iv_query_ddlname TYPE viewname.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sat_query_monitor_util IMPLEMENTATION.
  METHOD create_sapaox_launcher.
    DATA: lv_launcher_xml        TYPE xstring,
          lv_launcher_xml_string TYPE string,
          lv_size                TYPE i,
          lt_launcher_binary     TYPE TABLE OF w3_mime,
          lv_file_ext            TYPE string.

    DATA(lv_query) = |2C{ iv_query_ddlname }|.

    CALL FUNCTION 'RSAO_CREATE_LAUNCH_FILE'
      EXPORTING
        i_application    = 00
        i_object_type    = 01
        i_object_id      = lv_query
        i_force_refresh  = abap_false
      IMPORTING
        e_launcher_xml   = rv_serialized_launcher
        e_file_extension = lv_file_ext.

  ENDMETHOD.

  METHOD open_in_analyis_for_office.
    DATA: lt_params TYPE TABLE OF rsparams.

*.. this sets the radio-group to document
*.. all entries are set to insure that exactly one parameter is set to true
*.. radio-button "Query" set to true
    lt_params = VALUE #(
     ( selname = 'P_T_DOC'
       kind    = 'P'
       low     = ' ' )
     ( selname = 'P_T_QV'
       kind    = 'P'
       low     = ' ' )
     ( selname = 'P_T_QU'
       kind    = 'P'
       low     = 'X' )
     ( selname = 'P_T_NONE'
       kind    = 'P'
       low     = ' ' )
*... this set the type of application - 00 for Excel, 01 for Powerpoint
     ( selname = 'P_APP'
       kind    = 'P'
       low     = '00' )
     ( selname = 'P_QUERY'
       kind    = 'P'
       low     = |2C{ iv_query_ddlname }| )
    ).

    SUBMIT rs_ao_launcher WITH SELECTION-TABLE lt_params AND RETURN .
  ENDMETHOD.

  METHOD open_in_query_monitor.
    CONSTANTS:
      BEGIN OF c_general_fields,
        cursor    TYPE bdcdata-fnam VALUE 'BDC_CURSOR',
        subscreen TYPE bdcdata-fnam VALUE 'BDC_SUBSCR',
        ok_code   TYPE bdcdata-fnam VALUE 'BDC_OKCODE',
      END OF c_general_fields .
    DATA: lt_bdc_input TYPE bdcdata_tab,
          ls_options   TYPE ctu_params.

    lt_bdc_input = VALUE #(
      ( program = 'SAPMRRI1'      dynpro = '0100' dynbegin = abap_true )
      ( fnam = c_general_fields-cursor   fval = 'GENUNIID' )
      ( fnam = c_general_fields-ok_code  fval = '/00' )
      ( fnam = 'GENUNIID'                fval = '2C/' && iv_query_ddlname )
*.... ABAP BICS
      ( fnam = 'G_DISPMODE'              fval = '3' )
      ( program = 'SAPMRRI1'      dynpro = '0100' dynbegin = abap_true )
      ( fnam = c_general_fields-cursor   fval = 'GENUNIID' )
      ( fnam = c_general_fields-ok_code  fval = '=GO' )
      ( fnam = 'GENUNIID'                fval = '2C' && iv_query_ddlname )
*.... ABAP BICS
      ( fnam = 'G_DISPMODE'              fval = '3' )
    ).

    ls_options-dismode = 'E'.
    ls_options-defsize = space.

    TRY .
        CALL TRANSACTION 'RSRT' WITH AUTHORITY-CHECK
                                USING lt_bdc_input
                                OPTIONS FROM ls_options.
      CATCH cx_sy_authorization_error INTO DATA(lx_auth_error).
      CATCH cx_root INTO DATA(lx_error).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
