#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating Firebase configuration...');

const configPath = path.join(__dirname, '../../config/firebase.json');

try {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  
  // Validate required emulator configurations
  const requiredEmulators = ['auth', 'firestore', 'storage', 'ui'];
  const missingEmulators = [];
  
  requiredEmulators.forEach(emulator => {
    if (!config.emulators || !config.emulators[emulator]) {
      missingEmulators.push(emulator);
    }
  });
  
  if (missingEmulators.length > 0) {
    console.error(`❌ Missing emulator configurations: ${missingEmulators.join(', ')}`);
    process.exit(1);
  }
  
  // Validate port configurations
  const expectedPorts = {
    auth: 5171,
    firestore: 5172,
    hosting: 5174,
    storage: 5175,
    ui: 5179,
    hub: 5170
  };
  
  Object.entries(expectedPorts).forEach(([emulator, expectedPort]) => {
    if (config.emulators[emulator] && config.emulators[emulator].port !== expectedPort) {
      console.warn(`⚠️  ${emulator} port is ${config.emulators[emulator].port}, expected ${expectedPort}`);
    }
  });
  
  console.log('✅ Firebase configuration is valid');
} catch (error) {
  console.error('❌ Failed to validate Firebase configuration:', error.message);
  process.exit(1);
}