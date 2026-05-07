#lang forge/temporal

open "2x2_cube_design2.frg"


test suite for totalTwistValid {
    necessaryForSolved: assert totalTwistValid is necessary for solved
}

test suite for wellFormed {
    wellFormedExists: assert {
        wellFormed
    } is sat

    oneBlockPerSlot: assert {
        some s: Slot | some disj b1,b2: Block | wellFormed and Cube.occupy[s] = b1 and Cube.occupy[s] = b2
    } is unsat

    oneSlotPerBlock: assert {
        some b: Block | some disj s1,s2: Slot | wellFormed and Cube.occupy[s1] = b and Cube.occupy[s2] = b
    } is unsat

    twistConserved: assert {
        wellFormed
        remainder[add[#{s: Slot | Cube.tw[s] = tTwo}, multiply[2,#{s: Slot | Cube.tw[s] = tThree}]],3] != 0
    } is unsat

}

test suite for solved {
    validTwist: assert {
        solved
        some s: Slot | Cube.tw[s] != tOne
    } is unsat

    wellFormedNecessary: assert wellFormed is necessary for solved
}

test suite for occupyUnchanged{
    unchanged: assert {
        wellFormed
        some s: Slot {
            all s2: Slot | s2 != s implies {
                occupyUnchanged[s2]
                Cube.occupy'[s] != Cube.occupy[s]
            }
        }
    } is unsat
}

test suite for twistUnchanged{
    unchangedTwist: assert {
        wellFormed
        some s: Slot {
            all s2: Slot | s2 != s implies {
                twistUnchanged[s2]
                Cube.tw'[s] != Cube.tw[s]
            }
        }
    } is unsat
}


//for our rotate functions, we just want to check that total twist is conserved between rotations
// ie -> need to check that total twist is divisible by 3 after rotation

test suite for rotateU {
    conserveU: assert {
        wellFormed
        rotateU
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat
}
test suite for rotateD {
    conserveD: assert {
        wellFormed
        rotateD
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat
}

test suite for rotateL {
    conserveL: assert {
        wellFormed
        rotateL
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat for 6 Int
}

test suite for rotateR {
    conserveR: assert {
        wellFormed
        rotateR
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat for 6 Int
}

test suite for rotateF {
    conserveF: assert {
        wellFormed
        rotateF
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat for 6 Int
}

test suite for rotateB {
    conserveB: assert {
        wellFormed
        rotateB
        totalTwistValid
        next_state (not totalTwistValid)
    } is unsat for 6 Int
}
