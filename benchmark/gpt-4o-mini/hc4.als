sig Vertex {
    left: lone Vertex,
    right: lone Vertex
}

sig Joint extends Vertex {
}

sig End extends Vertex {
}

// Constraints for Joint
fact JointConstraints {
    all j: Joint | 
        j.left.left = j implies j.right.right = j and
        j.right.right = j implies j.left.left = j and
        j.left != j.right
}

// Constraints for End
fact EndConstraints {
    all e: End | 
        (e.left = none implies e = e.right.left) and
        (e.right = none implies e = e.left.right)
}

// Relations to ensure non-overlapping subsets
fact SubsetConstraints {
    all v: Vertex | v in Joint or v in End
    no Joint & End
}

// Reachability constraints
fact Reachability {
    all v: Vertex | 
        let reachableLeft = v.*left, 
            reachableRight = v.*right |
        reachableLeft + reachableRight = Vertex - v
}