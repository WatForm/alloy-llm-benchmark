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

fact OwnerUnique {
  all l: Link | one (public.l + secret.l + link.l)
}

fact SecretIfSecretLink {
  all sm: StoredModel | some sm.secret => sm in Secret
}

fact SecretRequiresPublic {
  all s: Secret | some s.secret => some s.public
}

fact SecretReachesSecret {
  all s: Secret | some s.public => (some s.secret or some s.^derivationOf.secret)
}

fact NoSelfDerivation {
  no sm: StoredModel | sm in sm.^derivationOf
}

fact AtMostOneDerivationWhenNoPublic {
  all sm: StoredModel | no sm.public => lone derivationOf.sm
}

fact ReachSecretImpliesSecret {
  all sm: StoredModel | some (sm.^derivationOf & Secret) => sm in Secret
}

fact SecretPublicNoSecretCondition {
  all s: Secret | (some s.public and no s.secret) => (no sm: StoredModel | s in sm.*derivationOf and some sm.secret)
}

fact CommandOfExactlyOne {
  all c: Command | one command.c
}

fact PublicIffNoCommand {
  all sm: StoredModel | (no sm.public) <=> (some sm.command)
}

fact InstanceModelDefinition {
  all i: Instance | i.model = { sm: StoredModel | sm.command = i.instanceOf }
}

fact CommandAtMostOneInstance {
  all c: Command | lone instanceOf.c
}