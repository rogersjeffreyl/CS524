$title Manufacturing transistors
sets
 grade /defective, grade1 * grade4/ ,
 methods /method1 * method2 /;

set refiring_grade(grade) /defective, grade1 * grade3/; 
set required_grade(grade) /grade1 * grade4/;
parameter processing_cost(methods) "processing cost per method"
   / method1 50
     method2 70 /;
scalar refiring_cost / 25 /;
table percentage_yields(grade,methods)
                 method1      method2
   defective      30           20
   grade1         30           20
   grade2         20           25
   grade3         15           20
   grade4         5            15     ; 


table refiring_yields(grade, grade)
                  defective   grade1    grade2  grade3  grade4
   defective       30           25       15       20     10
   grade1          0            30       30       20     20
   grade2          0            0        40       30     30
   grade3          0            0        0        50     50  ;
   grade4          0            0        0        0      0
     
variables
  x(methods) ,
  y(methods, refiring) "germanium that is refired ";

free variable cost "cost of germanium processing";
equations
  cost_of_processing "cost of processing germanium";
  number_of_valves (grade) "number of valves per grade";   

cost_of_processing..
  cost =e=  sum(methods, processing_cost(methods) * x(methods)) + refiring_cost * sum((methods, refiring), y(methods, refiring));
      
number_of_valves(grade)..
 sum((methods, refiring), percentage_yields(methods,grade)/100 * x(methods)-y(methods,refiring)) 
         

 
  


