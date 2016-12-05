sets
     N /ad1*ad20/
;
option seed=10;
alias(I,N) ;
   parameters
     c(I) Cost
     alpha(I) Witches proportionality constant
     beta(I) Wizards proportionality constant
;
scalars K1, K2 ;
c(I) = normal(100,5) ;
alpha(I) = uniform(7,13) ;
beta(I) = 13-alpha(I) + 7 + 5$(uniform(0,1) < 0.3) ;
K1 = 5000;
K2 = 8000;

positive variable X(I) "minutes per advertisement of type I"
free variable cost;
equations
	witches_reached "equation for witches reached",
	wizards_reached "equation for wizards reached",
	obj_eq;

obj_eq..
	cost =e= sum (i,C(i)*X(i));	
witches_reached..
	sum (i, alpha(i)*sqrt(x(i))) =g= k1;
wizards_reached..
	sum (i, beta(i)*sqrt(x(i))) =g= k2;

model w1 /obj_eq, witches_reached,wizards_reached/;	
option nlp=KNITRO;

solve w1 using nlp minimizing cost ;
display x.L;
parameter totalAdTime;
totalAdTime = sum(I, x.L(I)) ;
display totalAdTime;   

display alpha
display beta

positive variables 
	u(i), 
	v(i);
equations
	
	witches_eq2, 
	wizards_eq2, 
	def_u(i),
	def_v(i);

witches_eq2..
	sum (i, alpha(i)*u(i)) =g= k1;
wizards_eq2..
	sum (i, beta(i)*u(i)) =g= k2;
def_u(i)..
	x(i) =g= u(i)*u(i);
def_v(i)..
	x(i) =g= v(i)*v(i);

option qcp = cplex;
model w2 /obj_eq, witches_eq2, wizards_eq2, def_u, def_v /;
option QCP=CPLEX
solve w2 using qcp minimizing cost;


display x.L;
parameter totalAdTime2;
totalAdTime2 = sum(I, x.L(I)) ;
display totalAdTime2;