const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// Database pool
const db = new Pool({
  host: process.env.DB_HOST || 'database',  // Use container name for Docker
  user: process.env.DB_USER || 'appuser',
  password: process.env.DB_PASSWORD || 'password123',
  database: process.env.DB_NAME || 'appdb',
  port: process.env.DB_PORT || 5432,
});

// Root route
app.get('/', (req, res) => res.send('Backend API running...'));

// Messages route
app.get('/messages', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM messages');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`✅ Backend listening on port ${PORT}`));
