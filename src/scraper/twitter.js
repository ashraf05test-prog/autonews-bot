const logger = require('../utils/logger');
class TwitterScraper {
  async getTrendingNews() {
    logger.warn('Twitter API not configured - returning empty');
    return [];
  }
}
module.exports = new TwitterScraper();
