// .husky/pre-commit runs the same check pipeline as package.json > lint script,
// but scoped to staged files only
module.exports = {
  '**/*.{js,ts,tsx}': ['biome check --write'],
  '**/*.{json,css}': ['biome check --write'],
};
