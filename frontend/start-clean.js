#!/usr/bin/env node

// Suppress all deprecation warnings before anything else loads
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096 --disable-warning=DEP0060 --no-warnings';

// Override process.emitWarning before any modules load
const originalEmitWarning = process.emitWarning;
process.emitWarning = function(warning, name, code, ...args) {
  if (code === 'DEP0060' || (warning && warning.toString().includes('util._extend'))) {
    return;
  }
  return originalEmitWarning.apply(this, [warning, name, code, ...args]);
};

// Override process.emit before any modules load
const originalEmit = process.emit;
process.emit = function(event, ...args) {
  if (event === 'warning' || event === 'deprecation') {
    return false;
  }
  return originalEmit.apply(this, [event, ...args]);
};

// Override console methods to filter warnings
const originalConsoleWarn = console.warn;
const originalConsoleError = console.error;

console.warn = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return;
  }
  originalConsoleWarn.apply(console, args);
};

console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return;
  }
  originalConsoleError.apply(console, args);
};

// Override process streams
const originalStderrWrite = process.stderr.write;
const originalStdoutWrite = process.stdout.write;

process.stderr.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return true;
  }
  return originalStderrWrite.call(this, chunk, encoding, callback);
};

process.stdout.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning')) {
    return true;
  }
  return originalStdoutWrite.call(this, chunk, encoding, callback);
};

// Remove all warning listeners
process.removeAllListeners('warning');
process.on('warning', () => {});

// Patch util._extend globally and suppress DEP0060 warnings
try {
  const util = require('util');
  if (util._extend) {
    util._extend = Object.assign;
  }
  
  // Override the deprecated util._extend with Object.assign
  Object.defineProperty(util, '_extend', {
    value: Object.assign,
    writable: false,
    configurable: false
  });
} catch (e) {
  // Ignore errors
}

// Additional suppression for DEP0060 warnings (already handled above)

// Start Angular CLI
require('@angular/cli/bin/ng');