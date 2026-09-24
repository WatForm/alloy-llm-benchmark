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
    all l: Link | one public.l + secret.l + link.l
}

fact {
    all m: StoredModel | some m.secret implies m in Secret
}

fact {
    all s: Secret | some s.secret implies some s.public
}

fact {
    all s: Secret | some s.public implies (some s.secret or some (s.^derivationOf).secret)
}

fact {
    no m: StoredModel | m in m.^derivationOf
}

fact {
    all m: StoredModel | no m.public implies lone derivationOf.m
}

fact {
    all m: StoredModel | some (m.^derivationOf & Secret) implies m in Secret
}

fact {
    all s: Secret | (some s.public and no s.secret) implies (no m: StoredModel | s in m.*derivationOf and some m.secret)
}

fact {
    all c: Command | one m: StoredModel | m.command = c
}

fact {
    all m: StoredModel | no m.public iff some m.command
}

fact {
    all i: Instance | i.model = { m: StoredModel | m.command = i.instanceOf }
}

fact {
    all c: Command | lone i: Instance | i.instanceOf = c
}