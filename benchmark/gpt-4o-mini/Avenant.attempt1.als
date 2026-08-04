sig Amendment {}

sig Modification {
    modified_entity: one ModifiedEntity,
    application_date: one Date
}

sig ModifiedEntity {}

sig Date {}

fact {
    // There is exactly one Amendment
    lone a: Amendment | true

    // Every Modification is in the set of modifications of some Amendment
    all m: Modification | m in a.modifications

    // Every Modification is related to at most one ModifiedEntity
    all m: Modification | lone m.modified_entity

    // Every Modification is related to at most one application_date
    all m: Modification | lone m.application_date

    // Every ModifiedEntity is in the set of modified_entity of some Modification
    all me: ModifiedEntity | some m: Modification | me in m.modified_entity

    // Every Date is in the set of application_date of some Modification
    all d: Date | some m: Modification | d in m.application_date
}

// There are some modifications
pred someModifications {
    some m: Modification
}

run someModifications for 10 but 1 Amendment, 10 Modification, 10 ModifiedEntity, 10 Date