#lang forge/temporal

open "setup.frg"



// currently, our well formed predicate does not constrict our cube to solvable states:
// We probably will have to add predicates dictating that the total twist of a well-formed cube is
// a multiple of 3.  This will also exponentially decrease the number of states we have to explore, 
// making traces of 14 (or defining all possible movements) more feasible.

//more of a general test, but want to determine whether every cube that starts with valid twist is solvable
// -> ie there is no cube with twist % mod3 = 0 that is not eventually solvable

//test whether there are any well formed cubes which are not solvable in 14 moves (or 11 if all rotations defined)

test suite for basicStates {
    test expect {
        initSolvedExists: {
            initSolved
        } is sat

        scrambledExists: {
            scrambled
        } is sat

        initSolvedIsSolved: {
            initSolved
            not solved
        } is unsat

        solvedNotScrambled: {
            solved
            scrambled
        } is unsat
    }
}



test suite for rotationExists {
    test expect {
        rightCanHappen: {
            initSolved
            rotationRight
        } is sat

        topCanHappen: {
            initSolved
            rotationTop
        } is sat

        bottomCanHappen: {
            initSolved
            rotationBottom
        } is sat
    }
}

