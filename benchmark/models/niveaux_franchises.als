-- niveaux de franchise

open util/ternary

sig NiveauFranchise
{
  produit: Produit,
  garanties: Garantie -> TypeRisque -> ValeurFranchise
}

pred NiveauFranchise.est_valide
{
  select12[this.garanties] = (this.produit.garanties <: types_risque)
  all G: this.produit.garanties_hors_options, TR: TypeRisque | one this.garanties[G, TR]
}

sig Produit
{
  garanties_hors_options: set Garantie,
  garanties_optionnelles: set Garantie,
  types_risque: set TypeRisque
}

fun garanties : Produit->Garantie { garanties_hors_options + garanties_optionnelles }

sig Garantie
{
  types_risque: set TypeRisque
}

sig TypeRisque {}

sig ValeurFranchise {}

run est_valide for 3 but exactly 1 Produit, exactly 1 NiveauFranchise, exactly 1 Garantie
