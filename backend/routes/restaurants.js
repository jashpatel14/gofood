const express = require('express');
const db = require('../config/database');
const router = express.Router();

// Get all restaurants
router.get('/', async (req, res) => {
  try {
    const [restaurants] = await db.query('SELECT * FROM restaurants ORDER BY rating DESC');
    res.json(restaurants);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get restaurant by ID
router.get('/:id', async (req, res) => {
  try {
    const [restaurants] = await db.query('SELECT * FROM restaurants WHERE id = ?', [req.params.id]);
    if (restaurants.length === 0) return res.status(404).json({ error: 'Restaurant not found' });
    res.json(restaurants[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Search restaurants
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    const [restaurants] = await db.query(
      'SELECT * FROM restaurants WHERE name LIKE ? OR cuisine_type LIKE ?',
      [`%${q}%`, `%${q}%`]
    );
    res.json(restaurants);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
