open util/ternary

sig DeductibleLevel {
  product: Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

pred DeductibleLevel.is_valid {
  select12[this.coverages] = (this.product.coverages <: risk_types)
  all C: this.product.base_coverages, RT: RiskType | one this.coverages[C, RT]
}

sig Product {
  base_coverages: set Coverage,
  optional_coverages: set Coverage,
  risk_types: set RiskType
}

fun coverages : Product -> Coverage { base_coverages + optional_coverages }

sig Coverage {
  risk_types: set RiskType
}

sig RiskType {}

sig DeductibleValue {}

fact AllDeductibleLevelsAreValid {
  all d: DeductibleLevel | d.is_valid
}
