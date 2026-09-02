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
  (all l: Link | one (public + secret + link).l) and
  (all s: StoredModel | some s.secret implies s in Secret) and
  (all s: Secret | some s.secret implies some s.public) and
  (all s: Secret | some s.public implies (some s.secret or some s.^derivationOf.secret)) and
  (no s: StoredModel | s in s.^derivationOf) and
  (all s: StoredModel | no s.public implies lone s.~derivationOf) and
  (all s: StoredModel | some (s.^derivationOf & Secret) implies s in Secret) and
  (all s: Secret |
    (some s.public and no s.secret) implies
      no x: StoredModel | s in x.*derivationOf and some x.secret) and
  (all c: Command | one c.~command) and
  (all s: StoredModel | no s.public iff some s.command) and
  (all i: Instance | i.model = i.instanceOf.~command) and
  (all c: Command | lone c.~instanceOf)
}