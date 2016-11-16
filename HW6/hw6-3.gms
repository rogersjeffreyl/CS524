$if not set sos1 $set sos1 binary

* Rows/cols labeled from top left corner
set o operations / m multiply, d divide, a add, s subtract/;
set mult(o) / m,d /;
set add(o) / a,s /;
set diff(o) / d,s /;
sets r rows / r1 * r6/ 
     c columns/c1*c6/ 
     v values /v1*v6/
     b boxes / b1*b15 /;
parameter value(b) /b1 24, b2 1, b3 3, b4 36, b5 10, b6 7, b7 1, b8 20, b9 20,
  b10 3, b11 11, b12 3, b13 3, b14 1, b15 1/;
set boxmap(b,o,r,c) /
  b1.m.(r1*r2.c1,r1.c2),
  b2.s.r1.c3*c4,
  b3.d.r1.c5*c6,
  b4.m.(r2.c2*c3,r3.c3),
  b5.a.(r4.c3,r2*r4.c4),
  b6.a.r2.c5*c6,
  b7.s.r3.c1*c2,
  b8.m.(r3.c5*c6,r4.c6),
  b9.m.r4*r6.c1,
  b10.d.r4*r5.c2,
  b11.a.r4*r5.c5,
  b12.s.r5.c3*c4,
  b13.d.r5*r6.c6,
  b14.s.r6.c2*c3,
  b15.s.r6.c4*c5 /;
set boxops(b,o);
option boxops < boxmap;
display boxops ;

binary variable x(r,c,v) "x[r,c,v] = 1 means cell [r,c] is assigned value v";

x.l(r,c,v) =0;
variable valincell(r,c);
free variable objective;
equations 
  objective_eq,
  value_in_cell(r,c)     "equation for assigning values to cell" 
  cell_unique_num(r,c)   each cell must be assigned exactly one number
  row_unqiue_num(r,v)   cells in the same row must be assigned distinct numbers
  col_unique_num(c,v)   cells in the same column must be assigned distinct numbers,
  addition_constraints(b)  "constraints for addition" ,
  multiplication_constraints(b),
  subtraction_constraints_1(b) "constraints for multiplication", 
  subtraction_constraints_2(b) "constraints for multiplication",
  division_constraints_1(b),
  division_constraints_2(b)

display boxmap;

objective_eq..
    objective =e= 1;

cell_unique_num(r,c)..  
  sum(v, x(r,c,v) )=e= 1;

row_unqiue_num(r,v)..  
  sum(c, x(r,c,v) )=e= 1;

col_unique_num(c,v).. 
  sum(r, x(r,c,v))=e= 1;

value_in_cell(r,c)..
  valincell(r,c) =e= sum(v,x(r,c,v)*ord(v));

addition_constraints(b)$boxops(b,'a')..
  value(b) =e= sum((r,c)$boxmap(b,'a',r,c),sum(v,ord(v) *x(r,c,v)));


subtraction_constraints_1(b)$boxops(b,'s')..
  sum((r,c)$boxmap(b,'s',r,c),power((-1),ord(r))*power((-1),ord(c))*sum(v,x(r,c,v)*ord(v))) =l= value(b)  ;

subtraction_constraints_2(b)$boxops(b,'s')..
  -sum((r,c)$boxmap(b,'s',r,c),power((-1),ord(r))*power((-1),ord(c))*sum(v,x(r,c,v)*ord(v))) =l= value(b) ;

multiplication_constraints(b)$boxops(b,'m')..
  log(value(b)) =e= sum((r,c)$boxmap(b,'m',r,c),sum(v,x(r,c,v)*log(ord(v))));

division_constraints_1(b)$boxops(b,'d')..
  sum((r,c)$boxmap(b,'d',r,c),power((-1),ord(r))*power((-1),ord(c))*sum(v,x(r,c,v)*log(ord(v)))) =l= log(value(b))  ;
division_constraints_2(b)$boxops(b,'d')..
  -sum((r,c)$boxmap(b,'d',r,c),power((-1),ord(r))*power((-1),ord(c))*sum(v,x(r,c,v)*log(ord(v)))) =l= log(value(b)) ;

model kenkensolver / all/;

solve kenkensolver using mip minimizing objective;  
valincell.L(r,c) = sum(v,x.L(r,c,v)*ord(v));
display valincell.L;


parameter results(r,c);
loop(boxops(b,o),
     results(r,c)$boxmap(b,o,r,c) =
       valincell.l(r,c)$add(o)
       + valincell.l(r,c)$mult(o);
   );


  



