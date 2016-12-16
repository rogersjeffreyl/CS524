$title hw8p1
option limrow = 0, limcol = 0;

scalars 
	cda_0 /0.0306/,
	rho /1.23/,
	mu /1.78e-5/,
	sw_s /2.05/,
	k /1.2/,
	e /0.96/,
	w_0 /4940/,
	n_lift /2.5/,
	tau /0.12/,
	v_min /22/,
	cl_max /2.0/
	pi /3.1412/;

positive variables 
	s, 
	a, 
	v, 
	C_d, 
	C_f, 
	C_l, 
	R_e, 
	w, 
	W_w, 
	b;

* Defining slack variables
positive variables ecd, ew, eww, ecu, ecv,ewt,eww,ve,ewu,ewv;

free variable drag;

equation
	D_eqn
	a_eqn
	cd_eqn
	cf_eqn
	re_eqn
	weight_eqn
	ww_eqn
	w_eqn
	v_eqn;

D_eqn..
	drag =e= 0.5*rho*v*v*C_d*s+ ecd + ecu + ecv + ewt + eww + ewu + ewv + ve;

a_eqn..
	s*a =e= b*b;

cd_eqn..
	a*s*C_d +ecd=g= a*(cda_0) + a*k*c_f* sw_s*s + (C_l*C_l/(pi*e))*s;

cf_eqn..
	(R_e**0.2)*C_f +ecu-ecv=e= 0.074;

re_eqn..
	(a**0.5)*R_e =e= (rho*v/mu)* (s**0.5);

weight_eqn..
	w+ewt =g= w_0 + W_w;

ww_eqn..
	s*W_w +eww=g= 45.42*s*s +8.71*(10**(-5))*n_lift*(b**3)*((w_0*w)**0.5)/tau;

w_eqn..
	w+ewu-ewv =e= 0.5*rho*v*v*C_l*s;

v_eqn..
	2*w/(rho*v_min*v_min)-ve =l= s*cl_max;

model p1 /all/;


solve p1 minimizing drag using nlp;


display S.L;
display a.l;
display b.l;
