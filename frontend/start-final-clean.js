// Ultimate warning suppression script
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-warnings --trace-warnings=false';

// Override console methods
const originalWarn = console.warn;
const originalError = console.error;
const originalLog = console.log;

console.warn = function() {
  const args = Array.from(arguments);
  if (args.some(arg => typeof arg === 'string' && arg.includes('DEP0060'))) {
    return; // Suppress DEP0060 warnings
  }
  originalWarn.apply(console, arguments);
};

console.error = function() {
  const args = Array.from(arguments);
  if (args.some(arg => typeof arg === 'string' && arg.includes('DEP0060'))) {
    return; // Suppress DEP0060 errors
  }
  originalError.apply(console, arguments);
};

// Override process.emitWarning
const originalEmitWarning = process.emitWarning;
process.emitWarning = function(warning, name, code) {
  if (code === 'DEP0060') {
    return; // Suppress DEP0060 warnings
  }
  originalEmitWarning.call(process, warning, name, code);
};

// Override process.emit
const originalEmit = process.emit;
process.emit = function(event, ...args) {
  if (event === 'warning') {
    const warning = args[0];
    if (warning && warning.code === 'DEP0060') {
      return false; // Suppress DEP0060 warnings
    }
  }
  return originalEmit.apply(process, [event, ...args]);
};

// Override stderr
const originalStderrWrite = process.stderr.write;
process.stderr.write = function(chunk, encoding, callback) {
  if (typeof chunk === 'string' && chunk.includes('DEP0060')) {
    return true; // Suppress DEP0060 warnings
  }
  return originalStderrWrite.call(process, chunk, encoding, callback);
};

// Override stdout
const originalStdoutWrite = process.stdout.write;
process.stdout.write = function(chunk, encoding, callback) {
  if (typeof chunk === 'string' && chunk.includes('DEP0060')) {
    return true; // Suppress DEP0060 warnings
  }
  return originalStdoutWrite.call(process, chunk, encoding, callback);
};

// Patch util._extend globally
const util = require('util');
if (util._extend) {
  util._extend = Object.assign;
}

// Global patch for util._extend
global.util = global.util || {};
global.util._extend = Object.assign;

// Override require to patch modules
const originalRequire = require;
require = function(id) {
  const module = originalRequire(id);
  
  // Patch util module if it's being required
  if (id === 'util' && module._extend) {
    module._extend = Object.assign;
  }
  
  return module;
};

console.log('🚀 Starting Angular with all warnings suppressed...');

// Start Angular CLI
require('@angular/cli/bin/ng');
