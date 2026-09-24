abstract sig Element {}

sig StoredModel extends Element {
    derivationOf: lone StoredModel,
    public: lone Link,
    secret: lone Link,
    command: lone Command
}

sig Link extends Element {}

sig Command extends Element {}

sig Instance extends Element {
    instanceOf: one Command,
    model: set StoredModel,
    link: one Link
}

sig Secret in StoredModel {}

// Every Link has exactly one owner
fact {
    all l: Link | 
        (#{sm: StoredModel | sm.public = l or sm.secret = l} + #{i: Instance | i.link = l}) = 1
}

// Every StoredModel that has a secret Link is a Secret
fact {
    all sm: StoredModel | some sm.secret implies sm in Secret
}

// Every Secret that has a secret Link must have a public Link
fact {
    all s: Secret | some s.secret implies some s.public
}

// Every Secret that has a public Link must reach a secret Link or be reached by one via derivationOf steps
fact {
    all s: Secret | some s.public implies (
        some s.secret or (some s2: Secret | some s2.secret and s2 in s.^derivationOf)
    )
}

// No StoredModel is reachable from itself by following derivationOf one or more times
fact {
    all sm: StoredModel | sm not in sm.^derivationOf
}

// Every StoredModel that has no public Link is the derivationOf at most one StoredModel
fact {
    all sm: StoredModel | no sm.public implies #{sm2: StoredModel | sm in sm2.derivationOf} <= 1
}

// Every StoredModel that can reach a Secret by following one or more derivationOf steps is also a Secret
fact {
    all sm: StoredModel | (some s: Secret | s in sm.^derivationOf) implies sm in Secret
}

// If a Secret has a public value and no secret value, then there is no StoredModel that can reach it via derivationOf* that has a secret value
fact {
    all s: Secret | (some s.public and no s.secret) implies 
        (all sm: StoredModel | s in sm.*derivationOf implies no sm.secret)
}

// Every Command is the command of exactly one StoredModel
fact {
    all c: Command | #{sm: StoredModel | sm.command = c} = 1
}

// Every StoredModel has no public value if and only if it has some command
fact {
    all sm: StoredModel | (no sm.public) iff (some sm.command)
}

// For every Instance, its model set is exactly the set of StoredModels whose command is the instanceOf
fact {
    all i: Instance | i.model = {sm: StoredModel | sm.command = i.instanceOf}
}

// Every Command has at most one Instance with that instanceOf
fact {
    all c: Command | #{i: Instance | i.instanceOf = c} <= 1
}