sig DeductibleLevel {
    product: one Product,
    coverages: Coverage -> RiskType -> DeductibleValue
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

fact {
    all d: DeductibleLevel |
        all c: d.product.base_coverages |
            all r: RiskType |
                one { v: DeductibleValue | c -> r -> v in d.coverages }

    all d: DeductibleLevel |
        all c: Coverage |
            all r: RiskType |
                (some v: DeductibleValue | c -> r -> v in d.coverages)
                iff
                (c in d.product.base_coverages + d.product.optional_coverages
                 and r in c.risk_types)
}