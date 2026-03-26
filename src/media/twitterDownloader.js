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
