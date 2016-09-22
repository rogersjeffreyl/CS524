$title Manufacturing transistors
sets
 grade /defective, grade1 * grade4/ ,
 methods /method1 * method2 /;

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
   grade3          0            0        0        50     50  
   grade4          0            0        0        0      0 ;

variables
  x(methods) ,
  y(methods, grade) "germanium that is refired ";

positive variables
x, y;
y.fx(methods , 'grade4') = 0 ;
free variable cost "cost of germanium processing";
equations
  cost_of_processing "cost of processing germanium",
  number_of_valves_grade4 "number of valves per grade",
  number_of_valves_grade3,
  number_of_valves_grade2,
  number_of_valves_grade1,
  total_refiring_limits,   
  refiring_amount_limit(grade,methods); 	   
cost_of_processing..
  cost =e=  sum(methods, processing_cost(methods) * x(methods)) + refiring_cost * sum((methods, grade), y(methods, grade));
      
number_of_valves_grade4..
 sum(methods,(percentage_yields('grade4', methods)/100 * x(methods)) -y(methods,'grade4')  )+ sum((methods,grade), y(methods, grade)*refiring_yields(grade, 'grade4')/100) =e= 1000;  

number_of_valves_grade3..
 sum(methods,percentage_yields('grade3', methods)/100 * x(methods) -y(methods,'grade3')  )+ sum((methods,grade), y(methods, grade)*refiring_yields(grade, 'grade3')/100) =e= 2000;

number_of_valves_grade2..
 sum(methods,(percentage_yields('grade2', methods)/100 * x(methods)) -y(methods,'grade2')  )+ sum((methods,grade), y(methods, grade)*refiring_yields(grade, 'grade2')/100) =e= 3000;

number_of_valves_grade1..
 sum(methods,(percentage_yields('grade1', methods)/100 * x(methods)) -y(methods,'grade1')  )+ sum((methods,grade), y(methods, grade)*refiring_yields(grade, 'grade1')/100) =e= 3000;

refiring_amount_limit(grade,methods)..
 y(methods, grade) =l= x(methods) * percentage_yields(grade,methods)/100;

total_refiring_limits..
 sum(methods, x(methods))  =l=20000;
model manufacturingtransistors /all/;
solve manufacturingtransistors using lp minimizing cost;

         

 
  


