#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating JSON files...');

const jsonFiles = [
  '../../config/firebase.json',
  '../../config/firestore.indexes.json',
  '../../seed/auth.json',
  '../../seed/firestore.json'
];

let hasErrors = false;

jsonFiles.forEach(file => {
  const fullPath = path.join(__dirname, file);
  
  try {
    if (fs.existsSync(fullPath)) {
      const content = fs.readFileSync(fullPath, 'utf8');
      JSON.parse(content);
      console.log(`✅ ${path.basename(file)} is valid JSON`);
    } else {
      console.log(`⏭️  ${path.basename(file)} not found (skipping)`);
    }
  } catch (error) {
    console.error(`❌ ${path.basename(file)} has invalid JSON:`, error.message);
    hasErrors = true;
  }
});

if (hasErrors) {
  process.exit(1);
} else {
  console.log('✅ All JSON files are valid');
}