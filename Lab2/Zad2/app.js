import express from "express";

const app = express();

const PORT = 8080;

app.listen(PORT);

console.log(`Server running on port ${PORT}`);

app.get("/", (req, res) => {
  const today = new Date();
  const formattedToday = new Intl.DateTimeFormat("pl-PL", {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).format(today);

  return res.status(200).json({ today: formattedToday });
});
