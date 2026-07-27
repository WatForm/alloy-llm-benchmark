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

  all s: StoredModel | some s.secret => s in Secret

  all s: Secret | some s.secret => some s.public

  all s: Secret | some s.public => some (s.*derivationOf).secret

  no s: StoredModel | s in s.^derivationOf

  all s: StoredModel | no s.public => lone derivationOf.s

  all s: StoredModel | some (s.^derivationOf & Secret) => s in Secret

  all s: Secret |
    (some s.public and no s.secret) =>
      no m: StoredModel | s in m.*derivationOf and some m.secret

  all c: Command | one command.c

  all s: StoredModel | no s.public <=> some s.command

  all i: Instance | i.model = command.(i.instanceOf)

  all c: Command | lone instanceOf.c
}