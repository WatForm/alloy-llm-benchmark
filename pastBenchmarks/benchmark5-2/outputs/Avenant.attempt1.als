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
  all m: Modification | some a: Amendment | m in a.modifications
}

fact {
  all e: ModifiedEntity | some m: Modification | e in m.modified_entity
}

fact {
  all d: Date | some m: Modification | d in m.application_date
}

fact {
  some Amendment.modifications
}

fact {
  all a: Amendment, m: a.modifications |
    one m.modified_entity and one m.application_date
}