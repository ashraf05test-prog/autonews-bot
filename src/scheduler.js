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
