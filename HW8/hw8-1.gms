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
free variable drag;

equation
	D_eqn
*	a_eqn
	cd_eqn
	cf_eqn
	re_eqn
	weight_eqn
	ww_eqn
	w_eqn
	v_eqn;
			
D_eqn..
    drag =e= .5*rho*sqr(V)*C_D*S;
cd_eqn..
    1 =g= cda_0/(s*c_d) + k*C_f*sw_s/C_D + sqr(C_l)/(4*arctan(1)*(a)*e*c_d);
weight_eqn..
    1 =g= (W_0 + W_w)/w;
ww_eqn..
    1 =g= 45.42*s/W_w + (.0000871/W_w)*(n_lift*(a**1.5)*sqrt(w_0*w*s))/(tau);
v_eqn..    
    1 =g= (2*W)/(rho*sqr(V_min)*S*cl_max);
cf_eqn..
    C_f*(R_e**.2)/.074 =e= 1;
re_eqn..
    1 =e= (R_e*mu)/(rho*V*sqrt(S/A));
w_eqn..
    1 =e= .5*rho*sqr(V)*c_l*s/w;
* setting bounds
v.lo = v_min;
C_l.up = cl_max;
W.lo = W_0;
s.lo = (2*W_0)/(rho*sqr(v_min)*cl_max);
W_w.lo = 45.42*S.lo;
c_d.lo = .000000000001;
a.lo = 0.000000001;

model geometric_standard /all/;
option nlp=knitro;
solve geometric_standard using nlp minimizing drag;
display v.l

***********************************
variables 
	log_s, 
	log_a, 
	log_v, 
	log_cd, 
	log_cf, 
	log_cl, 
	log_re, 
	log_w, 
	log_ww, 
	log_b;

equation
	g_D_eqn
	g_a_eqn
	g_cd_eqn
	g_cf_eqn
	g_re_eqn
	g_weight_eqn
	g_ww_eqn
	g_w_eqn
	g_v_eqn;
free variable drag;
g_D_eqn..
	drag =e= log(0.5*rho) + 2*log_v + log_cd + log_s;
g_a_eqn..
	log_a =e= 2*log_b - log_s;
g_cd_eqn..
	log_cd =g= log(exp(log(cda_0) - log_s) + exp(log(k*sw_s) + log_cf) + exp(2*log_cl - log(pi*e) - log_a));
g_cf_eqn..
	log_cf =e= log(0.074) - 0.2*log_re;
g_re_eqn..
	log_re =e= log(rho/mu) + log_v + 0.5*(log_s - log_a);
g_weight_eqn..
	log_w =g= log(w_0 + exp(log_ww));
g_ww_eqn..
	log_ww =g= log(45.42*exp(log_s) + exp(log(8.71e-5*n_lift/tau) + 3*log_b + 0.5*(log(w_0) + log_w) -log_s));
g_w_eqn..
	log_w =e= log(0.5*rho) + 2*log_v + log_cl + log_s;
g_v_eqn..
	log(2) + log_w - log(rho*v_min*v_min) -log_s =l= log(cl_max);

model geometric_invertible /
	g_D_eqn
	g_a_eqn
	g_cd_eqn
	g_cf_eqn
	g_re_eqn
	g_weight_eqn
	g_ww_eqn
	g_w_eqn
	g_v_eqn/;
solve geometric_invertible minimizing drag using nlp;
parameters gs,ga,gv;
gs = exp(log_s.l);
ga = exp(log_a.l);
gv = exp(log_v.l)
display gs,ga,gv;