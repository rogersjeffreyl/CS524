$title Manufacturing transistors
sets
 grade "grades of germanium" /defective, grade1 * grade4/ ,
 methods "methods of melting germanium" /method1 * method2 /,
 refiring(grade) "grades of germanium used in the refiring process" /defective, grade1 * grade3/; 
parameter processing_cost(methods) "processing cost per method"
   / method1 50
     method2 70 /;

scalar refiring_cost / 25 /;

table percentage_yields(grade,methods) "yeilds of germanium of different grades from each method"
                 method1      method2
   defective      30           20
   grade1         30           20
   grade2         20           25
   grade3         15           20
   grade4         5            15     ; 


table refiring_yields(refiring, grade) "percentage of germanium obtained from each grade after refiring "
                  defective   grade1    grade2  grade3  grade4
   defective       30           25       15       20     10
   grade1          0            30       30       20     20
   grade2          0            0        40       30     30
   grade3          0            0        0        50     50 ;  

variables
  produced_quantity(methods) "total amount of germanium obtained in the initial stage before refiring",
  refired_quantity(methods, refiring) "germanium that is refired per grade per method ";

positive variables
produced_quantity, refired_quantity;
*y.fproduced_quantity(methods , 'grade4') = 0 ;
free variable cost "cost of germanium processing";
equations
  cost_of_processing "cost of processing germanium",
  number_of_transistors_grade4 "demand of number of grade4 transistors",
  number_of_transistors_grade3 "demand of number of grade3 transistors ",
  number_of_transistors_grade2 "demand of number of grade2 transistors",
  number_of_transistors_grade1 "demand on number of grade1 transistors",
  total_firing_limits "limit on amount of germanium that can be fired and refired",   
  refiring_amount_limit(refiring,methods) "maproduced_quantityimum amount of germanium produced using each method that can be refired from each grade "; 	   
cost_of_processing..
  cost =e=  sum(methods, processing_cost(methods) * produced_quantity(methods)) + refiring_cost * sum((methods, refiring), refired_quantity(methods, refiring));
      
number_of_transistors_grade4..
 sum(methods,(percentage_yields('grade4', methods)/100 * produced_quantity(methods)) )+ sum((methods,refiring), refired_quantity(methods, refiring)*refiring_yields(refiring, 'grade4')/100) =g= 1000;  

number_of_transistors_grade3..
 sum(methods,percentage_yields('grade3', methods)/100 * produced_quantity(methods) -refired_quantity(methods,'grade3')  )+ sum((methods,refiring), refired_quantity(methods, refiring)*refiring_yields(refiring, 'grade3')/100) =g= 2000;

number_of_transistors_grade2..
 sum(methods,(percentage_yields('grade2', methods)/100 * produced_quantity(methods)) -refired_quantity(methods,'grade2')  )+ sum((methods,refiring), refired_quantity(methods, refiring)*refiring_yields(refiring, 'grade2')/100) =g= 3000;

number_of_transistors_grade1..
 sum(methods,(percentage_yields('grade1', methods)/100 * produced_quantity(methods)) -refired_quantity(methods,'grade1')  )+ sum((methods,refiring), refired_quantity(methods, refiring)*refiring_yields(refiring, 'grade1')/100) =g= 3000;

refiring_amount_limit(refiring,methods)..
 refired_quantity(methods, refiring) =l= produced_quantity(methods) * percentage_yields(refiring,methods)/100;

total_firing_limits..
 sum(methods, produced_quantity(methods))  =l=20000;

model manufacturingtransistors /all/;
solve manufacturingtransistors using lp minimizing cost;

         
display produced_quantity.l;
display refired_quantity.l;
display cost.l;
display manufacturingtransistors.modelstat,manufacturingtransistors.solvestat,manufacturingtransistors.objval,produced_quantity.l,refired_quantity.l;
  

