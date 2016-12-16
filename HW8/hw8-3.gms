set moves /"wake_up","fake_sleep"/;
alias (moves,I,J);
 
table payoff_professor(i,j)
                 fake_sleep  wake_up
     fake_sleep  60	         0
     wake_up	 45          30  ;

table payoff_wife(i,j)
                 fake_sleep  wake_up
     fake_sleep  60	        30
     wake_up	 0          30  ;     

set  T /1*2/;

positive variables 
	X(T,I)
	Y(T,J)	;

free variables
	obj1,
	obj2;

equations 
	objective1,
	objective2,
	one_x(T),
	one_y(T);


objective1..
	obj1 =e=  sum(T, sum(  (I,J),  X(T,I)* payoff_professor(I,J) * Y(T,J) ) );

objective2..
	obj2 =e=  sum(T, sum((I,J),X(T,I)*payoff_wife(I,J)*Y(T,J)));

one_x(T)..
	sum (I, X(T,I))=e=1;

one_y(T)..
	sum (I, Y(T,I))=e=1;
model bimatrix /all/;



file empinfo / '%emp.info%' /;
put empinfo;
put 'equilibrium' /;
put "min obj1 x objective1 one_x"
put "min obj2 y objective2 one_y"
putclose empinfo;


solve bimatrix using emp;	     