const express = require('express');
const db = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all addresses for user
router.get('/', auth, async (req, res) => {
  try {
    const [addresses] = await db.query('SELECT * FROM addresses WHERE user_id = ?', [req.userId]);
    res.json(addresses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create new address
router.post('/', auth, async (req, res) => {
  try {
    const { label, full_address, city, pincode, is_default } = req.body;
    
    if (is_default) {
      await db.query('UPDATE addresses SET is_default = 0 WHERE user_id = ?', [req.userId]);
    }
    
    const [result] = await db.query(
      'INSERT INTO addresses (user_id, label, full_address, city, pincode, is_default) VALUES (?, ?, ?, ?, ?, ?)',
      [req.userId, label, full_address, city, pincode, is_default ? 1 : 0]
    );
    
    const [newAddress] = await db.query('SELECT * FROM addresses WHERE id = ?', [result.insertId]);
    res.status(201).json(newAddress[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update address
router.put('/:id', auth, async (req, res) => {
  try {
    const { label, full_address, city, pincode, is_default } = req.body;
    
    if (is_default) {
      await db.query('UPDATE addresses SET is_default = 0 WHERE user_id = ?', [req.userId]);
    }
    
    await db.query(
      'UPDATE addresses SET label = ?, full_address = ?, city = ?, pincode = ?, is_default = ? WHERE id = ? AND user_id = ?',
      [label, full_address, city, pincode, is_default ? 1 : 0, req.params.id, req.userId]
    );
    
    const [updated] = await db.query('SELECT * FROM addresses WHERE id = ?', [req.params.id]);
    res.json(updated[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete address
router.delete('/:id', auth, async (req, res) => {
  try {
    await db.query('DELETE FROM addresses WHERE id = ? AND user_id = ?', [req.params.id, req.userId]);
    res.json({ message: 'Address deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
