-- GoFood Database Schema & Seed Data
-- Run this file in MySQL: mysql -u root < gofood.sql

CREATE DATABASE IF NOT EXISTS gofood;
USE gofood;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url VARCHAR(500) DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurants
CREATE TABLE IF NOT EXISTS restaurants (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  image VARCHAR(500) NOT NULL,
  rating DECIMAL(2,1) DEFAULT 0.0,
  review_count INT DEFAULT 0,
  delivery_time VARCHAR(30) DEFAULT '30 min',
  cuisine_type VARCHAR(200) NOT NULL,
  is_open BOOLEAN DEFAULT TRUE,
  address VARCHAR(300) DEFAULT '',
  distance DECIMAL(4,1) DEFAULT 0.0,
  delivery_fee DECIMAL(6,2) DEFAULT 40.00,
  open_time VARCHAR(10) DEFAULT '09:00',
  close_time VARCHAR(10) DEFAULT '22:00',
  is_busy BOOLEAN DEFAULT FALSE,
  is_temporarily_closed BOOLEAN DEFAULT FALSE
);

-- Foods
CREATE TABLE IF NOT EXISTS foods (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  image VARCHAR(500) NOT NULL,
  description TEXT,
  price DECIMAL(8,2) NOT NULL,
  rating DECIMAL(2,1) DEFAULT 0.0,
  restaurant_id INT,
  category VARCHAR(50) DEFAULT '',
  is_veg BOOLEAN DEFAULT TRUE,
  is_popular BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Addons
CREATE TABLE IF NOT EXISTS addons (
  id INT PRIMARY KEY AUTO_INCREMENT,
  food_id INT,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(6,2) NOT NULL,
  FOREIGN KEY (food_id) REFERENCES foods(id)
);

-- Addresses
CREATE TABLE IF NOT EXISTS addresses (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  label VARCHAR(50) NOT NULL,
  full_address VARCHAR(300) NOT NULL,
  city VARCHAR(100) DEFAULT '',
  pincode VARCHAR(10) DEFAULT '',
  is_default BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  subtotal DECIMAL(10,2) NOT NULL,
  gst DECIMAL(10,2) DEFAULT 0,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  discount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending','accepted','preparing','outForDelivery','delivered') DEFAULT 'pending',
  payment_method VARCHAR(50) DEFAULT 'Cash on Delivery',
  delivery_address VARCHAR(300),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order Items
CREATE TABLE IF NOT EXISTS order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  food_id INT,
  food_name VARCHAR(150),
  food_image VARCHAR(500),
  price DECIMAL(8,2),
  quantity INT DEFAULT 1,
  total_price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- Coupons
CREATE TABLE IF NOT EXISTS coupons (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) UNIQUE NOT NULL,
  discount_amount DECIMAL(8,2) NOT NULL,
  min_order DECIMAL(8,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE
);

-- ═══════════════════════════════════════════
-- SEED DATA
-- ═══════════════════════════════════════════

-- Restaurants
INSERT INTO restaurants (name, image, rating, review_count, delivery_time, cuisine_type, is_open, address, distance, delivery_fee, open_time, close_time, is_busy, is_temporarily_closed) VALUES
('Royal Biryani House', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600', 4.5, 324, '25-35 min', 'Biryani • Mughlai • North Indian', TRUE, 'MG Road, Bangalore', 2.5, 40, '11:00', '04:00', FALSE, FALSE),
('Pizza Paradise', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600', 4.7, 512, '20-30 min', 'Pizza • Italian • Pasta', TRUE, 'Koramangala, Bangalore', 1.8, 40, '08:00', '23:30', FALSE, FALSE),
('Dragon Wok', 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600', 4.3, 267, '30-40 min', 'Chinese • Thai • Asian', TRUE, 'Indiranagar, Bangalore', 3.2, 40, '10:00', '22:00', TRUE, FALSE),
('Burger Junction', 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600', 4.6, 445, '15-25 min', 'Burger • American • Fast Food', TRUE, 'HSR Layout, Bangalore', 1.2, 40, '09:00', '23:00', FALSE, FALSE),
('South Spice', 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600', 4.4, 198, '20-30 min', 'South Indian • Dosa • Idli', FALSE, 'Jayanagar, Bangalore', 4.0, 40, '07:00', '21:00', FALSE, TRUE),
('Dessert Haven', 'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=600', 4.8, 678, '25-35 min', 'Desserts • Ice Cream • Cakes', TRUE, 'Whitefield, Bangalore', 5.5, 40, '09:00', '23:59', FALSE, FALSE),
('Tandoori Nights', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600', 4.2, 156, '35-45 min', 'Tandoori • North Indian • Kebab', TRUE, 'Electronic City, Bangalore', 6.0, 40, '17:00', '23:00', FALSE, FALSE),
('Wrap & Roll', 'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae?w=600', 4.1, 89, '15-20 min', 'Rolls • Wraps • Kebabs', TRUE, 'BTM Layout, Bangalore', 1.5, 40, '08:00', '23:00', FALSE, FALSE);

-- Foods (sample - matches mock data)
INSERT INTO foods (name, image, description, price, rating, restaurant_id, category, is_veg, is_popular) VALUES
('Hyderabadi Chicken Biryani', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600', 'Aromatic basmati rice layered with tender chicken, saffron, and traditional Hyderabadi spices.', 299, 4.6, 1, 'Biryani', FALSE, TRUE),
('Mutton Biryani Special', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', 'Premium mutton pieces cooked with fragrant rice, whole spices, and topped with crispy fried onions.', 399, 4.8, 1, 'Biryani', FALSE, TRUE),
('Paneer Biryani', 'https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?w=600', 'Cottage cheese cubes with flavored rice, mint, and aromatic spices.', 249, 4.3, 1, 'Biryani', TRUE, FALSE),
('Chicken 65', 'https://images.unsplash.com/photo-1610057099443-fde6c99db9e1?w=600', 'Crispy deep-fried chicken marinated in red chilli paste and curry leaves.', 229, 4.5, 1, 'Starters', FALSE, FALSE),
('Margherita Pizza', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600', 'Classic Italian pizza with fresh mozzarella, tomato sauce, and basil.', 349, 4.7, 2, 'Pizza', TRUE, TRUE),
('Pepperoni Pizza', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600', 'Loaded with spicy pepperoni, melted mozzarella, and signature sauce.', 449, 4.8, 2, 'Pizza', FALSE, TRUE),
('Classic Smash Burger', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', 'Double smashed patty with cheddar cheese, pickles, and secret sauce.', 279, 4.7, 4, 'Burger', FALSE, TRUE),
('Belgian Chocolate Cake', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600', 'Rich chocolate cake with Belgian chocolate ganache frosting.', 349, 4.9, 6, 'Dessert', TRUE, TRUE),
('Butter Chicken', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600', 'Tender chicken in rich tomato-butter gravy.', 329, 4.6, 7, 'Main Course', FALSE, TRUE),
('Chicken Shawarma Roll', 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600', 'Juicy chicken shawarma wrapped in warm pita with garlic sauce.', 179, 4.3, 8, 'Rolls', FALSE, TRUE);

-- Addons
INSERT INTO addons (food_id, name, price) VALUES
(1, 'Extra Raita', 30), (1, 'Boiled Egg', 20), (1, 'Extra Chicken', 80),
(2, 'Extra Raita', 30), (2, 'Extra Mutton', 120),
(5, 'Extra Cheese', 50), (5, 'Olives', 30), (5, 'Jalapenos', 25),
(7, 'Extra Patty', 100), (7, 'Fries', 80),
(9, 'Butter Naan', 40), (9, 'Jeera Rice', 60);

-- Coupons
INSERT INTO coupons (code, discount_amount, min_order) VALUES
('FIRST50', 50, 200),
('GOFOOD20', 20, 100),
('SAVE30', 30, 300),
('FLAT100', 100, 500),
('WELCOME', 40, 150);
