# Use the latest LTS version of Node.js
FROM node:18 AS base

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application files
COPY . .

RUN npm run build
#============2nd stage---------------------------------
FROM node:18-slim

WORKDIR /app

COPY --from=base /app/build ./

RUN npm install -g serve
# Expose the port your app runs on
EXPOSE 3000

# Define the command to run your app
CMD ["serve", "-s", ".", "-p", "3000"]
