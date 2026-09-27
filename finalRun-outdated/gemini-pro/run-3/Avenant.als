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
	all m: Modification | m in Amendment.modifications
	all me: ModifiedEntity | me in Modification.modified_entity
	all d: Date | d in Modification.application_date
	some Amendment.modifications
	all m: Amendment.modifications | one m.modified_entity and one m.application_date
}