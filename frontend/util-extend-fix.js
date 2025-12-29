// Fix for util._extend deprecation warnings
// This script patches the deprecated util._extend usage in node_modules

const fs = require('fs');
const path = require('path');

// Files to patch in node_modules
const filesToPatch = [
  'node_modules/needle/lib/needle.js',
  'node_modules/spdy-transport/lib/spdy-transport/utils.js',
  'node_modules/spdy/lib/spdy/server.js',
  'node_modules/spdy/lib/spdy/agent.js'
];

// Patch function to replace util._extend with Object.assign
function patchFile(filePath) {
  try {
    if (fs.existsSync(filePath)) {
      let content = fs.readFileSync(filePath, 'utf8');
      
      // Replace util._extend with Object.assign
      content = content.replace(/util\._extend/g, 'Object.assign');
      
      // Also handle cases where it might be used with require
      content = content.replace(/require\(['"]util['"]\)\._extend/g, 'Object.assign');
      
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`✅ Patched: ${filePath}`);
      return true;
    } else {
      console.log(`⚠️  File not found: ${filePath}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error patching ${filePath}:`, error.message);
    return false;
  }
}

// Apply patches
console.log('🔧 Applying util._extend fixes...');
let patchedCount = 0;

filesToPatch.forEach(filePath => {
  if (patchFile(filePath)) {
    patchedCount++;
  }
});

console.log(`\n✅ Successfully patched ${patchedCount}/${filesToPatch.length} files`);
console.log('🎉 util._extend deprecation warnings should now be eliminated!');
