const express = require("express");
const mongoose = require("mongoose");

const app = express();
const PORT = 8080;

// Połączenie z MongoDB
mongoose.connect("mongodb://mongo:27017/mydatabase", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Model MongoDB
const ItemSchema = new mongoose.Schema({
  name: String,
});

const Item = mongoose.model("Item", ItemSchema);

// Endpoint do pobierania danych z MongoDB
app.get("/items", async (req, res) => {
  try {
    const items = await Item.find();
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Dodanie przykładowych danych do bazy
app.get("/seed", async (req, res) => {
  try {
    await Item.create([
      { name: "Item 1" },
      { name: "Item 2" },
      { name: "Item 3" },
    ]);
    res.send("Database seeded!");
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Uruchomienie serwera
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
