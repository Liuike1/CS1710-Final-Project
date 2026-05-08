# Rather than defining rotations strictly over all columns and rows, 
# we rely on Singmaster Notation (https://www.speedsolving.com/wiki/index.php/Singmaster_notation).

# Consider a cube in a fixed position such that one face is always facing you.  We define the six
# faces as such:
# u: up -> top face
# d: down -> bottom face
# l: left
# r: right
# f: front -> the face we are looking at
# b: back -> face opposite the front

# All rotations are done by looking at the specified face and rotating it one turn clockwise.
# Look at Singmaster Notation above for more details.


#Diagrams for how the 2x2 and 3x3 were mapped out are both included as pngs under their respective name.

#2x2:
# We define all 6 rotations over our 24 spaces
# The solved state of our cube is the identity (the state in which no moves have been done)

f := (1,2,4,3)(5,14,12,23)(7,13,10,24);
r := (7,5,6,8)(4,24,20,16)(2,22,18,14);
u := (21,22,24,23)(6,2,10,19)(5,1,9,20);

# b := (17,18,20,19)(15,8,22,9)(16,6,21,11);
# d := (13,14,16,15)(3,7,18,11)(4,8,17,12);
# l := (10,12,11,9)(1,13,17,21)(3,15,19,23);

# we actually only need to define our group over u, f, r.
# this anchors spaces in the back left bottom corner so that the spatial positioning of the cube is locked into place.
# If we don't anchor the spatial positioning of the cube, then every possible orientation of the colors would count
# as a different solved state 
# (i.e. a solved cube with the white face being on top, bottom, left, right... all count as different permutations)

cube2x2 := Group(u,r,f);
mystery_scramble := Random(cube2x2);
Print("Random Scramble Permutation: ", mystery_scramble, "\n");

hom := EpimorphismFromFreeGroup(cube2x2);
solution := PreImagesRepresentative(hom, mystery_scramble^-1);

Print("Solution: ", solution, "\n");




