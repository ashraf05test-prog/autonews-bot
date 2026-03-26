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
