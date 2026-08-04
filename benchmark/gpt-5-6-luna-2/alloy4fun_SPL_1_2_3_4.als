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
    all l: Link |
        one (l.~public + l.~secret + l.~link)

    all s: StoredModel |
        some s.secret implies s in Secret

    all s: Secret |
        some s.secret implies some s.public

    all s: Secret |
        some s.public implies
            (some s.secret or
             some {m: StoredModel | m in s.^derivationOf and some m.secret})

    no iden & ^derivationOf

    all s: StoredModel |
        no s.public implies lone s.derivationOf

    all s: StoredModel |
        some {m: Secret | m in s.^derivationOf} implies s in Secret

    all s: Secret |
        (some s.public and no s.secret) implies
            no {m: StoredModel | s in m.*derivationOf and some m.secret}

    all c: Command |
        one c.~command

    all s: StoredModel |
        no s.public iff some s.command

    all i: Instance |
        i.model = {s: StoredModel | s.command = i.instanceOf}

    all c: Command |
        lone c.~instanceOf
}