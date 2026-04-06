-- avenant

-- Domain
--open util/ordering[Date]

one sig Avenant
{
	modifications: set Modification
}

sig Modification
{
	modified_entity: lone ModifiedEntity,
	date_application: lone Date
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
	some date_application.this
}


-- Counter examples
pred CtrEx1[]
{
	no modifications
}

pred CtrEx2[]
{
	some M: Modification | no M.modified_entity or no M.date_application
}

-- Model
pred ModificationSpec[ M: Modification ]
{
	one  M.modified_entity
	one  M.date_application
}

pred Specification[]
{
	some modifications
	all M: Avenant.modifications | ModificationSpec[M]
}

assert la_specification_respecte_les_contre_exemples
{ 
	-- list counter examples here
	CtrEx1[] => not Specification[]
	CtrEx2[] => not Specification[]

}
check la_specification_respecte_les_contre_exemples for 3 but 1 Avenant

-- run model to see if generated samples are all OK
run { Specification[] } for 3 but 1 Avenant, exactly 2 Modification



