$title Lights Out 

set cell_dim /1*5/;

alias (cell_dim,i,j);
integer variable light_status(i,j) "light status = 0 implies light is off";
integer variable switch_clicked(i,j) "";

free variable num_turns;
equations
	objective_eq,
    light_state_toggle_eqn(i,j);

objective_eq..
	num_turns =e= sum((i,j),switch_clicked(i,j)); 

light_state_toggle_eqn(i,j)..
	switch_clicked(i-1,j)+switch_clicked(i,j-1)+switch_clicked(i,j)+switch_clicked(i,j+1)+switch_clicked(i+1,j)+1 =e= 2*light_status(i,j)

model lights_out /light_state_toggle_eqn , objective_eq/;

solve lights_out using mip minimizing num_turns;
	
display light_status.L;


equations
	light_state_toggle_eqn_1(i,j);
	

switch_clicked.L(i,j)=0;

scalar init /3/;
light_state_toggle_eqn_1(i,j)..
	switch_clicked(i-1,j)+switch_clicked(i,j-1)+switch_clicked(i,j)+switch_clicked(i,j+1)+switch_clicked(i+1,j)+init =e= 4*light_status(i,j);

model lights_out_3 /light_state_toggle_eqn_1 , objective_eq/;
solve lights_out_3 using mip minimizing num_turns;

init =2;
model lights_out_2 /light_state_toggle_eqn_1 , objective_eq/;
solve lights_out_2 using mip minimizing num_turns;

init =1;
model lights_out_1 /light_state_toggle_eqn_1 , objective_eq/;
solve lights_out_1 using mip minimizing num_turns;