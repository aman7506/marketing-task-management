#!/usr/bin/env node

// Ultra-aggressive warning suppression script
process.env.NODE_NO_WARNINGS = '1';
process.env.NODE_OPTIONS = '--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096';

// Completely override the warning system
const originalEmitWarning = process.emitWarning;
process.emitWarning = function() {
  // Suppress ALL warnings
  return;
};

// Override console methods
const originalConsoleWarn = console.warn;
const originalConsoleError = console.error;
const originalConsoleLog = console.log;

console.warn = function() {
  // Suppress all warnings
  return;
};

console.error = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return;
  }
  originalConsoleError.apply(console, args);
};

console.log = function(...args) {
  const message = args.join(' ');
  if (message.includes('DEP0060') || message.includes('util._extend') || message.includes('deprecated') || message.includes('DeprecationWarning') || message.includes('(node:') || message.includes('Use `node --trace-deprecation')) {
    return;
  }
  originalConsoleLog.apply(console, args);
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

// Override util._extend globally
const util = require('util');
if (util._extend) {
  util._extend = Object.assign;
}

// Override process.on('warning')
process.removeAllListeners('warning');
process.on('warning', () => {});

// Override process.listeners
const originalListeners = process.listeners;
process.listeners = function(event) {
  if (event === 'warning') {
    return [];
  }
  return originalListeners.call(this, event);
};

// Override process.off
const originalOff = process.off;
process.off = function(event, listener) {
  if (event === 'warning') {
    return this;
  }
  return originalOff.call(this, event, listener);
};

// Override process.once
const originalOnce = process.once;
process.once = function(event, listener) {
  if (event === 'warning') {
    return this;
  }
  return originalOnce.call(this, event, listener);
};

// Override process.addListener
const originalAddListener = process.addListener;
process.addListener = function(event, listener) {
  if (event === 'warning') {
    return this;
  }
  return originalAddListener.call(this, event, listener);
};

// Override process.removeListener
const originalRemoveListener = process.removeListener;
process.removeListener = function(event, listener) {
  if (event === 'warning') {
    return this;
  }
  return originalRemoveListener.call(this, event, listener);
};

// Start the Angular CLI
require('@angular/cli/bin/ng');
