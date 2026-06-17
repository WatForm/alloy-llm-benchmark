module alloy4fun

sig StoredModel {
	derivationOf : lone StoredModel,
	public : lone Link,
	secret : lone Link,
	command : lone Command
}

sig Secret in StoredModel {}

sig Link {}

sig Command {}

sig Instance {
	instanceOf : one Command,
	model : set StoredModel,
	link : one Link
}

fact Links {
	all l : Link | one (public+secret+link).l
	secret.Link in Secret
	all m : Secret | some m.secret implies some m.public
	all m : Secret | some m.public implies some m.(^derivationOf+iden).secret
}

fact Derivations {
	no m : StoredModel | m in m.^derivationOf
	all m : StoredModel | no m.public implies lone derivationOf.m
	all m : Secret | ^derivationOf.m in Secret
	all m : Secret | (some m.public and no m.secret) implies no (*derivationOf.m).secret
}

fact Commands {
	all c : Command | one command.c
	all m : StoredModel | no m.public iff some m.command
}

fact Instances {
	model = instanceOf.~command
	all c : Command | lone instanceOf.c
}
