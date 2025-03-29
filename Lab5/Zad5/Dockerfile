FROM ubuntu AS build

WORKDIR /app


RUN apt-get update && \
    apt-get install -y nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

    
COPY /app/package*.json ./

RUN npm install

COPY /app ./

RUN npm run build



FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD [ "nginx","-g", "daemon off;" ]

