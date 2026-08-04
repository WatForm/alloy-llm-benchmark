abstract sig Element {}

sig StoredModel extends Element {
    derivationOf: lone StoredModel,
    public: lone Link,
    secret: lone Link,
    command: one Command
}

sig Secret extends StoredModel {}

sig Link {
    owner: one Element
}

sig Command {
    instances: lone Instance
}

sig Instance {
    instanceOf: one Command,
    model: set StoredModel,
    link: one Link
}

fact {
    // Every Link has exactly one owner
    all l: Link | lone l.owner

    // Every StoredModel that has a secret Link is a Secret
    all sm: StoredModel | sm.secret != none implies sm in Secret

    // Every Secret that has a secret Link must have a public Link
    all s: Secret | s.secret != none implies s.public != none

    // Every Secret that has a public Link must reach a secret Link or must reach a secret Link via one or more derivationOf steps
    all s: Secret | s.public != none implies (s.secret != none or some sm: StoredModel | sm in s.derivationOf*)

    // No StoredModel is reachable from itself by following derivationOf one or more times
    no sm: StoredModel | sm in sm.derivationOf*

    // Every StoredModel that has no public Link is the derivationOf at most one StoredModel
    all sm: StoredModel | sm.public = none implies lone sm.derivationOf

    // Every StoredModel that can reach a Secret by following one or more derivationOf steps is also a Secret
    all sm: StoredModel | some s: Secret | s in sm.derivationOf* implies sm in Secret

    // If a Secret has a public value and no secret value, then there is no StoredModel that can reach it 
    // by following derivationOf zero or more times that has a secret value
    all s: Secret | s.public != none and s.secret = none implies no sm: StoredModel | s in sm.derivationOf*

    // Every Command is the command of exactly one StoredModel
    all c: Command | one sm: StoredModel | sm.command = c

    // Every StoredModel has no public value if and only if it has some command
    all sm: StoredModel | sm.public = none <=> sm.command != none

    // For every Instance, its model set is exactly the set of StoredModels whose command value is the instanceOf value of the Instance
    all i: Instance | i.model = {sm: StoredModel | sm.command = i.instanceOf}

    // Every Command has at most one Instance that is the instanceOf of that Command
    all c: Command | lone i: Instance | i.instanceOf = c
}