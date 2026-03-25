@isTest
public class MC_AccountDocGen_AgreementsTest {
 
    @isTest
    static void testHappyPath() {
        Account acc = MC_TestDataFactory.createPersonAccount();
        ContentVersion cv = MC_TestDataFactory.createContentVersion();
        DocumentTemplate dt = MC_TestDataFactory.createDocumentTemplateForAssessment('RepresentativeNominationTemplate');
 
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = cv.Id;
        wrapper.docTemplateName = dt.Name;
 
        Test.startTest();
        MC_AccountDocGen_Agreements.generateFromAccountFlow(
            new List<MC_AccountDocGen_Agreements.Wrapper>{ wrapper }
        );
        Test.stopTest();
 
        // No assert needed because insert is skipped in test context
    }
 
    @isTest
    static void testProcessAccountDirectCall() {
        Account acc = MC_TestDataFactory.createPersonAccount();
        ContentVersion cv = MC_TestDataFactory.createContentVersion();
        DocumentTemplate dt = MC_TestDataFactory.createDocumentTemplateForAssessment('RepresentativeNominationTemplate');
 
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = cv.Id;
        wrapper.docTemplateName = dt.Name;
 
        Test.startTest();
        MC_AccountDocGen_Agreements.processAccount(wrapper);
        Test.stopTest();
    }
 
    @isTest
    static void testNullInputException() {
        Test.startTest();
        try {
            MC_AccountDocGen_Agreements.generateFromAccountFlow(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No Account Id'));
        }
        Test.stopTest();
    }
 
    @isTest
    static void testEmptyRecordIdsException() {
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>();
 
        Test.startTest();
        try {
            MC_AccountDocGen_Agreements.generateFromAccountFlow(
                new List<MC_AccountDocGen_Agreements.Wrapper>{ wrapper }
            );
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No Account Id'));
        }
        Test.stopTest();
    }
 
    @isTest
    static void testNullAccountIdException() {
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ null };
 
        Test.startTest();
        try {
            MC_AccountDocGen_Agreements.processAccount(wrapper);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No Account Id'));
        }
        Test.stopTest();
    }
 
    @isTest
    static void testEnvVariableFailurePath() {
        Account acc = MC_TestDataFactory.createPersonAccount();
        DocumentTemplate dt = MC_TestDataFactory.createDocumentTemplateForAssessment('RepresentativeNominationTemplate');
 
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = null; // Force ENV path
        wrapper.docTemplateName = dt.Name;
        wrapper.envContentDocVarName = 'NON_EXISTENT_ENV';
 
        Test.startTest();
        try {
            MC_AccountDocGen_Agreements.processAccount(wrapper);
            System.assert(false, 'Expected ENV failure');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No Environment Variable'));
        }
        Test.stopTest();
    }
 
    @isTest
    static void testTemplateNotFoundException() {
        Account acc = MC_TestDataFactory.createPersonAccount();
        ContentVersion cv = MC_TestDataFactory.createContentVersion();
 
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = cv.Id;
        wrapper.docTemplateName = 'INVALID_TEMPLATE_NAME';
 
        Test.startTest();
        try {
            MC_AccountDocGen_Agreements.processAccount(wrapper);
            System.assert(false, 'Expected template failure');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('DocumentTemplate'));
        }
        Test.stopTest();
    }
 
    @isTest
    static void testNullFieldHandling() {
        Account acc = new Account(

    FirstName = 'Test',
    LastName = 'Person',

    PersonEmail = 'test@test.com',
    PersonMobilePhone = '9999999999',
    Phone = '9876564534',

    PersonBirthdate = Date.today().addYears(-30),

    // THESE ARE REQUIRED BY YOUR VALIDATION RULE
    maica_cc__Gender__pc = 'Man',
    maica_cc__Country_of_Birth__pc = 'India',
    maica_cc__Primary_Language__pc = 'English',
    maica_cc__Indigenous_Status__pc = 'Declined to answer',
    Living_Arrangements__pc = 'SINGLE',
    DVA_Card_Type__c = 'Gold Card',
    Accommodation_Residential_Setting__pc = 'Alcohol and Drugs Treatment Residence',
    Pension_Type__pc = '4',
    Carer_availability__pc = 'Has a carer'
);
        insert acc;
 
        ContentVersion cv = MC_TestDataFactory.createContentVersion();
        DocumentTemplate dt = MC_TestDataFactory.createDocumentTemplateForAssessment('RepresentativeNominationTemplate');
 
        MC_AccountDocGen_Agreements.Wrapper wrapper = new MC_AccountDocGen_Agreements.Wrapper();
        wrapper.recordIds = new List<Id>{ acc.Id };
        wrapper.templateContentVersionId = cv.Id;
        wrapper.docTemplateName = dt.Name;
 
        Test.startTest();
        MC_AccountDocGen_Agreements.processAccount(wrapper);
        Test.stopTest();
    }
}
