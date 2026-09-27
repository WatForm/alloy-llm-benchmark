sig N {
  suivant: set N
} {
  no iden & ^(this.suivant)
  no ((this.suivant).(this.suivant) & this.suivant)
}