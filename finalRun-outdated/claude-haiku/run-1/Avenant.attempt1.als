sig Amendment {
  modifications: set Modification
}

sig Modification {
  modified_entity: lone ModifiedEntity,
  application_date: lone Date
}

sig ModifiedEntity {}

sig Date {}

fact {
  #Amendment = 1
}

fact {
  all m: Modification | m in Amendment.modifications
}

fact {
  all me: ModifiedEntity | me in Modification.modified_entity
}

fact {
  all d: Date | d in Modification.application_date
}

fact {
  #Modification > 0
}

fact {
  all m: Modification | m in Amendment.modifications implies (one m.modified_entity and one m.application_date)
}