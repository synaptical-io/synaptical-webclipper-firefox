- [x] Setup pre-commit hook using Husky
- [ ] Check for Jetbrains Biome plugin and configure environment setting if it exists
- [ ] Revise project setup scripts to update package.json for format, lint, and check
- [ ] Evaluate Firefox Devtools extension
- [ ] Create documentation describing how to create a Firefox profile for debugging
---

# TODO Details

### Installing husky
```bash
npm install --save-dev husky lint-staged
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

### Revise package.json - linting
```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx,json,css}": [
      "biome check --write"
    ]
  }
}
```

---

### Revise package.json - scripts
```
"biome:format": "biome format .",
"biome:lint": "biome lint .",
"biome:check": "biome check ."
```

---

### Revise .vscode/extensions.json
```
// Firefox extension dev / debugging
"firefox-devtools.vscode-firefox-debug", // Debug your web extension directly in Firefox
```

---
