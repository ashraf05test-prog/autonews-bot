FROM node:18-slim

# Install FFmpeg
RUN apt-get update && apt-get install -y ffmpeg fonts-liberation

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy all files
COPY . .

# Create required directories
RUN mkdir -p assets/music assets/fonts assets/templates temp output logs public

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
