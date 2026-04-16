const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const { defineConfig } = require("cypress");

const composeProject =
   process.env.COMPOSE_PROJECT_NAME ||
   process.env.CYPRESS_COMPOSE_PROJECT ||
   "ab_stack";

module.exports = defineConfig({
   chromeWebSecurity: false,
   experimentalModifyObstructiveThirdPartyCode: true,
   defaultCommandTimeout: 12000,
   env: {
      composeProject,
   },
   responseTimeout: 60000,
   video: false,
   experimentalWebKitSupport: true,
   // supportFile: false,
   e2e: {
      baseUrl: "http://localhost:8088/",
      excludeSpecPattern: [
         "**/test_cases/*.js",
         "**/test_setup/**",
         "**/test_setup/auth/**/*",
      ],
      specPattern: "cypress/e2e/**/*.js",
   },
});
