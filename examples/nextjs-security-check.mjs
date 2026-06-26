#!/usr/bin/env node

import fs from 'node:fs';

const packageJsonPath = process.argv[2] || 'package.json';
const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

const version =
  pkg.dependencies?.next ||
  pkg.devDependencies?.next ||
  pkg.peerDependencies?.next;

if (!version) {
  console.error('No Next.js version found in', packageJsonPath);
  process.exit(1);
}

const clean = version.replace(/^[^0-9]*/, '');
const [major, minor, patch] = clean.split('.').map(Number);

function fail(message) {
  console.error(`Next.js security check failed: ${message}`);
  process.exit(1);
}

if (major !== 15) {
  console.log(`Next.js version is ${clean}. This example only enforces 15.x floors.`);
  process.exit(0);
}

const floors = new Map([
  [0, 5],
  [1, 9],
  [2, 6],
  [3, 6],
  [4, 8],
  [5, 7],
]);

const requiredPatch = floors.get(minor);

if (requiredPatch === undefined) {
  console.log(`Next.js security check passed for ${clean}; please verify against current advisories.`);
  process.exit(0);
}

if (patch < requiredPatch) {
  fail(`next@${clean} is below the patched floor for 15.${minor}.x: 15.${minor}.${requiredPatch}`);
}

console.log(`Next.js security check passed: next@${clean}`);
