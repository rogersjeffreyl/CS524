$Title The Electric Company HW 04 Problem 02
option limrow = 7;
set power_stations /S1*S7,D1*D7,Source/;
set supply_stations(power_stations) /S1*S7/;
set demand_stations(power_stations) /D1*D7/;
set producing_power_stations (power_stations)  /S1, S4, S7/;
set demanding_power_stations (power_stations)  /D2, D5, D7/;
set power_lines(power_stations,power_stations) ;

alias(power_stations, I,J);


parameters
	cost(power_stations,power_stations),
	total_demand;

parameters  
demand(power_stations)
	/'D2' 35 ,
	 'D5' 50,
	 'D6' 60 /,
capacity(power_stations)
	/'D1' 100 ,
	 'D4' 60,
	 'D7' 80 /,
power_cost (power_stations)
	/'D1' 15 ,
	 'D4' 13.5,
	 'D7' 21/;

parameters
supply(supply_stations)  /S1 100, S4 60, S7 80/,
totalsupply,

generatingcost(supply_stations) /S1 15, S4 13.5, S7 21/;

totalsupply = sum(supply_stations,supply(supply_stations));
total_demand = sum(demand_stations,demand(demand_stations));

scalar transmissioncost /11/;



power_lines('Source',supply_stations) = yes;
power_lines(demand_stations,supply_stations)$(ord(supply_stations) = ord(demand_stations)) = yes;
power_lines('S1','D2') = yes;
power_lines('S2','D3') = yes;
power_lines('S2','D7') = yes;
power_lines('S3','D2') = yes;
power_lines('S3','D4') = yes;
power_lines('S3','D5') = yes;
power_lines('S4','D3') = yes;
power_lines('S4','D5') = yes;
power_lines('S5','D4') = yes;
power_lines('S5','D3') = yes;
power_lines('S6','D7') = yes;
power_lines('S7','D2') = yes;
power_lines('S7','D6') = yes;


parameter totaldemand(power_stations);
demand('Source') = sum(demand_stations,demand(demand_stations)) ;
free variable min_cost;
positive variable x(power_stations,power_stations) ;

equations objective,powersource,flowbalance(power_stations);
*,supplylimit(power_stations)
X.up('Source',supply_stations) =supply(supply_stations);

objective ..  min_cost =e= sum((supply_stations,demand_stations),X(supply_stations,demand_stations)*transmissioncost)+sum(supply_stations,X('Source',supply_stations)*generatingcost(supply_stations));

*supplylimit(supply_stations) .. X('Source',supply_stations) =l= supply(supply_stations);
powersource .. sum(power_stations,X('Source',power_stations)) =l= total_demand ;
demand(demand_stations) = -demand(demand_stations) ;
flowbalance(I) .. sum(J$(power_lines(I,J)), x(I,J)) -  sum(J$(power_lines(J,I)), x(J,I)) =E= demand(I) ;


model electricpower /all/;
$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho
electricpower.optfile =1;

solve electricpower using lp minimizing min_cost  ;

display min_cost.l,x.l;

display power_lines,supply,demand ;