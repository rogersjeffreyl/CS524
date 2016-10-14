$title The Electric Company
set power_stations /S1*S7,D1*D7, source/;
set  supply_stations(power_stations) /S1*S7/;
set  demand_stations(power_stations) /D1*D7/;
set producing_power_stations (power_stations)  /S1, S4, S7/;
set demanding_power_stations (power_stations)  /D2, D5, D7/;
set power_lines(power_stations, power_stations) ;

scalar tx_cost /11.00/;
parameters
	cost(power_stations,power_stations),
	u(power_stations,power_stations);
parameters  
demand(power_stations)
	/'D2' 35 ,
	 'D5' 50,
	 'D6' 60 /;

alias(power_stations, I, J);

positive variable
	x(I,J);


* Defining Arcs
power_lines('source',supply_stations) = yes;
power_lines(supply_stations,demand_stations)$(ord(supply_stations) = ord(demand_stations)) = yes;

*Setting Demand at Source
demand('source') = sum (demand_stations,demand(demand_stations) );

*Setting Demand at Destination
demand(demand_stations) = -demand(demand_stations);

display demand;








