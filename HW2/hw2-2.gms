$title Bussville

set school /Cooley, Whitman/;
set district /District1 * District3/; 
set student_type /minority, non-minority/;
table number_of_students(district, student_type) "number of students of each type from each district"
                  minority   non-minority
      District1    50          200
      District2    50          250
      District3    100         150 ;
table distance(district, school) "distance of each school from the districts"
                   Cooley   Whitman
      District1      1.2       1.8
      District2      2.2       0.9
      District3      1.4       0.8 ;
 
variables
  number_of_students_enrolled(district , school, student_type) "numer of students of each type and  district enrolled in a particular school";
positive variable number_of_students_enrolled;  
free variable distance_travelled "total distance travelled by the students";    
equations
  percentage_of_minority_1 "upper bound on percentage difference of minority students between Whitman and Cooley",
  percentage_of_minority_2 "lower bound on percentage difference of minority students between Whitman and Cooley",
  number_of_students_constraint(district , student_type) "constraint that states the number of students enrolled should not exeed the available students", 	
  school_enrollment_up(school) "upper bound on the total number of students enrolled",
  school_enrollment_lo(school) "lower bound on the total number of students enrolled",
  minimum_distance "objective that has to be minimized";

percentage_of_minority_1..
   sum(district,number_of_students_enrolled(district,'Whitman','minority')) - sum(district,number_of_students_enrolled(district,'Cooley','minority')) =l= 0.05 * sum((school, district), number_of_students_enrolled(district , school, 'minority')); 
 
percentage_of_minority_2..
   sum(district,number_of_students_enrolled(district,'Whitman','minority')) - sum(district,number_of_students_enrolled(district,'Cooley','minority')) =g= -0.05 * sum((school, district), number_of_students_enrolled(district , school, 'minority'));

minimum_distance..
   distance_travelled =e=  sum((district, school, student_type), number_of_students_enrolled(district , school, student_type) * distance(district, school));

number_of_students_constraint(district , student_type)..
   sum(school,number_of_students_enrolled(district , school, student_type)) =e= number_of_students(district, student_type);

school_enrollment_lo(school)..
  sum((district, student_type),number_of_students_enrolled(district , school, student_type)) =g= 350;


school_enrollment_up(school)..
  sum((district, student_type),number_of_students_enrolled(district , school, student_type)) =l= 500;
  
model hw2_2 /all/; 
solve hw2_2 using lp minimizing distance_travelled;
display number_of_students_enrolled.l;
display distance_travelled.l;
