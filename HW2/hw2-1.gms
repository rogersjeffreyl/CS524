$ondollar
$title hw2-1 (LP)
$Ondotl offsymxref offsymlist offuelxref offuellist offupper
option limrow = 0, limcol = 0;

set valve_types /large, medium, small/;
set suppliers /1*3/;

table suppliers_valve_type_percentage(suppliers, valve_types) "percentage of valve type per supplier"
         large  medium  small
     
     1    40     40      20      
     2    30     35      35
     3    20     20      60   ;
free variable acquire "cost of purchasing the pig valves";
parameters 
   cost(suppliers)
        / 1   5
          2   4
          3   3 /,
   valve_type_count(valve_types)
      /  large  500
         medium 300
         small  300  /; 
         
variables
 num_valves_per_supplier(suppliers, valve_types) "number of valves purchased from each supplier";

equations
  valve_limit(suppliers),
  per_month_valve_purchase(valve_types),
  valve_percentage_per_supplier(suppliers,  valve_types),  
  cost_of_valve_purchase ; 

variables 
valves_per_supplier(suppliers) = sum (valve_types , num_valves_per_supplier(suppliers, valve_types));

valve_limit(suppliers)..
   sum(valve_types, num_valves_per_supplier(suppliers, valve_types)) =l= 700; 

per_month_valve_purchase(valve_types)..
  sum(suppliers, num_valves_per_supplier(suppliers, valve_types)) =l= valve_type_count (valve_types);

valve_percentage_per_supplier(suppliers, valve_types)..
  num_valves_per_supplier(suppliers ,valve_types) =e= suppliers_valve_type_percentage(suppliers, valve_types)/100  * valves_per_supplier(suppliers);

cost_of_valve_purchase..
  acquire  =e=  sum( (suppliers,valve_types),num_valves_per_supplier(suppliers, valve_types)  * cost(suppliers) );

model hw2_1 /all/;
solve hw2_1 using lp minimizing acquire; 
