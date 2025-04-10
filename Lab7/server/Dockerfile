FROM node:18-alpine

WORKDIR /src

COPY package*.json ./

RUN npm install

COPY app/ ./

ENV PORT=3003
ENV MONGO_URI=mongodb://db:27017/mydatabase

EXPOSE ${PORT}

CMD [ "node", "server.js" ]