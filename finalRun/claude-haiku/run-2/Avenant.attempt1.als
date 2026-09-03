sig Amendment {
  modifications: set Modification
}

sig Modification {
  modified_entity: one ModifiedEntity,
  application_date: one Date
}

sig ModifiedEntity {}

sig Date {}

fact {
  #Amendment = 1
}

fact {
  Modification in Amendment.modifications
}

fact {
  ModifiedEntity in Modification.modified_entity
}

fact {
  Date in Modification.application_date
}

fact {
  #Modification > 0
}