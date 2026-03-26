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
