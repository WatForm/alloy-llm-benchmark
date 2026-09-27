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

fact Disjoint {
  no StoredModel & Link
  no StoredModel & Command
  no StoredModel & Instance
  no Link & Command
  no Link & Instance
  no Command & Instance
}

fact LinkOwner {
  all l: Link | one s: (StoredModel + Instance) |
    (s in StoredModel and (s.public = l or s.secret = l)) or
    (s in Instance and s.link = l)
}

fact SecretLinkImpliesSecret {
  all sm: StoredModel | (some sm.secret) implies sm in Secret
}

fact SecretSecretImpliesPublic {
  all s: Secret | (some s.secret) implies (some s.public)
}

fact SecretPublicReachesSecret {
  all s: Secret | (some s.public) implies
    (some s.secret or (some sm: s.^derivationOf | some sm.secret))
}

fact NoSelfDerivation {
  all sm: StoredModel | sm not in sm.^derivationOf
}

fact NoPublicAtMostOneDerivation {
  all sm: StoredModel | (no sm.public) implies lone (derivationOf.sm)
}

fact ReachesSecretIsSecret {
  all sm: StoredModel | (some (sm.^derivationOf & Secret)) implies sm in Secret
}

fact PublicNoSecretNoSecretAncestor {
  all s: Secret | (some s.public and no s.secret) implies
    (no sm: StoredModel | (s in sm.*derivationOf) and (some sm.secret))
}

fact CommandOfExactlyOne {
  all c: Command | one command.c
}

fact NoPublicIffHasCommand {
  all sm: StoredModel | (no sm.public) iff (some sm.command)
}

fact InstanceModelDefinition {
  all i: Instance | i.model = { sm: StoredModel | sm.command = i.instanceOf }
}

fact CommandAtMostOneInstance {
  all c: Command | lone instanceOf.c
}