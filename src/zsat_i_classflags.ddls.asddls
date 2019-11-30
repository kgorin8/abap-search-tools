@AbapCatalog.sqlViewName: 'ZSATICLSFLAGS'
@AbapCatalog.compiler.CompareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flags in a Class/Interface'

define view ZSAT_I_ClassFlags
  as select distinct from seoclassdf
{
  key clsname         as ClassName,
  key 'SHARED_MEMORY' as Flag
}
where
      version         = '1'
  and clssharedmemory = 'X'

union select distinct from seoclassdf

{
  key clsname as ClassName,
  key 'FINAL' as Flag
}
where
      version  = '1'
  and clsfinal = 'X'
union select distinct from seoclassdf

{
  key clsname as ClassName,
  key 'TEST'  as Flag
}
where
      version         = '1'
  and with_unit_tests = 'X'
union select distinct from seoclassdf

{
  key clsname    as ClassName,
      'FIXPOINT' as Flag
}
where
      version = '1'
  and fixpt   = 'X'
union select distinct from seoclassdf

{
  key clsname    as ClassName,
      'ABSTRACT' as Flag
}
where
      version    = '1'
  and clsabstrct = 'X'
union select distinct from seoclassdf

{
  key clsname    as ClassName,
      'UNICODE' as Flag
}
where
      version    = '1'
  and unicode    = 'X'
  
