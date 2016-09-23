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
   cost(suppliers)  "cost of valve manufacture per supplier"
        / 1   5
          2   4
          3   3 /,
   valve_type_count(valve_types)  "count of required valve types "
      /  large  500
         medium 300
         small  300  /; 
         
variables
 num_valves_per_supplier(suppliers) "number of valves purchased from each supplier";

num_valves_per_supplier.up(suppliers)=700;
equations
  cost_of_valve_acquisition "cost of acquiring the valves",
  count_per_valve_type(valve_types);  	


cost_of_valve_acquisition..
  acquire =e= sum(suppliers, cost(suppliers) * num_valves_per_supplier(suppliers));
count_per_valve_type(valve_types)..
  sum(suppliers, suppliers_valve_type_percentage(suppliers, valve_types)/100 * num_valves_per_supplier(suppliers)) =g= valve_type_count(valve_types);   

model hw2_1 /all/;
solve hw2_1 using lp minimizing acquire; 
display num_valves_per_supplier.l;
display acquire.l;
