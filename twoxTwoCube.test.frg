#lang forge/temporal

open "setup.frg"





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

