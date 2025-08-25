#!/usr/bin/env node

console.log('🧪 Testing emulator package...');

try {
  const packageJson = require('./package.json');
  console.log(`✅ Package: ${packageJson.name}@${packageJson.version}`);
  
  // Check if Dockerfile exists
  const fs = require('fs');
  const path = require('path');
  
  const dockerfilePath = path.join(__dirname, '../../Dockerfile');
  if (fs.existsSync(dockerfilePath)) {
    console.log('✅ Dockerfile exists');
  } else {
    throw new Error('Dockerfile not found');
  }
  
  console.log('✅ Emulator package test passed');
} catch (error) {
  console.error('❌ Emulator package test failed:', error.message);
  process.exit(1);
}