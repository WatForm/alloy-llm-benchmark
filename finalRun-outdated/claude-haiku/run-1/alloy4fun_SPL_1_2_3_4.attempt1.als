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

sig Secret extends StoredModel {}

fact linksHaveOneOwner {
  all l: Link | 
    #{s: StoredModel | s.public = l or s.secret = l} + #{i: Instance | i.link = l} = 1
}

fact hasSecretImpliesSecret {
  all s: StoredModel | (some s.secret) implies s in Secret
}

fact secretWithSecretHasPublic {
  all s: Secret | (some s.secret) implies (some s.public)
}

fact secretWithPublicReachesSecret {
  all s: Secret | (some s.public) implies (some s.secret or some s2: StoredModel | s2 in s.^derivationOf and some s2.secret)
}

fact noCycles {
  all s: StoredModel | s not in s.^derivationOf
}

fact noPublicLimitsDerivedFrom {
  all s: StoredModel | (no s.public) implies #{s2: StoredModel | s2.derivationOf = s} <= 1
}

fact reachSecretImpliesSecret {
  all s: StoredModel | (some s2: Secret | s2 in s.^derivationOf) implies s in Secret
}

fact secretPublicNoSecretConstraint {
  all s: Secret | (some s.public and no s.secret) implies 
    (all s2: StoredModel | (s in s2.^derivationOf or s2 = s) implies no s2.secret)
}

fact commandUnique {
  all c: Command | one s: StoredModel | s.command = c
}

fact publicIffCommand {
  all s: StoredModel | (no s.public) iff (some s.command)
}

fact instanceModelSet {
  all i: Instance | i.model = {s: StoredModel | s.command = i.instanceOf}
}

fact commandAtMostOneInstance {
  all c: Command | #{i: Instance | i.instanceOf = c} <= 1
}