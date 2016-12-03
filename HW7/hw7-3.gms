sets
 N /ad1*ad20/
;
alias(I,N) ;
parameters
 c(I) Cost
 alpha(I) Witches proportionality constant
 beta(I) Wizards proportionality constant
;
scalars K1, K2 ;
c(I) = normal(100,5) ;
alpha(I) = uniform(7,13) ;
beta(I) = 13-alpha(I) + 7 + 5$(uniform(0,1) < 0.3) ;
K1 = 5000;
K2 = 8000;




solve w1 using nlp minimizing cost ;
display x.L;
parameter totalAdTime;
totalAdTime = sum(I, x.L(I)) ;
display totalAdTime;
