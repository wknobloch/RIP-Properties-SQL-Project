/*A few quick select statements to show who we are working with in this transaction.*/
/*Velma Dinkly is booking*/
SELECT * FROM Customer
WHERE customer_ID=5;
/*A room at the Transylvanian Heights*/
SELECT * FROM Room_Type
WHERE Room_Type_ID=1;
/*With this rate schedule*/
SELECT * FROM Room_Rate_Code NATURAL JOIN Room_Day_Rate
WHERE Room_Type_ID=1;
/*And apply this discount*/
SELECT *FROM Discount
WHERE Discount_ID=1;


/*We've had enough fun with employees. Now let's book some rooms*/
/*First of all, Velma is going to book a room for the girls in the gamg at Transylvanian Heights*/
INSERT INTO Reservation
VALUES(1,5,1);
INSERT INTO Reservation_Day
VALUES(1,TO_DATE('10/30/2020','MM/DD/YYYY'),0,0,NULL);
INSERT INTO Reservation_Day
VALUES(1,TO_DATE('10/31/2020','MM/DD/YYYY'),0,0,NULL);
INSERT INTO Reservation_Day
VALUES(1,TO_DATE('11/01/2020','MM/DD/YYYY'),0,0,NULL);
INSERT INTO Reservation_Day
VALUES(1,TO_DATE('11/02/2020','MM/DD/YYYY'),0,0,NULL);
/*But we need to set the No Show penalty for the room before we can complete the transaction*/
UPDATE Reservation_Day
SET Base_No_Show=(SELECT No_Show_Penalty
                  FROM Room_Type, Reservation
                  WHERE Room_Type.Room_Type_ID=Reservation.Room_Type_ID AND Reservation.Reservation_ID=Reservation_Day.Reservation_ID)
WHERE Reservation_Day.Reservation_ID=1;

/*Again, I need to work out the "How to" for searching the LATEST Rate_Start_Date that is BEFORE the book date,
so here is the SELECT statement I will be using for the subselect later. Not part of the transaction, but important
for showing my process*/
SELECT * FROM
(SELECT Room_Type_ID, Room_Rate_Code_ID, Rate_Start_Date
FROM Room_Day_Rate
WHERE Room_Type_ID=1 AND Rate_Start_Date<TO_DATE('11/02/2020','MM/DD/YYYY')
ORDER BY Rate_Start_Date DESC)
WHERE ROWNUM = 1;

/*Now we need to update the base price. Since weekends and weekdays have different prices, I'll do it in 2 statements*/
/*First, let's update the weekend rate*/
UPDATE Reservation_Day
SET Base_Price=(SELECT Weekend_Rate
                FROM Room_Rate_Code, (
                SELECT * FROM
(SELECT Room_Type_ID, Room_Rate_Code_ID, Rate_Start_Date
FROM Room_Day_Rate
WHERE Room_Type_ID=1 AND Rate_Start_Date<=Reservation_Day.Reservation_Date
ORDER BY Rate_Start_Date DESC)
WHERE ROWNUM = 1
) Day_Rate
WHERE Room_Rate_Code.Room_Rate_Code_ID=Day_Rate.Room_Rate_Code_ID)
WHERE Reservation_Day.Reservation_ID=1 AND TO_CHAR(Reservation_Day.Reservation_Date, 'D') IN (1,7);
/*Next, the weekday rate*/
UPDATE Reservation_Day
SET Base_Price=(SELECT Weekday_Rate
                FROM Room_Rate_Code, (
                SELECT * FROM
(SELECT Room_Type_ID, Room_Rate_Code_ID, Rate_Start_Date
FROM Room_Day_Rate
WHERE Room_Type_ID=1 AND Rate_Start_Date<=Reservation_Day.Reservation_Date
ORDER BY Rate_Start_Date DESC)
WHERE ROWNUM = 1
) Day_Rate
WHERE Room_Rate_Code.Room_Rate_Code_ID=Day_Rate.Room_Rate_Code_ID)
WHERE Reservation_Day.Reservation_ID=1 AND TO_CHAR(Reservation_Day.Reservation_Date, 'D') NOT IN (1,7);

/* She is also going to tap into her friend George's discount for people who wear ascots. This won't change the base price, but later transactions that look up the detail would apply the discount rate. */
UPDATE Reservation_Day
SET Discount_ID=1
WHERE Reservation_ID=1;
/* And the results. Note that the price changes from Saturday to Sunday. That's because Velma booked right over a rate change date of November 1st. 
Also note that the discount does not directly effect the base price. It will need to be applied in later queries when looking up transactions.*/
SELECT * FROM Reservation_Day
WHERE Reservation_ID=1;

