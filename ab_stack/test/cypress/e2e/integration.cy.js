// eslint-disable-next-line prettier/prettier
const testCases = [
   require("./test_cases/001_portal_auth_login.js"),
];

// Don't stop tests on uncaught errors
Cypress.on("uncaught:exception", (e) => {
   // Unless the error matches below
   if (!e.message.includes("this.parentFormComponent is not a function")) {
      return false;
   }
});

before(() => {
   cy.visit("/");
});

describe("Smoke Test", () => {
   it("Visit AB", () => {
      cy.AuthLogin();
      cy.visit("/");
      cy.get("[data-cy=portal_work_menu_sidebar]").should("exist");
   });
});

describe("Tests", () => {
   before(() => {
      function initialLoad() {
         // cy.RunSQL([
         //    "reset_db.sql"
         // ]);
         cy.RunSQL([
            "reset_db.sql",
            "init_db_permissions.sql",
            "init_db_default.sql",
         ]);
      }
      initialLoad();
      cy.visit("/");
   });
   beforeEach(() => {
      // cy.RunSQL(["clearObjs.sql", "init_db_default.sql"]);
      cy.AuthLogin();
      cy.visit("/");
   });

   testCases.forEach((tc) => {
      tc();
   });
});

