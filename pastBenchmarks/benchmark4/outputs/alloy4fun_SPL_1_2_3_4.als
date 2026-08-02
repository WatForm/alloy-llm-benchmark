sig Link {}

sig Command {}

sig StoredModel {
  derivationOf: lone StoredModel,
  public: lone Link,
  secret: lone Link,
  command: lone Command
}

sig Secret in StoredModel {}

sig Instance {
  instanceOf: one Command,
  model: set StoredModel,
  link: one Link
}

fact {
  Link = StoredModel.public + StoredModel.secret + Instance.link
  no (StoredModel.public & StoredModel.secret)
  no (StoredModel.public & Instance.link)
  no (StoredModel.secret & Instance.link)

  all m: StoredModel | some m.secret => m in Secret

  all s: Secret | some s.secret => some s.public

  all s: Secret | some s.public => (some s.secret or some (s.^derivationOf).secret)

  no m: StoredModel | m in m.^derivationOf

  all m: StoredModel | no m.public => lone derivationOf.m

  all s: Secret | s.^derivationOf in Secret

  all s: Secret |
    (some s.public and no s.secret) =>
      no { m: StoredModel | s in m.*derivationOf and some m.secret }

  all c: Command | one command.c

  all m: StoredModel | (no m.public) <=> (some m.command)

  all i: Instance | i.model = { m: StoredModel | m.command = i.instanceOf }

  all c: Command | lone instanceOf.c
}