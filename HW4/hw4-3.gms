$Title Broom Rental
set broom_shops   "Broom Rental Shops"
  / Hogwarts,
    "Godric's Hollow",
    "Little Whinging",
    "Shell Cottage",
    "The Leashops_with_demandy Cauldron",
    "Ollivander's",
    "Zonko's Joke Shop" ,
    "Dervish and Banges",
    "Little Hangleton",
    "Weasley's Wizard Wheezes"/,
  
  shops_with_demand(broom_shops),
  not_from_closest(broom_shops);

alias(broom_shops,I,J);
set nearest_node(broom_shops, J); 

parameters
   xcord(broom_shops) "x-coordinates of shop"
   / Hogwarts                   0
     "Godric's Hollow"          20
     "Little Whinging"          18
     "Shell Cottage"            30
     "The Leashops_with_demandy Cauldron" 35
     "Ollivander's"             33
     "Zonko's Joke Shop"  5
     "Dervish and Banges"       5
     "Little Hangleton"         11
     "Weasley's Wizard Wheezes" 2   /

   ycord(broom_shops) "y-coordinates of shop"
   / Hogwarts                   0
     "Godric's Hollow"          20
     "Little Whinging"          10
     "Shell Cottage"            12
     "The Leashops_with_demandy Cauldron" 0
     "Ollivander's"             25
     "Zonko's Joke Shop" 27
     "Dervish and Banges"       10
     "Little Hangleton"         0
     "Weasley's Wizard Wheezes" 15   /

   brooms_needed(broom_shops) "brooms needed by each shop"
   / Hogwarts                   10
     "Godric's Hollow"          6
     "Little Whinging"          8
     "Shell Cottage"            11
     "The Leashops_with_demandy Cauldron" 9
     "Ollivander's"             7
     "Zonko's Joke Shop"  15
     "Dervish and Banges"       7
     "Little Hangleton"         9
     "Weasley's Wizard Wheezes" 12   /

   available_brooms(broom_shops) "brooms currently available"
   / Hogwarts                   8
     "Godric's Hollow"          13
     "Little Whinging"          4
     "Shell Cottage"            8
     "The Leashops_with_demandy Cauldron" 12
     "Ollivander's"             2
     "Zonko's Joke Shop"  14
     "Dervish and Banges"       11
     "Little Hangleton"         15
     "Weasley's Wizard Wheezes" 7   /;


scalar broom_transport_cost "broom transport cost Galleons/Km" /0.5/;

parameter 
  pairwise_distance(broom_shops,J) "parameter to hold the pairwise distances" , 
  minimum_pairwise_distance(I) "parameter to store the minimum distance";

*Finding the pairwise distances between all shops  
pairwise_distance(broom_shops,J) = sqrt( (xcord(broom_shops) - xcord(J))*(xcord(broom_shops) - xcord(J)) + (ycord(broom_shops) - ycord(J))*(ycord(broom_shops) - ycord(J)));

*Finding the shops with Demand
shops_with_demand(broom_shops)=yes$(available_brooms(broom_shops)-brooms_needed(broom_shops) < 0 );

*Finding the minimum distance of a given shop to other shops
minimum_pairwise_distance(I) = smin(J$(ord(J) ne ord(I)),pairwise_distance(I,J));


free variable cost "objective variable";

positive Variable
  z(I,J) "brooms shipped from shop I to shop J";

equations
   flow_balance(broom_shops) "Balance of Flow",
   objective_eq "Objecive to minimize the shipping cost while satisfying the demands";
   
                                                                 
objective_eq.. 
  sum((broom_shops,J), pairwise_distance(broom_shops,J)* broom_transport_cost *z(broom_shops,J)) =e= cost;

flow_balance(broom_shops).. 
    sum(J, z(J,broom_shops)) + available_brooms(broom_shops) =e= brooms_needed(broom_shops) + sum(J, z(broom_shops,J)) ;

model broom_rental /all/ ;
$onecho >cplex.opt
lpmethod 3
netfind 1
preind 0
$offecho
broom_rental.optfile=1;
solve broom_rental using lp minimizing cost;

* Finding node which has not received supply from any of the nearest nodes
nearest_node(shops_with_demand, J) = yes$(pairwise_distance(shops_with_demand,J)=minimum_pairwise_distance(shops_with_demand) and (z.l(J,shops_with_demand) =0 ));

parameter 
  nearest_neighbor(broom_shops,J) ;
nearest_neighbor(nearest_node)=1;

not_from_closest(shops_with_demand) = yes$(sum(j, nearest_neighbor(shops_with_demand,J) )=1 )

parameter transportCost ;
transportCost = cost.L;
display transportCost
option not_from_closest:0:0:1;
display not_from_closest;

