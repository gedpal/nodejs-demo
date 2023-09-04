# Use a minimal Node.js image
FROM node:14-slim

# Create the /usr/Nodejsdemoapp directory in the container
RUN mkdir -p /usr/Nodejsdemoapp

# Set the working directory in the container
WORKDIR /usr/Nodejsdemoapp

# Copy the built artifacts to the container directory
COPY /src .

# Install dependencies
RUN npm ci --production

# Set port environment variable
ENV PORT=3000

# Expose port
EXPOSE 3000

# Start the Node.js app
CMD ["npm", "run", "start"]
