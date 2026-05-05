#lang forge/temporal

option max_tracelength 11
option min_tracelength 11

option run_sterling "vis_ver2.js"

abstract sig Slot {}
one sig UFR, UFL, UBR, UBL, DFR, DFL, DBR, DBL extends Slot {}

abstract sig Block {}
one sig bUFR, bUFL, bUBR, bUBL, bDFR, bDFL, bDBR, bDBL extends Block {}

abstract sig Twist {}
one sig tOne, tTwo, tThree extends Twist {}

abstract sig TwistUpdate {}
one sig TUOne, TUTwo extends TwistUpdate {}

one sig Cube {
    var occupy: pfunc Slot -> Block,
    var tw: pfunc Slot -> Twist
}

pred wellFormed {
    all s: Slot | one b: Block | Cube.occupy[s] = b
    all b: Block | one s: Slot | Cube.occupy[s] = b

    all s: Slot | one t: Twist | Cube.tw[s] = t
}

pred solved {
    Cube.occupy[UFR] = bUFR
    Cube.occupy[UFL] = bUFL
    Cube.occupy[UBR] = bUBR
    Cube.occupy[UBL] = bUBL
    Cube.occupy[DFR] = bDFR
    Cube.occupy[DFL] = bDFL
    Cube.occupy[DBR] = bDBR
    Cube.occupy[DBL] = bDBL

    all s: Slot | Cube.tw[s] = tOne
}

pred occupyUnchanged[changed: set Slot] {
    all s: Slot | (not (s in changed)) implies (Cube.occupy'[s] = Cube.occupy[s])
}

pred twistUnchanged[changed: set Slot] {
    all s: Slot | (not (s in changed)) implies (Cube.tw'[s] = Cube.tw[s])
}

fun twistUpdate[t: Twist, tu: TwistUpdate]: one Twist {
    (t = tOne and tu = TUOne) => tTwo else
    (t = tOne and tu = TUTwo) => tThree else
    (t = tTwo and tu = TUOne) => tThree else
    (t = tTwo and tu = TUTwo) => tOne else
    (t = tThree and tu = TUOne) => tOne else
    tTwo
}

pred rotateU {
    Cube.occupy'[UFR] = Cube.occupy[UFL]
    Cube.occupy'[UFL] = Cube.occupy[UBL]
    Cube.occupy'[UBL] = Cube.occupy[UBR]
    Cube.occupy'[UBR] = Cube.occupy[UFR]

    Cube.tw'[UFR] = Cube.tw[UFL]
    Cube.tw'[UFL] = Cube.tw[UBL]
    Cube.tw'[UBL] = Cube.tw[UBR]
    Cube.tw'[UBR] = Cube.tw[UFR]

    occupyUnchanged[UFR + UFL + UBL + UBR]
    twistUnchanged[UFR + UFL + UBL + UBR]
}

pred rotateD {
    Cube.occupy'[DFR] = Cube.occupy[DFL]
    Cube.occupy'[DFL] = Cube.occupy[DBL]
    Cube.occupy'[DBL] = Cube.occupy[DBR]
    Cube.occupy'[DBR] = Cube.occupy[DFR]

    Cube.tw'[DFR] = Cube.tw[DFL]
    Cube.tw'[DFL] = Cube.tw[DBL]
    Cube.tw'[DBL] = Cube.tw[DBR]
    Cube.tw'[DBR] = Cube.tw[DFR]

    occupyUnchanged[DFR + DFL + DBL + DBR]
    twistUnchanged[DFR + DFL + DBL + DBR]
}

pred rotateR {
    Cube.occupy'[UFR] = Cube.occupy[DFR]
    Cube.occupy'[DFR] = Cube.occupy[DBR]
    Cube.occupy'[DBR] = Cube.occupy[UBR]
    Cube.occupy'[UBR] = Cube.occupy[UFR]

    Cube.tw'[UFR] = twistUpdate[Cube.tw[DFR], TUTwo]
    Cube.tw'[DFR] = twistUpdate[Cube.tw[DBR], TUOne]
    Cube.tw'[DBR] = twistUpdate[Cube.tw[UBR], TUTwo]
    Cube.tw'[UBR] = twistUpdate[Cube.tw[UFR], TUOne]

    occupyUnchanged[UFR + DFR + DBR + UBR]
    twistUnchanged[UFR + DFR + DBR + UBR]
}

pred rotateL {
    Cube.occupy'[UFL] = Cube.occupy[UBL]
    Cube.occupy'[DFL] = Cube.occupy[UFL]
    Cube.occupy'[DBL] = Cube.occupy[DFL]
    Cube.occupy'[UBL] = Cube.occupy[DBL]

    Cube.tw'[UFL] = twistUpdate[Cube.tw[UBL], TUOne]
    Cube.tw'[DFL] = twistUpdate[Cube.tw[UFL], TUTwo]
    Cube.tw'[DBL] = twistUpdate[Cube.tw[DFL], TUOne]
    Cube.tw'[UBL] = twistUpdate[Cube.tw[DBL], TUTwo]

    occupyUnchanged[UFL + DFL + DBL + UBL]
    twistUnchanged[UFL + DFL + DBL + UBL]
}

pred rotateF {
    Cube.occupy'[UFR] = Cube.occupy[UFL]
    Cube.occupy'[DFR] = Cube.occupy[UFR]
    Cube.occupy'[DFL] = Cube.occupy[DFR]
    Cube.occupy'[UFL] = Cube.occupy[DFL]

    Cube.tw'[UFR] = twistUpdate[Cube.tw[UFL], TUOne]
    Cube.tw'[DFR] = twistUpdate[Cube.tw[UFR], TUTwo]
    Cube.tw'[DFL] = twistUpdate[Cube.tw[DFR], TUOne]
    Cube.tw'[UFL] = twistUpdate[Cube.tw[DFL], TUTwo]

    occupyUnchanged[UFR + DFR + DFL + UFL]
    twistUnchanged[UFR + DFR + DFL + UFL]
}

pred rotateB {
    Cube.occupy'[UBR] = Cube.occupy[DBR]
    Cube.occupy'[UBL] = Cube.occupy[UBR]
    Cube.occupy'[DBL] = Cube.occupy[UBL]
    Cube.occupy'[DBR] = Cube.occupy[DBL]

    Cube.tw'[UBR] = twistUpdate[Cube.tw[DBR], TUTwo]
    Cube.tw'[UBL] = twistUpdate[Cube.tw[UBR], TUOne]
    Cube.tw'[DBL] = twistUpdate[Cube.tw[UBL], TUTwo]
    Cube.tw'[DBR] = twistUpdate[Cube.tw[DBL], TUOne]

    occupyUnchanged[UBR + UBL + DBL + DBR]
    twistUnchanged[UBR + UBL + DBL + DBR]
}

pred oneStep {
    wellFormed
    (rotateU or rotateD or rotateR or rotateL or rotateF or rotateB)
    next_state wellFormed
}

pred oneAwayFromSolved{
    wellFormed
    (rotateU or rotateD or rotateR or rotateL or rotateF or rotateB)
    next_state (solved and wellFormed)
}

pred move{
    (rotateU or rotateD or rotateR or rotateL or rotateF or rotateB)
}

pred fourToSolved {
    wellFormed and not solved
    move
    next_state {
        wellFormed and not solved
        move
        next_state {
            wellFormed and not solved
            move
            next_state {
                wellFormed and not solved
                move
                next_state{solved and wellFormed}
}}}}

pred unsolvedSteps{
    wellFormed and not solved
    move
}

pred notSolvable{
    always unsolvedSteps
}

pred elevenLongSolvedOnlyAtEnd {
    unsolvedSteps
    next_state {
        unsolvedSteps
        next_state {
            unsolvedSteps
            next_state {
                unsolvedSteps
                next_state {
                    unsolvedSteps
                    next_state {
                        unsolvedSteps
                        next_state {
                            unsolvedSteps
                            next_state {
                                unsolvedSteps
                                next_state {
                                    unsolvedSteps
                                    next_state {
                                        unsolvedSteps
                                        next_state {
                                            wellFormed and solved
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


run {elevenLongSolvedOnlyAtEnd}
