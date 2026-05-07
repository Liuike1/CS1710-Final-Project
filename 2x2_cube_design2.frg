#lang forge/temporal

option max_tracelength 11
option min_tracelength 11

option run_sterling "design2_vis.js"

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

pred totalTwistValid {
    //adding a total twist conservation predicate for wellfFormed
    //tOne implies 0 twist, so we do not add it to our sum 
    // --> consider the solved state is all tOne, then if it was +1 the state mod3 would not be valid.
    remainder[add[#{s: Slot | Cube.tw[s] = tTwo}, multiply[2,#{s: Slot | Cube.tw[s] = tThree}]],3] = 0
}

pred wellFormed {
    // bijective correspondance between slot and block
    all s: Slot | one b: Block | Cube.occupy[s] = b
    all b: Block | one s: Slot | Cube.occupy[s] = b

    // each slot must have one (non-unique) twist
    all s: Slot | one t: Twist | Cube.tw[s] = t
    totalTwistValid
}

pred solved {
    // default state via construction
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
    // helper function simulating integer addition mod 3
    (t = tOne and tu = TUOne) => tTwo else
    (t = tOne and tu = TUTwo) => tThree else
    (t = tTwo and tu = TUOne) => tThree else
    (t = tTwo and tu = TUTwo) => tOne else
    (t = tThree and tu = TUOne) => tOne else
    tTwo
}

// rotation preds start
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

pred rotateU2 {
    Cube.occupy'[UFR] = Cube.occupy[UBL]
    Cube.occupy'[UFL] = Cube.occupy[UBR]
    Cube.occupy'[UBL] = Cube.occupy[UFR]
    Cube.occupy'[UBR] = Cube.occupy[UFL]
    Cube.tw'[UFR] = Cube.tw[UBL]
    Cube.tw'[UFL] = Cube.tw[UBR]
    Cube.tw'[UBL] = Cube.tw[UFR]
    Cube.tw'[UBR] = Cube.tw[UFL]
    occupyUnchanged[UFR + UFL + UBL + UBR]
    twistUnchanged[UFR + UFL + UBL + UBR]
}
pred rotateU3 {
    Cube.occupy'[UFR] = Cube.occupy[UBR]
    Cube.occupy'[UFL] = Cube.occupy[UFR]
    Cube.occupy'[UBL] = Cube.occupy[UFL]
    Cube.occupy'[UBR] = Cube.occupy[UBL]
    Cube.tw'[UFR] = Cube.tw[UBR]
    Cube.tw'[UFL] = Cube.tw[UFR]
    Cube.tw'[UBL] = Cube.tw[UFL]
    Cube.tw'[UBR] = Cube.tw[UBL]
    occupyUnchanged[UFR + UFL + UBL + UBR]
    twistUnchanged[UFR + UFL + UBL + UBR]
}
pred rotateD2 {
    Cube.occupy'[DFR] = Cube.occupy[DBL]
    Cube.occupy'[DFL] = Cube.occupy[DBR]
    Cube.occupy'[DBL] = Cube.occupy[DFR]
    Cube.occupy'[DBR] = Cube.occupy[DFL]
    Cube.tw'[DFR] = Cube.tw[DBL]
    Cube.tw'[DFL] = Cube.tw[DBR]
    Cube.tw'[DBL] = Cube.tw[DFR]
    Cube.tw'[DBR] = Cube.tw[DFL]
    occupyUnchanged[DFR + DFL + DBL + DBR]
    twistUnchanged[DFR + DFL + DBL + DBR]
}
pred rotateD3 {
    Cube.occupy'[DFR] = Cube.occupy[DBR]
    Cube.occupy'[DFL] = Cube.occupy[DFR]
    Cube.occupy'[DBL] = Cube.occupy[DFL]
    Cube.occupy'[DBR] = Cube.occupy[DBL]
    Cube.tw'[DFR] = Cube.tw[DBR]
    Cube.tw'[DFL] = Cube.tw[DFR]
    Cube.tw'[DBL] = Cube.tw[DFL]
    Cube.tw'[DBR] = Cube.tw[DBL]
    occupyUnchanged[DFR + DFL + DBL + DBR]
    twistUnchanged[DFR + DFL + DBL + DBR]
}
pred rotateR2 {
    Cube.occupy'[UFR] = Cube.occupy[DBR]
    Cube.occupy'[DFR] = Cube.occupy[UBR]
    Cube.occupy'[DBR] = Cube.occupy[UFR]
    Cube.occupy'[UBR] = Cube.occupy[DFR]
    Cube.tw'[UFR] = Cube.tw[DBR]
    Cube.tw'[DFR] = Cube.tw[UBR]
    Cube.tw'[DBR] = Cube.tw[UFR]
    Cube.tw'[UBR] = Cube.tw[DFR]
    occupyUnchanged[UFR + DFR + DBR + UBR]
    twistUnchanged[UFR + DFR + DBR + UBR]
}
pred rotateR3 {
    Cube.occupy'[UFR] = Cube.occupy[UBR]
    Cube.occupy'[DFR] = Cube.occupy[UFR]
    Cube.occupy'[DBR] = Cube.occupy[DFR]
    Cube.occupy'[UBR] = Cube.occupy[DBR]
    Cube.tw'[UFR] = twistUpdate[Cube.tw[UBR], TUTwo]
    Cube.tw'[DFR] = twistUpdate[Cube.tw[UFR], TUOne]
    Cube.tw'[DBR] = twistUpdate[Cube.tw[DFR], TUTwo]
    Cube.tw'[UBR] = twistUpdate[Cube.tw[DBR], TUOne]
    occupyUnchanged[UFR + DFR + DBR + UBR]
    twistUnchanged[UFR + DFR + DBR + UBR]
}
pred rotateL2 {
    Cube.occupy'[UFL] = Cube.occupy[DBL]
    Cube.occupy'[DFL] = Cube.occupy[UBL]
    Cube.occupy'[DBL] = Cube.occupy[UFL]
    Cube.occupy'[UBL] = Cube.occupy[DFL]
    Cube.tw'[UFL] = Cube.tw[DBL]
    Cube.tw'[DFL] = Cube.tw[UBL]
    Cube.tw'[DBL] = Cube.tw[UFL]
    Cube.tw'[UBL] = Cube.tw[DFL]
    occupyUnchanged[UFL + DFL + DBL + UBL]
    twistUnchanged[UFL + DFL + DBL + UBL]
}
pred rotateL3 {
    Cube.occupy'[UFL] = Cube.occupy[DFL]
    Cube.occupy'[DFL] = Cube.occupy[DBL]
    Cube.occupy'[DBL] = Cube.occupy[UBL]
    Cube.occupy'[UBL] = Cube.occupy[UFL]
    Cube.tw'[UFL] = twistUpdate[Cube.tw[DFL], TUOne]
    Cube.tw'[DFL] = twistUpdate[Cube.tw[DBL], TUTwo]
    Cube.tw'[DBL] = twistUpdate[Cube.tw[UBL], TUOne]
    Cube.tw'[UBL] = twistUpdate[Cube.tw[UFL], TUTwo]
    occupyUnchanged[UFL + DFL + DBL + UBL]
    twistUnchanged[UFL + DFL + DBL + UBL]
}
pred rotateF2 {
    Cube.occupy'[UFR] = Cube.occupy[DFL]
    Cube.occupy'[DFR] = Cube.occupy[UFL]
    Cube.occupy'[DFL] = Cube.occupy[UFR]
    Cube.occupy'[UFL] = Cube.occupy[DFR]
    Cube.tw'[UFR] = Cube.tw[DFL]
    Cube.tw'[DFR] = Cube.tw[UFL]
    Cube.tw'[DFL] = Cube.tw[UFR]
    Cube.tw'[UFL] = Cube.tw[DFR]
    occupyUnchanged[UFR + DFR + DFL + UFL]
    twistUnchanged[UFR + DFR + DFL + UFL]
}
pred rotateF3 {
    Cube.occupy'[UFR] = Cube.occupy[DFR]
    Cube.occupy'[DFR] = Cube.occupy[DFL]
    Cube.occupy'[DFL] = Cube.occupy[UFL]
    Cube.occupy'[UFL] = Cube.occupy[UFR]
    Cube.tw'[UFR] = twistUpdate[Cube.tw[DFR], TUOne]
    Cube.tw'[DFR] = twistUpdate[Cube.tw[DFL], TUTwo]
    Cube.tw'[DFL] = twistUpdate[Cube.tw[UFL], TUOne]
    Cube.tw'[UFL] = twistUpdate[Cube.tw[UFR], TUTwo]
    occupyUnchanged[UFR + DFR + DFL + UFL]
    twistUnchanged[UFR + DFR + DFL + UFL]
}
pred rotateB2 {
    Cube.occupy'[UBR] = Cube.occupy[DBL]
    Cube.occupy'[UBL] = Cube.occupy[DBR]
    Cube.occupy'[DBL] = Cube.occupy[UBR]
    Cube.occupy'[DBR] = Cube.occupy[UBL]
    Cube.tw'[UBR] = Cube.tw[DBL]
    Cube.tw'[UBL] = Cube.tw[DBR]
    Cube.tw'[DBL] = Cube.tw[UBR]
    Cube.tw'[DBR] = Cube.tw[UBL]
    occupyUnchanged[UBR + UBL + DBL + DBR]
    twistUnchanged[UBR + UBL + DBL + DBR]
}
pred rotateB3 {
    Cube.occupy'[UBR] = Cube.occupy[UBL]
    Cube.occupy'[UBL] = Cube.occupy[DBL]
    Cube.occupy'[DBL] = Cube.occupy[DBR]
    Cube.occupy'[DBR] = Cube.occupy[UBR]
    Cube.tw'[UBR] = twistUpdate[Cube.tw[UBL], TUTwo]
    Cube.tw'[UBL] = twistUpdate[Cube.tw[DBL], TUOne]
    Cube.tw'[DBL] = twistUpdate[Cube.tw[DBR], TUTwo]
    Cube.tw'[DBR] = twistUpdate[Cube.tw[UBR], TUOne]
    occupyUnchanged[UBR + UBL + DBL + DBR]
    twistUnchanged[UBR + UBL + DBL + DBR]
}
// rotation preds end

pred move{
    rotateU or rotateD or rotateR or rotateL or rotateF or rotateB or
    rotateU2 or rotateU3 or rotateD2 or rotateD3 or rotateR2 or rotateR3 or
    rotateL2 or rotateL3 or rotateF2 or rotateF3 or rotateB2 or rotateB3
}

pred step{
    wellFormed
    move
}

pred unsolvedSteps{
    wellFormed and not solved
    move
}

pred notSolvable{
    always unsolvedSteps
}

// example to generate a 11 step trace
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

elevenLongTrace: run {elevenLongSolvedOnlyAtEnd} for 6 Int

pred hardStartExample{
    Cube.occupy[UFR] = bDFL
    Cube.occupy[UFL] = bDBR
    Cube.occupy[UBR] = bUFR
    Cube.occupy[UBL] = bUFL
    Cube.occupy[DFR] = bUBL
    Cube.occupy[DFL] = bDFR
    Cube.occupy[DBR] = bUBR
    Cube.occupy[DBL] = bDBL

    Cube.tw[UFR] = tOne
    Cube.tw[UFL] = tTwo
    Cube.tw[UBR] = tOne
    Cube.tw[UBL] = tOne
    Cube.tw[DFR] = tOne
    Cube.tw[DFL] = tOne
    Cube.tw[DBR] = tThree
    Cube.tw[DBL] = tOne
}

pred solveExample{
    hardStartExample
    always(step)
    eventually(solved)
}

exampleCube: run{solveExample}
