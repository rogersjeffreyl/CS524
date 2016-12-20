$title Single Machine Schedling
scalar total_memory_available "total memory available in the system for query execution "/20000/;
Option Limrow=0;
* Loading the data
$GDXIN workorder.gdx
       sets 
       		workorders;       		       		
$LOAD workorders
$GDXIN
$GDXIN operator.gdx
       sets 
       		operators;       		       		
$LOAD operators
$GDXIN

alias (workorders,I,J);
alias (operators,o1,o2);

$GDXIN duration.gdx
       parameters
       		duration(workorders);
$LOAD duration
$GDXIN

$GDXIN memory_consumption.gdx
       parameters
       		memory_consumption(workorders);
$LOAD memory_consumption
$GDXIN

$GDXIN pipelining.gdx
       sets
       		pipelining(o1,o2);
$LOAD pipelining
$GDXIN

$GDXIN pred.gdx
       sets
       		pred(I,J);
$LOAD pred
$GDXIN

$GDXIN map.gdx
       sets
       		map(operators,workorders);
$LOAD map
$GDXIN

scalar total_task_duration "Time limit for query execution" /1000/ ;
set time "Set for discrete time units" /1*1000/ ;
alias (time t,t1);
free variable memory_footprint;
binary variables 
	wo_scheduled(t,I)  "binary variable  indicating work order t is scheduled at time I"
	wo_ended(t,I) "binary variable indicating work order I has ended at time t"
	wo_active(t,I) "binary variable indicating work order I has ended at time t"
	wo_mem_active(t,I) "binary variable indicating work order I's memory is active at time T";

option pred:1:0:2;
display pred;
option memory_consumption:1:0:2;
display memory_consumption;

positive variable 
	
	start(I) "time work order I starts",
	z(operators) "max time for work order of operator I to complete",
	end(I) "time work order I ends";
	
equations
	memory_footprint_objective "objective equation representing tradeoff between memory and time optimization",
	wo_precedence_eq(I,J) "precedence relationships between work orders",
	wo_end_time_eq(I) "precedence relationships between work orders",
	only_one_can_be_scheduled(t) "one one work order can be scheduled at a time instance",
	a_wo_can_be_scheduled_only_once(I) "a  work order cannot be schedule multiple times",
	a_wo_can_end_only_once(I) "a work order can end only once(may be a redundant constraint)",
	wo_pipelining_constraint(O1,O2,T1) "if operators O1 and O2 are pipelining, then at any given time instant T1 the number of work orders of O1 that have completed should be lesser than number of work orders of O2",
	wo_pipelining_constraint_1(O1,O2) "preventing invalid schedules that arise due to the first constraint",
	one_job_active(t) "only one job is active at a time in a single core system",
	start_less_end(I) ,
	wo_scheduled_at(I) "to set the indicator wo_scheduled",
	wo_ended_at(I) "to set the indicator wo_ended",
	wo_active_eq(I,T) "to set the indicator wo_active",
	wo_mem_active_constraint(T) "the total memory occupied by operators should be lesser than the total available memory",
	max_operator_completion_time(O1,I) 
	wo_mem_active_eq(I,T) "to set the indicator wo_mem_active";


*and pipelining(o1,o2)
*sum ((I,T)$(map(O1,I) and ord(T)<=ord(T1)),wo_ended(T,I))-sum ((J,T)$(map(O2,J) and ord(T)<=ord(T1)),wo_ended(T,J)) =g=0;
*sum ((J,T)$(map(O2,J)),wo_ended(T,J)) == sum ((I,T)$(map(O1,I)),wo_ended(T,I)) ;

wo_pipelining_constraint(O1,O2,T1)$(pipelining(O1,O2))..
	sum ((I,T)$(map(O1,I) and ord(T)<=ord(T1)),wo_ended(T,I)) =g= sum ((J,T)$(map(O2,J) and ord(T)<=ord(T1)),wo_scheduled(T,J));

*sum ((I,T)$(map(O1,I)),ord(T)*wo_ended(T,I)) =l= sum ((J,T)$(map(O2,J)),ord(T)*wo_ended(T,J));
*Z(O2) =g= Z(O1) ;
wo_pipelining_constraint_1(O1,O2)$(pipelining(O1,O2))..
	sum ((I,T)$(map(O1,I)),ord(T)*wo_ended(T,I)) =l= sum ((J,T)$(map(O2,J)),ord(T)*wo_ended(T,J));

max_operator_completion_time(O1,I)$(map(O1,I))..
	z(O1) =g= end(I);

wo_mem_active_constraint(T)..
	sum(I,memory_consumption(I)*wo_mem_active(T,I)) =l= total_memory_available;

wo_mem_active_eq(I,T)..
	wo_mem_active(T,I) =e= wo_mem_active(T-1,I)+wo_scheduled(t,I);

one_job_active(t)..
	sum(I,wo_active(t,I)) =l=1;

wo_active_eq(I,T)..
	wo_active(T,I) =e= wo_active(T-1,I)+wo_scheduled(t,I)-wo_ended(t,I);

wo_precedence_eq(I,J)$pred(I,J)..
    start(J) =g= start(I) + duration(I);

wo_end_time_eq(I)..
	end(I) =e= start(I) + duration(I);

wo_scheduled_at(I)..
	sum(t,ord(t)*wo_scheduled(t,I)) =e= start(I);

wo_ended_at(I)..
	sum(t,ord(t)*wo_ended(t,I)) =e= end(I);	

only_one_can_be_scheduled(t)..
	sum(I,wo_scheduled(t,I)) =l= 1;

a_wo_can_be_scheduled_only_once(I)..
	sum(t,wo_scheduled(t,I)) =e= 1;

a_wo_can_end_only_once(I)..
	sum(t,wo_ended(t,I)) =e= 1;	

start_less_end(I)..
	start(I) =l=end(I);

*memory_footprint =e= sum(I,memory_consumption(I)*(total_task_duration-sum(T,ord(t)*wo_scheduled(t,I))) );

memory_footprint_objective..
	memory_footprint =e= sum(I,memory_consumption(I)*(total_task_duration-start(I)))+ sum(I,start(I))
						;
		
model scheduling 
	/memory_footprint_objective,
	wo_precedence_eq,
	wo_end_time_eq,
	only_one_can_be_scheduled,
	a_wo_can_be_scheduled_only_once,
	a_wo_can_end_only_once,
	wo_pipelining_constraint,
	wo_pipelining_constraint_1,
	one_job_active,
	start_less_end,
	wo_scheduled_at,
	wo_ended_at,
	wo_active_eq,
	max_operator_completion_time,
	wo_mem_active_constraint,
	wo_mem_active_eq/;

scheduling.optcr=0.02;	
Option Reslim=10000
solve scheduling using  rmip minimizing  memory_footprint;
option memory_footprint:1:0:2;
display memory_footprint.L

option start:1:0:2;
display start.L

option wo_scheduled:1:0:2;
display wo_scheduled.L

option end:1:0:2;
display end.L

scalar mem_cons /0/;
mem_cons = memory_footprint.L -sum(I,start.L(I));
display mem_cons;