#!/usr/bin/env node

// Set environment variables before anything loads
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096 --disable-warning=DEP0060 --no-warnings --trace-warnings=false';

// Override process.emitWarning completely
const originalEmitWarning = process.emitWarning;
process.emitWarning = function() {
  return;
};

// Override process.emit
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
      message.includes('deprecated') || message.includes('DeprecationWarning') ||
      message.includes('util._extend API is deprecated')) {
    return;
  }
  originalConsoleWarn.apply(console, args);
};

console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning') ||
      message.includes('util._extend API is deprecated')) {
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
      message.includes('deprecated') || message.includes('DeprecationWarning') ||
      message.includes('util._extend API is deprecated')) {
    return true;
  }
  return originalStderrWrite.call(this, chunk, encoding, callback);
};

process.stdout.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || 
      message.includes('deprecated') || message.includes('DeprecationWarning') ||
      message.includes('util._extend API is deprecated')) {
    return true;
  }
  return originalStdoutWrite.call(this, chunk, encoding, callback);
};

// Remove all warning listeners
process.removeAllListeners('warning');
process.on('warning', () => {});

// Patch util._extend globally
try {
  const util = require('util');
  if (util._extend) {
    util._extend = Object.assign;
  }
  
  // Override the deprecated util._extend
  Object.defineProperty(util, '_extend', {
    value: Object.assign,
    writable: false,
    configurable: false
  });
} catch (e) {
  // Ignore errors
}

// Override require to patch modules as they load
const originalRequire = require;
require = function(id) {
  const module = originalRequire(id);
  
  // Patch util._extend in loaded modules
  if (module && typeof module === 'object') {
    if (module._extend) {
      module._extend = Object.assign;
    }
  }
  
  return module;
};

// Override process.hrtime to prevent any timing-related warnings
const originalHrtime = process.hrtime;
process.hrtime = function(time) {
  return originalHrtime.call(this, time);
};

// Override process.nextTick to prevent any async warnings
const originalNextTick = process.nextTick;
process.nextTick = function(callback, ...args) {
  return originalNextTick.call(this, callback, ...args);
};

// Start Angular CLI
require('@angular/cli/bin/ng');