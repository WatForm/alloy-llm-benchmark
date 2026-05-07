sig Avenant {
  modifications: set Modification
}

sig Modification {
  modified_entity: lone ModifiedEntity,
  date_application: lone Date
} {
  some Avenant.modifications & this
}

sig ModifiedEntity {} {
  some Modification.modified_entity & this
}

sig Date {} {
  some Modification.date_application & this
}

pred CtrEx1 {
  no Modification
}

pred CtrEx2 {
  some m: Modification | no m.modified_entity and no m.date_application
}

pred ModificationSpec[m: Modification] {
  one m.modified_entity
  one m.date_application
}

pred Specification {
  some Modification
  all m: Avenant.modifications | ModificationSpec[m]
}

assert la_specification_respecte_les_contre_exemples {
  Specification implies (not CtrEx1 and not CtrEx2)
}

check la_specification_respecte_les_contre_exemples for 3 but 1 Avenant
run Specification for 3 but 1 Avenant, exactly 2 Modification