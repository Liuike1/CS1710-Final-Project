#lang forge/temporal

option max_tracelength 2

abstract sig Boolean {}
one sig True, False extends Boolean {}
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

pred rotationRight{
    all x, y: Int | {
        (y in {0 + 1} and x = 1) implies {
            Front.board'[x][y] = Top.board[x][y]
            Bottom.board'[x][y] = Front.board[x][y]
            Back.board'[x][y] = Bottom.board[x][y]
            Top.board'[x][y] = Bottom.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Left.board'[x][y] = Left.board[x][y]
        }

        Right.board'[0][0]= Right.board[0][1]
        Right.board'[0][1] = Right.board[1][1]
        Right.board'[1][1] = Right.board[1][0]
        Right.board'[1][0] = Right.board[0][0]
    }
}

pred rotationLeft{
    all x, y: Int | {
        (y in {0 + 1} and x = 0) implies {
            Front.board'[x][y] = Top.board[x][y]
            Bottom.board'[x][y] = Front.board[x][y]
            Back.board'[x][y] = Bottom.board[x][y]
            Top.board'[x][y] = Bottom.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Right.board'[x][y] = Right.board[x][y]
        }

        Left.board'[0][0] = Left.board[0][1]
        Left.board'[0][1] = Left.board[1][1]
        Left.board'[1][1] = Left.board[1][0]
        Left.board'[1][0] = Left.board[0][0]
    }
}

pred rotationFront{
    all x, y: Int | {
        (y in {0 + 1} and x = 1) implies {
            Left.board'[x][y] = Top.board[x][y]
            Bottom.board'[x][y] = Left.board[x][y]
            Right.board'[x][y] = Bottom.board[x][y]
            Top.board'[x][y] = Right.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Back.board'[x][y] = Back.board[x][y]
        }

        Front.board'[0][0] = Front.board[0][1]
        Front.board'[0][1] = Front.board[1][1]
        Front.board'[1][1] = Front.board[1][0]
        Front.board'[1][0] = Front.board[0][0]
    }
}

pred rotationBack{
    all x, y: Int | {
        (y in {0 + 1} and x = 1) implies {
            Left.board'[x][y] = Top.board[x][y]
            Bottom.board'[x][y] = Left.board[x][y]
            Right.board'[x][y] = Bottom.board[x][y]
            Top.board'[x][y] = Right.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Front.board'[x][y] = Front.board[x][y]
        }

        Back.board'[0][0] = Back.board[0][1]
        Back.board'[0][1] = Back.board[1][1]
        Back.board'[1][1] = Back.board[1][0]
        Back.board'[1][0] = Back.board[0][0]
    }
}

pred rotationTop{
    all x, y: Int | {
        (y in {0 + 1} and x = 1) implies {
            Left.board'[x][y] = Back.board[x][y]
            Front.board'[x][y] = Left.board[x][y]
            Right.board'[x][y] = Front.board[x][y]
            Back.board'[x][y] = Right.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Bottom.board'[x][y] = Bottom.board[x][y]
        }

        Top.board'[0][0] = Top.board[0][1]
        Top.board'[0][1] = Top.board[1][1]
        Top.board'[1][1] = Top.board[1][0]
        Top.board'[1][0] = Top.board[0][0]
    }
}

pred rotationBottom{
    all x, y: Int | {
        (y in {0 + 1} and x = 1) implies {
            Left.board'[x][y] = Back.board[x][y]
            Front.board'[x][y] = Left.board[x][y]
            Right.board'[x][y] = Front.board[x][y]
            Back.board'[x][y] = Right.board[x][y]
        }

        (y in {0 + 1} and x in {0 + 1}) implies {
            Top.board'[x][y] = Top.board[x][y]
        }

        Bottom.board'[0][0] = Bottom.board[0][1]
        Bottom.board'[0][1] = Bottom.board[1][1]
        Bottom.board'[1][1] = Bottom.board[1][0]
        Bottom.board'[1][0] = Bottom.board[0][0]
    }
}

pred RubiksTraces{
    always(twoxTwoWellFormed)
    always(rotationBottom or rotationTop or rotationRight or rotationLeft or rotationFront or rotationBack)
}

run{RubiksTraces}