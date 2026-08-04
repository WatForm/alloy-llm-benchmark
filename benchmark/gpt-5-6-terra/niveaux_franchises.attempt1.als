sig DeductibleLevel {
    product: one Product,
    coverages: Coverage -> RiskType -> DeductibleValue
}

sig Product {
    base_coverages: set Coverage,
    optional_coverages: set Coverage,
    risk_types: set RiskType,
    coverages: set Coverage
}

sig Coverage {
    risk_types: set RiskType
}

sig RiskType {}

sig DeductibleValue {}

fact {
    all p: Product |
        p.coverages = p.base_coverages + p.optional_coverages

    all dl: DeductibleLevel | {
        all c: dl.product.base_coverages, r: RiskType |
            one dl.coverages[c][r]

        { c: Coverage, r: RiskType | some dl.coverages[c][r] } =
            (dl.product.coverages <: Coverage.risk_types)
    }
}