option limrow = 0, limcol = 0;
set P "products" /"salsa", "ketchup", "tomato-paste"/ ;
set R "raw materials" /"tomatoes", "sugar", "labour", "spices"/ ;
set t "phases"/1*3/;
set scenario "scenarios"/1*4/;
set s(scenario) "alias for scenarios" /1*4/;
table resources(p,r) "resources"
                "tomatoes"    "sugar"    "labour"    "spices"
"salsa"         0.5           1.0        1.0         3.0
"ketchup"       0.5           0.5        0.8         1.0
"tomato-paste"  1.0           0          0.5         0.25;
parameter limit(R) "resource limit"
/"labour" 200, "tomatoes" 250, "sugar" 300, "spices" 100/;

parameter extra_resource_cost(R) "cost"
/"labour" 2, "tomatoes" 0.5, "sugar" 1.0, "spices" 1.0/;
 
table prod_cost(P, t)
                1    2    3
"tomato-paste"  1.0  1.1  1.2
"ketchup"       1.5  1.75 2.0
"salsa"         2.5  2.75 3.0;
 
parameter storage_cost(P)
/"tomato-paste" 0.5, "ketchup" 0.25, "salsa" 0.2/;
 
parameter penalty(P)
/"tomato-paste" 4.0, "ketchup" 6.0, "salsa" 12/;
 
table scenarios(scenario,t,p)
      "tomato-paste"    "ketchup"    "salsa"
1.1    100              30           5
1.2    100              30           5
1.3    100              30           5
2.1    100              30           5
2.2    100              30           5
2.3    200              40           20
3.1    100              30           5
3.2    200              40           20
3.3    100              30           5
4.1    100              30           5
4.2    200              40           20
4.3    200              40           20;
 
parameter ps(scenario)
/1 0.15, 2 0.4, 3 0.15, 4 0.3/;
positive variables 
	products(t, P)
	raw_materials(t, R), 
	extra_raw_materials(t, R),
	inventory(scenario, t, P), 
	products_sold(scenario,t,p);
 
free variables cost;
raw_materials.up(t,R) = limit(R);
products_sold.up(s,t,P) = scenarios(s,t,P);
  
equations
        objective
        resource_eq
        inventory_eq(scenario,t,P);
 
objective..
	cost =e= sum( (t, R), 
				 extra_raw_materials(t,R) * extra_resource_cost(R)) + sum((t, P), products(t,P)*prod_cost(P,t)) +
               sum(s, ps(s) * sum((t, p), 
                     			(scenarios(s,t,p) - products_sold(s,t,p)) * penalty(p) + inventory(s,t,p)*storage_cost(p)));
resource_eq(t,R)..
	sum(P, resources(P,R) * products(t,P)) =e= raw_materials(t,R) + extra_raw_materials(t,R);
inventory_eq(s,t,P)..
	inventory(s,t,P) + products_sold(s,t,p) =e= inventory(s,t-1,P) + products(t,P);
model tomato /all/;
solve tomato using lp minimizing cost;
 display cost.l;
scalar zs 'expected solutions' /0/;
zs = cost.l ;

parameter scenario_probabilities(scenario)
/1 0.15,
 2 0.4, 
 3 0.15, 
 4 0.3/;
scalar evpi 'expected value of perfect information' /0/;
ps(scenario) = 0;
s(scenario) = no;
loop(scenario,
  s(scenario) = yes; ps(scenario) = 1;
  solve tomato using lp minimizing cost;
  evpi = evpi + scenario_probabilities(scenario)*cost.l;
  s(scenario) = no; ps(scenario) = 0;
);

evpi =   zs - evpi;

parameter 
  average_demand(t, P),
  average_products(t, P),
  average_raw_materials(t, r),
  average_extra_materials(t, r);

positive variable
  products_sold_mean(t,p),
  inventory_mean(t, P);

s(scenario) = yes;

free variable cost_mean;
average_demand(t,P) = sum(s, scenarios(s,t,P))/4;
raw_materials.up(t,R) = limit(R);
products_sold_mean.up(t,p) = average_demand(t,P);
equations
        objective_mean
        resource_eq_mean(t,R)
        inventory_eq_mean(t,P);

objective_mean..
  cost_mean =e= sum( (t, R), 
         extra_raw_materials(t,R) * extra_resource_cost(R)) + sum((t, P), products(t,P)*prod_cost(P,t)) +
               sum((t, p), 
                          (average_demand(t,P) - products_sold_mean(t,p)) * penalty(p) + inventory_mean(t,p)*storage_cost(p));

resource_eq_mean(t,R)..
  sum(P, resources(P,R) * products(t,P)) =e= raw_materials(t,R) + extra_raw_materials(t,R);

inventory_eq_mean(t,P)..
  inventory_mean(t,P) + products_sold_mean(t,p) =e= inventory_mean(t-1,P) + products(t,P);

model tomato_mean /
objective_mean
resource_eq_mean
inventory_eq_mean
/;
scalar vss /0/;
ps(scenario) = scenario_probabilities(scenario);
solve tomato_mean minimizing cost_mean using lp;

average_products(t,p) =  products.l(t,P);
average_raw_materials(t, r) = raw_materials.l(t,r);
average_extra_materials(t, r) = extra_raw_materials.l(t,R);

products.fx(t,p)=average_products(t,p);
raw_materials.fx(t,r)=average_raw_materials(t,r);
extra_raw_materials.fx(t,r) = average_extra_materials(t, r);

solve tomato minimizing cost using lp;

display cost.l;
vss =  zs-cost.l ;
display zs;
display vss;










