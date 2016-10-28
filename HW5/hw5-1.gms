$title GlassCo
set  glass_type /WINEGLASS, BEERGLASS, CHMPGNEGLASS, WHISKEYGLASS/;
set  tasks  /'Molding', 'Packaging'/ ;
parameter molding_time(glass_type)
	/ WINEGLASS 4, 
	  BEERGLASS 9, 
	  CHMPGNEGLASS 7, 
	  WHISKEYGLASS   10/;
parameter packaging_time(glass_type)	  
	/ WINEGLASS 1, 
	  BEERGLASS 1, 
	  CHMPGNEGLASS 3, 
	  WHISKEYGLASS   40/;
parameter selling_price(glass_type)	  
	/ WINEGLASS 6, 
	  BEERGLASS 10, 
	  CHMPGNEGLASS 9, 
	  WHISKEYGLASS   20/;	  
parameter glass_required(glass_type)	  
	/ WINEGLASS 3, 
	  BEERGLASS 4, 
	  CHMPGNEGLASS 2, 
	  WHISKEYGLASS  1/;	  	  

scalar molding_time_up /600/ ; 
scalar packaging_time_up /400/;
scalar glass_quantity_up /500/;


free variable profit;
positive variable glass_quantity(glass_type)	; 

equations
	primal_objective_eq,
	molding_time_eq,
	packaging_time_eq,
	glass_quantity_eq;


primal_objective_eq..
	profit =e= sum(glass_type,glass_quantity(glass_type)* selling_price(glass_type));

molding_time_eq..
	sum(glass_type, glass_quantity(glass_type)* molding_time(glass_type)) =l= molding_time_up; 

packaging_time_eq..
	sum(glass_type, glass_quantity(glass_type)* packaging_time(glass_type)) =l= packaging_time_up;

glass_quantity_eq..

	sum(glass_type, glass_quantity(glass_type)* glass_required(glass_type)) =l= glass_quantity_up;

model glass_co_primal /primal_objective_eq, molding_time_eq, packaging_time_eq ,glass_quantity_eq /;
solve glass_co_primal using lp maximizing profit;


*Dual Formulation

positive variables
	glass_quantity_dual,
	molding_time_dual,
	packaging_time_dual;

free variable dual_objective;


equations
	dual_objective_equation,
	dual_constraints_WINEGLASS, 
	dual_constraints_BEERGLASS,
	dual_constraints_CHMPGNEGLASS,
	dual_constraints_WHISKEYGLASS;

dual_objective_equation..
	dual_objective =e= glass_quantity_dual * glass_quantity_up +molding_time_dual * molding_time_up + packaging_time_up * packaging_time_dual;

dual_constraints_WINEGLASS..
	glass_quantity_dual *glass_required('WINEGLASS') + molding_time_dual*molding_time('WINEGLASS')  +packaging_time_dual* packaging_time('WINEGLASS')	=g= selling_price('WINEGLASS');
dual_constraints_BEERGLASS..
	glass_quantity_dual *glass_required('BEERGLASS') + molding_time_dual*molding_time('BEERGLASS')  +packaging_time_dual* packaging_time('BEERGLASS')	=g= selling_price('BEERGLASS');
dual_constraints_CHMPGNEGLASS..
	glass_quantity_dual *glass_required('CHMPGNEGLASS') + molding_time_dual*molding_time('CHMPGNEGLASS')  +packaging_time_dual* packaging_time('CHMPGNEGLASS')	=g= selling_price('CHMPGNEGLASS');
dual_constraints_WHISKEYGLASS..
	glass_quantity_dual *glass_required('WHISKEYGLASS') + molding_time_dual*molding_time('WHISKEYGLASS')  +packaging_time_dual* packaging_time('WHISKEYGLASS')	=g= selling_price('WHISKEYGLASS');	

model glass_co_dual /dual_objective_equation,dual_constraints_WINEGLASS, dual_constraints_BEERGLASS, dual_constraints_CHMPGNEGLASS , dual_constraints_WHISKEYGLASS /;
solve glass_co_dual using lp minimizing dual_objective;		
