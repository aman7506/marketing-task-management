#!/usr/bin/env node

// Aggressive patch to completely eliminate deprecation warnings
const fs = require('fs');
const path = require('path');

// Find the Angular CLI file
const angularCliPath = path.join(__dirname, 'node_modules', '@angular', 'cli', 'bin', 'ng');
const angularCliContent = fs.readFileSync(angularCliPath, 'utf8');

// Check if already patched
if (angularCliContent.includes('// PATCHED: Deprecation warning suppression')) {
  console.log('Angular CLI already patched');
  process.exit(0);
}

// Create backup
fs.writeFileSync(angularCliPath + '.backup', angularCliContent);

// Patch the file
const patchedContent = `#!/usr/bin/env node

// PATCHED: Deprecation warning suppression
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false';

// Override console.warn
const originalWarn = console.warn;
console.warn = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated')) {
    return;
  }
  originalWarn.apply(console, args);
};

// Override process.emitWarning
const originalEmitWarning = process.emitWarning;
process.emitWarning = function(warning, name, code) {
  if (code === 'DEP0060' || (typeof warning === 'string' && warning.includes('util._extend'))) {
    return;
  }
  originalEmitWarning.call(process, warning, name, code);
};

${angularCliContent}`;

fs.writeFileSync(angularCliPath, patchedContent);
console.log('Angular CLI patched successfully');
