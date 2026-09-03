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
	one Amendment
}

fact {
	all m: Modification | m in Amendment.modifications
}

fact {
	all e: ModifiedEntity | e in Modification.modified_entity
}

fact {
	all d: Date | d in Modification.application_date
}

fact {
	some Amendment.modifications
	all m: Amendment.modifications | one m.modified_entity and one m.application_date
}