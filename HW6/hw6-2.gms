$title Piecewise Linear Networks
$ontext
$offtext
option seed=0; set nodes /1*500/;
parameter offset(nodes); offset(nodes) = round(uniform(2,5));
alias (i,j,l,nodes); set arcs(nodes,nodes);
arcs(i,j) = no; arcs(i,i+1) = yes; arcs(i,i+offset(i)) = yes;
set k /1*3/;
parameter demand(nodes,k) /
     1.1 -70, 6.1 70, 3.2 -25, 500.2 25, 4.3 -20, 8.3 20, 54.1 -70, 55.1 70
     23.2 -25, 89.2 25, 10.3 -20, 89.3 20, 20.3 -10, 450.3 10 /;
parameter capacity(i,j); capacity(i,j) = uniform(75,85);


Set s   segments       / s0*s3 /
    sl  segment labels / x, y coordinates, l length, g slope /;

Table logp(s,sl) piecewise linear function for sqrt
      x		y             l     g
s0    0		0             5    [log10( 6)/5]		                							 
s1    5		[log10(6)]    5    [(log10(11)-log10( 6))/5]
s2    10	[log10(11)]   90   [(log10(101)-log10(11))/90]
s3    100	[log10(101)]  +INF [1/101] ; 

$ontext
Have solved this piwcewise model using log 10. 
Replacing log10 with log gives an objective 487.883563
$offtext                                  

positive variable q(i,j,k) "quantity of item carried through link i,j";
positive variable flow(i,j);
free variable PWcost "total cost of the flow";

equations
	link_capacity_eq(i,j) "Flow through a link should not exceed the capacity",
	piecewise_obj "Objectie to minimize the cost",
	flow_eq "Assigning flows from pwlfunc.inc",
	flow_equality_eqn(i,j) "equating the flow from piecewise and the q flows",
	demand_supply_equation(i,k) "demand at each node should be met for each product";
	
link_capacity_eq(i,j)$arcs(i,j)..
	sum(k,q(i,j,k)) =l= capacity(i,j);
demand_supply_equation(i,k)..
	sum(j$arcs(i,j),q(i,j,k)) -sum(j$(arcs(j,i)),q(j,i,k)) =e=-demand(i,k);

$batinclude pwlfunc.inc logp s x y l g '' 'i,j'

piecewise_obj..
    PWcost =e= sum((i,j)$arcs(i,j), logp_y(i,j));

flow_eq(i,j)$arcs(i,j)..
  flow(i,j) =e= logp_x(i,j);

flow_equality_eqn(i,j)$arcs(i,j)..
	flow(i,j) =e=sum(k,q(i,j,k));

model piecewise_networks /all/;
piecewise_networks.optcr = .02;
solve piecewise_networks minimizing  PWcost using mip;
display PWcost.up;
display PWcost.l;
display PWcost.lo;

parameter diff;
parameter upper, lower;
diff = abs(piecewise_networks.objest - piecewise_networks.objval);
lower = piecewise_networks.objval - diff;
upper = piecewise_networks.objval + diff;

display upper, lower;


