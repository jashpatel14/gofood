const express = require('express');
const db = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

// Place order
router.post('/', auth, async (req, res) => {
  try {
    const { items, subtotal, gst, delivery_fee, discount, total_amount, payment_method, delivery_address } = req.body;
    const [result] = await db.query(
      'INSERT INTO orders (user_id, subtotal, gst, delivery_fee, discount, total_amount, status, payment_method, delivery_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [req.userId, subtotal, gst, delivery_fee, discount || 0, total_amount, 'pending', payment_method, delivery_address]
    );
    const orderId = result.insertId;
    for (const item of items) {
      await db.query(
        'INSERT INTO order_items (order_id, food_id, food_name, food_image, price, quantity, total_price) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [orderId, item.food_id, item.food_name, item.food_image, item.price, item.quantity, item.total_price]
      );
    }
    res.status(201).json({ id: `ORD-${orderId}`, status: 'pending', message: 'Order placed successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get user orders
router.get('/', auth, async (req, res) => {
  try {
    const [orders] = await db.query('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC', [req.userId]);
    for (let order of orders) {
      const [items] = await db.query('SELECT * FROM order_items WHERE order_id = ?', [order.id]);
      order.items = items;
      
      const [restInfo] = await db.query(
        `SELECT f.restaurant_id, r.name as restaurant_name 
         FROM order_items oi
         JOIN foods f ON oi.food_id = f.id
         JOIN restaurants r ON f.restaurant_id = r.id
         WHERE oi.order_id = ? LIMIT 1`,
        [order.id]
      );
      if (restInfo.length > 0) {
        order.restaurant_id = restInfo[0].restaurant_id;
        order.restaurant_name = restInfo[0].restaurant_name;
      } else {
        order.restaurant_id = null;
        order.restaurant_name = null;
      }

      // Fetch user review if it exists
      const [review] = await db.query(
        'SELECT rating, comment FROM reviews WHERE order_id = ?',
        [order.id]
      );
      if (review.length > 0) {
        order.is_rated = true;
        order.user_rating = parseFloat(review[0].rating);
        order.user_comment = review[0].comment;
      } else {
        order.is_rated = false;
        order.user_rating = null;
        order.user_comment = null;
      }
      
      order.id = `ORD-${order.id}`;
    }
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get order by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const numericId = req.params.id.replace('ORD-', '');
    const [orders] = await db.query('SELECT * FROM orders WHERE id = ? AND user_id = ?', [numericId, req.userId]);
    if (orders.length === 0) return res.status(404).json({ error: 'Order not found' });
    const [items] = await db.query('SELECT * FROM order_items WHERE order_id = ?', [numericId]);
    orders[0].items = items;
    
    const [restInfo] = await db.query(
      `SELECT f.restaurant_id, r.name as restaurant_name 
       FROM order_items oi
       JOIN foods f ON oi.food_id = f.id
       JOIN restaurants r ON f.restaurant_id = r.id
       WHERE oi.order_id = ? LIMIT 1`,
      [numericId]
    );
    if (restInfo.length > 0) {
      orders[0].restaurant_id = restInfo[0].restaurant_id;
      orders[0].restaurant_name = restInfo[0].restaurant_name;
    } else {
      orders[0].restaurant_id = null;
      orders[0].restaurant_name = null;
    }

    // Fetch user review if it exists
    const [review] = await db.query(
      'SELECT rating, comment FROM reviews WHERE order_id = ?',
      [numericId]
    );
    if (review.length > 0) {
      orders[0].is_rated = true;
      orders[0].user_rating = parseFloat(review[0].rating);
      orders[0].user_comment = review[0].comment;
    } else {
      orders[0].is_rated = false;
      orders[0].user_rating = null;
      orders[0].user_comment = null;
    }
    
    orders[0].id = `ORD-${orders[0].id}`;
    res.json(orders[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update order status (for simulation/testing)
router.put('/:id/status', auth, async (req, res) => {
  try {
    const numericId = req.params.id.replace('ORD-', '');
    const { status } = req.body;
    await db.query('UPDATE orders SET status = ? WHERE id = ?', [status, numericId]);
    res.json({ message: 'Order status updated successfully', status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get orders for a specific restaurant (Partner Portal)
router.get('/restaurant/:restaurantId', auth, async (req, res) => {
  try {
    const restaurantId = req.params.restaurantId;
    
    // Fetch unique orders for this restaurant
    const [orders] = await db.query(
      `SELECT DISTINCT o.*, u.name as customer_name, u.email as customer_email, u.phone as customer_phone
       FROM orders o
       JOIN order_items oi ON o.id = oi.order_id
       JOIN foods f ON oi.food_id = f.id
       JOIN users u ON o.user_id = u.id
       WHERE f.restaurant_id = ?
       ORDER BY o.created_at DESC`,
      [restaurantId]
    );

    // Attach items belonging to this restaurant to each order
    for (let order of orders) {
      const [items] = await db.query(
        `SELECT oi.* 
         FROM order_items oi
         JOIN foods f ON oi.food_id = f.id
         WHERE oi.order_id = ? AND f.restaurant_id = ?`,
        [order.id, restaurantId]
      );
      order.items = items;
      order.id = `ORD-${order.id}`;
    }
    
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
