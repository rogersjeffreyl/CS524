$title Multi Period Processing
$if not set T $set T 10
$if not set n $set n 3
$if not set m $set m 5
$eval Tp1 %T%+1
set t /1*%Tp1%/, s(t) /1*%T%/;
set i products /1*%m%/, j processing type /1*%n%/;
parameter
   c(i) "Cost of manufacturing product",
   h(i,j) " time taken to process product i through method j",
   capH(j,s) " cap on the time spent for each processing type for each production period",
   e(i,t) " marketing time for each product", 
   d(t) "labor rate for marketing", 
   a(t) " time limit for normal labor rate", 
   capD(t) " overtime labor rate ",
   p(i,t) " selling price per product per production period", 
   q(i) " storage cost for per product";
option seed = 100;
c(i) = 1; h(i,j) = 0.1; capH(j,s) = uniform(6,8);
e(i,t) = 0.2; d(t) = 1; a(t) = 10; capD(t) = 5*d(t);
p(i,t) = uniform(3,10); q(i) = 0.1;

positive variables
   x(i,t) " production at time  T",
   y(i,t) " quantity of product sold at time t",
   disp(i,t) "quantity of product i disposed off at time t",
   inv(i,t)   " Ending inventory in period T",
   normal_marketing_hrs(t) "normal marketing hours",
   overtime_marketing_hrs(t) "over time marketing hours";
free variable profit;  


equations
   profit_equation "total profit obtained ",
   processing_time(j,s) "total time taken to process the articles  at time t for method j,"
   inventory_eq(i,t) "inventory for a particular product",
   quantity_sold_disposed(i,t)   "amount sold at time T should be at max amount left in the inventory",
   inventory_at_t_1(i,t) "All items should be sold at end of time t+1",
   normal_marketing_hours_cap(t) "cap on the normal marketing hours",
   total_marketing_hours_limit(t) "limit on the total marketing hours",
   no_production_in_t_1(i,t) "no items should be produced in t+1";

profit_equation..
   profit =e= sum((i,t), y(i,t) * p(i,t) - x(i,t) * c(i) - inv(i,t) * q(i)) - sum(t, normal_marketing_hrs(t) * d(t) + overtime_marketing_hrs(t) * capD(t) );

processing_time(j,s)..
   sum(i, h(i,j)*x(i,s) ) =l= capH(j,s);

*What about values for I0
inventory_eq(i,t)..
  inv(i,t) =e=  x(i,t-1)-y(i,t)+inv(i,t-1) - disp(i,t); 

quantity_sold_disposed(i,t)..
   y(i,t) + disp(i,t) =l= inv(i, t-1)+x(i,t-1);

inventory_at_t_1(i,t)..
  inv(i, t )$(ord(t) =card(t))  =e= 0;

no_production_in_t_1(i,t)..  
  x(i,t)$(ord(t) =card(t)) =e= 0;

normal_marketing_hours_cap(t)..
  normal_marketing_hrs(t) =l= a(t);	

total_marketing_hours_limit(t)..
  normal_marketing_hrs(t) + overtime_marketing_hrs(t) =e=  sum(i, y(i,t)*e(i,t)); 

model multi_period_processing /all/;
solve multi_period_processing using lp maximizing profit;
display profit.L;

