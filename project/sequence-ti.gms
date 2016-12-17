$title Sequencing on a single machine (Xpress Models: pp 128-132)

$ontext
A set of tasks is to be processed on a single machine.
The execution of the tasks is non-preemptive (ie cannot be interrupted).
For every task i its release date, duration and due date are given.

What is the sequence that minimizes the maximum tardiness?

Note the paper by Keha, Khowala et al that details this and other formulations.
The time indexed one is due to Sousa and Wolsey (1992)
$offtext

$if not set data $set data simple

$ifthen %data%==simple
set job / 1*7 /;
set times /release,duration,due/;

table data(times,job)
		1	2	3	4	5	6	7
release		2	5	4			8	9
duration	5	6	8	4	2	4	2
due		10	21	15	10	5	15	22
;
set k 'position' / p1*p7 /;
$else
set job(*), times(*), k(*);
parameter data(times,job);
$gdxin scheddata.gdx
$load job times data k
$gdxin
$endif

alias (job,j);

scalar capT;
capT = sum(j, data('duration',j))+smax(j, data('release',j));
display capT;

set t /t1*t1608/;
alias(s,t);
abort$(card(t) lt capT) 'capT too small';

binary variable x(j,t) "job j starts in period t (between t-1 and t)";
positive variables tard(j) "tardiness of job j";
variable tardiness;

equations
  onePer(t), defstart(j),
  deftard(j,t), deftardiness(j);

defstart(j)..
  sum(t$(t.ord le capT-data('duration',j)+1), x(j,t)) =e= 1;

onePer(t)..
  sum(j, sum(s$(s.ord ge t.ord-data('duration',j)+1 and s.ord le t.ord), x(j,s))) =l= 1;

deftard(j,t)..
  tard(j) =g= (t.ord - 1 + data('duration',j) - data('due',j))*x(j,t);

deftardiness(j)..
  tardiness =g= tard(j);

model sequence /all/;

* model release times using fixing of variables
x.fx(j,t)$(t.ord le data('release',j)) = 0;
sequence.optcr = 0;

solve sequence using mip min tardiness;

parameter comp(j) "completion time of job j";
comp(j) = sum(t$(t.ord le capT-data('duration',j)+1), 
	(t.ord - 1 + data('duration',j))*x.l(j,t));
parameter start(j) "start time of job j";
start(j) = sum(t$(t.ord le capT-data('duration',j)+1), 
	(t.ord - 1)*x.l(j,t));
display x.l, start, comp;

$exit

$ontext
Can model total weighted completion time, or total weighted tardiness
obj =e= sum(j, sum(t$(t.ord le capT-data('duration',j)+1), psi(j,t)*x(j,t))
where
psi(j,t) = w(j)(t.ord-1+data('duration',j) for completion
and
psi(j,t) = w(j)*max(0,t.ord-1+data('duration',j)-data('due',j)) for tardiness
without the addition of extra variables (w(j) = 1 when no weighting)

Can also minimize the number of tardy jobs by setting:
psi(j,t) = 1$(t.ord gt data('due',j) - data('duration',j) + 1);

Performance of this technique highly influenced by the sum of the processing times.
$offtext

parameter psi(j,t);
psi(j,t) = max(0,t.ord-1+data('duration',j)-data('due',j));
variable obj;
equation defobj;

defobj..
  obj =e= sum(j, sum(t$(t.ord le capT-data('duration',j)+1), psi(j,t)*x(j,t)));

model sched2 /defobj, defstart, onePer/;

psi(j,t) = max(0,t.ord-1+data('duration',j)-data('due',j));
solve sched2 using mip min obj;
display x.l;

psi(j,t) = 1$(t.ord gt data('due',j) - data('duration',j) + 1);
solve sched2 using mip min obj;
* determine tardy jobs
psi(j,t) = psi(j,t)*x.l(j,t);
display x.l, psi;
