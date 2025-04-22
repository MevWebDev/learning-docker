const express = require("express");
const redis = require("redis");

const app = express();
const port = process.env.PORT || 3000;

// Redis client setup
const redisHost = process.env.REDIS_HOST || "localhost";
const redisPort = process.env.REDIS_PORT || 6379;
const redisClient = redis.createClient({
  url: `redis://${redisHost}:${redisPort}`,
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

// Middleware
app.use(express.json());

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Hello from Express with Redis!" });
});

// Set a value in Redis
app.post("/data", async (req, res) => {
  try {
    const { key, value } = req.body;

    if (!key || !value) {
      return res.status(400).json({ error: "Key and value are required" });
    }

    await redisClient.set(key, value);
    res.status(201).json({ message: `Stored ${key}:${value}` });
  } catch (err) {
    console.error("Redis set error:", err);
    res.status(500).json({ error: "Failed to store data" });
  }
});

// Get a value from Redis
app.get("/data/:key", async (req, res) => {
  try {
    const { key } = req.params;
    const value = await redisClient.get(key);

    if (value === null) {
      return res.status(404).json({ error: "Key not found" });
    }

    res.json({ key, value });
  } catch (err) {
    console.error("Redis get error:", err);
    res.status(500).json({ error: "Failed to retrieve data" });
  }
});

// Increment a counter
app.post("/increment/:key", async (req, res) => {
  try {
    const { key } = req.params;
    const newValue = await redisClient.incr(key);
    res.json({ key, value: newValue });
  } catch (err) {
    console.error("Redis increment error:", err);
    res.status(500).json({ error: "Failed to increment counter" });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

// Handle Redis errors after initial connection
redisClient.on("error", (err) => {
  console.error("Redis error:", err);
});

// Handle process termination
process.on("SIGINT", async () => {
  await redisClient.quit();
  console.log("Redis connection closed");
  process.exit(0);
});
