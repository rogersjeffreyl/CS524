$ondollar
$title HW1 prob4
$offsymxref offsymlist offuelxref offuellist offupper
option limrow = 0, limcol = 0;

sets
I areas /1*4/,
J wood /pine, spruce, walnut, hardwd/; 

Table expected_annual_yield(I , J) "Expected annual yield (m3/ka)"
         pine       spruce      walnut        hardwd
      1   17           14          10            9
      2   15           16          12           11
      3   13           12          14            8
      4   10           11           8            6    ;

Table expected_annual_revenue(I , J) "Expected annual revenue (money units per ka)"
         pine       spruce      walnut        hardwd
      1   16           12          20           18
      2   14           13          24           20
      3   17           10          28           20
      4   12           11          18           17    ;

parameters

max_area_avl(I)     Maximum area available
           / 1       1500
             2       1700
             3       900
             4       600 / ,

min_req_yield(J)     Minimum required yield
         / pine       22500
           spruce     9000
           walnut     4800
           hardwd     3500 /;

free variable annual_revenue "expected annual revenue";

variables
x(I , J) "variables corresponding to the allocation for each type of wood J in site I ";

positive variable 
x;

equations
Total_Area(I) "the area allocated in each site must be atmost the area of that site ",
Min_Yield(J) "the yield of a wood type should meet the minimum req yield",
Revenue  "the total profit obtained from planting different trees in different areas";

Total_Area(I)..
sum(J , X(I, J)) =l= max_area_avl(I);

Min_Yield(J)..
sum(I, X(I, J) * expected_annual_yield(I, J)) =g= min_req_yield(J);

Revenue..
annual_revenue =e= sum((I,J), X(I, J) * expected_annual_revenue(I , J));


model TreePlanting  /all/ ;

solve TreePlanting using lp maximizing annual_revenue;

display x.l;
 
