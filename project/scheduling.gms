$title Single Machine Schedling
scalar total_memory_available /1000/;
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

scalar total_task_duration /3072/;
set time /1*3072/;
alias (time t,t1);
free variable memory_footprint;
binary variables 
	wo_scheduled(t,I)
	wo_ended(t,I)
	wo_active(t,I)
	wo_mem_active(t,I);

positive variable 
	
	start(I) "time work order I starts",	
	end(I) "time work order I ends";
	
equations
	memory_footprint_objective,
	wo_precedence_eq(I,J),
	wo_end_time_eq(I),
	only_one_can_be_scheduled(t),
	a_wo_can_be_scheduled_only_once(I),
	a_wo_can_end_only_once(I),
	wo_pipelining_constraint(O1,O2),
	one_job_active(t),
	start_less_end(I),
	wo_scheduled_at(I),
	wo_ended_at(I),
	wo_active_eq(I,T),
	wo_mem_active_constraint(T),
	wo_mem_active_eq(I,T);
*	start_time_bound_eq(J)

*and pipelining(o1,o2)
*sum ((J,T)$(map(O2,J)),wo_ended(T,J)) == sum ((I,T)$(map(O1,I)),wo_ended(T,I)) ;
wo_pipelining_constraint(O1,O2)$(pipelining(O1,O2))..
	sum ((I,T)$(map(O1,I)),wo_ended(T,I))-sum ((J,T)$(map(O2,J)),wo_ended(T,J)) =g=0;

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

memory_footprint_objective..
	memory_footprint =e= sum(I,memory_consumption(I)*(total_task_duration-sum(T,ord(t)*wo_scheduled(t,I))) );
		
model scheduling /all/;
scheduling.optcr=0.30;	
solve scheduling using  mip minimizing  memory_footprint;
display memory_footprint.L
display start.L
display wo_scheduled.L