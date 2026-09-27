sig TypeRisque {}

sig ValeurFranchise {}

sig Garantie {
  types_risque: set TypeRisque
}

sig Produit {
  garanties_hors_options: set Garantie,
  garanties_optionnelles: set Garantie,
  types_risque: set TypeRisque
} {
  types_risque = garanties.types_risque
}

fun Produit.garanties: set Garantie {
  garanties_hors_options + garanties_optionnelles
}

sig NiveauFranchise {
  produit: one Produit,
  garanties: Garantie -> TypeRisque -> ValeurFranchise
}

pred NiveauFranchise.est_valide {
  garanties.TypeRisque = produit.garanties.types_risque
  all g: produit.garanties_hors_options, tr: g.types_risque | one garanties[g][tr]
}

check { all nf: NiveauFranchise | nf.est_valide } for exactly 1 Produit, exactly 1 NiveauFranchise, exactly 1 Garantie