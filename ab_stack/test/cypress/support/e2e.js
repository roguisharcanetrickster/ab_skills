// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

Cypress.Commands.add("AuthLogin", () => {
   cy.session("admin", () => {
      const email = Cypress.env("USER_EMAIL") || "admin@email.com";
      cy.log(`Logging in as ${email}`);
      cy.request("POST", "/auth/login", {
         tenant: Cypress.env("TENANT") || "admin",
         email,
         password: Cypress.env("USER_PASSWORD") || "admin",
      })
         .its("body")
         .as("currentUser");
   });
});

Cypress.Commands.add("RunSQL", (files) => {
   const composeProject = Cypress.env("composeProject");
   if (!composeProject) {
      throw new Error(
         "Cypress env composeProject missing; set COMPOSE_PROJECT_NAME in .env to match docker compose project name.",
      );
   }
   const user = Cypress.env("DB_USER") || "root";
   const password = Cypress.env("DB_PASSWORD") || "root";

   const regEx = /^\S+/;
   cy.exec(`docker ps | grep ${composeProject}-db`).then(({ stdout }) => {
      if (!regEx.test(stdout)) {
         throw new Error(
            `No db container matching '${composeProject}-db'. Check COMPOSE_PROJECT_NAME and docker compose project.`,
         );
      }
      const containerId = stdout.match(regEx)[0];
      /* eslint-disable no-useless-escape*/
      files.forEach((file) => {
         let catCmd = `cat ./cypress/e2e/test_setup/sql/${file} > ./cypress/e2e/test_setup/sql/combineSql.sql`;
         cy.log(catCmd);
         cy.exec(catCmd);
      });
      cy.exec(`docker exec ${containerId} mkdir -p /sql`);
      cy.exec(
         `docker cp ./cypress/e2e/test_setup/sql/combineSql.sql ${containerId}:/sql/combineSql.sql`,
         {
            log: false,
         },
      );

      cy.exec(
         /* eslint-disable no-useless-escape*/
         `docker exec ${containerId} bash -c "mysql -u ${user} -p${password} \"appbuilder-admin\" < ./sql/combineSql.sql"`,
         { failOnNonZeroExit: true },
      );
      // cy.exec(
      //    /* eslint-disable no-useless-escape*/
      //    `docker exec ${containerId} bash -c "mysql -u ${user} -p${password} \"appbuilder-admin\" < ./sql/combineSql.sql"`,
      //    { failOnNonZeroExit: fail }
      // {failOnNonZeroExit: false}
      // );

      cy.exec(`docker exec ${containerId} bash -c "rm ./sql/combineSql.sql"`, {
         log: false,
      });
      cy.exec(`rm ./cypress/e2e/test_setup/sql/combineSql.sql`, {
         log: false,
      });
      //   });
      // });
   });
});