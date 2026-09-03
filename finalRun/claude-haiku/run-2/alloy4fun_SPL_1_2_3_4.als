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

fact {
  // Every StoredModel that has a secret Link is a Secret
  all sm: StoredModel | sm.secret != none implies sm in Secret
  
  // Every Secret that has a secret Link must have a public Link
  all s: Secret | s.secret != none implies s.public != none
  
  // Every Secret that has a public Link must reach a secret Link or be reached by a secret Link
  all s: Secret | s.public != none implies (
    s.secret != none or 
    (some s2: StoredModel | s2 in s.^derivationOf and s2.secret != none) or
    (some s2: StoredModel | s in s2.^derivationOf and s2.secret != none)
  )
  
  // No StoredModel is reachable from itself by following derivationOf one or more times
  all sm: StoredModel | sm not in sm.^derivationOf
  
  // Every StoredModel that has no public Link is the derivationOf of at most one StoredModel
  all sm: StoredModel | sm.public = none implies #(derivationOf.sm) <= 1
  
  // Every StoredModel that can reach a Secret by following derivationOf is also a Secret
  all sm: StoredModel | (some s: Secret | s in sm.^derivationOf) implies sm in Secret
  
  // If a Secret has a public value and no secret value, no reachable StoredModel has a secret value
  all s: Secret | (s.public != none and s.secret = none) implies 
    (all sm: StoredModel | sm in s.*derivationOf implies sm.secret = none)
  
  // Every Command is the command of exactly one StoredModel
  all c: Command | one sm: StoredModel | c = sm.command
  
  // Every StoredModel has no public if and only if it has a command
  all sm: StoredModel | sm.public = none iff sm.command != none
  
  // For every Instance, its model set is exactly the StoredModels whose command is the instanceOf value
  all i: Instance | i.model = {sm: StoredModel | sm.command = i.instanceOf}
  
  // Every Command has at most one Instance that is the instanceOf of that Command
  all c: Command | #{i: Instance | c = i.instanceOf} <= 1
  
  // Every Link has exactly one owner
  all l: Link | 
    (#{sm: StoredModel | l in (sm.public + sm.secret)} +
     #{i: Instance | l = i.link}) = 1
}