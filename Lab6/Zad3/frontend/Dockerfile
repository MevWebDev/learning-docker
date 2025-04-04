FROM node:latest AS build

WORKDIR /app


COPY package*.json ./

RUN npm install --verbose

COPY . .

RUN npm run build

FROM node:latest

WORKDIR /app

RUN npm install -g serve

COPY --from=build /app/dist ./dist

EXPOSE 3000

CMD [ "serve", "-s", "dist", "-l", "3000" ]



