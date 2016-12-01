$GDXIN abalone.gdx
$LOAD
  parameters
  	data	
  sets
  	i,
  	headr
$load i,data,headr    
$GDXIN
alias (i,j,k);
display headr
set features(headr);
features('Rings')=no;
set train_indices(i) /1*4000/;
set test_indices(i) /4001*4177/;
parameter y(i);
scalar C /10/;

y(i)$(data(i,'Rings')>10) =1; 
y(i)$(data(i,'Rings')<=10) =-1;

*primal formulation
variable gamma;
variable w(headr);
positive variable eta(train_indices);
free variable primal_objective;
equations
	primal_constraint_1(i),
	primal_objective_eq;

primal_constraint_1(train_indices)..	
	y(train_indices) *(sum(features,w(features)*data(train_indices,features))+gamma) =g=1-eta(train_indices);
primal_objective_eq..
	primal_objective =e= 0.5*(sum(features,w(features)*w(features)))+C* sum(train_indices,eta(train_indices));	

model svm_primal	/all/;


solve svm_primal minimizing primal_objective using qcp;
display C
display gamma.L
* Dual formulation
  positive variable  alpha(train_indices);
  variable v(headr);
  
  free variable dual_obj;
equations
  dual_constraint_1(headr),
  dual_constraint_2,
  constraint_C(train_indices),
  svm_dual_objective;

dual_constraint_1(features)..
	v(features) =e= sum(train_indices,data(train_indices,features));
dual_constraint_2..
	sum(train_indices,y(train_indices)*alpha(train_indices)) =e=0;
svm_dual_objective..
	dual_obj =e= sum(train_indices,alpha(train_indices))-0.5*sum(features,v(features)*v(features)) ;

constraint_C(train_indices)..
	C =g=alpha(train_indices);

model svm_dual /all/;
*solve  svm_dual maximizing dual_obj using qcp;



