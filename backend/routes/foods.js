const express = require('express');
const db = require('../config/database');
const router = express.Router();

// Get foods (optionally filter by restaurant)
router.get('/', async (req, res) => {
  try {
    const { restaurant_id, category } = req.query;
    let query = 'SELECT f.*, r.name as restaurant_name FROM foods f LEFT JOIN restaurants r ON f.restaurant_id = r.id';
    const params = [];
    const conditions = [];
    if (restaurant_id) { conditions.push('f.restaurant_id = ?'); params.push(restaurant_id); }
    if (category) { conditions.push('f.category = ?'); params.push(category); }
    if (conditions.length > 0) query += ' WHERE ' + conditions.join(' AND ');
    query += ' ORDER BY f.rating DESC';
    const [foods] = await db.query(query, params);

    // Attach addons
    for (let food of foods) {
      const [addons] = await db.query('SELECT * FROM addons WHERE food_id = ?', [food.id]);
      food.addons = addons;
    }
    res.json(foods);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get popular foods
router.get('/popular', async (req, res) => {
  try {
    const [foods] = await db.query(
      'SELECT f.*, r.name as restaurant_name FROM foods f LEFT JOIN restaurants r ON f.restaurant_id = r.id WHERE f.is_popular = 1 ORDER BY f.rating DESC'
    );
    for (let food of foods) {
      const [addons] = await db.query('SELECT * FROM addons WHERE food_id = ?', [food.id]);
      food.addons = addons;
    }
    res.json(foods);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get food by ID
router.get('/:id', async (req, res) => {
  try {
    const [foods] = await db.query(
      'SELECT f.*, r.name as restaurant_name FROM foods f LEFT JOIN restaurants r ON f.restaurant_id = r.id WHERE f.id = ?',
      [req.params.id]
    );
    if (foods.length === 0) return res.status(404).json({ error: 'Food not found' });
    const [addons] = await db.query('SELECT * FROM addons WHERE food_id = ?', [req.params.id]);
    foods[0].addons = addons;
    res.json(foods[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Search foods
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    const [foods] = await db.query(
      'SELECT f.*, r.name as restaurant_name FROM foods f LEFT JOIN restaurants r ON f.restaurant_id = r.id WHERE f.name LIKE ? OR f.description LIKE ?',
      [`%${q}%`, `%${q}%`]
    );
    res.json(foods);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
