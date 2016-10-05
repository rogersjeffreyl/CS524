$if not set T $set T 10
$if not set n $set n 3
$if not set m $set m 5
$eval Tp1 %T%+1
set t /1*%Tp1%/, s(t) /1*%T%/;
set i products /1*%m%/, j processing type /1*%n%/;
parameter c(i), h(i,j), capH(j,s),
           e(i,t), d(t), a(t), capD(t),
           p(i,t), q(i);
option seed = 100;
c(i) = 1; h(i,j) = 0.1; capH(j,s) = uniform(6,8);
e(i,t) = 0.2; d(t) = 1; a(t) = 10; capD(t) = 5*d(t);
p(i,t) = uniform(3,10); q(i) = 0.1;

positive variables
   x(i,t) " production at time  T",
   y(i,t) " quantity of product sold at time t",
   inv(i,t)   " Ending inventory in period T"; 
free variable profit;  

equations
   profit_equation "total profit obtained ",
   processing_time(j,s) "total time taken to process the articles  at time t for method j,"
   inventory_eq(i,t) "inventory for a partocular product",
   quantity_sold(i,t)   "amount sold at time T should be at max amount left in the inventory",
   inventory_at_t_1(i,t) "All items should be sold at end of time t+1",
   no_production_in_t_1(i,t) "no items should be produced in t+1";

profit_equation..
   profit =e= sum((i,t), y(i,t)*p(i,t) - x(i,t)*c(i) -inv(i,t)*q(i)  );

processing_time(j,s)..
   sum(i, h(i,j)*x(i,s) ) =l= capH(j,s);
*What about values for I0
inventory_eq(i,t)..
  inv(i,t) =e=  x(i,t)-y(i,t)+inv(i,t-1); 
quantity_sold(i,t)..
   y(i,t) =l= inv(i, t-1);

inventory_at_t_1(i,t)..
  inv(i, t )$(ord(t) =card(t))  =e= 0;

no_production_in_t_1(i,t) ..  
  x(i,t)$(ord(t) =card(t)) =e= 0;
display s;
display capH;
