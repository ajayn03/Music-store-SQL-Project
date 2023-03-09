/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) , billing_country 
FROM invoice
GROUP BY 2
ORDER BY 1 DESC

/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */     

select billing_city, sum(total) as invoice_total from invoice
group by 1 
order by 2 desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select 
c.customer_id , 
concat(c.first_name,' ',c.last_name) as full_name,
sum(i.total) as total_spendings
from customer c
inner join invoice i  
on c.customer_id = i.customer_id
group by c.first_name,c.last_name , c.customer_id
order by 3 desc 
limit 1

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email,c.first_name,c.last_name , g.name
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on t.track_id = il.track_id
join genre g on t.genre_id = g.genre_id 
where g.name = 'Rock'
order by 1 asc

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */    

select 
	 a.name, count(*) 
from artist a  
join album al on a.artist_id = al.artist_id  
join track t on al.album_id = t.album_id  
join genre g on g.genre_id = t.genre_id   
where g.name = 'Rock'
group by 1
order by 2 desc 
limit 10 


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
 
select 
t.name , milliseconds
from track t
where milliseconds > (select avg(milliseconds) from track)
order by 2 desc


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

select c.customer_id, concat(c.first_name,' ',c.last_name) as full_name, ar.name, 
sum(il.unit_price*il.quantity) as Total_spent 
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join artist ar on ar.artist_id = a.album_id
group by 1,2,3
order by 1 ) 


/* Q10: Find how much amount spent by customer on best selling artist? Write a query to return customer name, artist name and total spent */

with best_selling_artist as(
SELECT 
	ar.artist_id AS artist_id, 
	ar.name AS artist_name, 
	SUM(il.unit_price*il.quantity) AS total_sales
FROM invoice_line il 
JOIN track t ON t.track_id = il.track_id
JOIN album a ON a.album_id = t.album_id
JOIN artist ar ON ar.artist_id = a.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1 )
select 
	c.customer_id , c.first_name ,c.last_name, 
	bsa.artist_name, 
	SUM(il.unit_price*il.quantity) AS total_sales
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = a.artist_id
	group by 1,2,3,4
	order by 5 desc
	

/* Q11: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as(
select 
	c.country,count(*) as purchases, g.genre_id , g.name,
	rank()over(partition by c.country order by count(*) desc ) as rk
from customer c 
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on t.track_id = il.track_id
join genre g on t.genre_id = g.genre_id 
	group by 1,3,4) 
select * from popular_genre
where rk =1


/* Q12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as (
select 
c.customer_id,c.first_name,c.last_name,i.billing_country,SUM(i.total) AS total_spending,
row_number()over(partition by i.billing_country order by SUM(i.total) desc ) as rn
from customer c
join invoice i on c.customer_id=i.customer_id
group by 1,2,3,4
order by 4 , 5 desc) 
select * from customer_with_country 
where rn = 1







