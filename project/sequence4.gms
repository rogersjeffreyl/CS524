$title Sequencing on a single machine (Xpress Models: pp 128-132)
$stitle using sos1 to model indicator constraints

$ontext
A set of tasks is to be processed on a single machine.
The execution of the tasks is non-preemptive (ie cannot be interrupted).
For every task i its release date, duration and due date are given.

What is the sequence that minimizes the maximum tardiness?

This formulation uses order and sos1 variables, no bigM
$offtext

set job / 1*7 /;
set times /release,duration,due/;

table data(times,job)
		1	2	3	4	5	6	7
release		2	5	4			8	9
duration	5	6	8	4	2	4	2
due		10	21	15	10	5	15	22
;

alias (job,i,j);

set eos 'either-or set' /s1,s2/;
sos1 variables eo(i,j,eos) "either-or constraint";
positive variables start(j) "start time of job j";
positive variables comp(j) "completion time of job j";
positive variables late(j) "lateness of job j";
variable tardiness;

equations
  defcomp(j),
  disjoint1(i,j),
  disjoint2(i,j),
  deflate(j),
  deftard(j);

defcomp(j)..
  comp(j) =e= start(j) + data('duration',j);

* The following are either-or constraints, do paper i or paper j
disjoint1(i,j)$(ord(i) lt ord(j))..
  eo(i,j,'s1') =g= comp(i) - start(j);

disjoint2(i,j)$(ord(i) lt ord(j))..
  eo(i,j,'s2') =g= comp(j) - start(i);

* This is really max(0, comp(j) - data('due',j))
deflate(j)..
  late(j) =g= comp(j) - data('due',j);

deftard(j)..
  tardiness =g= late(j);

model sequence /all/;
sequence.optcr = 0;

start.lo(j) = max(0, data('release',j));

solve sequence using mip min tardiness;

* How to generate sequence from start times?
* parameter rank(i) = sort(start);
