option seed=0; set nodes /1*500/;
parameter offset(nodes); offset(nodes) = round(uniform(2,5));
alias (i,j,nodes); set arcs(nodes,nodes);
arcs(i,j) = no; arcs(i,i+1) = yes; arcs(i,i+offset(i)) = yes;
set k /1*3/;
parameter demand(nodes,k) /
     1.1 -70, 6.1 70, 3.2 -25, 500.2 25, 4.3 -20, 8.3 20, 54.1 -70, 55.1 70
     23.2 -25, 89.2 25, 10.3 -20, 89.3 20, 20.3 -10, 450.3 10 /;
parameter capacity(i,j); capacity(i,j) = uniform(75,85);


Set s   segments       / s0*s3 /
    sl  segment labels / x, y coordinates, l length, g slope /;

Table sqrtp(s,sl) piecewise linear function for sqrt
      x		y 				l                                                g
s0    0		0 				[sqrt(sqr(log(6)-0)+sqr(5))]                 [log( 6)/5]		
s1    5		[log(6)] 		[sqrt(sqr(log(11)-log( 6))+sqr(5))]          [(log(11)-log( 6))/5]	
s2    10	[log(11)] 		[sqrt(sqr(log(101)-log( 11))+sqr(90))]       [(log(101)-log( 11))/90]		
s3    100	[log(101)] 		+INF                                         [1/101] ;
