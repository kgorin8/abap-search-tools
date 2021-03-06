"! <p class="shorttext synchronized" lang="en">Types for Object Search</p>
INTERFACE zif_sat_ty_object_search
  PUBLIC .
  TYPES:
    "! <p class="shorttext synchronized" lang="en">Type for the object search</p>
    ty_search_type TYPE c LENGTH 15,
    "! <p class="shorttext synchronized" lang="en">Value range for search option value entry</p>
    BEGIN OF ty_s_value_range,
      sign    TYPE ddsign,
      sign2   TYPE ddsign,
      option  TYPE ddoption,
      option2 TYPE ddoption,
      low     TYPE string,
      high    TYPE string,
    END OF ty_s_value_range,
    "! <p class="shorttext synchronized" lang="en">Table of option value ranges</p>
    ty_t_value_range TYPE STANDARD TABLE OF ty_s_value_range WITH EMPTY KEY,

    "! <p class="shorttext synchronized" lang="en">Represents search option with its values</p>
    BEGIN OF ty_s_search_option,
      option      TYPE string,
      value_range TYPE ty_t_value_range,
    END OF ty_s_search_option,
    "! <p class="shorttext synchronized" lang="en">Table of search options</p>
    ty_t_search_option TYPE STANDARD TABLE OF ty_s_search_option WITH KEY option,

    "! <p class="shorttext synchronized" lang="en">Search engine parameters</p>
    BEGIN OF ty_s_search_engine_params,
      use_and_cond_for_options TYPE abap_bool,
      with_api_state           TYPE abap_bool,
      get_all                  TYPE abap_bool,
    END OF ty_s_search_engine_params.

ENDINTERFACE.
