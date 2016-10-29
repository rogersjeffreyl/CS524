$title Critical Path Method
set nodes /A*H/;
alias (nodes,I,J,K,L);
set activities(I,J) 
/
  A.(B,D)
  D.(F,E)
  B.(D,E,C)
  C.(E,G)
  E.(F,H,G)
  F.H
  G.H
 /;
parameter duration(I,J) "duration for each of the events. Used as an upper bound of the time later"
  /A.B 4
   A.D 3
   B.C 5
   B.D 5
   B.E 8
   C.E 6
   C.G 4
   D.E 7
   D.F 9   
   E.F 10
   E.G 7
   E.H 3
   F.H 3 
   G.H 5
   /;

parameter min_start(I,J) "Minimum required starting time for each of the activities"
  /A.B 3
   A.D 2
   B.C 2
   B.D 4
   B.E 6
   C.E 5
   C.G 2
   D.E 5
   D.F 8   
   E.F 6
   E.G 4
   E.H 2   
   F.H 2
   G.H 4 /;   

set precedence(I,J,K,L)
/
  (A.B).(B.D, B.E, B.C)
  (A.D).(D.E, D.F)
  (B.C).(C.E, C.G)
  (B.D).(D.E,D.F)
  (B.E).(E.F,E.H,E.G)
  (D.E).(E.F,E.H,E.G)
  (C.E).(E.F,E.H,E.G)
  (C.G).(G.H)
  (E.F).(F.H)  
  (E.G).(G.H) 
/;

variables time_duration "Total duration for the whole set of activities to be done";
positive variable t(I,J) "time activity starts";
equations 
  incidence(I,J,K,L) "order of the activities", 
  end_time(I,J) "end time of the activities for mini max";
incidence(I,J,K,L)$precedence(I,J,K,L)..
    t(K,L) =g= t(I,J) + duration(I,J);
end_time(I,J)..
    time_duration =g= t(I,J) + duration(I,J);

model critical_path_method /incidence, end_time/;
solve critical_path_method using lp minimizing time_duration;

set critical(I,J) "critical activities";
critical(I,J)=yes$( smax((K,L)$precedence(K,L,I,J), incidence.m(K,L,I,J)) ge 1
              or smax((K,L)$precedence(I,J,K,L), incidence.m(I,J,K,L)) ge 1 );
display critical;	
display t.L;

*2.2  

free variable cost; 
positive variables x(I,J) ;  
equation 
  cost_eq "cost for the activties based on the time taken",
  incidence_eq "order of the activities",
  end_time_eq "end time of the activities";
* Fixing the time duration  
time_duration.fx=25;
cost_eq..
    cost =e= sum((I,J)$activities(I,J),3+2*(duration(I,J)-x(I,J) )/(duration(I,J)-min_start(I,J)));
incidence_eq(I,J,K,L)$precedence(I,J,K,L)..
    t(K,L) =g= t(I,J) + x(I,J) ;
end_time_eq(I,J)..
    time_duration =g= t(I,J) + x(I,J);
x.up(I,J)=duration(I,J);
x.lo(I,J)=min_start(I,J);
model critical_path_cost /incidence_eq, end_time_eq,cost_eq/;
solve  critical_path_cost using lp minimizing cost;
set critical_25(I,J) "critical activities";
critical_25(I,J)=yes$( smax((K,L)$precedence(K,L,I,J), incidence_eq.m(K,L,I,J)) ge 1
              or smax((K,L)$precedence(I,J,K,L), incidence_eq.m(I,J,K,L)) ge 1 );
display critical_25; 
display cost.L;
display t.L;
$ontext
parameter
    eeTime(I,J) "early event time",
    leTime(I,J) "late event time";

time_duration.fx = projDur.l;

variables objective;
equations timeopt;

timeopt..
    objective =e= sum(activities,t(activity));

model eventtimes /timeopt,incidence,endTime/;

solve eventtimes using lp maximizing objective;
leTime(activity) = t.l(activity);
solve eventtimes using lp minimizing objective;
eeTime(activity) = t.l(activity);

critical(activity) = yes$(eeTime(activity) ge leTime(activity));

display eeTime,leTime,critical;
$offtext

parameter
    eeTime(I,J) "early event time",
    leTime(I,J) "late event time";   
set firstdone(I,J), next(I,J);
set iters /iter1*iter100/;
set lastdone(I,J), prev(I,J);

eeTime(I,J) = -inf;
firstdone(K,L) = yes$(sum((I,J)$precedence(I,J,K,L),1) eq 0);
eeTime(firstdone) = 0;
loop(iters$(card(firstdone) gt 0),
  next(I,J) = yes$sum(precedence(firstdone,I,J),1);
  eeTime(next) = smax(precedence(I,J,next), eeTime(I,J)+x.L(I,J));
  firstdone(activities) = next(activities);
);
leTime(I,J) = inf;
lastdone(I,J) = yes$(sum((K,L)$(precedence(I,J,K,L)),1) eq 0);
leTime(lastdone) = time_duration.l-x.l(lastdone);
loop(iters$(card(lastdone) gt 0),
  prev(I,J) = yes$sum(precedence(I,J,lastdone),1);
  leTime(prev) = smin(precedence(prev,I,J), leTime(I,J)-x.L(prev));
  lastdone(activities) = prev(activities);
);

critical_25(I,J) = yes$(eeTime(I,J) ge leTime(I,J));

display eeTime,leTime,critical_25;

parameter time_critical_25(I,J);
time_critical_25(I,J) = t.L(I,J)$(critical_25(I,J));
display time_critical_25;

*fx=20

time_duration.fx=20;
set critical_20(I,J) "critical activities";
solve  critical_path_cost using lp minimizing cost;
critical_20(I,J)=yes$( smax((K,L)$precedence(K,L,I,J), incidence_eq.m(K,L,I,J)) ge 1
              or smax((K,L)$precedence(I,J,K,L), incidence_eq.m(I,J,K,L)) ge 1 );

eeTime(I,J) = -inf;
firstdone(K,L) = yes$(sum((I,J)$precedence(I,J,K,L),1) eq 0);
eeTime(firstdone) = 0;
loop(iters$(card(firstdone) gt 0),
  next(I,J) = yes$sum(precedence(firstdone,I,J),1);
  eeTime(next) = smax(precedence(I,J,next), eeTime(I,J)+x.L(I,J));
  firstdone(activities) = next(activities);
);
leTime(I,J) = inf;
lastdone(I,J) = yes$(sum((K,L)$(precedence(I,J,K,L)),1) eq 0);
leTime(lastdone) = time_duration.l-x.l(lastdone);
loop(iters$(card(lastdone) gt 0),
  prev(I,J) = yes$sum(precedence(I,J,lastdone),1);
  leTime(prev) = smin(precedence(prev,I,J), leTime(I,J)-x.L(prev));
  lastdone(activities) = prev(activities);
);

critical_20(I,J) = yes$(eeTime(I,J) ge leTime(I,J));

display critical_20; 
display cost.L;
display t.L;


parameter time_critical_20(I,J);
time_critical_20(I,J) = t.L(I,J)$(critical_20(I,J));
display time_critical_20;