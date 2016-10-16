$title United Airlines
set cities /MSN, ORD, MSP, DTW, SFO, IAH, DCA, MCO/;
set united(cities) /MSN, ORD, SFO, IAH, DCA, MCO/;
set delta(cities) /MSN, MSP, DTW, SFO, IAH, DCA, MCO/;
set destinations(cities) /SFO, IAH, DCA, MCO/;
set hubs(cities) /ORD, MSP, DTW/;

alias(cities, I, J);
parameters 

travel_demand(cities)
cost(cities, cities) /
   MSN.ORD 22, MSN.DTW 65, MSN.MSP 46,
   MSP.SFO 213, MSP.IAH 139, MSP.DCA 125, MSP.MCO 176,
   ORD.SFO 247, ORD.IAH 124, ORD.DCA  82, ORD.MCO 135,
   DTW.SFO 280, DTW.IAH 147, DTW.DCA  53, DTW.MCO 130 /,
delays_at_hubs(cities),
travel_delays(cities, cities);

set iterations /10/;
parameters 
	delta_travel_times(iterations),
	united_travel_times(iterations);
	
positive variables x(I,J);
free variable travel_time;

set routes(cities, cities);
routes(I,J) = yes$(cost(I,J));
display routes;
travel_demand(destinations) = -3;
travel_demand('MSN') = - sum(destinations, travel_demand(destinations));

equations 
	flow_balance(cities),
	travel_time_eq,
	delta_route_eq,
	united_route_1_eq,
	united_route_2_eq;
;

flow_balance(I)..
	sum(J$routes(I,J), x(I,J)) - sum(J$routes(J,I), x(J,I)) =e= travel_demand(I);

travel_time_eq..
	travel_time =e= sum(routes, travel_delays(routes) * x(routes));


model use_delta /flow_balance, travel_time_eq/;

model use_united /flow_balance, travel_time_eq/;

model which_airline /flow_balance, travel_time_eq/;

$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho

loop (iterations,
	delays_at_hubs('ORD') = uniform(0,3*60);
	delays_at_hubs('DTW') = uniform(0,1.5*60);
	delays_at_hubs('MSP') = uniform(0,2*60);
	use_delta.optfile=1;
	use_united.optfile = 1;
	travel_delays(I,J) = cost(I,J) + delays_at_hubs(J); 
	
	x.up('MSN', 'ORD')= 0;
	x.up('MSN', 'DTW') = +Inf;
	x.up('MSN', 'MSP') = +Inf;
	solve use_delta using lp minimizing travel_time;
	delta_travel_times(iterations) = travel_time.l;
	
	x.up('MSN', 'ORD')= +Inf;
	x.up('MSN', 'DTW') = 0;
	x.up('MSN', 'MSP') = 0;

	solve use_united using lp minimizing travel_time;
	united_travel_times(iterations) = travel_time.l;
);	

parameters max_travel_delta, max_travel_united;

max_travel_delta = smax(iterations, delta_travel_times(iterations));
max_travel_united = smax(iterations, united_travel_times(iterations));

display max_travel_delta, max_travel_united;

$ontext
if the maximum travel time in delta (max_travel_delta) is greater than maximum travel time in united(max_travel_united)
then Prof.Wright should take united, otherwise delta. By solving the model for multiple iterations  and choosing  the maximum delay
that results in the iterations, to compare two airlines, I am hoping to account for the uncertanity in the waiting times in the hubs.
$offtext

*4.2 
parameters 
	delta_travel_times_DTW(iterations),
	delta_travel_times_MSP(iterations),
	united_travel_times_ORD(iterations);

loop (iterations,
	delays_at_hubs('ORD') = uniform(0,3*60);
	delays_at_hubs('DTW') = uniform(0,1.5*60);
	delays_at_hubs('MSP') = uniform(0,2*60);
	
	use_delta.optfile=1;
	use_united.optfile = 1;
	travel_delays(I,J) = cost(I,J) + delays_at_hubs(J); 
	
	x.up('MSN', 'ORD')= 0;
	
*   FOR THROUGH DTW
	x.up('MSN', 'DTW') = +Inf;
	x.up('MSN', 'MSP') = 0;
	solve use_delta using lp minimizing travel_time;
	delta_travel_times_DTW(iterations) = travel_time.l;

*   FOR THROUGH MSP
	x.up('MSN', 'DTW') = 0;
	x.up('MSN', 'MSP') = +INF;
	solve use_delta using lp minimizing travel_time;
	delta_travel_times_MSP(iterations) = travel_time.l;
	
*   FOR THROUGH ORD
	x.up('MSN', 'ORD')= +Inf;
	x.up('MSN', 'DTW') = 0;
	x.up('MSN', 'MSP') = 0;

	solve use_united using lp minimizing travel_time;
	united_travel_times_ORD(iterations) = travel_time.l;
);	


parameters 
	max_travel_delta_DTW, 
	max_travel_delta_MSP,
	max_travel_united_ORD;

max_travel_delta_DTW = smax(iterations, delta_travel_times_DTW(iterations));
max_travel_delta_MSP = smax(iterations, delta_travel_times_MSP(iterations));
max_travel_united_ORD = smax(iterations, united_travel_times_ORD(iterations));

display max_travel_delta_DTW, max_travel_delta_MSP, max_travel_united_ORD;

$ontext
		The minimum of max_travel_delta_DTW , max_travel_delta_MSP, max_travel_united_ORD would give us the airline and the corresponding hub
$offtext

*4.3 
delays_at_hubs('ORD') = uniform(0,3*60);
delays_at_hubs('DTW') = uniform(0,1.5*60);
delays_at_hubs('MSP') = uniform(0,2*60);

which_airline.optfile=1;
travel_delays(I,J) = cost(I,J) + delays_at_hubs(J); 
x.up('MSN', 'ORD')= +Inf;
x.up('MSN', 'DTW') = +Inf;
x.up('MSN', 'MSP') = +Inf;

solve which_airline using lp minimizing travel_time;
display x.l;


