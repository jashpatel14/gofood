require('dotenv').config();
const db = require('./config/database');

(async () => {
  try {
    const [users] = await db.query('SELECT id, name, email, role FROM users');
    console.log("--- Registered Users in Database ---");
    console.log(JSON.stringify(users, null, 2));
    process.exit(0);
  } catch (err) {
    console.error("Error fetching users:", err);
    process.exit(1);
  }
})();
