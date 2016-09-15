$ondollar
$title prob1 (LP)
$Ondotl offsymxref offsymlist offuelxref offuellist offupper
option limrow = 0, limcol = 0;

parameter x1val, x2val, x3val, objval;

free variable x4 "minimization objective";

positive variables
x1 "variable 1",
x2 "variable 2",
x3 "variable 3";

equations
obj  "minimize objective",
c1   "Constraint 1",
c2   "Constraint 2",
c3   "Constraint 3";

obj..
x4 =e= 3*x1 + 2*x2 - 33*x3;

c1..
x1 -4*x2 + x3 =l= 15;

c2..
9*x1 + 6*x3  =e= 12;

c3..
-5*x1 + 9*x2 =g= 3;


model prob1 /all/;

solve prob1 using lp minimizing x4;

objval = obj.L ;
x1val = x1.L ;
x2val = x2.L ;
x3val = x3.L ;
display "Parameters";
display objval, x1val, x2val, x3val ;
