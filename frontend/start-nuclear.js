#!/usr/bin/env node

// Nuclear option - completely override Node.js internals
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096';

// Override the entire process object before anything loads
const originalProcess = process;

// Completely disable all warning mechanisms
originalProcess.removeAllListeners('warning');
originalProcess.on('warning', () => {});

// Override process.emitWarning completely
originalProcess.emitWarning = function() {
  return;
};

// Override all console methods with aggressive filtering
const originalConsole = console;
originalConsole.warn = function() {
  return;
};

originalConsole.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return;
  }
  // Only show real errors
  originalProcess.stderr.write(message + '\n');
};

// Override process streams with nuclear filtering
const originalStderrWrite = originalProcess.stderr.write;
const originalStdoutWrite = originalProcess.stdout.write;

originalProcess.stderr.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return true;
  }
  return originalStderrWrite.call(this, chunk, encoding, callback);
};

originalProcess.stdout.write = function(chunk, encoding, callback) {
  const message = chunk.toString();
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return true;
  }
  return originalStdoutWrite.call(this, chunk, encoding, callback);
};

// Override all process event methods
const originalOn = originalProcess.on;
const originalOnce = originalProcess.once;
const originalAddListener = originalProcess.addListener;
const originalRemoveListener = originalProcess.removeListener;
const originalOff = originalProcess.off;

originalProcess.on = function(event, listener) {
  if (event === 'warning') return this;
  return originalOn.call(this, event, listener);
};

originalProcess.once = function(event, listener) {
  if (event === 'warning') return this;
  return originalOnce.call(this, event, listener);
};

originalProcess.addListener = function(event, listener) {
  if (event === 'warning') return this;
  return originalAddListener.call(this, event, listener);
};

originalProcess.removeListener = function(event, listener) {
  if (event === 'warning') return this;
  return originalRemoveListener.call(this, event, listener);
};

originalProcess.off = function(event, listener) {
  if (event === 'warning') return this;
  return originalOff.call(this, event, listener);
};

// Patch util._extend globally before any modules load
try {
  const util = require('util');
  if (util._extend) {
    util._extend = Object.assign;
  }
} catch (e) {
  // Ignore errors
}

// Override Module.prototype.require to patch modules as they load
const Module = require('module');
const originalRequire = Module.prototype.require;

Module.prototype.require = function(id) {
  const module = originalRequire.call(this, id);
  
  // Patch util module specifically
  if (id === 'util' && module._extend) {
    module._extend = Object.assign;
  }
  
  return module;
};

// Override the internal warning system
const originalEmitWarning = originalProcess.emitWarning;
originalProcess.emitWarning = function() {
  return;
};

// Start Angular CLI
require('@angular/cli/bin/ng');
