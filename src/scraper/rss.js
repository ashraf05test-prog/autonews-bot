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
