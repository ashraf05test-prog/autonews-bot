const logger = require('../utils/logger');
class FacebookUploader {
  async upload(videoPath, metadata) {
    logger.warn('Facebook upload not configured');
    return null;
  }
}
module.exports = new FacebookUploader();
