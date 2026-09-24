sig StoredModel {
	derivationOf: lone StoredModel,
	public: lone Link,
	secret: lone Link,
	command: lone Command
}

sig Secret in StoredModel {}

sig Link {}

sig Command {}

sig Instance {
	instanceOf: one Command,
	model: set StoredModel,
	link: one Link
}

fact {
	all l: Link | one (public.l + secret.l + link.l)

	all s: StoredModel | some s.secret implies s in Secret

	all s: Secret | some s.secret implies some s.public

	all s: Secret | some s.public implies (some s.secret or some s.^derivationOf.secret)

	all s: StoredModel | s not in s.^derivationOf

	all s: StoredModel | no s.public implies lone derivationOf.s

	all s: StoredModel | some (s.^derivationOf & Secret) implies s in Secret

	all s: Secret | (some s.public and no s.secret) implies (no m: StoredModel | s in m.*derivationOf and some m.secret)

	all c: Command | one command.c

	all s: StoredModel | no s.public <=> some s.command

	all i: Instance | i.model = { s: StoredModel | s.command = i.instanceOf }

	all c: Command | lone instanceOf.c
}