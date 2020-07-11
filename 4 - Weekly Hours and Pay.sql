/*Fun with employee timecards
I honestly do not know if I should be proud of this page or ashamed of it. It is definitely a but of a hack job that shows more of my skills as a programmer than as an database operator.
I've broken down the main query into some sub-queries to show how I arrived at it*/

/*The first query shows Xander Harris his timecard for the week. There are some complexities in here about date and time formatting, and Iterval math adding and subtracting dates.
I figured out later in the process that a NULL in the break time would interfere with everything else, so I had to look into the NVL function to deal with that issue.*/
SELECT to_char(Clock_In_Time,'MM/DD/YYYY') as Day, 
        to_char(Clock_In_Time,'HH24:MI') as Clock_In, 
        to_char(Clock_Out_Time,'HH24:MI') as Clock_Out, 
        NVL(extract(minute from Meal_Break_End-Meal_Break_Start),0) as Break, 
        SUBSTR(Clock_Out_Time-Clock_In_Time-NVL(Meal_Break_End-Meal_Break_Start,INTERVAL '0' MINUTE),12,5) AS Time_Worked
FROM Clock_In
WHERE Employee_ID=4;

/*The second query takes use of the TIME_WORKED substring I wrote out for Xander's timecard.
This one sums the time worked for ALL employees and groups them by employee.
One major issue here is that SUM() does not work on intervals, so here I had to pull in some typecasting to change the datatype to something that does work.
I basically subtract the dates/times, which converts them to an interval, pull the Hours and Minutes substrings from that, and add the Hours with the Minutes/60, ending with a number that can be summed.
This whole process is a really really good argument for the original table having the calculated Hours Worked value, even though it is not 3rd normalization with that.
*/
SELECT Employee_ID, SUM(TIME_WORKED) 
FROM (SELECT Employee_ID, 
        CAST(SUBSTR(Clock_Out_Time-Clock_In_Time-NVL(Meal_Break_End-Meal_Break_Start,INTERVAL '0' MINUTE),12,2) AS NUMBER)+CAST(SUBSTR(Clock_Out_Time-Clock_In_Time-NVL(Meal_Break_End-Meal_Break_Start,INTERVAL '0' MINUTE),15,2) AS NUMBER)/60 AS Time_Worked
FROM Clock_In)
GROUP BY Employee_ID;

/*Next, I want to pull the most recent Salary History for each staff member from the Salary History table. This shows each worker's current pay.
The fact that I need to do this in order to calculate their total pay for the week is a good reason for, again, discarding normalization to have their current salary stored in the employee table.
However, since I did not go that route, here is that calculation:
*/
SELECT employee.employee_name, a.SALARY_VALUE, SALARIED 
FROM employee, employee_salary_history a
INNER JOIN (
SELECT EMPLOYEE_ID, MAX(SALARY_START_DATE) as sal
FROM employee_salary_history
GROUP BY Employee_ID
) b ON a.Employee_ID=b.Employee_ID AND a.SALARY_START_DATE=b.sal
WHERE Employee.Employee_ID=a.employee_id;

/*Here is where I put all of it together.*/
/*The first part determines the weekly pay of our salaried employees (Frank and Remus, if file 3 has been done)*/
SELECT a.EMPLOYEE_ID, trunc(a.SALARY_VALUE/52,2) as WEEKLY_PAY 
FROM employee_salary_history a
INNER JOIN (
SELECT EMPLOYEE_ID, MAX(SALARY_START_DATE) as sal
FROM employee_salary_history
GROUP BY Employee_ID
) b ON a.Employee_ID=b.Employee_ID AND a.SALARY_START_DATE=b.sal AND salaried='Y'
/*Now we union that with the weekly pay of the remaining members - multiplying their current hourly rate by the number of hours they worked.*/
UNION (

SELECT Clocktime.Employee_ID, SUM(TIME_WORKED*Salary_Value) AS Weekly_Pay
FROM employee_salary_history A
INNER JOIN (
SELECT EMPLOYEE_ID, MAX(SALARY_START_DATE) as sal
FROM employee_salary_history
GROUP BY Employee_ID
) B ON a.Employee_ID=b.Employee_ID AND a.SALARY_START_DATE=B.sal,

(SELECT Employee_ID, 
        CAST(SUBSTR(Clock_Out_Time-Clock_In_Time-NVL(Meal_Break_End-Meal_Break_Start,INTERVAL '0' MINUTE),12,2) AS NUMBER)+CAST(SUBSTR(Clock_Out_Time-Clock_In_Time-NVL(Meal_Break_End-Meal_Break_Start,INTERVAL '0' MINUTE),15,2) AS NUMBER)/60 AS Time_Worked
FROM Clock_In) Clocktime
WHERE a.employee_id=clocktime.employee_id AND a.salaried='N'
GROUP BY Clocktime.Employee_ID )
ORDER BY Employee_ID ASC;

/*In a business environment, I would want to clean this up further to add the employees name and hours worked to this chart, but I feel this shows the overall abilities of the database to calculate these values.