$title Single Machine Schedling
scalar total_memory_available /1000/;
set work_orders_all /a,b,c,da,db,dc,d,dd/;
set work_orders(work_orders_all) /a,b,c,da,db,dc/;
set k 'position' / p1*p8 /;
alias (work_orders_all,I,J);
scalar total_task_duration /14/;
set time /1*14/;
alias (time t,t1);
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

binary variables 
	wo_scheduled(t,I)
	wo_ended(t,I)
	wo_active(t,I)
	wo_mem_active(t,I);

positive variable 
	
	start(I) "time work order I starts",
	dummy(I),
	end(I) "time work order I ends";
	
equations
	memory_footprint_objective,
	wo_precedence_eq(I,J),
	wo_end_time_eq(I),
	only_one_can_be_scheduled(t),
	a_wo_can_be_scheduled_only_once(I),
	a_wo_can_end_only_once(I),
	one_job_active(t),
	start_less_end(I),
	wo_scheduled_at(I),
	wo_ended_at(I),
	wo_active_eq(I,T),
	wo_mem_active_constraint(T),
	wo_mem_active_eq(I,T);
*	start_time_bound_eq(J)

sum (wo_ended(t,I)
 
wo_mem_active_constraint(T)..
	sum(I,memory_consumption(I)*wo_mem_active(T,I)) =l=total_memory_available;

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
scheduling.optcr=0;	
solve scheduling using  mip minimizing  memory_footprint;
display memory_footprint.L
display start.L
display wo_scheduled.L
display wo_ended.L
display wo_active.L
display wo_mem_active.L



