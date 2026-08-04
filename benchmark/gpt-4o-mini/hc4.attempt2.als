sig Vertex {
    left: lone Vertex,
    right: lone Vertex
}

sig Joint extends Vertex {
    // Constraints for Joint
    fact {
        // Following left and then right returns to the same element
        left.left = this implies right.right = this
        // Following right and then left returns to the same element
        right.right = this implies left.left = this
        // Left and right values are different
        left != right
    }
}

sig End extends Vertex {
    // Constraints for End
    fact {
        // If left is absent, End equals the left of right
        (left = none implies this = right.left) and
        // If right is absent, End equals the right of left
        (right = none implies this = left.right)
    }
}

// Relations to ensure non-overlapping subsets
fact {
    // Every Vertex is either a Joint or an End
    all v: Vertex | v in Joint or v in End
    // Joint and End are disjoint
    no Joint & End
}

// Reachability constraints
fact {
    all v: Vertex | 
        let reachableLeft = v.*left |
        let reachableRight = v.*right |
        reachableLeft + reachableRight = Vertex - v
}