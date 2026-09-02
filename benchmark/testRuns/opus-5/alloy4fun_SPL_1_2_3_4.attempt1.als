sig StoredModel {
	derivationOf : lone StoredModel,
	public : lone Link,
	secret : lone Link,
	command : lone Command
}

sig Link {}

sig Command {}

sig Instance {
	instanceOf : one Command,
	model : set StoredModel,
	link : one Link
}

sig Secret in StoredModel {}

fact oneOwnerPerLink {
	all l : Link | one (public.l + secret.l + link.l)
}

fact secretLinkImpliesSecret {
	all m : StoredModel | some m.secret implies m in Secret
}

fact secretLinkNeedsPublicLink {
	all s : Secret | some s.secret implies some s.public
}

fact publicSecretReachesSecretLink {
	all s : Secret | some s.public implies some (s.*derivationOf).secret
}

fact noDerivationCycle {
	all m : StoredModel | m not in m.^derivationOf
}

fact noPublicAtMostOneDerived {
	all m : StoredModel | no m.public implies lone derivationOf.m
}

fact reachesSecretIsSecret {
	all m : StoredModel | some (m.^derivationOf & Secret) implies m in Secret
}

fact publicOnlySecretNoSecretAncestors {
	all s : Secret | (some s.public and no s.secret) implies no (*derivationOf.s).secret
}

fact commandOfExactlyOneStoredModel {
	all c : Command | one command.c
}

fact noPublicIffCommand {
	all m : StoredModel | no m.public iff some m.command
}

fact instanceModels {
	all i : Instance | i.model = command.(i.instanceOf)
}

fact atMostOneInstancePerCommand {
	all c : Command | lone instanceOf.c
}