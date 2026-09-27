sig DeductibleValue {}

sig RiskType {}

sig Coverage {
  risk_types: set RiskType
}

sig Product {
  base_coverages: set Coverage,
  optional_coverages: set Coverage,
  risk_types: set RiskType
}

sig DeductibleLevel {
  product: one Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

fact {
  all dl: DeductibleLevel |
    all c: dl.product.base_coverages |
      all rt: c.risk_types |
        one dv: DeductibleValue | c -> rt -> dv in dl.coverages
}

fact {
  all dl: DeductibleLevel |
    all c: Coverage |
      all rt: RiskType |
        (some dv: DeductibleValue | c -> rt -> dv in dl.coverages) <=>
        (c in (dl.product.base_coverages + dl.product.optional_coverages) and 
         rt in c.risk_types)
}