require('dotenv').config();
const logger = require('./src/utils/logger');
const scheduler = require('./src/scheduler');
const { execSync } = require('child_process');
const express = require('express');
const path = require('path');
const fs = require('fs-extra');

function checkFFmpeg() {
  try {
    execSync('ffmpeg -version', { stdio: 'ignore' });
    logger.info('✅ FFmpeg is available');
    return true;
  } catch (error) {
    logger.error('❌ FFmpeg not found!');
    return false;
  }
}

async function main() {
  logger.info('🚀 AutoNews Bot Starting...');
  
  const hasFFmpeg = checkFFmpeg();
  
  const dirs = ['assets/music', 'assets/fonts', 'assets/templates', 'temp', 'output', 'logs', 'public'];
  for (const dir of dirs) {
    await fs.ensureDir(path.join(__dirname, dir));
  }
  
  const required = ['GEMINI_API_KEY'];
  const missing = required.filter(key => !process.env[key]);
  if (missing.length > 0) {
    logger.warn(`⚠️ Missing env vars: ${missing.join(', ')}`);
  }
  
  const app = express();
  const port = process.env.PORT || 3000;
  
  // Serve static files
  app.use(express.static('public'));
  
  // Root route
  app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  });
  
  // Health endpoint
  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      uptime: process.uptime(),
      ffmpeg: hasFFmpeg,
      timestamp: new Date().toISOString(),
      version: '1.0.0'
    });
  });
  
  app.listen(port, () => {
    logger.info(`🌐 Server running on http://localhost:${port}`);
    logger.info(`📊 Dashboard: http://localhost:${port}`);
    logger.info(`🏥 Health: http://localhost:${port}/health`);
  });
  
  scheduler.start();
  logger.info('✅ AutoNews Bot is running!');
}

process.on('uncaughtException', (error) => {
  logger.error('💥 Uncaught Exception:', error);
  process.exit(1);
});

process.on('SIGTERM', () => {
  logger.info('🛑 Shutting down...');
  process.exit(0);
});

main().catch(console.error);
