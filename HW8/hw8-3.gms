$title Bimatrix game
set moves /"wake_up","fake_sleep"/;
alias (moves,I,J);
 
table payoff_professor(i,j) "payoff matrix for player1(professor)"
                 fake_sleep  wake_up
     fake_sleep  60	         0
     wake_up	 45          30  ;

table payoff_wife(i,j) "payoff matrix for player2(wife)"
                 fake_sleep  wake_up
     fake_sleep  60	        30
     wake_up	 0          30  ;     

set  T /1*2/;

positive variables 
	X(T,I) "random variable for player1"
	Y(T,J) "random variable for player2";

free variables
	obj1 "first players objective",
	obj2 "second players objective";

equations 
	objective1 "objective for the second player",
	objective2 "objective for the first player",
	one_x(T)   "probability constraint for the first player",
	one_y(T)   "probability constraint for the second player";
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
display X.L
display Y.L	     