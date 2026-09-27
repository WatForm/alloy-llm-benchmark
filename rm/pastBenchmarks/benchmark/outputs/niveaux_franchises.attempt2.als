sig TypeRisque {}

sig ValeurFranchise {}

sig Garantie {
  types_risque: set TypeRisque
}

sig Produit {
  garanties_hors_options: set Garantie,
  garanties_optionnelles: set Garantie,
  types_risque: set TypeRisque
}

fun garanties[p: Produit]: set Garantie {
  p.garanties_hors_options + p.garanties_optionnelles
}

fact ProduitTypesRisque {
  all p: Produit | p.types_risque = garanties[p].types_risque
}

sig NiveauFranchise {
  produit: one Produit,
  garanties: Garantie -> TypeRisque -> ValeurFranchise
}

pred est_valide[nf: NiveauFranchise] {
  nf.garanties.ValeurFranchise = garanties[nf.produit].types_risque
  all g: nf.produit.garanties_hors_options, tr: g.types_risque | one nf.garanties[g][tr]
}

check { all nf: NiveauFranchise | est_valide[nf] } for exactly 1 Produit, exactly 1 NiveauFranchise, exactly 1 Garantie