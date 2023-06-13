select * from album;

select * from artist;

/*Q1 How many albums have each artist made? Order your result in descending order. */
select album.artist_id ,artist.name,count(album.artist_id) as total_count
from album 
inner join artist on album.artist_id = artist.artist_id
group by album.artist_id,artist.name
order by total_count desc
--Iron Maiden has created most albums with the count of 21 abums--


/*Q2 Who is senior most employee based on job title? */
select title,first_name, last_name from employee
order by levels
limit 1
--Jane Peacock is the Senior most employee who works as Sales Supprt Agent--


/*Q3 Which countries have the most Invoices? */
select count(billing_country) as no_billing_country, billing_country
from invoice
group by billing_country
order by no_billing_country desc
--USA has the most bills with the count of 131--


/*Q4: Which are top 3 countries having total highest invoice? */
select (total), (billing_country) from invoice
order by (total) desc
limit 3
--France which is followed by Canada are the top 3 countries which generate highest bills--


/* Q5 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
      Write a query that returns one city that has the highest sum of invoice totals.
      Return both the city name & sum of all invoice totals */
select billing_city, sum(total)
from invoice
group by billing_city
order by sum(total) limit 1;
--Edmonton is the city with maximUM TOTAL OF 29.699


/* Q6: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
       Write a query that returns the person who has spent the most money.*/
SELECT CUS.CUSTOMER_ID,first_name, LAST_NAME, SUM(iv.TOTAL) AS TOTAL_SPENT
FROM CUSTOMER AS CUS
INNER JOIN INVOICE AS IV ON CUS.CUSTOMER_ID = IV.CUSTOMER_ID
GROUP BY CUS.CUSTOMER_ID
ORDER BY TOTAL_SPENT DESC
--R Madhav has spent most with total of 114.54


/* Q7  Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
       Return your list ordered alphabetically by email starting with A. */
SELECT DISTINCT EMAIL AS EMAIL, FIRST_NAME, LAST_NAME
FROM CUSTOMER AS CUS
INNER JOIN INVOICE AS IV ON CUS.CUSTOMER_ID = IV.CUSTOMER_ID
INNER JOIN INVOICE_LINE AS IVL ON IV.INVOICE_ID = IVL.INVOICE_ID
WHERE TRACK_ID IN (SELECT TRACK_ID FROM TRACK 
				  JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
				  WHERE GENRE.NAME = 'Rock')
--There are around 59 records of people who are Rock music listeners.--


/* Q8  Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/
select artist.name, count(artist.artist_id)
from artist 
inner join album on artist.artist_id = album.artist_id
inner join track on album.album_id = track.album_id
inner join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id


/* Q9 Return all the track names that have a song length longer than the average song length. 
      Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/
select name, milliseconds as song_length from track
where milliseconds > (select avg(milliseconds) from track)
order by song_length desc


/* Q10 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
with best_artist as(
	select ar.artist_id,ar.name,sum(ivl.unit_price*ivl.quantity) as total_sales
	from artist as ar
	join album on ar.artist_id = album.artist_id
	join track on album.album_id = track.album_id
	join invoice_line as ivl on ivl.track_id = track.track_id
	group by 1
	order by total_sales desc 
	limit 1
)
  select c.customer_id, c.first_name, c.last_name, art.name as artist_name, sum(ivl.unit_price*ivl.quantity) as amount_spent
  from  customer as c
  join invoice as iv on c.customer_id = iv.customer_id
  join invoice_line as ivl on iv.invoice_id = ivl.invoice_id
  join track as t on t.track_id = ivl.track_id
  join album as ab on ab.album_id = t.album_id
  join best_artist as art on art.artist_id = ab.artist_id
  group by 1,2,3,4
  
  
/* Q11 : We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with popular_genre as(
	select sum(ivl.quantity) as purchases, c.country, genre.name as genre_name ,genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(ivl.quantity) DESC) AS RowNo
	from invoice_line as ivl 
	join invoice as iv  on iv.invoice_id = ivl.invoice_id
	join customer as c on c.customer_id = iv.customer_id
	join track as t on t.track_id = ivl.track_id
	join genre on genre.genre_id = t.genre_id
	group by c.country,genre_name,genre.genre_id
	order by purchases desc
)
select * from popular_genre where rowno <= 1


/* Q12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */
with most_spent as(
	select sum(total) as spent ,c.country,c.first_name
	from customer as c
	join invoice as iv on c.customer_id = iv.customer_id
	group by 2,3
	order by spent desc
)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
