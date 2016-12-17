$title Flow shop scheduling  (Xpress models: pp 117-122)

$ontext
A workshop that produces metal pipes on demand for automotive industry
has three machines for bending the pipes, soldering the fastenings, 
and assembling the links.  The workshop has to produce six items,
for which the durations of the processing steps are given below. 
Once started, jobs must be carried out to completion, but
the workpieces(items) may wait between the machines.

Every machine only processs one item at a time.
A workpiece(item) may not overtake any other.

What is the sequence that minimizes the total time for 
completing all items (makespan)?
$offtext

option limrow = 0, limcol = 0;

set item / 1*6 /;
set mach /bending,soldering,assembly/;

table proctime(mach,item)
		1	2	3	4	5	6
bending		3	6	3	5	5	7
soldering	5	4	2	4	4	5
assembly	5	2	4	6	3	6
;

alias (item,i);
alias (mach,m);
set k 'position' / p1*p6 /;

set lastjob(k);
set lastmach(mach);
lastjob(k) = yes$(ord(k) eq card(k));
display lastjob;
lastmach(mach) = yes$(ord(mach) eq card(mach));

binary variable rank(i,k) "item i has position k";
positive variables start(m,k) "start time for job in position k on m";
positive variables comp(m,k) "completion time for job in postion k on m";
variable totwait "time before first job + times between jobs on last machine";

equations
  oneInPosition(k),
  oneRankPer(i),
  onmachrel(m,k),
  permachrel(m,k),
  defcomp(m,k),
  obj;

oneInPosition(k)..
  sum(i,rank(i,k)) =e= 1;

oneRankPer(i)..
  sum(k,rank(i,k)) =e= 1;

onmachrel(m,k)$(not lastjob(k))..
  start(m,k+1) =g= comp(m,k);

permachrel(m,k)$(not lastmach(m))..
  start(m+1,k) =g= comp(m,k);

defcomp(m,k)..
  comp(m,k) =e=
    start(m,k) + sum(i, proctime(m,i)*rank(i,k));

obj..
  totwait =e= sum((lastmach,lastjob), comp(lastmach,lastjob));

model sequence /all/;
sequence.optcr = 0;
solve sequence using mip min totwait;

* Maybe the following is better info to output
parameter startjob(m,i);
startjob(m,i) = sum(k$rank.l(i,k), start.l(m,k));

option rank:0:0:1; display rank.l;
option start:0:1:1; display start.l;
option startjob:0:1:1; display startjob;
display totwait.l;
