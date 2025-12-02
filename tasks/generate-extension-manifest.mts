#!/usr/bin/env node

import { promises as fs } from 'node:fs';
import path, { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function main() {
  const repoRoot = path.resolve(__dirname, '..');
  const templatePath = path.join(
    repoRoot,
    'src',
    'templates',
    'manifests',
    'base-extension-manifest.json',
  );
  const outPath = path.join(repoRoot, 'build', 'manifest.json');
  const pkgPath = path.join(repoRoot, 'package.json');

  const [templateRaw, pkgRaw] = await Promise.all([
    fs.readFile(templatePath, 'utf8'),
    fs.readFile(pkgPath, 'utf8'),
  ]);

  const pkg = JSON.parse(pkgRaw);
  const version = pkg.version || '0.0.0';

  const manifestRaw = templateRaw.replace('__VERSION__', version);

  await fs.mkdir(path.dirname(outPath), { recursive: true });
  await fs.writeFile(outPath, manifestRaw, 'utf8');

  console.log(`✅ Generated manifest.json (${version}) → ${outPath}`);
}

main().catch((err) => {
  console.error('❌ Failed to generate extension manifest.');
  console.error(err);
  process.exit(1);
});
