sig Link {}

sig Command {}

sig StoredModel {
  derivationOf: lone StoredModel,
  publicLinks: set Link,
  secret: lone Secret,
  command: lone Command
}

sig Secret in StoredModel {
  secretLinks: some Link
}

sig Instance {
  instanceOf: one Command,
  models: set StoredModel,
  link: one Link
}

fun model[i: Instance]: one Command { i.instanceOf }

fact CommandOwnership {
  all c: Command | one m: StoredModel | m.command = c
}

fact LinksUsed {
  all l: Link |
    l in StoredModel.publicLinks + Secret.secretLinks + Instance.link
}

fact SecretContainment {
  all m: StoredModel |
    some m.secret implies some m.secret.secretLinks
}

fact PublicRequiresSecretAncestry {
  all m: StoredModel |
    some m.publicLinks implies some ((m + m.^derivationOf) & Secret)
}

fact NoDerivationLoops {
  no m: StoredModel | m in m.^derivationOf
}

fact NoPublicAtMostOneDerivation {
  all m: StoredModel |
    no m.publicLinks implies lone m.derivationOf
}

fact SecretAncestorsAreSecrets {
  all m: Secret |
    m.^derivationOf in Secret
}

fact PublicOnlySecretCannotDeriveToSecretLinked {
  all m: Secret |
    (some m.publicLinks and no m.secretLinks) implies
      all d: StoredModel | d.derivationOf = m implies no (d & Secret)
}

fact CommandByPublicness {
  all m: StoredModel |
    (no m.publicLinks implies one m.command) and
    (some m.publicLinks implies no m.command)
}

fact InstanceCommandUniqueness {
  all c: Command | lone i: Instance | i.instanceOf = c
}