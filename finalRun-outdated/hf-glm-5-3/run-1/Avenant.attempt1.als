open util/ordering[Date] as D

sig Amendment {
  modifications : set Modification
}

sig Modification {
  modified_entity : lone ModifiedEntity,
  application_date : lone Date
}

sig ModifiedEntity {}

sig Date {}

one sig AmendmentInstance in Amendment {}

fact AmendmentConstraints {
  one Amendment
  all m : Modification | m in Amendment.modifications
}

fact ModificationConstraints {
  all m : Amendment.modifications | one m.modified_entity and one m.application_date
}

fact ModifiedEntityConstraints {
  all e : ModifiedEntity | some m : Modification | e = m.modified_entity
}

fact DateConstraints {
  all d : Date | some m : Modification | d = m.application_date
}

fact ExistenceConstraints {
  some Amendment.modifications
}