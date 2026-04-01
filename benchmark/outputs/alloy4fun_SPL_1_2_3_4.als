sig Link {}

sig Command {}

sig StoredModel {
  derivationOf: lone StoredModel,
  public: lone Link,
  secret: lone Link,
  command: lone Command
}

sig Secret extends StoredModel {}

sig Instance {
  instanceOf: one (Command + StoredModel),
  model: set StoredModel,
  link: one Link
}

fact LinkAssociatedExactlyOnce {
  all l: Link |
    one sm: StoredModel |
      l = sm.public or l = sm.secret
    or
    one i: Instance | l = i.link
}

fact SecretMayHaveSecretLink {
  all s: Secret | s.secret in Link + none
}

fact SecretLinkImpliesPublicLink {
  all s: Secret | some s.secret implies some s.public
}

fact SecretPublicImpliesDerivedFromSecretLinkModel {
  all s: Secret |
    some s.public implies
      some s.derivationOf and some s.derivationOf.secret
}

fact PublicAndSecretDifferentPerModel {
  all sm: StoredModel | sm.public != sm.secret
}

fact NoDerivationCycles {
  no sm: StoredModel | sm in sm.^derivationOf
}

fact NoPublicAtMostOneChild {
  all sm: StoredModel |
    no sm.public implies lone derivationOf.sm
}

fact SecretDerivationClosed {
  all s: Secret |
    some s.derivationOf implies s.derivationOf in Secret
}

fact SecretPublicNoSecretNoSecretInAncestors {
  all s: Secret |
    some s.public and no s.secret implies
      no ((s.^derivationOf) & { x: StoredModel | some x.secret })
}

fact EachCommandAssociatedWithOneStoredModel {
  all c: Command | one sm: StoredModel | sm.command = c
}

fact PublicCommandConstraint {
  all sm: StoredModel |
    (no sm.public implies some sm.command) and
    (some sm.public implies no sm.command)
}

fact EachCommandAtMostOneInstance {
  all c: Command | lone i: Instance | i.instanceOf = c
}

pred GoodSpec {
  no (StoredModel.public & StoredModel.secret)
}

pred BadSpec {
  all sm: StoredModel | sm.public != sm.secret
}

assert NoCommands {
  BadSpec implies no Command
}

assert PublicAndSecretLinksDisjoint {
  GoodSpec implies no (StoredModel.public & StoredModel.secret)
}

assert OneDerivation {
  all sm: StoredModel |
    no sm.public implies lone derivationOf.sm
}

check NoCommands
check PublicAndSecretLinksDisjoint
check OneDerivation