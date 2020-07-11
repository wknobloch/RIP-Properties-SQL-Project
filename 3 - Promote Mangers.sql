/*This is a simple transaction to promote Frank N Furter and Remus Lupin to managers.*/
/*First, setting the manager of the 1st property.*/
UPDATE Property
SET Manager_ID=1
WHERE Property_ID=1;
/*We also want to give Frank a new paygrade along with the promotion. He is also changing from hourly to salaried*/
INSERT INTO Employee_Salary_History
VALUES(1,CURRENT_DATE,33000,'Y');

/*Setting the manager of the 2nd property.*/
UPDATE Property
SET Manager_ID=2
WHERE Property_ID=2;
/*Management likes Remus a bit better, and gave him higher pay. It helps that Remus actually has staff to worry about*/
INSERT INTO Employee_Salary_History
VALUES(2,CURRENT_DATE,36000,'Y');

/*Of course, this also means that Frank and Remus are full time now*/
UPDATE Employee
SET etype_ID=1
WHERE Employee_ID IN (1,2);

/*Three brief select statements just to verify the updates
First, the new manager ID's in Property.
Second, the new Etype_ID's in the Employee ID
Third, the 2 new entries in the Salary chart.
*/
SELECT * FROM Property;

SELECT * FROM Employee
WHERE Employee_ID IN (1,2);

SELECT * FROM Employee_Salary_History
WHERE Employee_ID IN(1,2)
ORDER BY Employee_ID ASC;