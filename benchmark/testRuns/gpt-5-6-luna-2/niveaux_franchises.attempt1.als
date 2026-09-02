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
    all dl: DeductibleLevel |
        let p = dl.product |
            dl.coverages.DeductibleValue =
                (p.base_coverages + p.optional_coverages) <: Coverage.risk_types
            and
            all c: p.base_coverages, r: RiskType |
                one { v: DeductibleValue | c -> r -> v in dl.coverages }
}