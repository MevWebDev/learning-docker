# Użyj oficjalnego obrazu Node.js 16
FROM node:16

# Ustaw katalog roboczy
WORKDIR /usr/src/app

# Skopiuj pliki package.json i package-lock.json
COPY package*.json ./

# Zainstaluj zależności
RUN npm install

# Skopiuj resztę aplikacji
COPY . .

# Ustaw port, na którym będzie działać aplikacja
EXPOSE 8080

# Uruchom aplikację
CMD ["node", "app.js"]