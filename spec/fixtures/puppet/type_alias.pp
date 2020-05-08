# Documentation for Amodule::SimpleAlias
type Amodule::SimpleAlias = Variant[Numeric,String[1,20]]

# Documentation for Amodule::ComplexAlias
type Amodule::ComplexAlias = Struct[{
  value_type => Optional[ValueType],
  merge      => Optional[MergeType]
}]
