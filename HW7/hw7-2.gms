$title Example LQR: linear-quadratic optimal control

* here set the number of subintervals to the desired value (defined as a
* global parameter for the model)
$if not set K $set K 100
$if not set U $set U 10

option limrow=20, limcol=0, solprint=off;

set stages /0 * %K%/;
set states /1*4/;
set inputs /1/;

alias (states,n); alias (inputs,m);

parameter
*       Q(states, states)       Hessian wrt states
        R(inputs, inputs)       Hessian wrt inputs
        A(states, states)       state transition matrix in continuous formulation
        B(states, inputs)       input transition matrix in continuous formulation
        Xinitial(states)        initial X
           /1  0.4, 
            2  0.0,
            3  0.2, 
            4  0.0 /
;

scalar Ubound /%U%/
       deltaT
;

* set interval width deltaT to be 1/K.
deltaT = 1.0 / %K%;

variable
         x(stages, states)   state variables
         u(stages, inputs)   input variables (controls)
         cost                   objective function
;

table A
    1    2   3    4
1  0.0  1.0  0    0 
2  10   0.0  -12  0
3  0    0.0  0    1
4 -10   0.0  10   0;


table B
   1
1  0.0
2  -1.0
3  0.0
4  0.0 ;

equations
        state(stages, states)        state transition equation
        objective                       cost function
;

state(stages, states)$(ord(stages) < card(stages))..
    (x(stages+1, states) - x(stages, states) ) / deltaT
          =e= sum(n, A(states, n)*x(stages,n))
             +sum(m, B(states, m)*u(stages,m));

* objective includes a numerical integral over [0,1], using Trapezoidal rule

objective..
  cost =e= sum((stages,inputs)$(ord(stages) < card(stages)  ),u(stages,inputs)*u(stages,inputs));

* fix the initial values
x.fx('0',states) = Xinitial(states);

* fix lower and upper bounds
u.up(stages, inputs) =  Ubound; u.lo(stages, inputs) = -Ubound;

* fix final states
x.fx(stages, states)$(ord(stages) eq card(stages)) = 0;

model lqr /all/;
option QCP=CPLEX
solve lqr using qcp minimizing cost;

display Ubound; display cost.l; display x.l, u.l;

