/* eslint-disable cypress/unsafe-to-chain-command */

/** Bible study group app id from ab_stack/defs/app_bibleStudyGroup_20260416.json */
const BIBLE_STUDY_APP_ID = "a7418441-67ea-4311-a237-e39feb9824d1";

export default () => {
   describe("Bible study group app", () => {
      it("opens app from portal and shows seeded mother", () => {
         cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible").click();
         cy.get(`[data-cy=${BIBLE_STUDY_APP_ID}]`).should("be.visible").click();
         cy.get("body").should("contain", "Seed Mother");
      });
   });
};
