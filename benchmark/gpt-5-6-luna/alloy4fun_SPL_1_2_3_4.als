sig StoredModel {
    derivationOf: lone StoredModel,
    public: lone Link,
    secret: lone Link,
    command: lone Command
}

sig Link {}

sig Command {}

sig Instance {
    instanceOf: one Command,
    model: set StoredModel,
    link: one Link
}

sig Secret in StoredModel {}

fact {
    all l: Link | one (public.l + secret.l + link.l)

    all m: StoredModel | some m.secret implies m in Secret

    all s: Secret | some s.secret implies some s.public

    all s: Secret |
        some s.public implies
            (some s.secret or some x: StoredModel |
                x in s.^derivationOf and some x.secret)

    no iden & ^derivationOf

    all m: StoredModel |
        no m.public implies lone m.derivationOf

    all m: StoredModel |
        some (m.^derivationOf & Secret) implies m in Secret

    all s: Secret |
        (some s.public and no s.secret) implies
            (all x: StoredModel |
                s in x.*derivationOf implies no x.secret)

    all c: Command |
        one {m: StoredModel | m.command = c}

    all m: StoredModel |
        (no m.public) iff (some m.command)

    all i: Instance |
        i.model = {m: StoredModel | m.command = i.instanceOf}

    all c: Command |
        lone {i: Instance | i.instanceOf = c}
}