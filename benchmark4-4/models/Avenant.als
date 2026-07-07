one sig Amendment
{
	modifications: set Modification
}

sig Modification
{
	modified_entity: lone ModifiedEntity,
	application_date: lone Date
}
{
	some modifications.this
}

sig ModifiedEntity {}
{
	some modified_entity.this
}

sig Date {}
{
	some application_date.this
}

pred ModificationSpec[ M: Modification ]
{
	one M.modified_entity
	one M.application_date
}

fact Specification
{
	some modifications
	all M: Amendment.modifications | ModificationSpec[M]
}
