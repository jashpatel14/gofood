const express = require('express');
const db = require('../config/database');
const auth = require('../middleware/auth');
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

// Create new food item (Menu Management)
router.post('/', auth, async (req, res) => {
  try {
    const { name, image, description, price, restaurant_id, category, is_veg, is_popular } = req.body;
    if (!name || !image || !price || !restaurant_id) {
      return res.status(400).json({ error: 'Name, cover image, price, and restaurant ID are required' });
    }
    
    const [result] = await db.query(
      'INSERT INTO foods (name, image, description, price, restaurant_id, category, is_veg, is_popular) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [name, image, description || '', price, restaurant_id, category || '', is_veg || false, is_popular || false]
    );
    
    res.status(201).json({
      id: result.insertId,
      name,
      image,
      description: description || '',
      price,
      restaurant_id,
      category: category || '',
      is_veg: is_veg || false,
      is_popular: is_popular || false
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Edit food item details
router.put('/:id', auth, async (req, res) => {
  try {
    const { name, image, description, price, category, is_veg, is_popular } = req.body;
    const foodId = req.params.id;
    
    const [existing] = await db.query('SELECT * FROM foods WHERE id = ?', [foodId]);
    if (existing.length === 0) return res.status(404).json({ error: 'Food item not found' });
    
    const food = existing[0];
    
    await db.query(
      'UPDATE foods SET name = ?, image = ?, description = ?, price = ?, category = ?, is_veg = ?, is_popular = ? WHERE id = ?',
      [
        name || food.name,
        image || food.image,
        description !== undefined ? description : food.description,
        price !== undefined ? price : food.price,
        category !== undefined ? category : food.category,
        is_veg !== undefined ? is_veg : food.is_veg,
        is_popular !== undefined ? is_popular : food.is_popular,
        foodId
      ]
    );
    
    res.json({ message: 'Menu item updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete food item
router.delete('/:id', auth, async (req, res) => {
  try {
    const foodId = req.params.id;
    
    await db.query('DELETE FROM addons WHERE food_id = ?', [foodId]);
    await db.query('DELETE FROM foods WHERE id = ?', [foodId]);
    
    res.json({ message: 'Menu item deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
