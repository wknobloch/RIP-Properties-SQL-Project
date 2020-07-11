/*Keeping notes here simple. Dropping all tables first, to get a clean bill.
Once that is done, I will be adding each table.
The one note following explains the only complexity in this file*/
DROP TABLE Promotion
CASCADE CONSTRAINTS;
DROP TABLE Reward_Member_Promotion
CASCADE CONSTRAINTS;
DROP TABLE Local_Attraction
CASCADE CONSTRAINTS;
DROP TABLE Employee_Salary_History
CASCADE CONSTRAINTS;
DROP TABLE Department
CASCADE CONSTRAINTS;
DROP TABLE Time_Card
CASCADE CONSTRAINTS;
DROP TABLE Employee
CASCADE CONSTRAINTS;
DROP TABLE Membership_Level_Tier
CASCADE CONSTRAINTS;
DROP TABLE Reward_Member
CASCADE CONSTRAINTS;
DROP TABLE Property_Attraction
CASCADE CONSTRAINTS;
DROP TABLE Clock_In
CASCADE CONSTRAINTS;
DROP TABLE Customer
CASCADE CONSTRAINTS;
DROP TABLE Feedback_Note
CASCADE CONSTRAINTS;
DROP TABLE Credit_Card
CASCADE CONSTRAINTS;
DROP TABLE Property
CASCADE CONSTRAINTS;
DROP TABLE Employee_Type
CASCADE CONSTRAINTS;
DROP TABLE Reservation
CASCADE CONSTRAINTS;
DROP TABLE Room_Type
CASCADE CONSTRAINTS;
DROP TABLE Special_Event_Room
CASCADE CONSTRAINTS;
DROP TABLE Room_Feature
CASCADE CONSTRAINTS;
DROP TABLE Property_Partner
CASCADE CONSTRAINTS;
DROP TABLE Business_Partner
CASCADE CONSTRAINTS;
DROP TABLE Reservation_Day
CASCADE CONSTRAINTS;
DROP TABLE Discount
CASCADE CONSTRAINTS;
DROP TABLE Room_Day_Rate
CASCADE CONSTRAINTS;
DROP TABLE Room_Rate_Code
CASCADE CONSTRAINTS;
DROP TABLE Feature
CASCADE CONSTRAINTS;
/*Property
Property_ID - The primary key
Property_Name - Full Name of the property
Property_Address - Full address ""
Property_Desc - Brief description ""
Property_Phone - Phone number of property as 10 digit no punctuation number (5085551212)
Manager_ID - Employee ID of the manager. I set the foreign key constraint later, after defining the employee table*/
CREATE TABLE Property (
Property_ID INT PRIMARY KEY, 
Property_Name VARCHAR(25) NOT NULL, 
Property_Address VARCHAR(100) NOT NULL, 
Property_Desc VARCHAR(100) NOT NULL, 
Property_Phone VARCHAR(10) NOT NULL, 
Manager_ID NUMBER);
/*Employee_Type
Etype_ID - Primary key
Etype_Desc - Description of employee type, like "Part Time"
Benefit_Class - Benefit class of employees, like "No Benefits"*/
CREATE TABLE Employee_Type (
Etype_ID INT PRIMARY KEY,
Etype_Desc VARCHAR(25) NOT NULL,
Benefit_Class VARCHAR(25) NOT NULL);
/*Employee
Employe_ID - Primary key
Employee_Name - Full name (first and last) of employee
Emplyee_DOB - Date of Birth
Active - Currently active (Y or N)
Property_ID - ID of property they work at
Etype_ID - ID coressponding to their employee type*/
CREATE TABLE Employee (
Employee_ID INT PRIMARY KEY,
Employee_Name VARCHAR(40) NOT NULL,
Employee_DOB DATE NOT NULL,
Active CHAR(1) NOT NULL,
Property_ID INT REFERENCES Property(Property_ID) NOT NULL,
Etype_ID INT REFERENCES Employee_Type(Etype_ID) NOT NULL,
CONSTRAINT Employee_Active_YN
CHECK(Active IN ('Y','N')));
/*Adding foreign key constraint on property table*/
ALTER TABLE Property
ADD FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE;
/*Department
Department_ID - Primary KEy
Department Name - Name of the department*/
CREATE TABLE Department (
Department_ID INT PRIMARY KEY,
Department_Name VARCHAR(20) NOT NULL);
/*Time_Card
Employee_ID - Employee who owns the timecard
Department_ID - What department they are clocking in to*/
CREATE TABLE Time_Card (
Employee_ID INT REFERENCES Employee(Employee_ID),
Department_ID INT REFERENCES Department(Department_ID),
PRIMARY KEY(Employee_ID, Department_ID));
/*Employee_Salary_History
Employee_ID - Employe who has the history
Salary_Start_Date - When they started getting this pay
Salary_Value - How much they are paid
Salaried - Are they paid by hour ('N') or by year ('Y')*/
CREATE TABLE Employee_Salary_History (
Employee_ID INT REFERENCES Employee(Employee_ID),
Salary_Start_Date DATE,
Salary_Value NUMBER NOT NULL,
Salaried CHAR(1) NOT NULL,
PRIMARY KEY(Employee_ID, Salary_Start_Date),
CONSTRAINT Employee_Salaried
CHECK(Salaried IN ('Y','N')));
/*Clock_In
Employee_ID - What employee is clocked in
Department_ID - What department employee clocked in to
Clock_In_Time - When they clocked in
Clock_Out_Time - When they clocked out
Meal_Break_Start - When (if) they went on lunch break
Meal_Break_End - When they returned from lunch break*/

/*Some major constraints in this table
-The clock out time is later than the clock in time
-The meal start time is between clock in and clock out
-The meal end time is between meal start and clock out
-The meal duration is less than an hour (If you have a longer meal than that, clock out and clock back in.)
-The clock in duration is less than 16 hours*/
CREATE TABLE Clock_In (
Employee_ID INT REFERENCES Employee(Employee_ID),
Department_ID INT REFERENCES Department(Department_ID),
Clock_In_Time TIMESTAMP,
Clock_Out_Time TIMESTAMP,
Meal_Break_Start TIMESTAMP,
Meal_Break_End TIMESTAMP,
PRIMARY KEY(Employee_ID, Department_ID, Clock_In_Time),
CONSTRAINT Check_Clock_Out_Time
CHECK(Clock_Out_Time>Clock_In_Time),
CONSTRAINT Meal_Start_Time
CHECK(Meal_Break_Start BETWEEN Clock_In_Time AND Clock_Out_Time),
CONSTRAINT Meal_End_Time
CHECK(Meal_Break_End BETWEEN Meal_Break_Start AND Clock_Out_Time),
CONSTRAINT Meal_Duration
CHECK(extract(day from Meal_Break_End-Meal_Break_Start)=0 AND extract(hour from Meal_Break_End-Meal_Break_Start)=0),
CONSTRAINT Work_Duration
CHECK(extract(day from Clock_Out_Time-Clock_In_Time)=0 AND extract(hour from Clock_Out_Time-Clock_In_Time)<16)
);
/*Local Attraction
Attraction_ID - Primary key
Attraction_Name - Name of the attraction
Attraction_Type - Type of attraction ("Restaurant")
Attraction_DESC - Short description*/
CREATE TABLE Local_Attraction (
Attraction_ID INT PRIMARY KEY,
Attraction_Name VARCHAR(30) NOT NULL,
Attraction_Type VARCHAR(30) NOT NULL,
Attraction_DESC VARCHAR(100) NOT NULL);
/*Property_Attraction
Property_ID - What property is near the attraction
Attraction_ID - The attraction
Distance - How far from the property the attraction is ("5 Miles" or "Across the Street")*/
CREATE TABLE Property_Attraction (
Property_ID INT REFERENCES Property(Property_ID),
Attraction_ID INT REFERENCES Local_Attraction(Attraction_ID),
Distance VARCHAR(25) NOT NULL,
PRIMARY KEY(Property_ID, Attraction_ID));
/*Business_Partner
Business_Partner_ID - Primary Key
Business_Name - Name of the business
Business_Contact_Name - Full name of the primary contact
Business_Address - Full address of the business
Business_Phone - Phone number of the business (5085551212 format)*/
CREATE TABLE Business_Partner (
Business_Partner_ID INT PRIMARY KEY,
Business_Name VARCHAR(25) NOT NULL,
Business_Contact_Name VARCHAR(30) NOT NULL,
Business_Address VARCHAR(100) NOT NULL,
Business_Phone VARCHAR(10) NOT NULL);
/*Property_Partner
Property_ID - Property partnered
Business_Partner_ID - Business partnered with*/
CREATE TABLE Property_Partner (
Property_ID INT REFERENCES Property(Property_ID),
Business_Partner_ID INT REFERENCES Business_Partner(Business_Partner_ID),
PRIMARY KEY(Property_ID, Business_Partner_ID));
/*Room_Type
Room_Type_ID - Primary key
Room_Type_Name - Name of the room type ("Transylvanian King Bed")
Room_Type_Desc - Description of the room
No_Show_Penalty - How much is charged to customer if room is booked and not filled
Property_ID - Property the room is in */
CREATE TABLE Room_Type (
Room_Type_ID INT PRIMARY KEY,
Room_Type_Name VARCHAR(30) NOT NULL,
Room_Type_Desc VARCHAR(100) NOT NULL,
No_Show_Penalty NUMBER NOT NULL,
Property_ID INT REFERENCES Property(Property_ID) NOT NULL);
/*Room_Rate_Code
Room_Rate_Code_ID - Primary Key
Weekday_Rate - Charge for room for one weekday night
Weekend_Rate - Charge for room for one weekend night
Rate_Code_Desc - Description of the rate ("Transylvanian Heights King Room Peak Rate")*/
CREATE TABLE Room_Rate_Code (
Room_Rate_Code_ID INT PRIMARY KEY,
Weekday_Rate NUMBER NOT NULL,
Weekend_Rate NUMBER NOT NULL,
Rate_Code_Desc VARCHAR(50) NOT NULL);
/*Room_Day_Rate
Room_Type_ID - The room being priced
Room_Rate_Code_ID - The price code being used
Rate_Start_Date - When the rate starts. It will continue until supplanted by a later rate.*/
CREATE TABLE Room_Day_Rate (
Room_Type_ID INT REFERENCES Room_Type(Room_Type_ID),
Room_Rate_Code_ID INT REFERENCES Room_Rate_Code(Room_Rate_Code_ID),
Rate_Start_Date DATE NOT NULL,
PRIMARY KEY(Room_Type_ID, Room_Rate_Code_ID));
/*Customer
Customer_ID - Primary key
Customer_Name - Full name of the customer
Customer_Address - Full address of the customer
Customer_Phone - Phone number of customer (5085551212 format)*/
CREATE TABLE Customer (
Customer_ID INT PRIMARY KEY,
Customer_Name VARCHAR(50) NOT NULL,
Customer_Address VARCHAR(100) NOT NULL,
Customer_Phone NUMBER(10) NOT NULL);
/*Reservation 
Reservation_ID - Primary key
Customer ID - Who is making the reservation
Room_Type_ID - What room is being reserved*/
CREATE TABLE Reservation (
Reservation_ID INT PRIMARY KEY,
Customer_ID INT  NOT NULL REFERENCES Customer(Customer_ID),
Room_Type_ID INT  NOT NULL REFERENCES Room_Type(Room_Type_ID));
/*Discount
Discount_ID - Primary key
Discount_Value - Percentage discount applied to base price of room at checkout (0.2 = 20% discount)
Discount_Desc - Description of the discount ("15% military discount")*/
CREATE TABLE Discount (
Discount_ID INT PRIMARY KEY,
Discount_Value NUMBER NOT NULL,
Discount_Desc VARCHAR(50) NOT NULL);
/*Reservation_Day
Reservation_ID - Which reservation this day applies to
Reservation_Date - Day of the reservation
Base_Price - Rate of room, defined at booking time. Designed to not change if room price is changed later.
Base_No_Show - Penalty if customer does not show. Designed not to change if no_show rate of room is changed later.
Discount_ID - ID of discount applied to this day of stay. Limit one discount applied to a room per night.*/
CREATE TABLE Reservation_Day (
Reservation_ID INT REFERENCES Reservation(Reservation_ID),
Reservation_Date DATE,
Base_Price NUMBER NOT NULL,
Base_No_Show NUMBER NOT NULL,
Discount_ID INT REFERENCES Discount(Discount_ID),
PRIMARY KEY(Reservation_ID,Reservation_Date));
/*Feedback_Note
Note_ID - Primary Key
Customer_ID - Customer with the feedback
Property_ID - Property getting feedback
Date_Of_Stay - Date customer stayed at location
Rating - Rating between 1 and 5 stars
Feedback_Text - The customer's comment, limited to 1 twitter post in length (1 twit)*/
CREATE TABLE Feedback_Note (
Note_ID INT PRIMARY KEY,
Customer_ID INT NOT NULL REFERENCES Customer(Customer_ID),
Property_ID INT NOT NULL REFERENCES Property(Property_ID),
Date_Of_Stay DATE NOT NULL,
Rating INT NOT NULL,
Feedback_Text VARCHAR(280) NOT NULL,
CONSTRAINT Valid_Rating
CHECK(Rating BETWEEN 1 AND 5));
/*Credit_Card
Credit_Card_ID - Primary Key
Credit_Card_Number - Full credit card number
Customer ID - Who has this card on their account
Expiration date - Date of card expiration
Name on card - Full name on card as written*/
CREATE TABLE Credit_Card (
Credit_Card_ID INT PRIMARY KEY,
Credit_Card_Number VARCHAR(19) NOT NULL,
Customer_ID INT NOT NULL REFERENCES Customer(Customer_ID),
Expiration_Date DATE NOT NULL,
Name_On_Card VARCHAR(50) NOT NULL);
/*Membership_Level_Tier
Tier_ID - Primary key
Tier_Name - Name of membership tier ("Gold","Super Gold","Extreme Gold")
Tier_Desc - Short description of tier*/
CREATE TABLE Membership_Level_Tier (
Tier_ID INT PRIMARY KEY,
Tier_Name VARCHAR(15) NOT NULL,
Tier_Desc VARCHAR(100) NOT NULL);
/*Reward_Member
Reward Number - Primary key, also the actual reward number of the customer.
Reward_Login - Login name to access the customer account
Reward_Password - Customer's password, stored in plaintext for easy access for hackers
Tier_ID - What tier the customer is
Customer_ID - What customer has the account. One account per customer*/
CREATE TABLE Reward_Member (
Reward_Number INT PRIMARY KEY,
Reward_Login VARCHAR(20) NOT NULL,
Reward_Password VARCHAR(20) NOT NULL,
Tier_ID INT NOT NULL REFERENCES Membership_Level_Tier(Tier_ID),
Customer_ID INT UNIQUE NOT NULL REFERENCES Customer(Customer_ID));
/*Promotion
Promotion_ID - Primary Key
Promotion_Name - Name of the promotion
Promotion_Desc - Short description
Promotion_Type - What kind of promotion it is ("% off", "rate discount", "Free Breakfast")
Promotion_Discount_Value - Value of discount (0.2, -100, NULL)
Promotion_Req - Requirements to be eligible for this promotion*/
CREATE TABLE Promotion (
Promotion_ID INT PRIMARY KEY,
Promotion_Name VARCHAR(30) NOT NULL,
Premotion_Desc VARCHAR(100) NOT NULL,
Promotion_Type VARCHAR(30) NOT NULL,
Promotion_Discount_Value NUMBER NOT NULL,
Promotion_Req VARCHAR(100) NOT NULL);
/*Reward_Member_Promotion
Reward_Number - ID of reward member
Promition_ID - ID of the promotion signed up for*/
CREATE TABLE Reward_Member_Promotion (
Reward_Number INT REFERENCES Reward_Member(Reward_Number),
Promotion_ID INT REFERENCES Promotion(Promotion_ID),
PRIMARY KEY(Reward_Number, Promotion_ID));
/* Feature
Feature_ID - Primary key
Feature_Name - Name of the feature
Feature_Desc - Description of the feature*/
CREATE TABLE Feature (
Feature_ID INT PRIMARY KEY,
Feature_Name VARCHAR(30) NOT NULL,
Feature_Desc VARCHAR(100) NOT NULL);
/*Room_Feature
Room_Type_ID - Room type with the feature
Feature_ID - ID of the feature*/
CREATE TABLE Room_Feature (
Room_Type_ID INT REFERENCES Room_Type(Room_Type_ID),
Feature_ID INT REFERENCES Feature(Feature_ID),
PRIMARY KEY(Room_Type_ID, Feature_ID));
/*Special_Event_Room
Event_Room_ID - Primary key
Room_Type_ID - What room type is the special event room
Max_Capacity - Max number of people in the event room*/
CREATE TABLE Special_Event_Room (
Event_Room_ID INT PRIMARY KEY,
Room_Type_ID INT NOT NULL REFERENCES Room_Type(Room_Type_ID),
Max_Capacity INT NOT NULL);

