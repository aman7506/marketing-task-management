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

// Start the actual command
require('child_process').spawn('node', ['node_modules/@angular/cli/bin/ng', 'serve'], {stdio: 'inherit'});
