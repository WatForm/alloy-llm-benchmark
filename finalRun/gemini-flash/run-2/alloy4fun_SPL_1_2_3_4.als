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

fact {
	all l: Link | one (public.l + secret.l + link.l)
	all m: StoredModel | some m.secret implies m in Secret
	all s: Secret | some s.secret implies some s.public
	all s: Secret | some s.public implies (some s.secret or some s.^derivationOf.secret)
	all m: StoredModel | m not in m.^derivationOf
	all m: StoredModel | no m.public implies lone derivationOf.m
	all m: StoredModel | some (m.^derivationOf & Secret) implies m in Secret
	all s: Secret | (some s.public and no s.secret) implies (no m: StoredModel | s in m.*derivationOf and some m.secret)
	all c: Command | one command.c
	all m: StoredModel | no m.public <=> some m.command
	all i: Instance | i.model = { m: StoredModel | m.command = i.instanceOf }
	all c: Command | lone instanceOf.c
}