#Contains Instruction for Docker Image

FROM mcr.microsoft.com/playwright:v1.39.0-jammy

#WORKDIR /app
#COPY . .

RUN npm install -g serve 

FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

