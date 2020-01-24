FROM node:10

COPY ./alApp/ /usr/src/demoapplication
WORKDIR /usr/src/demoapplication

RUN npm install

EXPOSE 3000

ENTRYPOINT ["npm","start"]
