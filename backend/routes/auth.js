const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const auth = require('../middleware/auth');
const { sendResetEmail } = require('../services/email_service');
const router = express.Router();

// Ensure role column exists in users table and seed default admin/partners
(async () => {
  try {
    const [columns] = await db.query("SHOW COLUMNS FROM users LIKE 'role'");
    if (columns.length === 0) {
      await db.query("ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'customer'");
      console.log("Successfully migrated 'users' table: added 'role' column");
    }

    // Seed default administrator if not exists
    const [existing] = await db.query("SELECT id FROM users WHERE email = 'admin@gofood.com'");
    if (existing.length === 0) {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await db.query(
        "INSERT INTO users (name, email, phone, password_hash, role) VALUES (?, ?, ?, ?, ?)",
        ['System Administrator', 'admin@gofood.com', '9999999999', hashedPassword, 'admin']
      );
      console.log("Successfully seeded default Admin account: admin@gofood.com / admin123");
    }

    // Seed default partner logins associated with existing seeded restaurants
    const seedPartner = async (name, email, password, restaurantId) => {
      const [existingPartner] = await db.query("SELECT id FROM users WHERE email = ?", [email]);
      let partnerId;
      if (existingPartner.length === 0) {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query(
          "INSERT INTO users (name, email, phone, password_hash, role) VALUES (?, ?, ?, ?, ?)",
          [name, email, '9876543210', hashedPassword, 'partner']
        );
        partnerId = result.insertId;
        console.log(`Successfully seeded partner account: ${email} / ${password}`);
      } else {
        partnerId = existingPartner[0].id;
      }
      
      // Associate partner with the restaurant if owner_id is not already set
      await db.query("UPDATE restaurants SET owner_id = ? WHERE id = ? AND owner_id IS NULL", [partnerId, restaurantId]);
    };

    await seedPartner('Royal Biryani Owner', 'royal@gofood.com', 'royal123', 1);
    await seedPartner('Pizza Paradise Owner', 'pizza@gofood.com', 'pizza123', 2);
    await seedPartner('Burger Junction Owner', 'burger@gofood.com', 'burger123', 4);

  } catch (e) {
    console.error('Failed to migrate users table and seed admin/partners:', e);
  }
})();

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password, role } = req.body;
    if (!name || !email || !phone || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const assignedRole = role || 'customer';
    const [result] = await db.query(
      'INSERT INTO users (name, email, phone, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [name, email, phone, hashedPassword, assignedRole]
    );
    const token = jwt.sign({ id: result.insertId }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.status(201).json({
      id: result.insertId, name, email, phone, avatar_url: '', role: assignedRole, token
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({
      id: user.id, name: user.name, email: user.email, phone: user.phone,
      avatar_url: user.avatar_url || '', role: user.role || 'customer', token
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Profile
router.get('/profile', auth, async (req, res) => {
  try {
    const [users] = await db.query('SELECT id, name, email, phone, avatar_url FROM users WHERE id = ?', [req.userId]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json(users[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update Profile
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, email, phone, avatar_url } = req.body;
    if (!name || !email || !phone) {
      return res.status(400).json({ error: 'Name, email, and phone are required' });
    }

    // Check if email already taken by another user
    const [existing] = await db.query('SELECT id FROM users WHERE email = ? AND id != ?', [email, req.userId]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already in use by another account' });
    }

    await db.query(
      'UPDATE users SET name = ?, email = ?, phone = ?, avatar_url = ? WHERE id = ?',
      [name, email, phone, avatar_url || '', req.userId]
    );

    res.json({
      id: req.userId,
      name,
      email,
      phone,
      avatar_url: avatar_url || ''
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Forgot Password
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const [users] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      // For security, don't reveal if user exists or not
      return res.json({ message: 'If an account exists with this email, a reset link has been sent.' });
    }

    const userId = users[0].id;
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 3600000); // 1 hour from now

    // Clear any existing tokens for this user
    await db.query('DELETE FROM password_reset_tokens WHERE user_id = ?', [userId]);

    // Save new token
    await db.query(
      'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, token, expiresAt]
    );

    // Send email
    await sendResetEmail(email, token);

    res.json({ message: 'If an account exists with this email, a reset link has been sent.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Reset Password
router.post('/reset-password', async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) {
      return res.status(400).json({ error: 'Token and password are required' });
    }

    const [tokens] = await db.query(
      'SELECT user_id FROM password_reset_tokens WHERE token = ? AND expires_at > NOW()',
      [token]
    );

    if (tokens.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired token' });
    }

    const userId = tokens[0].user_id;
    const hashedPassword = await bcrypt.hash(password, 10);

    // Update user password
    await db.query('UPDATE users SET password_hash = ? WHERE id = ?', [hashedPassword, userId]);

    // Update token to be expired/used (preserves entry in database for audit logs)
    await db.query('UPDATE password_reset_tokens SET expires_at = NOW() WHERE user_id = ?', [userId]);

    res.json({ message: 'Password has been reset successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all registered partner users (for Admin dashboard restaurant assignment)
router.get('/partners', auth, async (req, res) => {
  try {
    const [users] = await db.query('SELECT role FROM users WHERE id = ?', [req.userId]);
    if (users.length === 0 || users[0].role !== 'admin') {
      return res.status(403).json({ error: 'Only administrators can fetch partner accounts.' });
    }
    const [partners] = await db.query("SELECT id, name, email FROM users WHERE role = 'partner' ORDER BY name ASC");
    res.json(partners);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
