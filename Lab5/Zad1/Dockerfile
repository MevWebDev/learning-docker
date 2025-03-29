FROM alpine

WORKDIR /src

COPY . .

RUN apk add --no-cache bash

RUN chmod +x ./script.sh

CMD [ "/bin/bash","./script.sh" ]
