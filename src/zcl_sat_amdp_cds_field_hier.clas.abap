CLASS zcl_sat_amdp_cds_field_hier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_cds_field_hierarchy FOR TABLE FUNCTION zsat_i_cdsfieldhierarchy.

    INTERFACES if_amdp_marker_hdb.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sat_amdp_cds_field_hier IMPLEMENTATION.


  METHOD get_cds_field_hierarchy BY DATABASE FUNCTION FOR HDB
                                  LANGUAGE SQLSCRIPT
                                  OPTIONS READ-ONLY
                                  USING dd27s zsatpcdsvb zsaticdsf.
    declare i int;
    declare lv_current_index int;
    declare lv_base_viewname nvarchar(30);
    declare lv_base_viewfield nvarchar(30);

    -- build initial view table
    field_tables = select distinct field.viewname as basetable,
                                   field.viewfield as basefield
                   from dd27s as field
                     inner join zsatpcdsvb as view_base
                       on   view_base.viewname = field.viewname
                       and  view_base.entityid = upper( :p_cdsviewname )
                   where FIELD.viewfield = upper( :p_cdsfieldname );

    -- determine all view FIELDS for the given table name
    WHILE record_count(:field_tables) > 0 DO

      view_fields = SELECT DISTINCT field.viewname as viewname,
                                    field.viewfield as viewfield,
                                    1 as level,
                                    '' as entityname,
                                    '' as viewfieldraw,
                                    field.tabname as basetable,
                                    '' as baseentityname,
                                    field.fieldname as basefield,
                                    '' as basefieldraw
                    from dd27s as field
                      inner join :field_tables as tables
                        on  field.viewname = tables.basetable
                        and field.viewfield = tables.basefield
                    where field.viewfield <> 'MANDT';

      if :lv_current_index is null then
        view_fields_final = select * from :view_fields;
        lv_current_index = record_count( :view_fields );
      ELSE
        for i in 1 .. record_count( :view_fields ) DO
           lv_base_viewname = :view_fields.viewname[i];
           lv_base_viewfield = :view_fields.viewfield[i];

           lt_root_field = select distinct level
                           from :view_fields_final
                           where basetable = :lv_base_viewname
                             and basefield = :lv_base_viewfield;
           IF is_empty( :lt_root_field ) then
             CONTINUE ;
           END if;

           lv_current_index = :lv_current_index + 1;

           :view_fields_final.insert((:view_fields.viewname[i],
                                      :view_fields.viewfield[i],
                                      :lt_root_field.level[1] + 1,
                                      :view_fields.entityname[i],
                                      :view_fields.viewfieldraw[i],
                                      :view_fields.basetable[i],
                                      :view_fields.baseentityname[i],
                                      :view_fields.basefield[i],
                                      :view_fields.basefieldraw[i]
                                     ), :lv_current_index);
        END for;
      END if;

      field_tables = SELECT DISTINCT basetable, basefield FROM :view_fields;
    END WHILE ;

    -- enhance final result WITH raw entity names and raw fieldnames

    RETURN SELECT DISTINCT all_fields.viewname,
                           all_fields.viewfield,
                           all_fields.level,
                           coalesce(view.rawentityid, all_fields.entityname) as entityname,
                           view.ddlname,
                           coalesce(view_field.rawfieldname, all_fields.viewfieldraw) as viewfieldraw,
                           all_fields.basetable,
                           coalesce(base_table.rawentityid, all_fields.baseentityname) as baseentityname,
                           base_table.ddlname as baseddlname,
                           base_table.sourcetype as basesourcetype,
                           all_fields.basefield,
                           coalesce(base_field.rawfieldname, all_fields.basefieldraw) as basefieldraw
           from :view_fields_final as all_fields
             left outer join zsatpcdsvb as view
               ON view.viewname = all_fields.viewname
             left outer join zsaticdsf as view_field
               on  view_field.entityid = view.entityid
               and view_field.fieldname = all_fields.viewfield
             left outer join zsatpcdsvb as base_table
               on base_table.viewname = all_fields.basetable
               or base_table.entityid = all_fields.basetable
             left outer join zsaticdsf as base_field
               on  base_field.entityid = base_table.entityid
               and base_field.fieldname = all_fields.basefield;
  endmethod.
ENDCLASS.
