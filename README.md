Complete before design check:
- Correctness fix & 1 - 2 step solving capabilities for current implementation & maybe add 180 and 270 degree rotation?
- not going back to same state --> look into forge capabilities
- Investigate 8 corner implementation
- visualization

Later
- Look into GAP & alternate pathways & 




# 2x2 Rubik's Cube Model

## Design Choices and Project Evolution
*Every model was designed rougly with Singmaster Notation (https://rubiks.fandom.com/wiki/Notation) in mind.  We consider the orientation of our cube fixed in space, and rotations are generally done clockwise with respect to any given face.

**Twist is defined as the orientation of a cube relative to our fixed axis on the Up and Down faces.  A slot has a twist of One when 

Our initial model* was developed with respect to probably the most natural way of understanding a Rubik's Cube.  This involves
defining 6 Sigs to represent each of the faces of a cube, and then each of the faces contains a 2x2 grid that tracks which stickers/colors are currently on each space.  We then define 6 rotations over this space and how they affect which stickers are in which coordinates. This was intuitive, but it proved to be too bulky to be fully useful for our purposes.  However,in making this initial attempt we were able to pinpoint what the necessary and unnecessary components of our model actually were.  
    
Our final Forge model abstracts away the idea of stickers/coordinates and instead models the cube as 8 corner pieces with 3 different possible spatial orientations.  In order to solve a cube we do not need to know where every sticker is at any point, we only need to know how the 8 different corners of the cube are oriented relative to our fixed orientation.  This choice maintains all of the same information about the cube by enforcing relational rules, and therefore no longer relies on computationally expensive pfuncs to track our states.  

Specifically, we define 8 Slots, 8 blocks, a cube.  A slot is the fixed position on our cube and a block is the physical object that is occupying some slot (basically slots are fixed and blocks are what moves around the cube).  Our Cube sig tracks which block is occupying a given slot as well as the twist** (orientation) of the block in each slot.  We consider a solved cube one in which every slot is occupied by its corresponding block and the twist of every slot is One.  Our rotate functions change what block is occupying a slot and update the twist of a slot.
