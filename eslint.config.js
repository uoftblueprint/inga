const prettier = require("eslint-plugin-prettier");
const eslintConfigPrettier = require("eslint-config-prettier");

module.exports = [
  eslintConfigPrettier,
  {
    plugins: {
      prettier,
    },
    rules: {
      "prettier/prettier": ["error"],
    },
  },
];
