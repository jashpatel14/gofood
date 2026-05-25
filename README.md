# GoFood - Food Delivery Platform (Full Stack Solution)

Welcome to **GoFood**, a professional, highly interactive full-stack food delivery platform modeled after premium service architectures like Zomato and Swiggy. 

This platform connects customers, restaurant partners, and system administrators into a single real-time operational loop.

---

## 🏗️ Project Architecture & Components

GoFood consists of three primary, tightly coupled software layers:
1. **Flutter Mobile Application**: A beautiful, premium customer-facing mobile client built with Google Fonts, dynamic glassmorphic elements, local database caching, and background synchronization.
2. **Node.js/Express REST API**: A secure Express backend that manages business logic, hashes credentials, coordinates JSON Web Tokens (JWT), and performs automatic database schema migrations.
3. **Partner & Admin Web Portal (HTML5/CSS3/Vanilla JS)**: A zero-compile single-page application served directly from the backend at `http://localhost:3000/portal/`. It features a sleek, dark glassmorphic UI, live order processing feeds, and global outlet managers.
4. **MySQL Database**: Persistent storage managing structured users, restaurants, menu dishes, live order queues, and customer reviews.

---

## 🔑 Pre-Seeded Login Credentials

To make testing immediate and frictionless, the system automatically migrates tables and seeds the following operational accounts upon backend startup:

### 1. System Administrator Account
* Access the Web Portal at `http://localhost:3000/portal/` to view global metrics, manage outlet profiles, and re-assign restaurant ownership.
* **Email**: `admin@gofood.com`
* **Password**: `admin123`

### 2. Pre-Seeded Restaurant Partner Accounts
* Access the Web Portal at `http://localhost:3000/portal/` to manage active orders, customize open/close timings, set outlet busy/closed status, and modify menu items.
* **Royal Biryani House**:
  * **Email**: `royal@gofood.com`
  * **Password**: `royal123`
* **Pizza Paradise**:
  * **Email**: `pizza@gofood.com`
  * **Password**: `pizza123`
* **Burger Junction**:
  * **Email**: `burger@gofood.com`
  * **Password**: `burger123`

### 3. Customer Mobile App Accounts
* Launch the Flutter Mobile App on an emulator or physical device.
* **Direct Signup**: Tap **Sign Up** on the login screen to register any fresh customer account instantly.

---

## 🚀 Complete Step-by-Step Launch Guide

Follow these simple steps to spin up the entire platform:

### Step 1: Initialize the MySQL Database
1. Open your local MySQL Command Line, Workbench, or phpMyAdmin.
2. Import the schema script located in the project repository:
   ```sql
   source backend/database/gofood.sql;
   ```
   *This automatically creates the `gofood` schema, creates tables, and seeds initial mock menus and restaurants.*

### Step 2: Start the REST API & Web Portal Server
1. Navigate to the backend directory in your terminal:
   ```bash
   cd backend
   ```
2. Install the lightweight package dependencies:
   ```bash
   npm install
   ```
3. Initialize the server:
   ```bash
   npm start
   ```
   *The server is now running at `http://localhost:3000`. It will display database connectivity logs and confirm that seed logins are active.*

### Step 3: Run the Flutter Mobile Application
1. Open the root project folder in your terminal.
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the app on a connected emulator or test device:
   ```bash
   flutter run
   ```

---

## 🧪 Interactive Real-Time Sync Testing Guide
Experience the complete interactive, multi-role synchronization loop:

1. **Access the Portal**: Open `http://localhost:3000/portal/` in your web browser. Log in as a partner (e.g., `royal@gofood.com` / `royal123`).
2. **Access the Mobile App**: Launch the mobile app and sign in or sign up a customer.
3. **Live Status Toggling**:
   * In the **Partner Portal**, toggle the restaurant status to **Set Busy** or **Temporarily Closed**, or update the store hours (e.g., close time `23:30`).
   * Watch the customer's mobile app: **Within 10 seconds**, the home screen card, search results, and category items automatically sync to show `BUSY`, `TEMPORARILY CLOSED`, or updated timings without a manual refresh! (You can also pull down on the Home Screen to trigger an instant refresh).
4. **Order Placement**: 
   * Add dishes to the cart in the Flutter app and proceed through checkout.
   * On checkout success, tap **Track Order**. You are instantly redirected to a live Swiggy/Zomato-style progress timeline.
5. **Live Order Feed Processing**:
   * Instantly check the **Partner Portal**: A new order card has slid into the live queue with a pulsing red notification light.
   * Click **Accept Order** -> **Start Preparing** -> **Handover / Out** inside the Web Portal.
   * Look at the Mobile App: The customer's tracking stepper dynamically repaints to reflect the status changes in perfect synchronization!
6. **Delivery Completion**:
   * Tap **Mark as Delivered** on the mobile app.
   * The order immediately moves to **Completed** on the Web Portal, updating the partner's completed orders counter and total revenue graph dynamically.

---
