/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name membercost
FROM Facilities 
WHERE membercost <> 0.0;


/* Q2: How many facilities do not charge a fee to members? */

    A: 4
    
SELECT COUNT(membercost) AS count_no_cost 
FROM Facilities 
WHERE membercost = 0.0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name AS facility_name, membercost, monthlymaintenance AS monthly_maintenance 
FROM Facilities 
WHERE membercost <> 0.0 AND membercost < monthlymaintenance*0.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM Facilities
WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
    CASE WHEN monthlymaintenance > 100 THEN 'expensive'
         ELSE 'cheap'
    END AS cost_category
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname FROM Members WHERE joindate = (SELECT MAX(joindate) FROM Members WHERE firstname NOT LIKE 'GUEST');


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(m1.firstname, ' ', m1.surname) AS member_name, f1.name AS tennis_count
FROM Bookings AS b1 
LEFT JOIN Members AS m1 
	ON b1.memid = m1.memid
LEFT JOIN Facilities AS f1
	ON b1.facid = f1.facid
WHERE f1.name LIKE 'Tennis%'
ORDER BY full_name;



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f1.name AS facility_name, CONCAT(m1.surname, ', ', m1.firstname) AS member_name,
       CASE
           WHEN b1.memid = 0 THEN f1.guestcost * b1.slots
           ELSE f1.membercost * b1.slots
       END AS cost
FROM Bookings AS b1
LEFT JOIN Facilities AS f1 ON b1.facid = f1.facid
LEFT JOIN Members AS m1 ON b1.memid = m1.memid
WHERE b1.starttime LIKE '2012-09-14%'
  AND (b1.memid = 0 AND f1.guestcost * b1.slots > 30 OR b1.memid != 0 AND f1.membercost * b1.slots > 30)
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT f1.name AS facility_name,
       CONCAT(m1.surname, ', ', m1.firstname) AS member_name,
       subq.cost AS cost
FROM Bookings AS b1
JOIN Facilities AS f1 ON b1.facid = f1.facid
LEFT JOIN Members AS m1 ON b1.memid = m1.memid
JOIN (
    SELECT b2.bookid,
           CASE
               WHEN b2.memid = 0 THEN f2.guestcost * b2.slots
               ELSE f2.membercost * b2.slots
           END AS cost
    FROM Bookings AS b2
    JOIN Facilities AS f2 
    ON b2.facid = f2.facid
    WHERE b2.starttime LIKE '2012-09-14%'
) AS subq ON b1.bookid = subq.bookid
WHERE (b1.memid = 0 AND subq.cost > 30) OR (b1.memid != 0 AND subq.cost > 30)
ORDER BY subq.cost DESC;



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

        SELECT f1.name AS facility_name,
        SUM(CASE
               WHEN b1.memid = 0 THEN f1.guestcost * b1.slots
               ELSE f1.membercost * b1.slots
           END) AS total_revenue
        FROM Bookings AS b1
        JOIN Facilities AS f1 ON b1.facid = f1.facid
        GROUP BY f1.facid
        HAVING total_revenue < 1000
        ORDER BY total_revenue
        ;
        

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.surname AS member_surname,
       m1.firstname AS member_firstname,
       m2.surname AS recommender_surname,
       m2.firstname AS recommender_firstname
FROM Members AS m1
LEFT JOIN Members AS m2 ON m1.recommendedby = m2.memid
ORDER BY member_surname, member_firstname;


/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name AS facility_name, b.memid,
       SUM(b.slots) AS usage_by_member
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.facid, b.memid
ORDER BY usage_by_member DESC;


/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name AS facility_name,
       strftime('%m', b.starttime) AS month,
       strftime('%Y', b.starttime) AS year,
       SUM(b.slots) AS usage_by_members
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.facid, year, month
ORDER BY usage_by_members DESC
;
