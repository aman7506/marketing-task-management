#!/usr/bin/env node

// Set environment variables first
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096';

// Completely override the warning system
process.removeAllListeners('warning');
process.on('warning', () => {});

// Override process.emitWarning
process.emitWarning = function() {
  return;
};

// Override console methods
console.warn = function() {
  return;
};

console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return;
  }
  process.stderr.write(message + '\n');
};

// Override process streams
const originalStderrWrite = process.stderr.write;
const originalStdoutWrite = process.stdout.write;

process.stderr.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return true;
  }
  return originalStderrWrite.call(this, chunk, encoding, callback);
};

process.stdout.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return true;
  }
  return originalStdoutWrite.call(this, chunk, encoding, callback);
};

// Patch util._extend
try {
  const util = require('util');
  if (util._extend) {
    util._extend = Object.assign;
  }
} catch (e) {
  // Ignore
}

// Start Angular CLI
require('@angular/cli/bin/ng');
