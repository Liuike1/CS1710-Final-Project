#GAP solver for 3x3

f := (1,3,9,7)(2,6,8,4)(43,10,48,36)(44,13,47,33)(45,16,46,30);
b := (19,21,27,25)(20,24,26,22)(18,39,28,54)(15,38,31,53)(12,37,34,52);
r := (10,12,18,16)(11,15,17,13)(45,19,54,9)(42,22,51,6)(39,25,52,3);
l := (28,30,36,34)(29,33,35,31)(37,1,46,27)(40,4,49,24)(43,7,52,21);
u := (37,39,45,43)(38,42,44,40)(21,12,3,30)(20,11,2,29)(19,10,1,28);
d := (46,48,54,52)(47,51,53,49)(34,7,16,25)(35,8,17,26)(36,9,18,27);

cube3x3 := Group(u,d,l,r,f,b);;
mystery_scramble := Random(cube3x3);
Print("Random Scramble Permutation: ", mystery_scramble, "\n");

hom := EpimorphismFromFreeGroup(cube3x3);
solution := PreImagesRepresentative(hom, mystery_scramble^-1);

Print("Solution: ", solution, "\n");