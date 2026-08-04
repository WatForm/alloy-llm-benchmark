one sig Amendment {
  modifications: set Modification
}

sig Modification {
  modified_entity: lone ModifiedEntity,
  application_date: lone Date
}

sig ModifiedEntity {}

sig Date {}

fact {
  Modification in Amendment.modifications
  ModifiedEntity in Modification.modified_entity
  Date in Modification.application_date
  some Modification
  all a: Amendment, m: a.modifications |
    one m.modified_entity and one m.application_date
}