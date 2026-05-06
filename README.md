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

**Twist is defined as the orientation of a cube relative to our fixed axis on the Up and Down faces.  A slot has a twist of One when the color that is arbitrarily determined to be the up/down facing color is correctly oriented up or down respectively.  Additionally, due to the way that rotations change the twist of a cube, we find that the total twist of our cube must be divisble by 3. 
Note: this page offers a bit more context on why this is the case (https://www.ryanheise.com/cube/cube_laws.html), but only talks about 3x3 cubes.

Our initial model* was developed with respect to probably the most natural way of understanding a Rubik's Cube.  This involves
defining 6 Sigs to represent each of the faces of a cube, and then each of the faces contains a 2x2 grid that tracks which stickers/colors are currently on each space.  We then define 6 rotations over this space and how they affect which stickers are in which coordinates. This was intuitive, but it proved to be too bulky to be fully useful for our purposes.  However,in making this initial attempt we were able to pinpoint what the necessary and unnecessary components of our model actually were.  
    
Our final Forge model abstracts away the idea of stickers/coordinates and instead models the cube as 8 corner pieces with 3 different possible spatial orientations.  In order to solve a cube we do not need to know where every sticker is at any point, we only need to know how the 8 different corners of the cube are oriented relative to our fixed orientation.  This choice maintains all of the same information about the cube by enforcing relational rules, and therefore no longer relies on computationally expensive pfuncs to track our states.  This model is significantly more effective, but is a much less natural way of considering our cube. 

Specifically, we define 8 Slots, 8 blocks, a cube.  A slot is the fixed position on our cube and a block is the physical object that is occupying some slot (basically slots are fixed and blocks are what moves around the cube).  Our Cube sig tracks which block is occupying a given slot as well as the twist** of the block in each slot.  We consider a solved cube one in which every slot is occupied by its corresponding block and the twist of every slot is One.  Our rotate functions change what block is occupying a slot and update the twist of a slot.  By updating the twist of each block at every rotation, we ensure that every move is legal/physically possible on a cube.


## Reach Goal and Further Research
While our updated Forge model proved capable of solving 2x2 cubes, we did initially want to see if it was possible to solve 3x3 or even larger cubes.  For this, abstracting away our stickers/coordinates would be significantly more challenging, so we looked into tools that were better suited for this type of problem.  In doing this research, we discovered GAP (https://www.gap-system.org/).  This tool uses group theory and an algorithmic approach to solving that does not require extensive exploration of our complete state space.  By representing cubes as the group of every possible permutation that is achievable from the set of rotations we define, GAP is able to find solutions to cubes extremely quickly.  Although GAP offers an extremely effective way of solving cubes, it is a much less interesting model that requires little consideration for the design of the model.  As such, we explored the tool mainly as a means to achieving our reach goal, but did all of the interesting and thoughtful modeling for our 2x2 in Forge. 


## An Instance of Our Model
In Forge our 8 corner model finds an instance of a scrambled cube which can be solved in some number of steps.  We tried to ensure that traces found by Forge were non-trivial by forcing the model to be unsolved until the final step of the trace (not allowing the model to start in a solved state and rotate the same face back and forth).  The visualizer shows a full trace of the cube being solved with the cube unfolded.

GAP instances approach solving slightly differently.  Since every permutation of our cube is already defined, we have GAP choose a random cube from the group of permutations and then find a sequence of moves that unscrambles the state.  Again, the visualizer shows the sequence/trace for our unfolded cube. 

## Tradeoffs from GAP to Forge
Because we are able to choose the specific tracelength for solutions in Forge, the 8 corner model is able to find cubes that can be solved within a given number of steps.  GAP is not particularly built for this use case, so Forge does offer some benefits.  This is an interesting application of the model that we did not initially consider.  Additionally, Forge is better suited to finding optimal*** solutions to our cubes, while GAP just finds some sequence of moves which is a solution.  

***We use optimal loosely here.  Research has proven that the maximum number of moves required to solve a 2x2 cube is 11 (https://ruwix.com/the-rubiks-cube/gods-number/).  By limiting our max trace length to 11 we force our model to find the path which is most effective for hard to solve cubes.  Additionally, by solving traces with a length of 11 we have by extension shown that we can solve any 2x2 cube with our Forge model.


## AI Usage
AI was used to generate visualizers, but never for development of our models.


## Collaborators

Luke Zheng, Ethan Wordell, and Griffin Milford:

We all worked collectively to develop our original model of the cube, and then divided work after that.

Luke did most of the work on creating and implementing the 8 corner model as well as writing the code for part of the original.

Ethan did backgroud research and model implementation with GAP as well as some testing.

Griffin completed the original model and did some testing on it as well. 
