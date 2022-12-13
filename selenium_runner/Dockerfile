FROM node:19-slim

WORKDIR /app
COPY package*.json .

RUN npm ci
COPY . /app
CMD npm run test
