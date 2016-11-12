option seed=0; set nodes /1*500/;
parameter offset(nodes); offset(nodes) = round(uniform(2,5));
alias (i,j,nodes); set arcs(nodes,nodes);
arcs(i,j) = no; arcs(i,i+1) = yes; arcs(i,i+offset(i)) = yes;
set k /1*3/;
parameter demand(nodes,k) /
     1.1 -70, 6.1 70, 3.2 -25, 500.2 25, 4.3 -20, 8.3 20, 54.1 -70, 55.1 70
     23.2 -25, 89.2 25, 10.3 -20, 89.3 20, 20.3 -10, 450.3 10 /;
parameter capacity(i,j); capacity(i,j) = uniform(75,85);

