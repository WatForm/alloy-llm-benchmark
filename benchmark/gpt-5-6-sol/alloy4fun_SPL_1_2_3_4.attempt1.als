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
    one (public.l + secret.l + link.l)

  all sm: StoredModel |
    some sm.secret implies sm in Secret

  all s: Secret |
    some s.secret implies some s.public

  all s: Secret |
    some s.public implies
      (some s.secret or some (s.^derivationOf).secret)

  no sm: StoredModel |
    sm in sm.^derivationOf

  all sm: StoredModel |
    no sm.public implies lone derivationOf.sm

  all sm: StoredModel |
    some (sm.^derivationOf & Secret) implies sm in Secret

  all s: Secret |
    (some s.public and no s.secret) implies
      (no sm: StoredModel |
        s in sm.*derivationOf and some sm.secret)

  all c: Command |
    one command.c

  all sm: StoredModel |
    no sm.public iff some sm.command

  all i: Instance |
    i.model = {
      sm: StoredModel |
        sm.command = i.instanceOf
    }

  all c: Command |
    lone instanceOf.c
}