$GDXIN abalone.gdx

  
  sets
  	i(*),
  	headr(*)
  
$load i,headr
parameters
    data(i, headr)    
$load data   
$GDXIN
alias (i,j,k);

set features(headr);
features(headr)=yes;
features('Rings')=no;
display features
set train_indices(i) /1*4000/;
set test_indices(i) /4001*4177/;
parameter y(i);
scalar C /%C%/;

y(i)$(data(i,'Rings')>10)=1; 
y(i)$(data(i,'Rings')<=10)=-1;

display y;
*primal formulation
free variable gamma;
free variable w(headr);
positive variable eta(train_indices);
free variable primal_objective_value;
equations
	primal_constraint_1(train_indices),
	primal_objective_eq;

primal_constraint_1(train_indices)..	
	y(train_indices) *(sum(features,w(features)*data(train_indices,features))+gamma) =g=1-eta(train_indices);
primal_objective_eq..
	primal_objective_value =e= 0.5*(sum(features,w(features)*w(features)))+C* sum(train_indices,eta(train_indices));	

model svm_primal	/primal_constraint_1,primal_objective_eq/;

solve svm_primal minimizing primal_objective_value using qcp;
display C
display gamma.L
display w.l
display primal_objective_value.L
display primal_constraint_1.m

* Dual formulation
  positive variable  alpha(train_indices);
  variable v(headr);
  
  free variable dual_obj_value;
equations
  dual_constraint_1(headr),
  dual_constraint_2,
  constraint_C(train_indices),
  svm_dual_objective;

alpha.L(train_indices)=primal_constraint_1.m(train_indices);

dual_constraint_1(features)..
	v(features) =e= sum(train_indices,alpha(train_indices)*y(train_indices)*data(train_indices,features));

dual_constraint_2..
	sum(train_indices,y(train_indices)*alpha(train_indices)) =e=0;

svm_dual_objective..
	dual_obj_value =e= sum(train_indices,alpha(train_indices))-0.5*sum(features,v(features)*v(features)) ;

constraint_C(train_indices)..
	C =g=alpha(train_indices);

model svm_dual /dual_constraint_1,dual_constraint_2,svm_dual_objective,constraint_C/;
solve  svm_dual maximizing dual_obj_value using qcp;
display dual_obj_value.L

*Predictions for the test test
parameter
  predictions_error(test_indices),
  w_final(headr);

w_final(features) =  sum (train_indices,y(train_indices)*alpha.L(train_indices)*data(train_indices,features));

predictions_error(test_indices)$(y(test_indices) ne sign(gamma.L+sum (features,w_final(features)*data(test_indices,features))))=1;
parameter total_error;
total_error = sum(test_indices,predictions_error(test_indices))
display total_error

* write output file
file errortxt/error.txt/;
put errortxt
put 'C= ', C/
put 'Error= ',total_error/;
putclose
