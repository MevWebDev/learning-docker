const { Pool } = require("pg");
const pool = new Pool({
  user: "webuser",
  host: "db",
  database: "webdb",
  password: "webpass",
  port: 5432,
});

pool.query("SELECT NOW()", (err, res) => {
  if (err) {
    console.error("Błąd połączenia z PostgreSQL:", err);
  } else {
    console.log(
      "Połączono z PostgreSQL pod adresem db:5432! Wynik:",
      res.rows[0]
    );
  }
});

const http = require("http");
const server = http.createServer((req, res) => {
  res.end("Działa! Połączono z bazą danych PostgreSQL.");
});
server.listen(3000, () => console.log("Serwer działa na porcie 3000"));
