$ondollar
$title HW1 prob2
$offsymxref offsymlist offuelxref offuellist offupper
option limrow = 0, limcol = 0;

set J /1*3/;

free variable objective "objective";
positive variables
x(J) "decision variables";

x.lo(J) =0;
x.up(J) =3;

equations
obj "objective to minimize",
const1 "constraint on the value of x(1)";

obj..
objective =e= 5 * (x('1') + 2 * x('2')) - 11 * (x('2') - x('3'));

const1.. 
3 * x('1') =g= sum(J, x(J));

model prob2 /all/;

solve prob2 using lp maximizing objective;

display x.l, x.lo, x.up, prob2.objval;
