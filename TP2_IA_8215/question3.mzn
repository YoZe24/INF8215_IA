%Eliot : 2159471
%Mehdi Ben Haddou : 2159482
include "globals.mzn"; 

int: n; % num rows and columns

int: L = 1; % Lamp
int: P = 2; % Plant

% 1 for a lamp, 2 for a plant and 0 for nothing 
array[1..n,1..n] of 0..2: garden;

% number of plants by row/col
array[1..n] of int: rows;
array[1..n] of int: cols;

% decision variables
array[1..n,1..n] of var 0..P: x;

array[1..8] of int: pos= [-1,0,+1,0,0,-1,0,+1];

%Set up plant
constraint forall(i,j in 1..n where garden[i,j] == 1)(
  x[i,j] = garden[i,j]
);

function bool: is_valid_pos(int: x, int: y) = 
  if (x < 1 \/ x > n \/ y < 1 \/ y > n) then false else true endif;

%Col and Row equals to constraint
constraint forall(i in 1..n)(
  count(row(x, i),2,rows[i]) 
  /\
  count(col(x, i),2,cols[i])
);


%At least one plant near a lamp
constraint forall(i,j in 1..n where x[i,j] == 1)(
%   forall(k in 1..4)(
%      (is_valid_pos(i + (k*2)-1,j + k*2) /\ garden[i + k*2-1,j + k*2] == 2)  
%   )

    (is_valid_pos(i-1,j) /\ x[i-1,j] == 2) \/
    (is_valid_pos(i,j-1) /\ x[i,j-1] == 2) \/ 
    (is_valid_pos(i+1,j) /\ x[i+1,j] == 2) \/
    (is_valid_pos(i,j+1) /\ x[i,j+1] == 2) 
);

%No plant around another plant
constraint forall(i,j in 1..n where x[i,j] == 2)(
     (if is_valid_pos(i-1,j-1) then x[i-1,j-1] != 2 else true endif) /\
     (if is_valid_pos(i+1,j+1) then x[i+1,j+1] != 2 else true endif) /\
     (if is_valid_pos(i+1,j-1) then x[i+1,j-1] != 2 else true endif) /\
     (if is_valid_pos(i-1,j+1) then x[i-1,j+1] != 2 else true endif) /\

     (if is_valid_pos(i,j-1) then x[i,j-1] != 2 else true endif) /\
     (if is_valid_pos(i-1,j) then x[i-1,j] != 2 else true endif) /\
     (if is_valid_pos(i,j+1) then x[i,j+1] != 2 else true endif) /\
     (if is_valid_pos(i+1,j) then x[i+1,j] != 2 else true endif) 

);

%No plant not attached to a lamp
constraint forall(i,j in 1..n where garden[i,j] == 0)(
    if ( (is_valid_pos(i-1,j) /\ x[i-1,j] == 1) \/
         (is_valid_pos(i,j-1) /\ x[i,j-1] == 1) \/ 
         (is_valid_pos(i+1,j) /\ x[i+1,j] == 1) \/
         (is_valid_pos(i,j+1) /\ x[i,j+1] == 1) )
    then x[i,j] = 2 \/ x[i,j] = 0
    else x[i,j] = 0
    endif
);


output 
[
 if j = 1 then "\n" ++ show(rows[i]) ++ " " else " " endif ++
   if fix(x[i,j]) = L then "L" elseif fix(x[i,j]) = P then "P" else "_" endif
| i,j in 1..n
] ++ ["\n  "] ++ [show(cols[i]) ++ " " | i in 1..n];
