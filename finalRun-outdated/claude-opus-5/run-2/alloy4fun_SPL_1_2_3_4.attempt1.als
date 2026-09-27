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

fact OneOwnerPerLink {
	all l: Link | one (public + secret + link).l
}

fact SecretLinkImpliesSecret {
	all m: StoredModel | some m.secret implies m in Secret
}

fact SecretWithSecretLinkHasPublicLink {
	all s: Secret | some s.secret implies some s.public
}

fact SecretWithPublicLinkReachesSecretLink {
	all s: Secret | some s.public implies some (s.*derivationOf).secret
}

fact NoDerivationCycles {
	no m: StoredModel | m in m.^derivationOf
}

fact NoPublicLimitsDerivations {
	all m: StoredModel | no m.public implies lone derivationOf.m
}

fact ReachesSecretIsSecret {
	all m: StoredModel | some (m.^derivationOf & Secret) implies m in Secret
}

fact PublicOnlySecretNotReachableFromSecretLink {
	all s: Secret | (some s.public and no s.secret) implies
		(no m: derivationOf.s | some m.secret) and no s.secret
}

fact CommandOfExactlyOneStoredModel {
	all c: Command | one command.c
}

fact NoPublicIffSomeCommand {
	all m: StoredModel | no m.public iff some m.command
}

fact InstanceModel {
	all i: Instance | i.model = command.(i.instanceOf)
}

fact AtMostOneInstancePerCommand {
	all c: Command | lone instanceOf.c
}