#lang forge/temporal

option max_tracelength 3
option min_tracelength 3

option run_sterling "design1_vis.js"

one sig Cube{
    front: one Face,
    back: one Face,
    top: one Face,
    bottom: one Face,
    left: one Face,
    right: one Face
}
abstract sig Face {
    var board: pfunc Int -> Int -> Int
}
one sig Front extends Face {}
one sig Back extends Face {}
one sig Top extends Face {}
one sig Bottom extends Face {}
one sig Left extends Face {}
one sig Right extends Face {}

pred twoxTwoWellFormed{
    all x, y: Int | {
        (some Front.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Front.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
        (some Back.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Back.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
        (some Top.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Top.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
        (some Bottom.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Bottom.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
        (some Left.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Left.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
        (some Right.board[x][y] iff (y in {0 + 1} and x in {0 + 1})) and (Right.board[x][y] in {1 + 2 + 3 + 4 + 5 + 6})
    }

    all x,y: Int | {
        y in {0 + 1} and x in {0 + 1} implies {
            all c: Int | { c in {1 + 2 + 3 + 4 + 5 + 6} implies 
                #{f: Face, x, y: Int |
                    x in {0 + 1} and y in {0 + 1} and f.board[x][y] = c} = 4            
                }
        }
    }
}

pred faceSolved[f: Face]{
    all x1, y1, x2, y2: Int |
        (x1 in {0 + 1} and y1 in {0 + 1}) and 
        (x2 in {0 + 1} and y2 in {0 + 1}) implies 
        f.board[x1][y1] = f.board[x2][y2]
}
pred solved{
    twoxTwoWellFormed
    faceSolved[Front]    
    faceSolved[Back] 
    faceSolved[Top] 
    faceSolved[Bottom] 
    faceSolved[Left] 
    faceSolved[Right] 
    
}
pred initSolved{
    twoxTwoWellFormed
    all x,y: Int |
        x in {0 + 1} and y in {0 + 1}
        implies {
            Front.board[x][y] = 1
            Back.board[x][y] = 2
            Top.board[x][y] = 3
            Bottom.board[x][y] = 4
            Left.board[x][y] = 5
            Right.board[x][y] = 6
        }
}

pred scrambled{
    twoxTwoWellFormed
    not solved
}
pred sameCell[f: Face, x: Int, y: Int] {
    f.board'[x][y] = f.board[x][y]
}

pred sameFace[f: Face] {
    all x, y: Int |
        x in {0 + 1} and y in {0 + 1}
        implies f.board'[x][y] = f.board[x][y]
}

pred sameExceptCol[f: Face, col: Int] {
    all x, y: Int |
        x in {0 + 1} and y in {0 + 1} and x != col
        implies f.board'[x][y] = f.board[x][y]
}

pred sameExceptRow[f: Face, row: Int] {
    all x, y: Int |
        x in {0 + 1} and y in {0 + 1} and y != row
        implies f.board'[x][y] = f.board[x][y]
}
pred rotateFace[f: Face] {
    f.board'[0][0] = f.board[0][1]
    f.board'[0][1] = f.board[1][1]
    f.board'[1][1] = f.board[1][0]
    f.board'[1][0] = f.board[0][0]
}
pred validTransition {
    twoxTwoWellFormed
    next_state {
        twoxTwoWellFormed
    }
}
pred rotationRight {
    validTransition
    all y: Int | y in {0 + 1} implies {
        // slide pieces across non-opp. faces
        Front.board'[1][y] = Top.board[1][y]
        Bottom.board'[1][y] = Front.board[1][y]
        Back.board'[1][y] = Bottom.board[1][y]
        Top.board'[1][y] = Back.board[1][y]
    }

    // opposite face is unchanged
    sameFace[Left]

    // columns on adjacent faces are unchanged
    sameExceptCol[Front, 1]
    sameExceptCol[Bottom, 1]
    sameExceptCol[Back, 1]
    sameExceptCol[Top, 1]

    // Rotate the face 
    rotateFace[Right]
}

pred rotationLeft{
    validTransition
    all y: Int | 
        (y in {0 + 1} ) implies {
            // slide pieces across non-opp. faces
            Front.board'[0][y] = Bottom.board[0][y]
            Top.board'[0][y] = Front.board[0][y]
            Back.board'[0][y] = Top.board[0][y]
            Bottom.board'[0][y] = Back.board[0][y]
    }
    // opposite face is unchanged
    sameFace[Right]

    // columns on adjacent faces are unchanged
    sameExceptCol[Front, 0]
    sameExceptCol[Bottom, 0]
    sameExceptCol[Back, 0]
    sameExceptCol[Top, 0]

    // Rotate the face 
    rotateFace[Left]
}

pred rotationFront{
    validTransition
    all p: Int | 
        (p in {0 + 1} ) implies {
            // slide pieces across non-opp. faces
            Top.board'[p][1] = Left.board[1][p]
            Right.board'[0][p] = Top.board[p][1]
            Bottom.board'[p][0] = Right.board[0][p]
            Left.board'[1][p] = Bottom.board[p][0]
    }
    // opposite face is unchanged
    sameFace[Back]

    // columns on adjacent faces are unchanged
    sameExceptRow[Top, 1]
    sameExceptRow[Bottom, 0]
    sameExceptCol[Left, 1]
    sameExceptCol[Right, 0]

    // Rotate the face 
    rotateFace[Front]
}

pred rotationBack{
    validTransition
    all p: Int | 
        (p in {0 + 1} ) implies {
            // slide pieces across non-opp. faces
            Top.board'[p][0] = Right.board[1][p]
            Left.board'[0][p] = Top.board[p][0]
            Bottom.board'[p][1] = Left.board[0][p]
            Right.board'[1][p] = Bottom.board[p][1]
    }
    // opposite face is unchanged
    sameFace[Front]

    // columns on adjacent faces are unchanged
    sameExceptRow[Top, 0]
    sameExceptRow[Bottom, 1]
    sameExceptCol[Left, 0]
    sameExceptCol[Right, 1]

    // Rotate the face 
    rotateFace[Back]
}

pred rotationTop{
    validTransition
    all x: Int | 
        (x in {0 + 1} ) implies {
            // slide pieces across non-opp. faces
            Front.board'[x][0] = Right.board[x][0]
            Right.board'[x][0] = Back.board[x][0]
            Back.board'[x][0] = Left.board[x][0]
            Left.board'[x][0] = Front.board[x][0]
    }
    // opposite face is unchanged
    sameFace[Bottom]

    // columns on adjacent faces are unchanged
    sameExceptRow[Front, 0]
    sameExceptRow[Left, 0]
    sameExceptRow[Back, 0]
    sameExceptRow[Right, 0]

    // Rotate the face 
    rotateFace[Top]
}

pred rotationBottom{
    validTransition
    all x: Int | 
        (x in {0 + 1} ) implies {
            // slide pieces across non-opp. faces
            Front.board'[x][1] = Right.board[x][1]
            Right.board'[x][1] = Back.board[x][1]
            Back.board'[x][1] = Left.board[x][1]
            Left.board'[x][1] = Front.board[x][1]
    }
    // opposite face is unchanged
    sameFace[Top]

    // columns on adjacent faces are unchanged
    sameExceptRow[Front, 1]
    sameExceptRow[Left, 1]
    sameExceptRow[Back, 1]
    sameExceptRow[Right, 1]

    // Rotate the face 
    rotateFace[Bottom]
}

pred oneMove{
    rotationBottom or rotationTop or rotationRight or rotationLeft or rotationFront or rotationBack
}
pred RubiksTraces{
    initSolved
    always(twoxTwoWellFormed)
    always(oneMove)
}
pred scrambleTwice {
    initSolved

    oneMove

    next_state {
        twoxTwoWellFormed
        oneMove
    }

    next_state {
        next_state {
            scrambled
        }
    }
}

run {
    scrambleTwice
}
// 
//