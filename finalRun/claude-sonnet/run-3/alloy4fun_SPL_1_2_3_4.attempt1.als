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

fact OwnerFact {
  all l: Link | one (public.l + secret.l + link.l)
}

fact SecretHasSecretLink {
  all s: StoredModel | some s.secret => s in Secret
}

fact SecretWithSecretMustHavePublic {
  all s: Secret | some s.secret => some s.public
}

fact SecretWithPublicMustReachSecret {
  all s: Secret | some s.public => some (s.*derivationOf).secret
}

fact NoSelfDerivation {
  no s: StoredModel | s in s.^derivationOf
}

fact NoPublicAtMostOneDerivation {
  all s: StoredModel | no s.public => lone derivationOf.s
}

fact DerivationReachesSecretImpliesSecret {
  all s: StoredModel | some (s.^derivationOf & Secret) => s in Secret
}

fact SecretPublicNoSecretCondition {
  all s: Secret | (some s.public and no s.secret) =>
    (no t: StoredModel | (s in t.*derivationOf) and some t.secret)
}

fact EveryCommandExactlyOneStoredModel {
  all c: Command | one command.c
}

fact NoPublicIffSomeCommand {
  all s: StoredModel | (no s.public) <=> (some s.command)
}

fact InstanceModelDefinition {
  all i: Instance | i.model = { s: StoredModel | s.command = i.instanceOf }
}

fact CommandAtMostOneInstance {
  all c: Command | lone instanceOf.c
}