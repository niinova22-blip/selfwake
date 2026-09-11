// PostToolUse (Edit|Write): package.json varsa degisen dosyayi prettier ile bicimlendirir.
// package.json, prettier veya desteklenmeyen uzanti yoksa sessizce cikar.
import { readFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import path from 'node:path';

let file;
try {
  const j = JSON.parse(readFileSync(0, 'utf8'));
  file = j.tool_response?.filePath ?? j.tool_input?.file_path;
} catch {}
if (!file) process.exit(0);

const root = process.env.CLAUDE_PROJECT_DIR || process.cwd();
if (!existsSync(path.join(root, 'package.json'))) process.exit(0);
if (!/\.(m?[jt]sx?|json|css|scss|less|html|vue|svelte|md|ya?ml)$/i.test(file)) process.exit(0);

try {
  execFileSync('npx', ['--no-install', 'prettier', '--write', file], {
    stdio: 'ignore',
    shell: true,
    cwd: root,
  });
} catch {}
process.exit(0);
