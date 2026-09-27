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
}

fact {
  all m: StoredModel |
    some m.secret implies m in Secret
}

fact {
  all m: Secret |
    some m.secret implies some m.public
}

fact {
  all m: Secret |
    some m.public implies (some m.secret or some (m.^derivationOf).secret)
}

fact {
  no m: StoredModel |
    m in m.^derivationOf
}

fact {
  all m: StoredModel |
    no m.public implies lone derivationOf.m
}

fact {
  all m: StoredModel |
    some (m.^derivationOf & Secret) implies m in Secret
}

fact {
  all m: Secret |
    (some m.public and no m.secret) implies
      no n: StoredModel |
        m in n.*derivationOf and some n.secret
}

fact {
  all c: Command |
    one command.c
}

fact {
  all m: StoredModel |
    (no m.public) iff (some m.command)
}

fact {
  all i: Instance |
    i.model = command.(i.instanceOf)
}

fact {
  all c: Command |
    lone instanceOf.c
}