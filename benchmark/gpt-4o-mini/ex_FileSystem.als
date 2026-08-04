abstract sig Object {}

sig Directory extends Object {
    contents: set Object
}

one sig Root extends Object {}

sig File extends Object {}

fact {
    all o: Object | (o in Directory or o in File) and not (o in Directory and o in File)
    
    all d: Directory | d !in d.contents
    
    Root in Object
    
    all o: Object - Root | some d: Directory | o in d.contents
    
    all d: Directory | all o: d.contents | o in Object
}