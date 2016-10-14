$title Malfoy Catering
set T /1*10/ ;
parameter d(T) / 1 50, 2 60, 3 80, 4 70, 5 50, 6 60, 7 90, 8 80, 9 50,10 100 / ;


scalar
	cost_of_buying 'cost of buying napkins'/200/,
	cost_of_2_day_laundry 'cost of two day laundry' /75/,
	cost_of_4_day_laundry 'cost of four day laundry' /25/;

set Nodes /Buy, End, Demand1*Demand10,Inventory1*Inventory10/;
set DemandForDayNodes(Nodes) /Demand1*Demand10/;
set Inventory(Nodes) /Inventory1*Inventory10/;
set Arcs(Nodes, Nodes) ;
alias(DemandForDayNodes,D1);
alias(Nodes, I, J) ;

parameters
  cost(Nodes,Nodes);
  
free variable min_cost;  

positive variables  
   x(I,J);

equations
  minimum_cost,
  arc_demands_eq(DemandForDayNodes),
  satisfy_demands(I);  

   
*Defining Arcs
Arcs('Buy',DemandForDayNodes)=yes;
Arcs('End','Buy') = yes;
Arcs(D1,D1+1) = yes;
Arcs(DemandForDayNodes,Inventory)$(ord(Inventory) = ord(DemandForDayNodes)) = yes;
Arcs(Inventory,DemandForDayNodes+2)$(ord(Inventory) = ord(DemandForDayNodes)) = yes;
Arcs(Inventory,DemandForDayNodes+4)$(ord(Inventory) = ord(DemandForDayNodes)) = yes;
Arcs(Inventory,'End') = yes;




*Assigning Costs
cost('Buy',DemandForDayNodes) = cost_of_buying;
cost('End','Buy') = 0;
cost(D1,D1+1) = 0;
cost(DemandForDayNodes,Inventory)$(ord(Inventory) = ord(DemandForDayNodes)) = 0;
cost(Inventory,DemandForDayNodes+2)$(ord(Inventory) = ord(DemandForDayNodes)) = cost_of_2_day_laundry;
cost(Inventory,DemandForDayNodes+4)$(ord(Inventory) = ord(DemandForDayNodes)) = cost_of_4_day_laundry;
cost(Inventory,'End') = 0;




minimum_cost ..
	min_cost =e= sum (Arcs,x(Arcs)*cost(Arcs));

satisfy_demands(I)..
	sum(J$(Arcs(I,J)), x(I,J)) - sum(J$(Arcs(J,I)), x(J,I)) =e=0 ;

arc_demands_eq(DemandForDayNodes)..
	sum( Inventory$(ord(Inventory) =ord(DemandForDayNodes)),x(DemandForDayNodes,Inventory)) =e= sum( T$(ord(T) =ord(DemandForDayNodes)),d(T));


model malfoy_catering /all/;

*Enforcing Demands through Arc Capacities to the Inventory


$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho

malfoy_catering.optfile=1;

solve malfoy_catering using lp minimizing min_cost;

option Arcs:0:0:1 ;
display Arcs; 
display cost;
*display x.l;