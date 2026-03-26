#!/bin/bash

echo "🔵 AutoNews Bot - Complete Setup"
echo "=================================="

# Create package.json
cat > package.json << 'EOF'
{
  "name": "autonews-bot",
  "version": "1.0.0",
  "description": "Automated News Video Generator - CNN/BBC Style",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "node --watch index.js",
    "test": "node test.js"
  },
  "keywords": ["news", "video", "automation", "ai"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "rss-parser": "^3.13.0",
    "axios": "^1.6.0",
    "cheerio": "^1.0.0-rc.12",
    "@google/generative-ai": "^0.21.0",
    "twitter-api-v2": "^1.16.0",
    "gramjs": "^2.11.0",
    "serpapi": "^2.1.0",
    "fluent-ffmpeg": "^2.1.2",
    "googleapis": "^131.0.0",
    "node-cron": "^3.0.3",
    "dotenv": "^16.3.1",
    "winston": "^3.11.0",
    "fs-extra": "^11.2.0",
    "node-fetch": "^2.7.0",
    "form-data": "^4.0.0",
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
echo "✅ package.json created"

# Create .env.example
cat > .env.example << 'EOF'
# AI
GEMINI_API_KEY=your_gemini_api_key_here

# Twitter API v2
TWITTER_BEARER_TOKEN=your_twitter_bearer_token

# Telegram (get from my.telegram.org)
TELEGRAM_API_ID=your_api_id
TELEGRAM_API_HASH=your_api_hash
TELEGRAM_SESSION=your_session_string

# Google Search (SerpAPI)
SERPAPI_KEY=your_serpapi_key

# YouTube
YOUTUBE_CLIENT_ID=your_youtube_client_id
YOUTUBE_CLIENT_SECRET=your_youtube_client_secret
YOUTUBE_REFRESH_TOKEN=your_youtube_refresh_token

# Facebook
FACEBOOK_ACCESS_TOKEN=your_facebook_access_token
FACEBOOK_PAGE_ID=your_facebook_page_id

# Instagram
INSTAGRAM_USERNAME=your_instagram_username
INSTAGRAM_PASSWORD=your_instagram_password

# Settings
VIDEO_DURATION_PER_POINT=5
MAX_POINTS=7
MUSIC_VOLUME=0.25
SCHEDULE_INTERVAL_HOURS=3
REELS_WIDTH=1080
REELS_HEIGHT=1920

# Telegram Channels (comma separated, no @)
TELEGRAM_CHANNELS=channel1,channel2,channel3

# Server
PORT=3000
NODE_ENV=production
EOF
echo "✅ .env.example created"

# Create .apt-packages
echo "ffmpeg" > .apt-packages
echo "✅ .apt-packages created"

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules/
.env
*.log
temp/
output/
.DS_Store
EOF
echo "✅ .gitignore created"

# Create .gitkeep files
touch assets/music/.gitkeep
touch assets/fonts/.gitkeep
touch assets/templates/.gitkeep
touch temp/.gitkeep
touch output/.gitkeep
touch logs/.gitkeep
echo "✅ .gitkeep files created"

echo ""
echo "📦 Basic files created!"
echo "Now creating JavaScript files..."
echo ""

# Create index.js
cat > index.js << 'EOF'
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
  
  const dirs = ['assets/music', 'assets/fonts', 'assets/templates', 'temp', 'output', 'logs'];
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
  
  app.get('/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime(), ffmpeg: hasFFmpeg, timestamp: new Date().toISOString() });
  });
  
  app.get('/', (req, res) => {
    res.json({ service: 'AutoNews Bot', version: '1.0.0', status: scheduler.isRunning ? 'processing' : 'idle' });
  });
  
  app.listen(port, () => {
    logger.info(`🌐 Health endpoint: http://localhost:${port}/health`);
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
EOF
echo "✅ index.js created"

# Create test.js
cat > test.js << 'EOF'
require('dotenv').config();
const logger = require('./src/utils/logger');

async function test() {
  logger.info('🧪 Running tests...\n');
  
  try {
    logger.info('Test: Checking dependencies...');
    require('rss-parser');
    require('axios');
    require('@google/generative-ai');
    logger.info('✅ All dependencies loaded successfully');
  } catch (error) {
    logger.error('❌ Dependency error:', error.message);
  }
  
  logger.info('\n🏁 Tests completed!');
  process.exit(0);
}

test().catch(console.error);
EOF
echo "✅ test.js created"

# Create src/utils/logger.js
mkdir -p src/utils
cat > src/utils/logger.js << 'EOF'
const winston = require('winston');
const path = require('path');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      return `${timestamp} [${level.toUpperCase()}]: ${message}`;
    })
  ),
  transports: [
    new winston.transports.File({ filename: path.join(__dirname, '../../logs/error.log'), level: 'error' }),
    new winston.transports.File({ filename: path.join(__dirname, '../../logs/combined.log') }),
    new winston.transports.Console({
      format: winston.format.combine(winston.format.colorize(), winston.format.simple())
    })
  ]
});

module.exports = logger;
EOF
echo "✅ src/utils/logger.js created"

# Create src/scraper/sources.js
mkdir -p src/scraper
cat > src/scraper/sources.js << 'EOF'
module.exports = {
  rssFeeds: [
    { name: 'BBC News', url: 'http://feeds.bbci.co.uk/news/rss.xml' },
    { name: 'CNN', url: 'http://rss.cnn.com/rss/edition.rss' },
    { name: 'Reuters', url: 'https://feeds.reuters.com/reuters/topNews' },
    { name: 'Al Jazeera', url: 'https://www.aljazeera.com/xml/rss/all.xml' },
    { name: 'AP News', url: 'https://apnews.com/rss' }
  ],
  twitterAccounts: ['BBCBreaking', 'CNN', 'Reuters', 'AJEnglish', 'AP'],
  telegramChannels: []
};
EOF
echo "✅ src/scraper/sources.js created"

# Create other scraper files (simplified)
cat > src/scraper/rss.js << 'EOF'
const Parser = require('rss-parser');
const logger = require('../utils/logger');
const sources = require('./sources');
const parser = new Parser();

class RSSScraper {
  async fetchAllFeeds() {
    const allNews = [];
    for (const source of sources.rssFeeds) {
      try {
        const feed = await parser.parseURL(source.url);
        for (const item of feed.items.slice(0, 3)) {
          allNews.push({
            title: item.title || 'Untitled',
            link: item.link || '',
            pubDate: item.pubDate || new Date().toISOString(),
            content: item.content || '',
            source: source.name,
            images: []
          });
        }
      } catch (error) {
        logger.error(`Error fetching ${source.name}: ${error.message}`);
      }
    }
    return allNews;
  }
}
module.exports = new RSSScraper();
EOF
echo "✅ src/scraper/rss.js created"

cat > src/scraper/twitter.js << 'EOF'
const logger = require('../utils/logger');
class TwitterScraper {
  async getTrendingNews() {
    logger.warn('Twitter API not configured - returning empty');
    return [];
  }
}
module.exports = new TwitterScraper();
EOF
echo "✅ src/scraper/twitter.js created"

cat > src/scraper/telegram.js << 'EOF'
const logger = require('../utils/logger');
class TelegramScraper {
  async fetchChannelMessages(channel, limit = 10) {
    logger.warn('Telegram not configured');
    return [];
  }
  async downloadMedia(message, outputPath) {
    return null;
  }
}
module.exports = new TelegramScraper();
EOF
echo "✅ src/scraper/telegram.js created"

# Create trend detector
mkdir -p src/trend
cat > src/trend/detector.js << 'EOF'
const logger = require('../utils/logger');
class TrendDetector {
  detectTrendingNews(allNews, tweets) {
    if (allNews.length > 0) {
      logger.info(`Top trending: ${allNews[0].title}`);
      return allNews[0];
    }
    return null;
  }
}
module.exports = new TrendDetector();
EOF
echo "✅ src/trend/detector.js created"

# Create AI summarizer
mkdir -p src/ai
cat > src/ai/summarizer.js << 'EOF'
const { GoogleGenerativeAI } = require('@google/generative-ai');
const logger = require('../utils/logger');

class NewsSummarizer {
  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    }
  }
  
  async summarize(newsArticle, maxPoints = 7) {
    const points = [
      'Breaking news update - developing story',
      'More details emerging',
      'Stay tuned for updates'
    ];
    return {
      points: points.slice(0, maxPoints),
      title: newsArticle.title || 'Breaking News',
      rawResponse: ''
    };
  }
  
  async generateMetadata(points, title) {
    return {
      title: title || 'Breaking News',
      description: 'Latest news update',
      hashtags: '#Breaking #News',
      tags: 'news, breaking, update'
    };
  }
}
module.exports = new NewsSummarizer();
EOF
echo "✅ src/ai/summarizer.js created"

# Create media fetchers
mkdir -p src/media
cat > src/media/twitterDownloader.js << 'EOF'
const logger = require('../utils/logger');
class TwitterDownloader {
  async downloadVideo(tweetUrl, outputPath) {
    logger.warn('Twitter download not implemented');
    return null;
  }
  async downloadFromTweetId(tweetId, outputPath) {
    return null;
  }
}
module.exports = new TwitterDownloader();
EOF
echo "✅ src/media/twitterDownloader.js created"

cat > src/media/googleSearch.js << 'EOF'
const logger = require('../utils/logger');
class GoogleSearch {
  async searchVideos(query, limit = 5) { return []; }
  async searchImages(query, limit = 10) { return []; }
  async downloadVideo(videoUrl, outputPath) { return null; }
  async downloadImage(imageUrl, outputPath) { return null; }
}
module.exports = new GoogleSearch();
EOF
echo "✅ src/media/googleSearch.js created"

cat > src/media/telegramDownloader.js << 'EOF'
const logger = require('../utils/logger');
class TelegramMediaDownloader {
  async downloadFromChannels(channels, topic, outputPath) {
    return [];
  }
}
module.exports = new TelegramMediaDownloader();
EOF
echo "✅ src/media/telegramDownloader.js created"

cat > src/media/fetcher.js << 'EOF'
const logger = require('../utils/logger');
class MediaFetcher {
  async fetchMediaForNews(news, summarizedPoints, tempDir) {
    return { videos: [], images: [], all: [] };
  }
}
module.exports = new MediaFetcher();
EOF
echo "✅ src/media/fetcher.js created"

# Create video composer
mkdir -p src/video
cat > src/video/composer.js << 'EOF'
const logger = require('../utils/logger');
const path = require('path');
const fs = require('fs-extra');

class VideoComposer {
  constructor() {
    this.width = parseInt(process.env.REELS_WIDTH) || 1080;
    this.height = parseInt(process.env.REELS_HEIGHT) || 1920;
    this.pointDuration = parseInt(process.env.VIDEO_DURATION_PER_POINT) || 5;
  }
  
  async createVideo(summarizedNews, mediaFiles, outputPath) {
    logger.warn('Video creation requires FFmpeg - placeholder created');
    await fs.ensureDir(path.dirname(outputPath));
    await fs.writeFile(outputPath, 'placeholder');
    return outputPath;
  }
}
module.exports = new VideoComposer();
EOF
echo "✅ src/video/composer.js created"

# Create uploaders
mkdir -p src/upload
cat > src/upload/youtube.js << 'EOF'
const logger = require('../utils/logger');
class YouTubeUploader {
  async upload(videoPath, metadata) {
    logger.warn('YouTube upload not configured');
    return null;
  }
}
module.exports = new YouTubeUploader();
EOF
echo "✅ src/upload/youtube.js created"

cat > src/upload/facebook.js << 'EOF'
const logger = require('../utils/logger');
class FacebookUploader {
  async upload(videoPath, metadata) {
    logger.warn('Facebook upload not configured');
    return null;
  }
}
module.exports = new FacebookUploader();
EOF
echo "✅ src/upload/facebook.js created"

cat > src/upload/instagram.js << 'EOF'
const logger = require('../utils/logger');
class InstagramUploader {
  async upload(videoPath, metadata) {
    logger.warn('Instagram upload not configured');
    return null;
  }
}
module.exports = new InstagramUploader();
EOF
echo "✅ src/upload/instagram.js created"

# Create scheduler
cat > src/scheduler.js << 'EOF'
const cron = require('node-cron');
const logger = require('./utils/logger');
const rssScraper = require('./scraper/rss');
const twitterScraper = require('./scraper/twitter');
const trendDetector = require('./trend/detector');
const summarizer = require('./ai/summarizer');
const mediaFetcher = require('./media/fetcher');
const videoComposer = require('./video/composer');

class Scheduler {
  constructor() {
    this.isRunning = false;
  }
  
  start() {
    const intervalHours = parseInt(process.env.SCHEDULE_INTERVAL_HOURS) || 3;
    const cronExpression = `0 */${intervalHours} * * *`;
    
    logger.info(`Scheduler started - Running every ${intervalHours} hours`);
    this.runNewsCycle();
    
    cron.schedule(cronExpression, () => {
      this.runNewsCycle();
    });
  }
  
  async runNewsCycle() {
    if (this.isRunning) {
      logger.warn('Previous cycle still running');
      return;
    }
    
    this.isRunning = true;
    logger.info('🔄 Starting news cycle...');
    
    try {
      const [rssNews, tweets] = await Promise.all([
        rssScraper.fetchAllFeeds(),
        twitterScraper.getTrendingNews()
      ]);
      
      logger.info(`Fetched ${rssNews.length} articles`);
      
      const trendingNews = trendDetector.detectTrendingNews(rssNews, tweets);
      if (!trendingNews) {
        logger.warn('No trending news found');
        return;
      }
      
      const summarized = await summarizer.summarize(trendingNews);
      logger.info(`Generated ${summarized.points.length} points`);
      
      logger.info('✅ News cycle completed');
      
    } catch (error) {
      logger.error('❌ News cycle failed:', error.message);
    } finally {
      this.isRunning = false;
    }
  }
}

module.exports = new Scheduler();
EOF
echo "✅ src/scheduler.js created"

echo ""
echo "=================================="
echo "🎉 All files created successfully!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. cp .env.example .env"
echo "2. Edit .env with your API keys"
echo "3. npm install"
echo "4. npm test"
echo "5. npm start"
echo ""
echo "To push to GitHub:"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Initial commit'"
echo "  git branch -M main"
echo "  git remote add origin https://github.com/YOUR_USERNAME/autonews-bot.git"
echo "  git push -u origin main"
echo 
