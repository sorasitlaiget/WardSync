/**
 * Simple logger utility
 * Uses ANSI colors for terminal output
 */

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  gray: '\x1b[90m',
};

function timestamp(): string {
  return new Date().toISOString();
}

function format(level: string, color: string, message: string, ...args: unknown[]): string {
  const ts = `${colors.gray}${timestamp()}${colors.reset}`;
  const lvl = `${color}[${level}]${colors.reset}`;
  const extras = args.length > 0 ? ' ' + args.map(a => typeof a === 'object' ? JSON.stringify(a, null, 2) : String(a)).join(' ') : '';
  return `${ts} ${lvl} ${message}${extras}`;
}

export const logger = {
  info: (message: string, ...args: unknown[]) => {
    console.log(format('INFO', colors.green, message, ...args));
  },
  warn: (message: string, ...args: unknown[]) => {
    console.warn(format('WARN', colors.yellow, message, ...args));
  },
  error: (message: string, ...args: unknown[]) => {
    console.error(format('ERROR', colors.red, message, ...args));
  },
  debug: (message: string, ...args: unknown[]) => {
    if (process.env.NODE_ENV !== 'production') {
      console.log(format('DEBUG', colors.blue, message, ...args));
    }
  },
};
