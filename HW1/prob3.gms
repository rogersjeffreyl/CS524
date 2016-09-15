$ondollar
$title HW1 prob3
$offsymxref offsymlist offuelxref offuellist offupper
option limrow = 0, limcol = 0;

sets
I "chem element" /C, Cu, Mn/,
J "raw material" /"Iron Alloy 1", "Iron Alloy 2", "Iron Alloy 3", "Copper 1", "Copper 2", "Aluminium 1", "Aluminium 2"/; 

Table raw_material_grades(J , I) "Grades for the different raw materials"
                             C    Cu   Mn
            "Iron Alloy 1"   2.5  0    1.3
            "Iron Alloy 2"   3    0    0.8
            "Iron Alloy 3"   0    0.3  0
            "Copper 1"       0    90   0
            "Copper 2"       0    96   4
            "Aluminium 1"    0    0.4  1.2
            "Aluminium 2"    0    0.6  0       ;

parameters

max_grade(I)     Maximum grade per element for the alloy
           / C      3
             Cu     0.6
             Mn     1.65 / ,

min_grade(I)     Minimum grade per element for the alloy
           / C    2
             Cu   0.4
             Mn   1.2 / ,

availability(J) "Availability of each raw material (t)"
          / "Iron Alloy 1" 400 
            "Iron Alloy 2" 300
            "Iron Alloy 3" 600
            "Copper 1"     500
            "Copper 2"     200
            "Aluminium 1"  300
            "Aluminium 2"  250 /,

cost(J) "Cost of each raw material ($/t)"
          / "Iron alloy 1" 200
            "Iron Alloy 2" 250
            "Iron Alloy 3" 150
            "Copper 1"     220
            "Copper 2"     240
            "Aluminium 1"  200
            "Aluminium 2"  165 /;
parameter
pct(I) "Actual Concenteration"
        /set.I 0/; 

free variable production_cost "production cost for the alloy";

variables
x(J) "variables corresponding to the allocation for each type of raw material for the alloy";

positive variable 
x;

equations
Allocation(J) "Allocation of the raw materials for the alloy",
Total_Allocation "The total allocation of raw materials should amount to 500 ",
Min_Grade_Requirements(I) "The minimum grade of the component in the alloy ",
Max_Grade_Requirements(I) "The maximum grade of the component in the alloy ",
Objective     "Minimize the production cost";

Allocation(J)..
x(J) =l= availability(J);

Total_Allocation..
sum(J, X(J)) =e= 500;

Min_Grade_Requirements(I)..
sum(J, X(J) * raw_material_grades(J,I)) / 500 =g= min_grade(I); 

Max_Grade_Requirements(I)..
sum(J, X(J) * raw_material_grades(J,I)) / 500 =l= max_grade(I);

Objective..
production_cost =e= sum(J, x(J) * cost(J)); 

model AlloyBlending  /all/ ;

solve AlloyBlending  using lp minimizing production_cost;
pct(I) = sum(J, x.l(J) * raw_material_grades(J,I)) / 500;
display pct;
