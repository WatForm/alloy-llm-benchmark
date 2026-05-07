open util/relation

sig N { suivant: set N }

fact
{
  -- only acyclic relation
  acyclic[suivant, N]
  -- constraint to check against examples and counter examples
  no suivant.^suivant & suivant
}
