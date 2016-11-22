$if not set n $set n 2000
set i /1*%n%/;
set j /1*3/;
* generate random reproducable data
option seed = 101;
parameter r(i); r(i) = uniform(0,0.2);
parameter c(i,j); c(i,j) = uniform(0,1);
free variable rad;
positive variables
    x(j)    Center coordinates
;
positive variables
  rc(i)  Copy of r;

free variables
  y(i,j) Separable points
;
equations
  inside_socp(i)
  def_y(i,j)
  def_r(i)
      ;

inside_socp(i)..
    sqr(rc(i)) =G= sum(j,sqr(y(i,j))) ;

def_y(i,j)..
  y(i,j) =E= x(j) - c(i,j) ;

def_r(i)..
  rad =G= rc(i)+r(i);

model mcb /inside_socp, def_y, def_r / ;
option qcp=knitro;

solve mcb minimizing rad using qcp; 
display rad.L;