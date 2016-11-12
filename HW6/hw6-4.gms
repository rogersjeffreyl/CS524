$title Lights Out 

set cell_dim /1*5/;

alias (cell_dim,i,j);
binary variable light_status(i,j) "light status = 0 implies light is off";
binary variable switch_clicked(i,j) "";
light_status.L(i,j)=1;

positive variable y(i,j);
y.up(i,j)=2;
y.lo(i,j)=0;
free variable num_turns;
equations
	objective_eq,
	all_lights_turned_off,
    light_state_toggle_eqn(i,j);

all_lights_turned_off..
sum((i,j),light_status(i,j)) =e=0;
objective_eq..
	num_turns =e= sum((i,j),switch_clicked(i,j)); 

light_state_toggle_eqn(i,j)..
	switch_clicked(i-1,j)+switch_clicked(i,j-1)+switch_clicked(i,j)+switch_clicked(i,j+1)+switch_clicked(i+1,j) =e= 2*y(i,j)+1-light_status(i,j)

model lights_out /light_state_toggle_eqn , all_lights_turned_off, objective_eq/;

solve lights_out using mip minimizing num_turns;
	

display light_status.L;







