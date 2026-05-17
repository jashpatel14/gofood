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
    orders[0].id = `ORD-${orders[0].id}`;
    res.json(orders[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
