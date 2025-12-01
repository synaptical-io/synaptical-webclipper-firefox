module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // You can customize or tighten as desired:
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'build',
        'ci',
        'chore',
        'revert',
      ],
    ],
    'scope-empty': [0, 'never'], // 0 = off; change to 2 to require scopes
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']], // allow kebab, lower, etc.
  },
};
