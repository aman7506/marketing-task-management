#!/usr/bin/env node

// Comprehensive deprecation warning suppression
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096 --disable-warning=DEP0060';

// Override all warning mechanisms
const originalEmitWarning = process.emitWarning;
process.emitWarning = function() {
  return;
};

const originalEmit = process.emit;
process.emit = function(event, ...args) {
  if (event === 'warning' || event === 'deprecation') {
    return false;
  }
  return originalEmit.apply(this, [event, ...args]);
};

// Override console methods
const originalConsoleWarn = console.warn;
const originalConsoleError = console.error;

console.warn = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return;
  }
  originalConsoleWarn.apply(console, args);
};

console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return;
  }
  originalConsoleError.apply(console, args);
};

// Override process streams
const originalStderrWrite = process.stderr.write;
const originalStdoutWrite = process.stdout.write;

process.stderr.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return true;
  }
  return originalStderrWrite.call(this, chunk, encoding, callback);
};

process.stdout.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return true;
  }
  return originalStdoutWrite.call(this, chunk, encoding, callback);
};

// Remove warning listeners
process.removeAllListeners('warning');
process.on('warning', () => {});

// Patch util._extend
try {
  const util = require('util');
  if (util._extend) {
    util._extend = Object.assign;
  }
  
  Object.defineProperty(util, '_extend', {
    value: Object.assign,
    writable: false,
    configurable: false
  });
} catch (e) {
  // Ignore
}

// Start Angular CLI
require('@angular/cli/bin/ng');