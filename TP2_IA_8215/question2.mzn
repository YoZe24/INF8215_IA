%Eliot : 2159471
%Mehdi Ben Haddou : 2159482
include "globals.mzn"; 

int: n = 5;
% the given results
array[1..4] of int: res = [1,2,5,7];

% number of points for each player
array[1..n] of var 0..3*n: x;

% (i, j) is the result of player i against player j
array[1..n, 1..n] of var {0,1,3}: matches;

%Sum of results for the first four row equals expected result
constraint forall(i in 1..n-1)(
  sum(j in 1..n where i != j)(matches[i,j]) == res[i]);

%Player can't play against themselves (work without this constraint)
% constraint forall(i in 1..n, j in 1..n where i == j)(matches[i,j] = 0);

%Set results of opposite player for each match
constraint forall(i in 1..n, j in 1..n where j < i)(
  matches[i,j] = if matches[j,i] == 0 then 3 elseif matches[j,i] == 1 then 1 else 0 endif
);

%Sum results in x
constraint forall(i in 1..n)(
  x[i] = sum(j in 1..n)(matches[i,j])
);

output 
[
  "Scores\n"
]
++
[
  show(x)
]
++	
[
  "\nMatches\n"
]
++
[ show(matches[i,j]) ++ 
         if j == n then "\n" else " " endif |
         i in 1..n, j in 1..n
]
;