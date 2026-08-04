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
  some Amendment.modifications
  all m: Modification | some a: Amendment | m in a.modifications
  all e: ModifiedEntity | some m: Modification | e in m.modified_entity
  all d: Date | some m: Modification | d in m.application_date
  all a: Amendment | all m: a.modifications |
    one m.modified_entity and one m.application_date
}