#!/usr/bin/env node

console.log('🧪 Testing configuration package...');

// Simple validation that the package.json is correct
try {
  const packageJson = require('./package.json');
  console.log(`✅ Package: ${packageJson.name}@${packageJson.version}`);
  
  // Validate that all required scripts exist
  const requiredScripts = ['build', 'test', 'lint'];
  for (const script of requiredScripts) {
    if (!packageJson.scripts[script]) {
      throw new Error(`Missing required script: ${script}`);
    }
  }
  
  console.log('✅ All required scripts present');
  console.log('✅ Configuration package test passed');
} catch (error) {
  console.error('❌ Configuration package test failed:', error.message);
  process.exit(1);
}