one sig Avenant {
  modifications: set Modification
}

sig Modification {
  modified_entity: one ModifiedEntity,
  date_application: one Date
}

sig ModifiedEntity {}
sig Date {}

fact AvenantContainsAllModifications {
  Avenant.modifications = Modification
}

fact ModifiedEntityIsReferenced {
  all me: ModifiedEntity | some m: Modification | m.modified_entity = me
}

fact DateIsReferenced {
  all d: Date | some m: Modification | m.date_application = d
}

pred CtrEx1 {
  no Modification
}

pred CtrEx2 {
  some m: Modification | no m.modified_entity or no m.date_application
}

pred ModificationSpec[m: Modification] {
  one m.modified_entity
  one m.date_application
}

pred Specification {
  some Avenant.modifications
  all m: Avenant.modifications | ModificationSpec[m]
}

assert la_specification_respecte_les_contre_exemples {
  (CtrEx1 or CtrEx2) implies not Specification
}

check la_specification_respecte_les_contre_exemples for 3 but exactly 1 Avenant
run Specification for 3 but exactly 1 Avenant, exactly 2 Modification