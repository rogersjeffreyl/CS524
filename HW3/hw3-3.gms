$title "Least Squares"
sets
ALLI /c1*c400/
ALLJ /x1*x100/
;
sets
I(ALLI) /c1*c6/
J(ALLJ) /x1*x4/
;

variables 
	differences(ALLI),
	x(ALLJ);

free variable ztotdev;	

parameters
b(ALLI)     "constant",
TotalDevSmall,
xValSmall(ALLJ) ; 

b( 'c1') =   17;
b ('c2' ) =  -16 ;
b('c3') =    7 ;
b('c4') =   -15 ;
b('c5')     =  6 ;
b('c6' )     = 0;
	

Table A (ALLI, ALLJ) "coefficients for the equation"
      x1 x2  x3  x4  
  c1   8  -2  4  -9
  c2   1   6  -1  -5
  c3   1   -1 1   0
  c4   1   2  -7  4 
  c5   0   0   1  -1
  c6   1   0   1   -1 ;

equations  

	positive_differences_eq(ALLI) ,
	negative_differences_eq(ALLI) ,
	sum_of_differences;

positive_differences_eq(I)..
 	sum(J,A(I, J)*x(J)) -b(I) =l= differences(I);

negative_differences_eq(I).. 	
	sum(J,A(I, J)*x(J) ) - b(I)  =g=  -differences(I);

sum_of_differences..
	ztotdev =e= sum(I,differences(I) );

*model abs_value_1 /all/;
model abs_value_1 /positive_differences_eq,negative_differences_eq,sum_of_differences/; 

solve abs_value_1 using lp minimizing ztotdev;

TotalDevSmall = ztotdev.L ;
xValSmall(J) = x.L(J);

display TotalDevSmall;
display xValSmall;

*3.2

free variable zminmax;
parameters
 MinMaxDevSmall;
 
equations
  min_max_difference;

min_max_difference(I)..
  zminmax =g= differences(I) ;

model abs_value_2 /positive_differences_eq,negative_differences_eq,min_max_difference/;

solve abs_value_2 using lp minimizing zminmax;

MinMaxDevSmall = zminmax.L;
display MinMaxDevSmall;

* 3.3
* Reset sets

I(ALLI) = yes;
J(ALLJ) = yes;


option seed = 666 ;
A(I,J) = uniform(-10,10) ;
b(I) = uniform(-100,100) ;


model abs_value_3 /positive_differences_eq,negative_differences_eq,sum_of_differences/;
solve abs_value_3 using lp minimizing ztotdev;

