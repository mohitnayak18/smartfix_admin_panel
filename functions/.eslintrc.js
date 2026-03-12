module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    "quotes": ["error", "single", { "avoidEscape": true }],
    "indent": ["error", 2],
    "max-len": ["error", { "code": 120 }],
    "comma-dangle": ["error", "always-multiline"],
    "arrow-parens": ["error", "always"],
    "padded-blocks": ["error", "never"],
    "eol-last": ["error", "always"],
  },
};