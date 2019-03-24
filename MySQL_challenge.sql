-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;
-- 1b
UPDATE actor SET Actor_Name = CONCAT (first_name, ' '  ,last_name);
-- 2a
select * from actor WHERE first_name = "Joe";
-- 2b
select * from actor WHERE last_name LIKE "%GEN%";
-- 2c
select * from actor WHERE last_name LIKE "%LI%" order by last_name, first_name;
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
Select country_id, country 
from country 
where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be 
-- performing queries on a description, so create a column in the table `actor` named 
-- `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).
alter table actor
add column description blob not null after Actor_name; 
--  3b. Very quickly you realize that entering descriptions for each actor is too much effort.
--  Delete the `description` column.
alter table actor
DROP COLUMN description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT distinct last_name, COUNT(last_name) FROM actor GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) c FROM actor GROUP BY last_name HAVING c >= 2;
-- 4c The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
--  Write a query to fix the record.
set SQL_SAFE_UPDATES =0;
UPDATE actor 
set Actor_Name = "HARPO WILLIAMS" 
where Actor_Name = "GROUCHO WILLIAMS";
-- or
update actor 
set first_name = "HARPO" 
where first_name = "GROUCHO" and last_name = "WILLIAMS";
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that 
-- `GROUCHO` was the correct name after all! In a single query, if the first name of 
-- the actor is currently `HARPO`, change it to `GROUCHO`.
update actor 
set first_name = "GROUCHO" 
where first_name = "HARPO" and last_name = "WILLIAMS";
-- or
UPDATE actor 
set Actor_Name = "GROUCHO WILLIAMS" 
where Actor_Name = "HARPO WILLIAMS";
-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;
 -- describe address;
 CREATE TABLE IF NOT EXISTS
 `address` (
 `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
 `address` varchar(50) NOT NULL,
 `address2` varchar(50) DEFAULT NULL,
 `district` varchar(20) NOT NULL,
 `city_id` smallint(5) unsigned NOT NULL,
 `postal_code` varchar(10) DEFAULT NULL,
 `phone` varchar(20) NOT NULL,
 `location` geometry NOT NULL,
 `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`address_id`),
 KEY `idx_fk_city_id` (`city_id`),
 SPATIAL KEY `idx_location` (`location`),
 CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff ON
staff.address_id=address.address_id;
-- Or 
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
INNER JOIN payment ON
staff.staff_id=payment.staff_id
where payment.payment_date like '2005-08%'
GROUP by payment.staff_id 
order by staff.last_name ASC;
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, count(film.film_id)
FROM film
INNER JOIN film_actor ON
film_actor.film_id=film.film_id
group by title;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, count(inventory.inventory_id)
FROM film
INNER JOIN inventory ON
film.film_id=inventory.film_id
where title = "Hunchback Impossible";
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount)
from customer
INNER JOIN payment ON
payment.customer_id=customer.customer_id
group by payment.customer_id
order by customer.last_name ASC;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title 
from film 
where title LIKE "K%" or title LIKE "Q%" and language_id
in(
	select language_id 
	from language 
	where name="English" 
    );
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor where actor_id in
   (
    SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
     SELECT film_id
     FROM film
     WHERE title = "Alone Trip"
    )
 );
-- 7c*****. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
 FROM customer
 WHERE address_id IN
 (
  SELECT address_id
  FROM address
  WHERE city_id IN
  (
   SELECT city_id
   FROM city
   WHERE country_id IN
   (
    SELECT country_id
    FROM country
    WHERE country = "Canada"
    
   )
  )
 );
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select title
from film where film_id in
( 
select film_id from film_category where category_id in
(
select category_id from category where name="Family"
 ));
-- 0r 
SELECT title, category
FROM film_list
WHERE category = 'Family';
-- 7e****. Display the most frequently rented movies in descending order.
select inventory.film_id, film_text.title, count(rental.inventory_id)
from inventory
inner join rental
on inventory.inventory_id=rental.inventory_id
inner join film_text
on inventory.film_id=film_text.film_id
group by rental.inventory_id
order by count(rental.inventory_id) desc, film_text.title asc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select payment.staff_id, sum(amount)
from payment
inner join staff
on payment.staff_id = staff.staff_id
inner join store
on store.store_id= staff.store_id
group by payment.staff_id
order by sum(amount);
-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id,city.city, country.country
from store
inner join address
on store.address_id=address.address_id
inner join city
on address.city_id=city.city_id
inner join country
on city.country_id=country.country_id;
-- 7h. List the top five genres in gross revenue in descending order.
select category.name, sum(payment.amount) as gross_revenue
from category
inner join film_category
on category.category_id=film_category.category_id
inner join inventory
on inventory.film_id=film_category.film_id
inner join rental
on inventory.inventory_id=rental.inventory_id
right join payment
on payment.rental_id = rental.rental_id
group by category.name
order by gross_revenue desc
limit 5;
-- 8a. In your new role as an executive, you would like to 
-- have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
drop view if exists top_five_genres;
create view top_five_genres as
select category.name, sum(payment.amount) as gross_revenue
from category
inner join film_category
on category.category_id=film_category.category_id
inner join inventory
on inventory.film_id=film_category.film_id
inner join rental
on inventory.inventory_id=rental.inventory_id
right join payment
on payment.rental_id = rental.rental_id
group by category.name
order by gross_revenue desc
limit 5;
-- 8b
select * from top_five_genres;
-- 8c
drop view top_five_genres;