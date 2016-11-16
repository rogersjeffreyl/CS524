$title Filtch’s Paint Company
set i /1*10/;
alias(i,j);
set k(i) /2*10/;
alias (k,l);
table clean(i,j)
    1    2    3    4    5   6   7   8   9   10
1       11    7    13   11  12  4   9   7   11   
2   5         13   15   15  6   8   10  9   8 
3   13  15         23   11  11  16  18  5   7
4   9   13     5        3   8   10  12  14  5  	        
5   3   7      7   7        9   10  11  12  13   
6   10  6      3   4    14      8   5   11  12  
7   4   6      7   3    13  7       10  4   6   
8   7   8      9   9    12  11  10      10  9 
9   9   14     8   4    9   6   10  8       12 
10  11  17     11  6    10  4   7   9   11     
;   

parameter dur(i) /1 40, 2 35, 3 45, 4 32, 5 50, 6 42, 7 44, 8 30, 9 33, 10 55 /;

free variable obj;
binary variable x(i,j);
positive variable u(i);

u.l('1')=1;
equations 
	objective_eq "objective equation for the shortest time",
	subtour_elimination_exit_eq(j),
	subtour_elimination_enter_eq(i),
	subtour_elimination_ordering_eq_1(i),
	subtour_elimination_ordering_eq_2(i,j);

objective_eq..             
	obj =e= sum((i,j),x(i,j)*(clean(i,j)+dur(i)));

subtour_elimination_exit_eq(j)..          
	sum(i$(ord(i) ne ord(j)),x(i,j)) =e=1;
subtour_elimination_enter_eq(i)..          
	sum(j$(ord(i) ne ord(j)),x(i,j)) =e=1;

subtour_elimination_ordering_eq_1(i)$(ord(i) > 1)..     
	u(i) =g= 2;
subtour_elimination_ordering_eq_2(k,l)..        
	(u(k)-u(l)+card(dur)*x(k,l)) =l= (card(dur)-1);

model paint /all/;
solve paint using mip minimizing obj;

display x.l;

parameter batchlength;
batchlength = obj.l;

parameter order(i);
loop(j,
     order(i)$(abs(u.L(j)-ord(i))<0.5) = ord(j) ;
      ) ;

display batchlength;
display order,u.l;
