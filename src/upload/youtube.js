const logger = require('../utils/logger');
class YouTubeUploader {
  async upload(videoPath, metadata) {
    logger.warn('YouTube upload not configured');
    return null;
  }
}
module.exports = new YouTubeUploader();
