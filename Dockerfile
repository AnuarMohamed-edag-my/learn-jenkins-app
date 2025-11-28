#Contains Instruction for Docker Image

FROM mcr.microsoft.com/playwright:v1.39.0-jammy as test-runner

WORKDIR /app
COPY . .

RUN npm install -g serve 

