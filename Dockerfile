# Start from the base image
FROM node:18-alpine

# Install Netlify CLI globally
# The global install path is automatically added to the container's PATH
RUN npm install -g netlify-cli@20.1.1

# Set the default working directory
WORKDIR /app