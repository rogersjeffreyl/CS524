$title Weasley's Wizard Wheezes
sets
  advertising_type "Method of advertising" /WizardTv, Magazines, Radio/;
variables 
  advertising_units(advertising_type) "Advertising  units for the corresponding advertising type";
positive variable advertising_units;
advertising_units.fx('Radio') = 0;  
parameters
   cost(advertising_type) "cost for each advertising type"
    / WizardTv   20000
      Magazines  10000
      Radio      2000 /,
   reach(advertising_type) "number of people reached for each advertising type"
     / WizardTv  1800000
       Magazines  1000000
       Radio      250000 /,

  wizard_weeks(advertising_type) "weeks required to create content for each type"
     / WizardTv   7
       Magazines  21 
       Radio      1 / ;

advertising_units.lo('WizardTv')=10;
free variable audience_reached "number of peope reached through advertising";
scalar max_budget "maximum budget for advertising" /1000000/  ;
scalar max_wizarding_weeks " maximum weeks available for content creation" /700/;
equations
  number_of_people_reached "number of people reached - the objective to be maximized",
  budget_limitations "budget limitations for advertising"; 

number_of_people_reached..
  audience_reached =e= sum((advertising_type),reach(advertising_type) * advertising_units(advertising_type));

budget_limitations..
  sum((advertising_type), cost(advertising_type) * advertising_units(advertising_type)) =l= max_budget ; 


model max_audience  /number_of_people_reached, budget_limitations/;

solve max_audience using lp maximizing audience_reached;

display advertising_units.l;
display audience_reached.l;
display max_audience.modelstat, max_audience.solvestat,max_audience.objval, advertising_units.l; 

equations
   wizard_week_limits "limits on the time taken to curate ad content per week";

wizard_week_limits..
  sum((advertising_type), wizard_weeks(advertising_type) * advertising_units(advertising_type)) =l= max_wizarding_weeks ;


model max_audience_with_wizard_weeks  /number_of_people_reached, budget_limitations, wizard_week_limits/;

solve max_audience_with_wizard_weeks  using lp maximizing audience_reached; 

display advertising_units.l;
display audience_reached.l;
display max_audience_with_wizard_weeks.modelstat, max_audience_with_wizard_weeks.solvestat,max_audience_with_wizard_weeks.objval, advertising_units.l;

*Freeing up the fixed values to add the radio constraint
advertising_units.lo('Radio') = 0;
advertising_units.up('Radio') = max_budget /cost('Radio');
equations
  number_of_people_reached_with_radio "number of people reached with radio - the objective to be maximized";
number_of_people_reached_with_radio..
  audience_reached =e= sum((advertising_type),reach(advertising_type) * advertising_units(advertising_type));

model max_audience_with_wizard_weeks_radio  /number_of_people_reached_with_radio, budget_limitations,wizard_week_limits /;

solve max_audience_with_wizard_weeks_radio using lp maximizing audience_reached;
display advertising_units.l;
display audience_reached.l;
display max_audience_with_wizard_weeks_radio.modelstat, max_audience_with_wizard_weeks_radio.solvestat,max_audience_with_wizard_weeks_radio.objval, advertising_units.l;

*Adding bounds on radio and magzine units
advertising_units.up('Radio') = 120;
advertising_units.lo('Magazines') = 2;

model max_audience_with_wizard_weeks_radio_magazine_constraint  /number_of_people_reached_with_radio, budget_limitations,wizard_week_limits /;

solve max_audience_with_wizard_weeks_radio_magazine_constraint using lp maximizing audience_reached;

display advertising_units.l;
display audience_reached.l;
display max_audience_with_wizard_weeks_radio_magazine_constraint.modelstat, max_audience_with_wizard_weeks_radio_magazine_constraint.solvestat,max_audience_with_wizard_weeks_radio_magazine_constraint.objval, advertising_units.l;
     
