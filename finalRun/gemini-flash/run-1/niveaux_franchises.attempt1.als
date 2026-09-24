Product`
      `Coverage`
      `RiskType`
      `base_coverages`
      `optional_coverages`
      `risk_types`
      `coverages`
      `product`

      Let's picture the exact Alloy file!
      ```alloy
      sig DeductibleLevel {
          product: one Product,
          coverages: Coverage -> RiskType -> DeductibleValue
      }
      ...
      ```
      Wait, how was `coverages` declared?
      Could it be:
      `coverages: Coverage -> RiskType -> DeductibleValue`
      or:
      `coverages: Coverage -> RiskType -> lone DeductibleValue`?
      Wait! If `coverages: Coverage -> RiskType -> lone DeductibleValue`:
      Wait, in Alloy, if you declare:
      `coverages: Coverage -> RiskType -> lone DeductibleValue` inside `sig DeductibleLevel`,
      what does that mean?
      In Alloy syntax:
      `sig DeductibleLevel { coverages: Coverage -> RiskType -> lone DeductibleValue }`
      Wait! Does Alloy allow multiplicities inside product types in field declarations?
      Let's check Alloy 6 grammar!
      In Alloy 6:
      `decl ::= [private] [disj] iden, ... : [disj] expr`
      `arrowExpr ::= expr [mult] -> [mult] expr`
      where `mult ::= lone | one | some | set`.
      So `Coverage -> RiskType -> lone DeductibleValue` IS valid syntax in Alloy!
      Wait, but what does the English text say?
      "Each "DeductibleLevel" also has a relation called "coverages" from "Coverage" and "RiskType" to "DeductibleValue"."
      Notice: "a relation called "coverages" from "Coverage" and "RiskType" to "DeductibleValue"".
      If it had `lone`, the English would likely say: "a relation ... to at most one DeductibleValue" or "a partial function ...".
      Here it just says: "a relation called "coverages" from "Coverage" and "RiskType" to "DeductibleValue"".
      So it is simply:
      `coverages: Coverage -> RiskType -> DeductibleValue` (or `set Coverage -> RiskType -> DeductibleValue`).
      Wait, in Alloy, does `coverages: Coverage -> RiskType -> DeductibleValue` mean the same as `coverages: set Coverage -> RiskType -> DeductibleValue`?
      Wait! In Alloy, what is the default multiplicity when `->` is present?
      Let's be 100% precise about Alloy's semantics for field declarations:
      In Alloy:
      `sig A { f: B }` -> multiplicity of `f` is `one` (i.e. `f: