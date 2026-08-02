one sig Amendment {
  modifications: set Modification
}

sig Modification {
  modified_entity: lone ModifiedEntry,
  application_date: lone Date,
  modified_entities: set ModifiedEntry,
  modified_entry: set ModifiedEntry
}

sig ModifiedEntry {}

sig Date {}

fact {
  all m: Modification | some a: Amendment | m in a.modifications

  all e: ModifiedEntry | some m: Modification | e in m.modified_entities

  all d: Date | some m: Modification | d in m.application_date

  some Amendment.modifications

  all a: Amendment | all m: a.modifications | one m.modified_entry and one m.application_date
}