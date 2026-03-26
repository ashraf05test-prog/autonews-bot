require('dotenv').config();
const logger = require('./src/utils/logger');

async function test() {
  logger.info('🧪 Running tests...\n');
  
  try {
    logger.info('Test: Checking dependencies...');
    require('rss-parser');
    require('axios');
    require('@google/generative-ai');
    logger.info('✅ All dependencies loaded successfully');
  } catch (error) {
    logger.error('❌ Dependency error:', error.message);
  }
  
  logger.info('\n🏁 Tests completed!');
  process.exit(0);
}

test().catch(console.error);
