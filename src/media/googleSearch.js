const logger = require('../utils/logger');
class GoogleSearch {
  async searchVideos(query, limit = 5) { return []; }
  async searchImages(query, limit = 10) { return []; }
  async downloadVideo(videoUrl, outputPath) { return null; }
  async downloadImage(imageUrl, outputPath) { return null; }
}
module.exports = new GoogleSearch();
