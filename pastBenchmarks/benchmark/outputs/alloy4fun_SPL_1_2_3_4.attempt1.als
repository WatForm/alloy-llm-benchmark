module alloy4fun

sig Link {}

sig Command {}

sig StoredModel {
  derivation: lone StoredModel,
  public: lone Link,
  secret: lone Link,
  cmd: lone Command
}

sig Secret in StoredModel {}

sig Instance {
  command: one Command,
  models: set StoredModel,
  link: one Link
}

fact LinkBelongsToOneStoredModel {
  all l: Link | one m: StoredModel | l in m.public + m.secret
}

fact OnlySecretsHaveSecretLinks {
  all m: StoredModel - Secret | no m.secret
}

fact SecretLinkImpliesPublicLink {
  all m: Secret | some m.secret implies some m.public
}

fact PublicLinkOfSecretComesFromSecretLinkedModel {
  all m: Secret | some m.public implies some m.~derivation.secret
}

fact PublicAndSecretLinksDistinctPerModel {
  all m: StoredModel | no (m.public & m.secret)
}

fact DerivationsFormForest {
  no iden & ^derivation
}

fact ModelsWithoutPublicHaveAtMostOneChild {
  all m: StoredModel | no m.public implies lone m.~derivation
}

fact SecretTreePreserved {
  all m: Secret, d: m.derivation | d in Secret
}

fact PublicOnlySecretHasNoSecretLinkedChildren {
  all m: Secret | (some m.public and no m.secret) implies no (m.~derivation.secret)
}

fact CommandsOwnedByOneModel {
  all c: Command | one m: StoredModel | m.cmd = c
}

fact NoPublicImpliesCommand {
  all m: StoredModel | no m.public implies some m.cmd
}

fact AtMostOneInstancePerCommand {
  all c: Command | lone i: Instance | i.command = c
}

pred GoodSpec {
  no public & secret
}

pred BadSpec {
  some public & secret
}

check NoCommands {
  no Command
} for 20

check PublicAndSecretLinksDisjoint {
  no public & secret
} for 20

check OneDerivation {
  all m: StoredModel | no m.public implies lone m.~derivation
} for 30