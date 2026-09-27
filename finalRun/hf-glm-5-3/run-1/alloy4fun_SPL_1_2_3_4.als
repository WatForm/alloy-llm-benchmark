sig StoredModel {
  derivationOf : lone StoredModel,
  public : lone Link,
  secret : lone Link,
  command : lone Command
}

sig Secret extends StoredModel {}

sig Link {}

sig Command {}

sig Instance {
  instanceOf : one Command,
  model : set StoredModel,
  link : one Link
}

fact {
  // Every Link has exactly one owner
  all l : Link | one (public.l + secret.l + link.l)

  // Every StoredModel that has a secret Link is a Secret
  all m : StoredModel | some m.secret implies m in Secret

  // Every Secret that has a secret Link must have a public Link
  all s : Secret | some s.secret implies some s.public

  // Every Secret that has a public Link must reach a secret Link,
  // or reach one via one or more derivationOf steps
  all s : Secret | some s.public implies
    (some s.secret or some m : s.^derivationOf | some m.secret)

  // No StoredModel is reachable from itself by following derivationOf one or more times
  all m : StoredModel | m not in m.^derivationOf

  // Every StoredModel with no public Link is the derivationOf of at most one StoredModel
  all m : StoredModel | no m.public implies lone derivationOf.m

  // Every StoredModel that can reach a Secret via derivationOf is also a Secret
  all m : StoredModel | some m.^derivationOf & Secret implies m in Secret

  // If a Secret has a public value and no secret value, no StoredModel
  // that can reach it via derivationOf (zero or more times) has a secret value
  all s : Secret | (some s.public and no s.secret) implies
    (no m : StoredModel | some m.secret and s in m.*derivationOf)

  // Every Command is the command of exactly one StoredModel
  all c : Command | one c.~command

  // Every StoredModel has no public value if and only if it has some command
  all m : StoredModel | (no m.public) iff (some m.command)

  // Each Instance's model set is exactly the set of StoredModels
  // whose command value is the instanceOf value of the Instance
  all i : Instance | i.model = i.instanceOf.~command

  // Every Command has at most one Instance that is the instanceOf of that Command
  all c : Command | lone c.~instanceOf
}