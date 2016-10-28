$title Generation capacity
set year "years of power demand" /1*5/ ;
set plant "power plants" /p1*p4/ ;
parameter reqCap(year) "in million Kwh" /
           1 80
		   2 100
		   3 120
		   4 140
           5 160/;
set dfields /
           genCap  generating capacity in Million Kwh
           cCost   construction cost in Million $
           opCost  annual operating cost in Million $
/;           
table data(plant,dfields)
          genCap  cCost   opCost
   p1      70      20      1.5
   p2      50      16      0.8
   p3      60      18      1.3
   p4      40      14      0.6 ;

binary variables 
    z(plant,year) "indicating if a pant is operational in a particular year",
    const(plant) "indicator for construction costs";

free variable total_cost;
equations
  total_cost_eq,
  operational_plants_stay_same(plant,year),
  construction_eq(plant,year),
  capacity_eq(year);
total_cost_eq..
  total_cost =e= sum ((plant,year),z(plant,year)*data(plant,'opCost')) + sum(plant, const(plant)*data(plant,'cCost'));
capacity_eq(year)..
  sum((plant), z(plant,year)*data(plant,'genCap')) =g= reqCap(year);
construction_eq(plant,year)..
  const(plant) =g= z(plant,year) ;
operational_plants_stay_same(plant,year)..
  z(plant,year-1) =l= 5*z(plant, year);
model gen_capacity_1 /total_cost_eq, construction_eq,operational_plants_stay_same, capacity_eq/;
solve  gen_capacity_1 using mip minimizing total_cost;
set action /reopen,shutdown/;
table costs(plant,action) in Million $
      reopen shutdown
   p1   1.9   1.7
   p2   1.5   1.2
   p3   1.6   1.3
   p4   1.1   0.8 ;

binary variables
 reopen(plant,year),
 shutdown(plant, year),
 inop(plant, year);

equations
  total_cost_with_shut_reopen,
  shutdown_eq(plant,year),
  capacity_new_eq(year),
  reopen_eq(plant,year);

parameter
   initial(plant)
   / p1  1
     p2  1
     p3  1
     p4  1
             /;
total_cost_with_shut_reopen..
 total_cost =e= sum((plant, year), costs(plant,'shutdown')*shutdown(plant, year))
                + sum((plant, year), costs(plant,'reopen')*reopen(plant, year))   
                + sum((plant, year), inop(plant, year)*data(plant,'opCost'))
alias (year,year1);
reopen_eq(plant, year)..
  inop(plant, year) - inop(plant, year - 1) - initial(plant)$(ord(year) = 1) =l= reopen(plant,year);
* inop(plant,year-1)-inop(plant,year)+initial(plant)$(ord(year)=1)+reopen(plant,year) =g=0;
shutdown_eq(plant,year)..
  inop(plant, year - 1) + initial(plant)$(ord(year) = 1) - inop(plant, year) =l= shutdown(plant, year);
*  inop(plant,year)-inop(plant,year-1)- initial(plant)$(ord(year)=1)+shutdown(plant,year) =g=0;
capacity_new_eq(year)..
  sum((plant), inop(plant,year)*data(plant,'genCap')) =g= reqCap(year);
model gen_capacity_2 /total_cost_with_shut_reopen,shutdown_eq,reopen_eq, capacity_new_eq/;
solve  gen_capacity_2 using mip minimizing total_cost;   	 	
display inop.L; 
display reopen.L;
display shutdown.L;
*4.3

initial('p1') = 0;
initial('p2') = 0;

solve gen_capacity_2 using mip minimizing total_cost;
display inop.L; 
display reopen.L;
display shutdown.L;
