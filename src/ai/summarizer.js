const { GoogleGenerativeAI } = require('@google/generative-ai');
const logger = require('../utils/logger');

class NewsSummarizer {
  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    }
  }
  
  async summarize(newsArticle, maxPoints = 7) {
    const points = [
      'Breaking news update - developing story',
      'More details emerging',
      'Stay tuned for updates'
    ];
    return {
      points: points.slice(0, maxPoints),
      title: newsArticle.title || 'Breaking News',
      rawResponse: ''
    };
  }
  
  async generateMetadata(points, title) {
    return {
      title: title || 'Breaking News',
      description: 'Latest news update',
      hashtags: '#Breaking #News',
      tags: 'news, breaking, update'
    };
  }
}
module.exports = new NewsSummarizer();
