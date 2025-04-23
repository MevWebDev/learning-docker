const express = require("express");
const { Pool } = require("pg");
const redis = require("redis");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: process.env.POSTGRES_USER || "postgres",
  host: process.env.POSTGRES_HOST || "postgres",
  database: process.env.POSTGRES_DB || "mydb",
  password: process.env.POSTGRES_PASSWORD || "password",
  port: process.env.POSTGRES_PORT || 5432,
});

// Redis connection
const redisClient = redis.createClient({
  url: `redis://${process.env.REDIS_HOST || "redis"}:${
    process.env.REDIS_PORT || 6379
  }`,
});

// Connect to Redis
(async () => {
  try {
    await redisClient.connect();
    console.log("Connected to Redis");
  } catch (err) {
    console.error("Redis connection error:", err);
  }
})();

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Express app with Redis and PostgreSQL" });
});

// Redis test route
app.get("/redis-test", async (req, res) => {
  try {
    const cacheKey = "test-key";
    await redisClient.set(cacheKey, "Redis is working!");
    const value = await redisClient.get(cacheKey);
    res.json({ message: value });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PostgreSQL test route
app.get("/pg-test", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({
      message: "PostgreSQL is working!",
      timestamp: result.rows[0].now,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

// Error handling
process.on("SIGINT", async () => {
  await redisClient.quit();
  await pool.end();
  console.log("Application terminated");
  process.exit(0);
});
