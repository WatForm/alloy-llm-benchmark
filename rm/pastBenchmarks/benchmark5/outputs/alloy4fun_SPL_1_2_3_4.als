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
        (one public.l and no secret.l and no link.l) or
        (no public.l and one secret.l and no link.l) or
        (no public.l and no secret.l and one link.l)

    all sm: StoredModel |
        some sm.secret => sm in Secret

    all s: Secret |
        some s.secret => some s.public

    all s: Secret |
        some s.public => some (s.*derivationOf).secret

    no sm: StoredModel |
        sm in sm.^derivationOf

    all sm: StoredModel |
        no sm.public => lone derivationOf.sm

    all sm: StoredModel |
        some (sm.^derivationOf & Secret) => sm in Secret

    all s: Secret |
        (some s.public and no s.secret) =>
            no sm: StoredModel | s in sm.*derivationOf and some sm.secret

    all c: Command |
        one command.c

    all sm: StoredModel |
        (no sm.public) <=> (some sm.command)

    all i: Instance |
        i.model = command.(i.instanceOf)

    all c: Command |
        lone instanceOf.c
}