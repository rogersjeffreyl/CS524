$Title Malfoy Catering 
set T /1*10/;
parameter d(T) / 1 50, 2 60, 3 80, 4 70, 5 50, 6 60, 7 90, 8 80, 9 50,10 100 / ;

scalar
	cost_of_buying_napkins 'cost of buying napkins'/200/,
	cost_of_2_day_laundry 'cost of two day laundry' /75/,
	cost_of_4_day_laundry 'cost of four day laundry' /25/;

set Nodes            /Day1*Day10,I1*I10,supply_through_buying,surplus_at_end/;
set Days(Nodes)      /Day1*Day10/;
set Surplus(Nodes) /I1*I10/;
set Arcs(Nodes,Nodes) ;

alias(Nodes,I,J,K);
alias(Days, D1);
parameter c(I,J);

*Setting Arcs
Arcs('supply_through_buying',Days) = yes;
Arcs('surplus_at_end','supply_through_buying') = yes;
Arcs(Days,Surplus)$(ord(Days)=ord(Surplus)) = yes;
Arcs(D1,D1+1) = yes;
Arcs(Surplus,'surplus_at_end') = yes;
Arcs(Surplus, Days+2)$(ord(Surplus) = ord(Days)) = yes;
Arcs(Surplus, Days+4)$(ord(Surplus) = ord(Days)) = yes;

*Setting Costs
c('supply_through_buying',Days) = cost_of_buying_napkins ;
c('surplus_at_end','supply_through_buying') = 0;
c(Days,Surplus)$(ord(Days)=ord(Surplus)) = 0;
c(D1,D1+1) = 0;
c(Surplus,Days+2)$(ord(Days)=ord(Surplus)) = cost_of_2_day_laundry;
c(Surplus,Days+4)$(ord(Days)=ord(Surplus)) = cost_of_4_day_laundry;
c(Surplus,'surplus_at_end') = 0;

free variable min_cost;
positive variable x(i,j);

equations  
	minimum_cost_eq,
	enforce_surplus_supply_eq_of_flow_eq(I), 
	enforce_surplus_supply_eq(Days) ;

minimum_cost_eq.. 
sum(arcs,c(arcs)*x(arcs)) =e= min_cost;

enforce_surplus_supply_eq_of_flow_eq(I)..  
sum(J$(Arcs(I,J)), x(I,J)) -  sum(J$(Arcs(J,I)), x(J,I)) =E= 0 ;

enforce_surplus_supply_eq(Days) ..
sum(Surplus$(Ord(Days)=Ord(Surplus)),X(Days,Surplus)) =e= sum(T$(Ord(T)=Ord(Days)),D(T));

model malfoy_catering /all/;
$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho
malfoy_catering.optfile =1;
solve malfoy_catering using lp minimizing min_cost ;

display x.l;

display malfoy_catering.numequ ;
