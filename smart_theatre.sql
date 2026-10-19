

CREATE DATABASE IF NOT EXISTS smart_theatre;
USE smart_theatre;

-- 1. MOVIES TABLE
CREATE TABLE IF NOT EXISTS movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

-- 2. SHOWS TABLE
CREATE TABLE IF NOT EXISTS shows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    show_time DATETIME NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- 3. COUPONS TABLE
CREATE TABLE IF NOT EXISTS coupons (
    code VARCHAR(30) PRIMARY KEY,
    discount INT NOT NULL
);

-- 4. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id VARCHAR(60) UNIQUE NOT NULL,
    customer VARCHAR(100) NOT NULL,
    movie_id INT NOT NULL,
    show_id INT NOT NULL,
    seat VARCHAR(10) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    food VARCHAR(100),
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (show_id, seat),
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (show_id) REFERENCES shows(id)
);

-- 5. FOOD ORDERS TABLE
CREATE TABLE IF NOT EXISTS food_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    food_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    delivery_time DATETIME,
    FOREIGN KEY (booking_id)
        REFERENCES bookings(id)
        ON DELETE CASCADE
);

-- ==================================================
-- SAMPLE DATA
-- ==================================================

INSERT INTO movies (title, genre, price)
SELECT 'Avengers', 'Action', 180.00
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'Avengers'
);

INSERT INTO movies (title, genre, price)
SELECT 'Inception', 'Sci-Fi', 160.00
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'Inception'
);

INSERT INTO movies (title, genre, price)
SELECT 'Interstellar', 'Sci-Fi', 200.00
WHERE NOT EXISTS (
    SELECT 1 FROM movies WHERE title = 'Interstellar'
);

INSERT INTO coupons (code, discount)
VALUES ('WELCOME10', 10)
ON DUPLICATE KEY UPDATE discount = 10;

INSERT INTO coupons (code, discount)
VALUES ('SAVE20', 20)
ON DUPLICATE KEY UPDATE discount = 20;

-- Create one sample show for each movie if absent
INSERT INTO shows (movie_id, show_time)
SELECT m.id, TIMESTAMP(CURDATE(), '18:00:00')
FROM movies m
WHERE NOT EXISTS (
    SELECT 1
    FROM shows s
    WHERE s.movie_id = m.id
      AND s.show_time = TIMESTAMP(CURDATE(), '18:00:00')
);

-- ==================================================
-- DISPLAY ALL STORED DETAILS
-- ==================================================

-- A. Display all movies
SELECT * FROM movies;

-- B. Display all shows with movie names
SELECT
    s.id AS show_id,
    m.title AS movie_name,
    m.genre,
    s.show_time,
    m.price
FROM shows s
JOIN movies m ON s.movie_id = m.id;

-- C. Display all coupons
SELECT * FROM coupons;

-- D. Display all bookings
SELECT
    b.id AS booking_id,
    b.ticket_id,
    b.customer,
    m.title AS movie_name,
    s.show_time,
    b.seat,
    b.amount,
    b.food,
    b.booking_time
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN shows s ON b.show_id = s.id
ORDER BY b.id DESC;

-- E. Display all food orders
SELECT
    f.id AS food_order_id,
    b.ticket_id,
    b.customer,
    f.food_name,
    f.quantity,
    f.delivery_time
FROM food_orders f
JOIN bookings b ON f.booking_id = b.id;

-- F. Total number of movies
SELECT COUNT(*) AS total_movies
FROM movies;

-- G. Total number of bookings
SELECT COUNT(*) AS total_bookings
FROM bookings;

-- H. Total booking revenue
SELECT COALESCE(SUM(amount), 0.00) AS total_revenue
FROM bookings;

-- I. Complete booking report
SELECT
    b.ticket_id AS 'Ticket ID',
    b.customer AS 'Customer Name',
    m.title AS 'Movie',
    s.show_time AS 'Show Time',
    b.seat AS 'Seat Number',
    b.food AS 'Food Order',
    b.amount AS 'Total Amount',
    b.booking_time AS 'Booking Date'
FROM bookings b
JOIN movies m ON b.movie_id = m.id
JOIN shows s ON b.show_id = s.id
ORDER BY b.booking_time DESC;

-- ==================================================
-- END OF FILE
-- ==================================================
