const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Node.js behind Nginx reverse proxy with SSL and cache!');
});

app.listen(port, () => {
  console.log(`Aplikacja Node.js działa na porcie ${port}`);
});
