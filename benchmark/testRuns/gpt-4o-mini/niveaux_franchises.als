sig DeductibleLevel {
    product: one Product,
    coverages: set Coverage -> set RiskType -> one DeductibleValue
}

sig Product {
    base_coverages: set Coverage,
    optional_coverages: set Coverage,
    risk_types: set RiskType
}

sig Coverage {
    risk_types: set RiskType
}

sig RiskType {}

sig DeductibleValue {}

fact CoveragesDefinition {
    all d: DeductibleLevel | 
        d.coverages = (d.product.base_coverages + d.product.optional_coverages).coverages
}

fact DeductibleValueCreation {
    all d: DeductibleLevel, c: Coverage, r: RiskType | 
        c in d.product.base_coverages and 
        r in c.risk_types implies 
        one d.coverages[c, r]
}