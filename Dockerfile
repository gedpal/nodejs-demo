# Use a minimal Node.js image
FROM node:14-slim

# Set the working directory in the container
WORKDIR /usr/Nodejsdemoapp

# Copy the built artifacts to the container directory
COPY . .

# Install dependencies
RUN npm ci

# Start the Node.js app
CMD ["npm", "run", "start"]
