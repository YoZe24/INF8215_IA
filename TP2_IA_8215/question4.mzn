%Eliot : 2159471
%Mehdi Ben Haddou : 2159482
include "globals.mzn";

int: n_nurse; % Number of nurses
int: n_week; % Number of weeks in our horizon
int: n_day; % Number of days in our horizon (7 * n_week). Monday is the first day of the week
int: n_work_period; % Number of work period. It equals 4 (MATIN, SOIREE, NUIT, REPOS)

% Indexing the work periods
int: MATIN = 1;
int: SOIREE = 2;
int: NUIT = 3;
int: REPOS = 4;

int: dur_work_period; % Duration of the work periods (6h)

array[1..n_day,1..n_work_period] of int: demande_min; % Number of nurses required for each day and each work period (= 0 for REPOS)
array[1..n_nurse,1..n_day,1..n_work_period] of int: preference; % Work preference for each nurse

% Decision variables
array[1..n_nurse,1..n_day,1..n_work_period] of var 0..1: x; % work period [MATIN, SOIREE, NUIT, REPOS]
var int: sum_preference;
%sum of day of work per week between 4 and 6
array[1..n_nurse,1..n_week] of var 4..6: sum_work;

%util functions
function var bool: workday(int: n, int: d) = x[n,d,1] + x[n,d,2] == 1;
function var bool: worknight(int: n, int: d) = x[n,d,3] == 1;
function var bool: dayoff(int: n, int: d) = x[n,d,4] = 1;
function var bool: work(int: n, int: d) = workday(n,d) \/ worknight(n,d);

%Each nurse has one type of work period (MATIN,SOIREE,NUIT or REPOS) assigned for each day
constraint forall(i in 1..n_nurse,j in 1..n_day)(
  sum(k in 1..n_work_period)(x[i,j,k]) == 1
);

%The number of nurses for each period respect the minimum expectations of the hospital
constraint forall(j in 1..n_day,k in 1..n_work_period)(
  sum(i in 1..n_nurse)(x[i,j,k]) >= demande_min[j,k]
);

%Each nurse work at least 4 day and at most 6 day per week
constraint forall(i in 1..n_nurse, w in 1..n_week)(
  sum_work[i,w] = sum(j in 1..7, k in 1..n_work_period-1)(x[i,j+((w-1)*7),k])
);

%If a nurse work at night he/she can't work the next day 
constraint forall(i in 1..n_nurse,j in 1..n_day-1)(
  worknight(i,j) -> dayoff(i,j+1) 
); 

%A nurse can't have an isolated work day 
constraint forall(i in 1..n_nurse,j in 2..n_day-1)(
  not(dayoff(i,j-1) /\ dayoff(i,j+1)) 
);

%A nurse can't work 4 day in a row
constraint forall(i in 1..n_nurse, j in 1..n_day-3)(
  (x[i,j,REPOS]= 0 /\ x[i,j+1,REPOS]= 0 /\ x[i,j+2,REPOS]= 0) -> x[i,j+3,REPOS]=1 
);

%Sum preference of nurses (x[i,j,k] * preference[i,j,k] because x = 1 for the work session assigned and 0 for other)
sum_preference =  sum(i in 1..n_nurse,j in 1..n_day,k in 1..n_work_period)( x[i,j,k] * preference[i,j,k]);

%Maximize sum_preference : to execute with solveur COIN-BC
solve maximize sum_preference;

output
[
  "total: " ++ show(sum_preference) ++ "\n" ++
  "solution:\n\t    "
]
++
["Day \(j)\t" | j in 1..n_day]
++ 
[ 
  if j = 1 then "\n NURSE \(i):   " else "\t" endif ++
    if fix(x[i,j,4]) == 1 then "--    " elseif fix(x[i,j,3]) == 1  then "NUIT  " elseif fix(x[i,j,2]) == 1  then "SOIREE" elseif fix(x[i,j,1]) == 1 then "MATIN " else "NONE  " endif
  | i in 1..n_nurse, j in 1..n_day
];
