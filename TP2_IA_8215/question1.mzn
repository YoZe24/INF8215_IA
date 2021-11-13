%Eliot : 2159471
%Mehdi Ben Haddou : 2159482
include "globals.mzn"; 

int: r; % number of rows 
int: c; % number of columns
array[1..r] of int: rowinsects; % total of insects by row
array[1..c] of int: colinsects; % total of insects by col
array[1..r, 1..c] of 0..r*c: knownpositions;  % known number of insects, 0 appears when unknown


array[1..r, 1..c] of var 1..r*c: x; % the final garden grid (decision variable)

%copy known number insect in x
constraint forall(i in 1..r, j in 1..c where knownpositions[i,j] != 0)(x[i,j] == knownpositions[i,j]);

%for each row sum of insects equals restrictions and all numbers are different
constraint forall(i in 1..r)(
  sum(ic in 1..c)(x[i,ic]) == rowinsects[i] /\
  alldifferent( [ x[i,j] | j in 1..c ]) 
 );
 
 %for each column sum of insects equals restrictions and all numbers are different
constraint forall(j in 1..c)(
  sum(ir in 1..r)(x[ir,j]) == colinsects[j]  /\
  alldifferent( [ x[i,j] | i in 1..r ]) 
);

output [
  "["
]
++
[
  if j = 1 then "\n" else "," endif ++
    if fix(x[i,j]) < 10 then "  " else " "  endif ++
    show(x[i,j]) ++
  if j = c then 
    ", f(" ++ show(rowinsects[i]) ++ "),"
  else 
    ""
  endif
  | i in 1..r, j in 1..c
] 
++
["\n"]++
[
  "f(" ++ show(colinsects[j]) ++ "),"
  | j in 1..c
]

++ ["]\n"]
;