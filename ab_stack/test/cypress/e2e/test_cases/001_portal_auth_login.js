const path = require("path");

/* eslint-disable cypress/unsafe-to-chain-command */
export default () => {
   describe("Test Movie Module", () => {
      it("View movie", () => {
         cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible").click();
         cy.get("[data-cy=874c974f-63c9-4ecb-9b4f-0b92a49568cc]").should("be.visible").click();
         cy.get("[data-cy=ABViewGrid_dc089b6d-912d-42b3-b0af-95a3b9b8df9e]").should("be.visible").contains("Citizen")
         // cy.get("[data-cy^=menu-item]").should("be.visible").click();
      });
      it.skip("Add movie", () => {
         cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible").click();
         cy.get("[data-cy=874c974f-63c9-4ecb-9b4f-0b92a49568cc]").should("be.visible").click();
         cy.get("[data-cy^=menu-item Add Movie]").should("be.visible").click();
         cy.get("[data-cy^=string Titles]").should("be.visible").type("Alien")
         cy.get("[data-cy^=date Date Released]").should("be.visible").type("1/1/1990")
         cy.get("[data-cy^=button save]").should("be.visible").click();
         cy.get("[data-cy^=ABViewGrid_dc089b6d-912d-42b3-b0af-95a3b9b8df9e]").should("be.visible").contains("Alien")
         // cy.get("[data-cy^=menu-item]").should("be.visible").click();
      });
   });
};