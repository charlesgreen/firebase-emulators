#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating security rules...');

const rulesFiles = [
  { name: 'Firestore', path: '../../config/firestore.rules' },
  { name: 'Storage', path: '../../config/storage.rules' }
];

let hasErrors = false;

rulesFiles.forEach(({ name, path: rulePath }) => {
  const fullPath = path.join(__dirname, rulePath);
  
  try {
    const rules = fs.readFileSync(fullPath, 'utf8');
    
    // Basic validation checks
    if (rules.length === 0) {
      console.error(`❌ ${name} rules file is empty`);
      hasErrors = true;
      return;
    }
    
    if (!rules.includes('service')) {
      console.warn(`⚠️  ${name} rules may be missing service declaration`);
    }
    
    if (!rules.includes('match')) {
      console.warn(`⚠️  ${name} rules may be missing match statements`);
    }
    
    console.log(`✅ ${name} rules file is valid`);
  } catch (error) {
    console.error(`❌ Failed to validate ${name} rules:`, error.message);
    hasErrors = true;
  }
});

if (hasErrors) {
  process.exit(1);
} else {
  console.log('✅ All security rules are valid');
}