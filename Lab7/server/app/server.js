const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const port = process.env.PORT || 3003;
const MONGO_URI =
  process.env.NODE_ENV === "production"
    ? process.env.MONGO_URI || "mongodb://db:27017/mydatabase"
    : "mongodb://localhost:27019/mydatabase";

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose
  .connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB connected"))
  .catch((err) => {
    console.error("MongoDB connection error:", err);
    process.exit(1);
  });

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    last_name: { type: String, required: true },
  },
  { timestamps: true }
);

const User = mongoose.model("User", userSchema);

app.get("/", (req, res) => {
  res.json({ message: "API is running" });
});

app.get("/users", async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/test-add", async (req, res) => {
  try {
    const newUser = new User({
      name: "Jan",
      last_name: "Kowalski",
    });

    const savedUser = await newUser.save();
    res.status(201).json({
      message: "User Jan Kowalski added successfully",
      user: savedUser,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
