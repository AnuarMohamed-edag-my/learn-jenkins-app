#Contains Instruction for Docker Image

FROM mcr.microsoft.com/playwright:v1.39.0-jammy AS test-runner

WORKDIR /app
COPY package.json package-lock.json ./

RUN npm install 

COPY . .

RUN npm install -g serve 

#stage 2: Final Production Image 
FROM node:18-alpine AS final-builder
WORKDIR /app
COPY --from=test-runner /app/dist ./dist

RUN npm install -g serve

CMD [ "serve", "-s", "dist"]
