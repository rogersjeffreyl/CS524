$title Single Machine Schedling
scalar total_memory_available /1000/;
set work_orders_all /a,b,c,da,db,dc,d,dd/;
set work_orders(work_orders_all) /a,b,c,da,db,dc/;
set k 'position' / p1*p8 /;
alias (work_orders_all,I,J);
scalar total_task_duration /12/;
set time /1*12/;
parameter duration(work_orders_all)
		/
			a   2,
			b	2,
			c   2,
			d   2,
			da   1,
			db   1,
			dc   1,
			dd   1 /;

parameter memory_consumption(work_orders_all)
		/
			a   400,
			b	600,
			c   800,
			d   800,
			da  -400,
			db  -600,
			dc  -800, 
			dd   -800/;

set pred(i,j) 
		/
			(a,b). c,
			a.b,
			a.da,
			b.db,
			c.dc,
			d.dd		/;

free variable memory_footprint;
sos1 variable rank(j,k) "job j has position k";

positive variable 
	start_act(K) "time activity of rank k starts",
	start(I) "time work order I starts",
	comp(K) "completion time of job in position k";
equations
	memory_footprint_objective,
	op_precedence_eq(I,J),
*	one_workorder_active_constraint_1(work_orders_all),
*	one_workorder_active_constraint_2(time),
	oneInPosition(k),
  	oneRankPer(j),
  	precedence(k),
  	memconsumption(J)
*  	defstart(k),
  	defcomp(k);

*	start_time_bound_eq(J);


start_act.up(K) = total_task_duration; 
oneInPosition(k)..
  sum(j,rank(j,k)) =e= 1;

oneRankPer(j)..
  sum(k,rank(j,k)) =e= 1;

defcomp(k)..
  comp(k) =e= start_act(k) + sum(j,duration(j)*rank(j,k));

$ontext  
op_precedence_eq(I,J)$pred(I,J)..
    start(J) =g= start(I) + duration(I);
$offtext

op_precedence_eq(I,J)$pred(I,J)..
    sum(k,rank(I,k)) =l= sum(k,rank(J,k));

memory_footprint_objective..

	memory_footprint =e= sum(K, (total_task_duration-start_act(K))*  (sum(J, rank(J,k)))       );

$ontext
start_time_bound_eq(J)..
	start(J) =l= total_task_duration - duration(J);
$offtext

$ontext
one_workorder_active_constraint_1(J)..
	sum (time$(ord(time) ge start.L(J)),active(J,time)) =e= duration(J);

one_workorder_active_constraint_2(time)..
	sum (J, active(J,time)) =l= 1;
$offtext

$ontext
defstart(k)..
  start_act(k) =g= sum(j,start(j)*rank(j,k));
$offtext

precedence(k)$(ord(k) lt card(k))..
  start_act(k+1) =g= comp(k);

model scheduling /all/;
solve scheduling using  mip minimizing  memory_footprint;
display memory_footprint.L

display rank.L


