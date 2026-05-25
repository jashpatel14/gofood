const express = require('express');
const db = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

// Ensure owner_id column exists in restaurants table
(async () => {
  try {
    const [columns] = await db.query("SHOW COLUMNS FROM restaurants LIKE 'owner_id'");
    if (columns.length === 0) {
      await db.query("ALTER TABLE restaurants ADD COLUMN owner_id INT, ADD CONSTRAINT fk_restaurants_users FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL");
      console.log("Successfully migrated 'restaurants' table: added 'owner_id' column");
    }
  } catch (e) {
    console.error('Failed to migrate restaurants table owner_id column:', e);
  }
})();

// Get all restaurants
router.get('/', async (req, res) => {
  try {
    const [restaurants] = await db.query('SELECT * FROM restaurants ORDER BY rating DESC');
    res.json(restaurants);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get restaurant linked to current owner
router.get('/owner/me', auth, async (req, res) => {
  try {
    const [restaurants] = await db.query('SELECT * FROM restaurants WHERE owner_id = ?', [req.userId]);
    if (restaurants.length === 0) {
      return res.status(404).json({ error: 'No restaurant registered to your account yet.' });
    }
    res.json(restaurants[0]);
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

// Create new restaurant profile (Admin or Partner signup)
router.post('/', auth, async (req, res) => {
  try {
    const { name, cuisine_type, image, address, distance, delivery_fee, owner_id } = req.body;
    if (!name || !cuisine_type || !image) {
      return res.status(400).json({ error: 'Name, cuisine type, and cover image URL are required' });
    }
    
    const finalOwnerId = owner_id || req.userId;
    const [result] = await db.query(
      'INSERT INTO restaurants (name, cuisine_type, image, address, distance, delivery_fee, owner_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, cuisine_type, image, address || '', distance || 1.0, delivery_fee || 40.0, finalOwnerId]
    );
    
    res.status(201).json({
      id: result.insertId,
      name,
      cuisine_type,
      image,
      address: address || '',
      distance: distance || 1.0,
      delivery_fee: delivery_fee || 40.0,
      owner_id: finalOwnerId
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Edit restaurant details
router.put('/:id', auth, async (req, res) => {
  try {
    const { name, cuisine_type, image, address, distance, delivery_fee, owner_id } = req.body;
    const restaurantId = req.params.id;
    
    const [existing] = await db.query('SELECT * FROM restaurants WHERE id = ?', [restaurantId]);
    if (existing.length === 0) return res.status(404).json({ error: 'Restaurant not found' });
    
    const rest = existing[0];
    const [user] = await db.query('SELECT role FROM users WHERE id = ?', [req.userId]);
    const isAdmin = user.length > 0 && user[0].role === 'admin';
    
    if (rest.owner_id !== req.userId && !isAdmin) {
      return res.status(403).json({ error: 'Unauthorized to update this restaurant' });
    }
    
    await db.query(
      'UPDATE restaurants SET name = ?, cuisine_type = ?, image = ?, address = ?, distance = ?, delivery_fee = ?, owner_id = ? WHERE id = ?',
      [
        name || rest.name,
        cuisine_type || rest.cuisine_type,
        image || rest.image,
        address || rest.address,
        distance !== undefined ? distance : rest.distance,
        delivery_fee !== undefined ? delivery_fee : rest.delivery_fee,
        owner_id !== undefined ? owner_id : rest.owner_id,
        restaurantId
      ]
    );
    
    res.json({ message: 'Restaurant updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete restaurant profile
router.delete('/:id', auth, async (req, res) => {
  try {
    const restaurantId = req.params.id;
    
    const [user] = await db.query('SELECT role FROM users WHERE id = ?', [req.userId]);
    const isAdmin = user.length > 0 && user[0].role === 'admin';
    
    if (!isAdmin) {
      return res.status(403).json({ error: 'Only administrators can delete restaurant listings' });
    }
    
    // Cleanup food items & reviews first to avoid integrity constraints
    await db.query('DELETE FROM reviews WHERE restaurant_id = ?', [restaurantId]);
    await db.query('DELETE FROM foods WHERE restaurant_id = ?', [restaurantId]);
    await db.query('DELETE FROM restaurants WHERE id = ?', [restaurantId]);
    
    res.json({ message: 'Restaurant profile deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add review for a restaurant
router.post('/:id/reviews', auth, async (req, res) => {
  const restaurantId = req.params.id;
  const userId = req.userId;
  const { rating, comment, order_id } = req.body;

  try {
    // Ensure reviews table exists
    await db.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id INT PRIMARY KEY AUTO_INCREMENT,
        restaurant_id INT NOT NULL,
        user_id INT NOT NULL,
        rating DECIMAL(2,1) NOT NULL,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    `);

    // Check if order_id column exists
    const [columns] = await db.query("SHOW COLUMNS FROM reviews LIKE 'order_id'");
    if (columns.length === 0) {
      await db.query("ALTER TABLE reviews ADD COLUMN order_id INT UNIQUE, ADD CONSTRAINT fk_reviews_orders FOREIGN KEY (order_id) REFERENCES orders(id)");
    }

    // Clean up order_id prefix if it exists (e.g. 'ORD-10' to 10)
    let numericOrderId = null;
    if (order_id) {
      numericOrderId = parseInt(order_id.toString().replace('ORD-', ''), 10);
    }

    // Insert review
    await db.query(
      'INSERT INTO reviews (restaurant_id, user_id, rating, comment, order_id) VALUES (?, ?, ?, ?, ?)',
      [restaurantId, userId, rating, comment || '', numericOrderId]
    );

    // Calculate new average and count
    const [[{ avg_rating, review_count }]] = await db.query(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as review_count FROM reviews WHERE restaurant_id = ?',
      [restaurantId]
    );

    // Update restaurant
    await db.query(
      'UPDATE restaurants SET rating = ?, review_count = ? WHERE id = ?',
      [parseFloat(avg_rating).toFixed(1), review_count, restaurantId]
    );

    res.status(201).json({
      message: 'Review added successfully',
      rating: parseFloat(avg_rating).toFixed(1),
      review_count: review_count
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
