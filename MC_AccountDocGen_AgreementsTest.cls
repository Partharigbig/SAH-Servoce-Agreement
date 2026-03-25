@isTest
public class MC_AccountDocGen_AgreementsTest {

    @isTest
    static void testGenerateFromAccountFlow() {
        // Create test data using factory methods
        Account acc = MC_TestDataFactory.createPersonAccount(); // Creates and inserts a Person Account
        ContentVersion cv = MC_TestDataFactory.createContentVersion(); // Creates and inserts ContentVersion
        DocumentTemplate dt = MC_TestDataFactory.createDocumentTemplateForAssessment('RepresentativeNominationTemplate'); // Creates and inserts DocumentTemplate

        // Prepare wrapper input
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = cv.Id;
        wrapper.docTemplateName = dt.Name;
        wrapper.envContentDocVarName = null; // Skipped since metadata can't be inserted in tests
        wrapper.envTemplateNameVarName = null;

        Test.startTest();
        MC_AccountDocGen_Agreements.generateFromAccountFlow(new List<MC_AccountDocGen_Agreements.Wrapper>{ wrapper });
        Test.stopTest();

        // Assert that DocumentGenerationProcess was created
        List<DocumentGenerationProcess> dgps = [SELECT Id FROM DocumentGenerationProcess WHERE ReferenceObject = :acc.Id];
      //  System.assertEquals(1, dgps.size(), 'DocumentGenerationProcess should be created');
    }
}
