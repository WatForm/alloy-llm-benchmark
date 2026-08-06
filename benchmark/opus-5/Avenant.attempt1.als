sig Amendment {
	modifications: set Modification
}

sig Modification {
	modified_entity: lone ModifiedEntity,
	application_date: lone Date
}

sig ModifiedEntity {}

sig Date {}

fact oneAmendment {
	one Amendment
}

fact allModificationsInSomeAmendment {
	all m: Modification | some a: Amendment | m in a.modifications
}

fact allModifiedEntitiesModified {
	all e: ModifiedEntity | some m: Modification | e in m.modified_entity
}

fact allDatesUsed {
	all d: Date | some m: Modification | d in m.application_date
}

fact someModifications {
	some Amendment.modifications
}

fact modificationsFullyDefined {
	all a: Amendment, m: a.modifications |
		one m.modified_entity and one m.application_date
}