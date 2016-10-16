$title The Electric Company 
option limrow = 7;
set power_stations /S1*S7,D1*D7,Source/;
set supply_stations(power_stations)  "Nodes for Supply" /S1*S7/;
set demand_stations(power_stations) "Nodes for Demand" /D1*D7/;
set producing_power_stations (power_stations)  "Producing Power Stations" /S1, S4, S7/;
set demanding_power_stations (power_stations)  "Demand Power stations" /D2, D5, D7/;
set power_lines(power_stations,power_stations)  "Power lines that correspond to arcs";

alias(power_stations, I,J);


parameters
	cost(power_stations,power_stations),
	total_demand;

parameters  
demand(power_stations) "Demand at the powerstations"
	/'D2' 35 ,
	 'D5' 50,
	 'D6' 60 /,
capacity(power_stations) "Capacity of the producing / supplying power stations"
	/'S1' 100 ,
	 'S4' 60,
	 'S7' 80 /,
power_cost (power_stations) "cost of power production"
	/'S1' 15 ,
	 'S4' 13.5,
	 'S7' 21/;


total_demand = sum(demand_stations,demand(demand_stations));

demand('source') = sum(demand_stations,demand(demand_stations)) ;

scalar tx_cost "Cost of Power Transmission" /11/;

*Setting Up Arcs
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


free variable min_cost;
positive variable x(power_stations,power_stations) ;

*Setting upper bounds on sources that can be sent to pwoer stations
x.up('source',supply_stations) = capacity(supply_stations);

equations 
	obj_eq,
	power_flow_balance(power_stations) "balance of power flow for the nodes";

obj_eq ..  
min_cost =e= sum((supply_stations,demand_stations),x(supply_stations,demand_stations)*tx_cost) +
			  sum(supply_stations,X('Source',supply_stations)*power_cost(supply_stations));

*Setting the Demand to be negative for the demand nodes
demand(demand_stations) = -demand(demand_stations) ;

power_flow_balance(I).. 
	sum(J$(power_lines(I,J)), x(I,J)) -  sum(J$(power_lines(J,I)), x(J,I)) =E= demand(I) ;


model electric_company /all/;
$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho
electric_company.optfile =1;

solve electric_company using lp minimizing min_cost  ;

display min_cost.l,x.l;

display power_lines,demand ;