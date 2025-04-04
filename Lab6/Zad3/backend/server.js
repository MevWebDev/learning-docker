const express = require("express");
const { Pool } = require("pg");
const app = express();
const port = process.env.PORT || 3001;

const pool = new Pool({
  user: "myuser",
  host: "postgres",
  database: "myapp",
  password: "mypassword",
  port: 5432,
});

app.use(express.json());

app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

app.get("/", (req, res) => {
  res.json({ message: "Hello from Express!" });
});

app.get("/db-test", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({
      message: "Database connected successfully!",
      timestamp: result.rows[0].now,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Backend server running on port ${port}`);
});
