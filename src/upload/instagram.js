const logger = require('../utils/logger');
class InstagramUploader {
  async upload(videoPath, metadata) {
    logger.warn('Instagram upload not configured');
    return null;
  }
}
module.exports = new InstagramUploader();
