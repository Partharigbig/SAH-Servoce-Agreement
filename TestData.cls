/**
 * @description       : Test Data Factory
 * @author            : Cognizant
 * @group             : 
 * @last modified on  : 04-09-2025
 * @last modified by  : 
**/
@isTest
public with sharing class MC_TestDataFactory {
    public static List<Account> createAccount(Integer numberOfAccounts){
        // For creating Account records
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account' + i;     
            accList.add(acc);
        }

        insert accList;
        return accList;
    }
    public static Account createAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }
    public static Account createPersonAccount() {
        Id recordTypeIdPersonAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account(FirstName='Cilent1',LastName='Account',Phone = '1234567890',Website = 'www.example.com',RecordTypeId=recordTypeIdPersonAccount,
                                       PersonEmail = 'testSales@apex.com');
        insert acc;
        return acc;
    }
    public static Opportunity createOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = accountId,
            StageName = 'New',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        return opp;
    }
    public static maica_cc__Support_Item__c CreateSupportItem(){
        maica_cc__Support_Item__c supportItem = new maica_cc__Support_Item__c();
        supportItem.Name = 'Ingoing Contribution';
        insert supportItem;
        return supportItem;
    }
    public static maica_cc__Support_Category__c CreateSupportCategory(){
        maica_cc__Support_Category__c supportCategory = new maica_cc__Support_Category__c();
        supportCategory.Name = 'Home and Living';
        
        insert supportCategory;
        return supportCategory;
    }
    public static Product2 createProduct(Id supportCategoryId) {
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true, Support_Category__c=supportCategoryId);
        insert prod;
        return prod;
    }
    public static PricebookEntry createPricebookEntry(Id productId) {
        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId());
        pb.IsActive = true;
        update pb;

        // Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        System.assertNotEquals(null, pbe.Id, 'PricebookEntry should be created');

        return pbe;
    } 
    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id pbeId, Id supportItemId) {
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppId,
            Quantity = 2,
            UnitPrice = 100,
            PricebookEntryId = pbeId,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(10),
            //Support_Category__c = 'Category A',
            //Support_Item_Number__c = supportItemId,
            Service_Day__c = 'Weekday',
            Service_Frequency__c = 'Week',
            Service_Time__c = 'Daytime'
        );
        insert oli;
        return oli;
    }
    public static DocumentTemplate createDocumentTemplate() {
        DocumentTemplate docTemplate = new DocumentTemplate(Name = 'Quote', IsActive = true, Type='MicrosoftWord', TokenMappingType='JSON', TokenMappingMethodType='CustomClass',CustomClassName='MC_QuoteGeneration');
        insert docTemplate;
        return docTemplate;
    } 
    public static DocumentTemplate createDocumentTemplateForAssessment(String docName) {
        DocumentTemplate docTemplate = new DocumentTemplate(Name = docName, IsActive = true, Type='MicrosoftWord', TokenMappingType='JSON', TokenMappingMethodType='CustomClass',CustomClassName='MC_DocumentGenerationClass');
        insert docTemplate;
        return docTemplate;
    }
    public static DocumentTemplate createDocumentTemplateForInvoice(String docNameinvoice) {
        DocumentTemplate docInvTemplate = new DocumentTemplate(Name = docNameinvoice, IsActive = true, Type='MicrosoftWord', TokenMappingType='JSON', TokenMappingMethodType='CustomClass',CustomClassName='MC_InvoiceDocumentGenerationClass');
        insert docInvTemplate;
        return docInvTemplate;
    }
    public static ContentVersion createContentVersion() {
        ContentVersion cv = new ContentVersion(
            Title = 'Quote Template',
            PathOnClient = 'QuoteTemplate.docx',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;
        return cv;
    }
    public static List<tc9_pr__Payee_Leave_Event__c> createPayeeLeaveEvent(Integer numberOfPayeeLeaveEvent) {
        // For Creating Payee Leave Event records

        // Creating Pay Code
        tc9_pr__Pay_Code__c payCode = new tc9_pr__Pay_Code__c();
        payCode.Name = 'Test pay Code';
        payCode.tc9_pr__Description__c = 'Testing xyz';
        payCode.tc9_pr__Pay_Advice_Description__c = 'Testing xyz and abc';
        payCode.tc9_pr__Pay_Rate_Multiplier__c = 12;
        payCode.tc9_pr__STP_Payment_Type__c = 'Gross';
        payCode.RecordTypeId = '0129p000001HdA4AAK';
        insert payCode;

        // Creating Unpaid Pay Code
        tc9_pr__Pay_Code__c unpayCode = new tc9_pr__Pay_Code__c();
        unpayCode.Name = 'Test unpaid Code';
        unpayCode.tc9_pr__Description__c = 'Testing xyz unpaid';
        unpayCode.tc9_pr__Pay_Advice_Description__c = 'Testing xyz and abc';
        unpayCode.tc9_pr__Pay_Rate_Multiplier__c = 12;
        unpayCode.tc9_pr__STP_Payment_Type__c = 'Gross';
        unpayCode.RecordTypeId = '0129p000001HdA4AAK';
        insert unpayCode;

        // Creating Leave Rule
        tc9_pr__Leave_Rule__c leaveRule = new tc9_pr__Leave_Rule__c();
        leaveRule.Name = 'Test Rule';
        leaveRule.tc9_pr__Effective_Date__c = System.today();
        leaveRule.tc9_pr__Status__c = 'Active';
        leaveRule.tc9_pr__Pay_Code__c = payCode.Id;
        leaveRule.tc9_pr__Unpaid_Pay_Code__c = unpayCode.Id;
        leaveRule.tc9_pr__Available_Pay_Rates__c = 'Standard Pay';
        leaveRule.tc9_pr__Allow_Pay_in_Advance__c = 'Yes';
        leaveRule.tc9_pr__Skip_Manager_Approval__c = 'Yes';
        insert leaveRule;

        // Creating Employee 
        Contact employee = new Contact();
        employee.FirstName = 'Test';
        employee.LastName = 'Employee 1';
        employee.RecordTypeId = '0129p000001Hd9QAAS';
        insert employee;
        
        // Creating Payment Entity
        Account paymentEntity = new Account();
        paymentEntity.Name = 'Test Payment Entity';
        paymentEntity.Phone = '1231231440';
        paymentEntity.RecordTypeId = '0129p000001Hd9FAAS';
        paymentEntity.tc9_pr__Available_Payment_Methods__c = 'Payee Australian Bank';
        paymentEntity.tc9_pr__Maximum_Payment_Distributions__c = '1';
        insert paymentEntity;

        // Creating Payee
        tc9_pr__Payee__c payee = new tc9_pr__Payee__c();
        payee.tc9_pr__Employee__c = employee.Id;
        payee.tc9_pr__Payment_Entity__c = paymentEntity.Id;
        payee.tc9_pr__Payroll_Start_Date__c = System.today();
        payee.tc9_pr__Payroll_Id__c = '000111';
        payee.tc9_pr__Primary_Record__c = true;
        payee.tc9_pr__Payment_Details_Complete__c = 'No';
        payee.tc9_pr__Payment_Consolidation__c = 'Separated';
        payee.tc9_pr__Payment_Details_Incomplete_reason__c = 'No Payment Found';
        insert payee;
        
        // Creating Payee Leave Rule
        tc9_pr__Payee_Leave_Rule__c payeeLeaveRule = new tc9_pr__Payee_Leave_Rule__c();
        payeeLeaveRule.tc9_pr__Effective_Date__c = System.today();
        payeeLeaveRule.tc9_pr__Status__c = 'Pending';
        payeeLeaveRule.tc9_pr__Original_Leave_Service_Date__c = System.today().addDays(-5);
        payeeLeaveRule.tc9_pr__Skip_Manager_Approval__c = 'No';
        payeeLeaveRule.tc9_pr__Leave_Rule__c = leaveRule.Id;
        payeeLeaveRule.tc9_pr__Payee__c = payee.Id;
        payeeLeaveRule.tc9_pr__Employee__c = employee.Id;
        insert payeeLeaveRule;

        // Creating Schedule
        tc9_pr__Schedule__c schedule = new tc9_pr__Schedule__c();
        schedule.RecordTypeId='0129p000001HdD7AAK';
        schedule.Name='Test Schedule';
        schedule.tc9_pr__Split_Option__c='No Split';
        schedule.tc9_pr__Period_Type__c='Monthly';
        insert schedule;

        // Creating Client 
        Account client = new Account();
        client.Name = 'Test Client';
        client.Phone = '1231231231';
        client.RecordTypeId = '0129p000001HdpBAAS';
        client.tc9_pr__Schedule__c = schedule.Id;
        insert client; 

        // Creating Assignment
        tc9_pr__Assignment__c assignment = new tc9_pr__Assignment__c();
        assignment.tc9_pr__Employee__c = employee.Id;
        assignment.tc9_pr__Assignment_Name__c = 'Test Assignment';
        assignment.tc9_pr__Payee__c = payee.Id;
        assignment.tc9_pr__Client__c = client.Id;
        assignment.tc9_pr__Payment_Entity__c = paymentEntity.Id;
        assignment.tc9_pr__Schedule__c = schedule.Id;
        assignment.tc9_pr__Assignment_Start_Date__c = System.today();
        assignment.tc9_pr__Assignment_End_Date__c = System.today().addMonths(1);
        assignment.tc9_pr__Status__c = 'Pending';
        insert assignment;

        List<tc9_pr__Payee_Leave_Event__c> payeeOnLeaveList = new List<tc9_pr__Payee_Leave_Event__c>();
        // Creating Payee Leave Event
        for (Integer i = 0; i < numberOfPayeeLeaveEvent; i++) {
            tc9_pr__Payee_Leave_Event__c payeeOnLeave = new tc9_pr__Payee_Leave_Event__c();
            payeeOnLeave.tc9_pr__Reason__c = 'Personal Leave';
            payeeOnLeave.RecordTypeId = '0129p000001HdCZAA0';
            payeeOnLeave.tc9_pr__Skip_Manager_Approval__c = 'Yes';
            payeeOnLeave.tc9_pr__Approval_Status__c = 'New';
            payeeOnLeave.tc9_pr__Payee_Leave_Rule__c = payeeLeaveRule.Id;
            payeeOnLeave.tc9_pr__Selected_Pay_Rate__c = 'Standard Pay';
            payeeOnLeave.tc9_pr__Payee__c = payee.Id; 
            payeeOnLeave.tc9_pr__Employee__c = employee.Id; 
            payeeOnLeave.tc9_pr__Assignment__c = assignment.Id; 
            payeeOnLeave.tc9_pr__Start_Date__c = System.today(); 
            payeeOnLeave.tc9_pr__End_Date__c = System.today().addDays(5); 
            payeeOnLeave.tc9_pr__Hours__c = 8; 
            payeeOnLeave.tc9_pr__Processing_Status__c = 'New'; 
            payeeOnLeaveList.add(payeeOnLeave);
        }
        insert payeeOnLeaveList;
        return payeeOnLeaveList;        
    }
    public static void createDocumentMappings(){
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        Document_Mappings__c docMapping = new Document_Mappings__c();
        docMapping.Document_Token__c = 'Amount__c';
        docMapping.Is_Parent_Object_Mapping__c = false;
        docMapping.Is_Child_Object_Mapping__c = false;
        docMapping.Token_Value__c = 'Amount__c';
        docMapping.Document_Name__c = 'EnteralFeeding'; 
        docMapping.Data_Type__c = 'Text';
        documentMappings.add(docMapping);
        
        Document_Mappings__c docMapping3 = new Document_Mappings__c();
        docMapping3.Document_Token__c = 'Giving_Set_Changed__c';
        docMapping3.Is_Parent_Object_Mapping__c = false;
        docMapping3.Is_Child_Object_Mapping__c = true;
        docMapping3.Token_Value__c = 'Giving_Set_Changed__c';
        docMapping3.Document_Name__c = 'EnteralFeeding'; 
        docMapping3.Data_Type__c = 'Boolean';
        documentMappings.add(docMapping3);
        
        Document_Mappings__c docMapping4 = new Document_Mappings__c();
        docMapping4.Document_Token__c = 'Date_Generated__c';
        docMapping4.Is_Parent_Object_Mapping__c = false;
        docMapping4.Is_Child_Object_Mapping__c = false;
        docMapping4.Token_Value__c = 'Date_Generated__c';
        docMapping4.Document_Name__c = 'EnteralFeeding'; 
        docMapping4.Data_Type__c = 'Date';
        documentMappings.add(docMapping4);
        
        Document_Mappings__c docMapping5 = new Document_Mappings__c();
        docMapping5.Document_Token__c = 'Date_of_Birth__c';
        docMapping5.Is_Parent_Object_Mapping__c = true;
        docMapping5.Is_Child_Object_Mapping__c = false;
        docMapping5.Token_Value__c = 'Date_of_Birth__c';
        docMapping5.Document_Name__c = 'EnteralFeeding'; 
        docMapping5.Data_Type__c = 'Date';
        documentMappings.add(docMapping5);
        
        Document_Mappings__c docMapping6 = new Document_Mappings__c();
        docMapping6.Document_Token__c = 'Formula_Type__c';
        docMapping6.Is_Parent_Object_Mapping__c = false;
        docMapping6.Is_Child_Object_Mapping__c = false;
        docMapping6.Token_Value__c = 'Formula_Type__c';
        docMapping6.Document_Name__c = 'EnteralFeeding'; 
        docMapping6.Data_Type__c = 'Picklist';
        documentMappings.add(docMapping6);
        
        Document_Mappings__c docMapping7 = new Document_Mappings__c();
        docMapping7.Document_Token__c = 'Time_Generated__c';
        docMapping7.Is_Parent_Object_Mapping__c = false;
        docMapping7.Is_Child_Object_Mapping__c = false;
        docMapping7.Token_Value__c = 'Time_Generated__c';
        docMapping7.Document_Name__c = 'EnteralFeeding'; 
        docMapping7.Data_Type__c = 'Time';
        documentMappings.add(docMapping7);
        
        Document_Mappings__c docMapping8 = new Document_Mappings__c();
        docMapping8.Document_Token__c = 'Giving_Yes';
        docMapping8.Is_Parent_Object_Mapping__c = false;
        docMapping8.Is_Child_Object_Mapping__c = true;
        docMapping8.Token_Value__c = 'Signature__c';
        docMapping8.Document_Name__c = 'EnteralFeeding'; 
        docMapping8.Data_Type__c = 'Text_Transform';
        documentMappings.add(docMapping8);
        
         insert documentMappings;
        
       
        //return documentMappings;
    }
    
    public static void createDocumentMappings2(){
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        Document_Mappings__c docMapping = new Document_Mappings__c();
        docMapping.Document_Token__c = 'T11_All of the time';
        docMapping.Is_Parent_Object_Mapping__c = false;
        docMapping.Is_Child_Object_Mapping__c = false;
        docMapping.Token_Value__c = 'Question_1__c';
        docMapping.Document_Name__c = 'KesslerPsychologicalDistressScale'; 
        docMapping.Data_Type__c = 'Text_Transform';
        documentMappings.add(docMapping);
        
        
        Document_Mappings__c docMapping8 = new Document_Mappings__c();
        docMapping8.Document_Token__c = 'Assessor_Name_Designation__c';
        docMapping8.Is_Parent_Object_Mapping__c = false;
        docMapping8.Is_Child_Object_Mapping__c = false;
        docMapping8.Token_Value__c = 'Assessor_Name_Designation__c';
        docMapping8.Document_Name__c = 'KesslerPsychologicalDistressScale'; 
        docMapping8.Data_Type__c = 'Text';
        documentMappings.add(docMapping8);
        
         insert documentMappings;
        
       
        //return documentMappings;
    }

	public static void createDocumentMappings3(){
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();

        Document_Mappings__c docMapping = new Document_Mappings__c();
        docMapping.Document_Token__c = 'Name_of_Doctor__c';
        docMapping.Is_Parent_Object_Mapping__c = false;
        docMapping.Is_Child_Object_Mapping__c = false;
        docMapping.Token_Value__c = 'Name_of_Doctor__c';
        docMapping.Document_Name__c = 'IndividualSupportPlan'; 
        docMapping.Data_Type__c = 'Text';
        documentMappings.add(docMapping);
        
        Document_Mappings__c docMapping9 = new Document_Mappings__c();
        docMapping9.Document_Token__c = 'Doctors_Details_Phone_No__c';
        docMapping9.Is_Parent_Object_Mapping__c = false;
        docMapping9.Is_Child_Object_Mapping__c = false;
        docMapping9.Token_Value__c = 'Doctors_Details_Phone_No__c';
        docMapping9.Document_Name__c = 'IndividualSupportPlan'; 
        docMapping9.Data_Type__c = 'Phone';
        documentMappings.add(docMapping9);

		Document_Mappings__c docMapping10 = new Document_Mappings__c();
        docMapping10.Document_Token__c = 'Identification_Date__c';
        docMapping10.Is_Parent_Object_Mapping__c = false;
        docMapping10.Is_Child_Object_Mapping__c = false;
        docMapping10.Token_Value__c = 'Identification_Date__c';
        docMapping10.Document_Name__c = 'IndividualSupportPlan'; 
        docMapping10.Data_Type__c = 'Date';
		docMapping10.Is_Unrelated_Object_Mapping__c = true;
		docMapping10.Unrelated_Object_Name__c = 'AllergyIntolerance';
        documentMappings.add(docMapping10);
		
		Document_Mappings__c docMapping11 = new Document_Mappings__c();
        docMapping11.Document_Token__c = 'Additional_Notes__c';
        docMapping11.Is_Parent_Object_Mapping__c = false;
        docMapping11.Is_Child_Object_Mapping__c = false;
        docMapping11.Token_Value__c = 'Additional_Notes__c';
        docMapping11.Document_Name__c = 'IndividualSupportPlan'; 
        docMapping11.Data_Type__c = 'Text Area';
		docMapping11.Is_Unrelated_Object_Mapping__c = true;
		docMapping11.Unrelated_Object_Name__c = 'AllergyIntolerance';
        documentMappings.add(docMapping11);
        
		Document_Mappings__c docMapping12 = new Document_Mappings__c();
        docMapping12.Document_Token__c = 'OS_AllergyDescription__c';
        docMapping12.Is_Parent_Object_Mapping__c = false;
        docMapping12.Is_Child_Object_Mapping__c = false;
        docMapping12.Token_Value__c = 'OS_AllergyDescription__c';
        docMapping12.Document_Name__c = 'IndividualSupportPlan'; 
        docMapping12.Data_Type__c = 'Text';
		docMapping12.Is_Unrelated_Object_Mapping__c = true;
		docMapping12.Unrelated_Object_Name__c = 'AllergyIntolerance';
        documentMappings.add(docMapping12);

        insert documentMappings;
        
        //return documentMappings;
    }	
    public static void createDocumentMappings6() {
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        
        //Record Creation - 1
        Document_Mappings__c docMapping13 = new Document_Mappings__c();
        docMapping13.Document_Token__c = 'Care_Plan_Developed__c';
        docMapping13.Is_Parent_Object_Mapping__c = false;
        docMapping13.Is_Child_Object_Mapping__c = false;
        docMapping13.Token_Value__c = 'Care_Plan_Developed__c';
        docMapping13.Document_Name__c = 'GoalDirectedCarePlan'; 
        docMapping13.Data_Type__c = 'Date';
        documentMappings.add(docMapping13);
        //Record Creation - 2
        Document_Mappings__c docMapping14 = new Document_Mappings__c();
        docMapping14.Document_Token__c = 'Goal_Description__c';
        docMapping14.Is_Parent_Object_Mapping__c = false;
        docMapping14.Is_Child_Object_Mapping__c = true;
        docMapping14.Token_Value__c = 'Goal_Description__c';
        docMapping14.Document_Name__c = 'GoalDirectedCarePlan'; 
        docMapping14.Data_Type__c = 'Text Area';
        documentMappings.add(docMapping14);
        //Record Creation - 3
        Document_Mappings__c docMapping15 = new Document_Mappings__c();
        docMapping15.Document_Token__c = 'Goal_Description__c';
        docMapping15.Is_Parent_Object_Mapping__c = false;
        docMapping15.Is_Child_Object_Mapping__c = true;
        docMapping15.Token_Value__c = 'Goal_Description__c';
        docMapping15.Document_Name__c = 'GoalDirectedCarePlan'; 
        docMapping15.Data_Type__c = 'Text Area';
        docMapping15.Child_Object_APiName__c = 'GDCP_Goal__c';
        documentMappings.add(docMapping15);
		//Record Creation - 4
		//
		Document_Mappings__c docMapping16 = new Document_Mappings__c();
        docMapping16.Document_Token__c = 'Action_Description__c';
        docMapping16.Is_Parent_Object_Mapping__c = false;
        docMapping16.Is_Child_Object_Mapping__c = true;
        docMapping16.Token_Value__c = 'Action_Description__c';
        docMapping16.Document_Name__c = 'GoalDirectedCarePlan'; 
        docMapping16.Data_Type__c = 'Text';
        docMapping16.Child_Object_APiName__c = 'GDCP_Action__c';
        documentMappings.add(docMapping16);     
        insert documentMappings;
    }
    
    public static Kessler_Form__c  createKesslerFormData(Id accId){
        Kessler_Form__c ksForm = new Kessler_Form__c();
        ksForm.Question_1__c = 'All of the time';
        ksForm.Related_Account__c = accId;
        insert ksForm;
        return ksForm;
        
    }
    public static Goal_Directed_Care_Plan_Fom__c  createGDCPFormData(Id accId) {
        Goal_Directed_Care_Plan_Fom__c gdcpForm = new Goal_Directed_Care_Plan_Fom__c();
        gdcpForm.Current_Situation__c = 'Current_Situation__c';
        gdcpForm.Related_Account__c = accId;
        insert gdcpForm;
        return gdcpForm;
    }
    public static GDCP_Goal__c createGoalRecord(Id gdcpId) {
        GDCP_Goal__c goalRecord = new GDCP_Goal__c();
        goalRecord.Goal_Description__c = 'Goal_Description__c';
        goalRecord.Goal_Directed_Care_Plan_Fom__c = gdcpId;
        insert goalRecord;
        return goalRecord;
    }
    public static GDCP_Action__c createActionRecord(Id gdcpId) {
        GDCP_Action__c actionRecord = new GDCP_Action__c();
        actionRecord.Action_Description__c = 'Action_Description__c';
        actionRecord.Goal_Directed_Care_Plan_Fom__c = gdcpId;
        insert actionRecord;
        return actionRecord;
    }
    
    public static void createNextOfkin(Id accId) {
        Account accRecord = [Select Id,PersonContactId,RecordType.Name from Account where Id =: accId];
        Id recordTypeIdPersonAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accRecord2 = new Account(FirstName='Related Cilent1 household',LastName='Account',Phone = '3237657660',Website = 'www.example.com',RecordTypeId=recordTypeIdPersonAccount,
                                       PersonEmail = 'testSalesHouse@apex.com');
      
        insert accRecord2;
        Account accRecord2Query = [Select Id,PersonContactId from Account where Id =: accRecord2.Id];
        
        PartyRoleRelation prrRecord = new PartyRoleRelation();
        prrRecord.RoleName='Husband';
        prrRecord.RelatedRoleName='Wife';
        prrRecord.RelationshipObjectName='Contact_Contact_Relationship';
        prrRecord.ShouldCreaInversRoleAuto=true;
        insert prrRecord;
        
        ContactContactRelation ccrRecord = new ContactContactRelation();
        ccrRecord.RelatedContactId = accRecord2Query.PersonContactId;
        ccrRecord.ContactId = accRecord.PersonContactId;
        ccrRecord.Next_of_Kin__c=true;
        ccrRecord.PartyRoleRelationId=prrRecord.Id;
        insert ccrRecord;
        
    }
	
    public static Enteral_feeding_chart__c createEnteralFeedingChartRecord(Id accId){
        Enteral_feeding_chart__c echart = new Enteral_feeding_chart__c();
        echart.Name__c = 'Test';
        echart.Date_of_Birth__c = system.today();
        echart.Status__c = 'Completed';
        echart.Date_Generated__c = system.today();
        echart.Time_Generated__c = Time.newInstance(14, 30, 15, 250);
        echart.Formula_Type__c = 'Champagne';
        echart.Amount__c = '10.00';
        echart.Related_Account__c = accId;
       // echart.Giving_Set_Changed__c = 'Yes';
        insert echart;
        return echart;
        
    }
    public static Enteral_Feeding_Record__c createEnteralFeedingRecord(Id feedingChartId){
        Enteral_Feeding_Record__c eRecord = new Enteral_Feeding_Record__c();
        //eRecord.Date_Time__c = system.now();
        eRecord.Pre_feed_flush_amount__c = Decimal.ValueOf('10.00');
        eRecord.Formula_amount__c = Decimal.ValueOf('10.00');
        eRecord.Total_mls__c = Decimal.ValueOf('10.00');
        eRecord.Giving_Set_Changed__c = true;
        eRecord.Enteral_Feeding_Chart__c = feedingChartId;
        eRecord.Date__c = System.today();
        eRecord.Time__c = Time.newInstance(14, 30, 15, 250);
        eRecord.Signature__c = 'Yes';
        insert eRecord;
        return eRecord;        
    }
    
    public static AllergyIntolerance createAllergyIntolerance(Id accId) {
    	AllergyIntolerance allergyrecord = new AllergyIntolerance();
        allergyrecord.PatientId = accId;
        allergyrecord.Allergy_Type__c = 'Other';
        allergyrecord.Allergy_Severity__c = 'Other';
    	allergyrecord.Identification_Date__c = System.today();
    	allergyrecord.Additional_Notes__c = 'test';
    	insert allergyrecord;
    	return allergyrecord;
		}


	public static Individual_Support_Plan__c createIndividualSupportPlan(Id accId) {
    Individual_Support_Plan__c  SupportPlan = new Individual_Support_Plan__c();
        SupportPlan.Related_Account__c = accId;
    	SupportPlan.Name_of_Doctor__c = 'Test Doctor';
    	SupportPlan.Doctors_Details_Phone_No__c = '9876543311';
    	insert SupportPlan;
    	return SupportPlan;
}
	// Fundting type != Agency Managed  & Funding Administrator = null
    public static maica_cc__Invoice__c createInvoice(Id accId){
        maica_cc__Invoice__c invoiceToInsert = new maica_cc__Invoice__c();
                invoiceToInsert.Account_Name__c = accId;
                invoiceToInsert.maica_cc__Funding_Type__c = 'Self Managed';
                invoiceToInsert.maica_cc__Funding_Administrator__c = null;
                invoiceToInsert.Service_Ref__c = '';
                invoiceToInsert.maica_cc__Invoice_Date__c = System.Today();
                invoiceToInsert.BPAY_Reference_Number__c = '32323';
                invoiceToInsert.maica_cc__Due_Date__c = System.Today() + 7;
                invoiceToInsert.Invoice_Type__c = 'Standard Charges';
            	invoiceToInsert.Dispatch_Date__c = Date.today();
            insert invoiceToInsert;
                   maica_cc__Invoice__c invoice = [
                    SELECT Id, Invoice_Number__c, maica_cc__Funding_Type__c,BPAY_Reference_Number__c,Biller_Code__c,
                   maica_cc__Invoice_Date__c,maica_cc__Funding_Administrator__c,Account_Name__r.Name,Account_Name__r.Opted_for_Direct_Debit__c,
                   Invoice_Type__c,Account_Name__r.maica_cc__NDIS_Number__pc,Account_Name__r.BillingStreet,Account_Name__r.BillingCity, Account_Name__r.BillingState, Account_Name__r.BillingPostalCode,
                   Account_Name__r.LastName,Account_Name__r.Unapplied_Payments__c,Payment_Terms_for_Doc1__c, Payment_Terms_for_Doc__c,Account_Name__r.Unapplied_Payment__c, Account_Name__r.Balance_Due__c, Account_Name__c,Total_Amount_Ex_GST__c,
                   Account_Name__r.FirstName,Account_Name__r.Days_Overdue_1__c,Account_Name__r.Days_Overdue_2__c, Account_Name__r.Days_Overdue_3__c, Account_Name__r.Days_OverDue_4__c, maica_cc__Due_Date__c,maica_cc__Total_Amount__c,Total_GST__c,
                   Account_Name__r.mecwacare_Client_ID__c
                    FROM maica_cc__Invoice__c
                    WHERE Id = :invoiceToInsert.Id
        ];
            return invoice;
    }
    
    public static maica_cc__Invoice_Line_Item__c createILI (Id invoiceId){
        maica_cc__Support_Item__c supportItem = CreateSupportItem();
        maica_cc__Invoice_Line_Item__c iliToInsert = new maica_cc__Invoice_Line_Item__c();

        iliToInsert.maica_cc__Invoice__c = invoiceId;
        iliToInsert.maica_cc__Quantity__c = 23;
        iliToInsert.maica_cc__Unit_Price__c = 23;
        iliToInsert.maica_cc__GST_Amount__c = 232;
        iliToInsert.maica_cc__Amount__c = 234;
        iliToInsert.maica_cc__Line_Total__c = 23;
        iliToInsert.maica_cc__Support_Item__c = supportItem.Id;
        iliToInsert.Service_Detail_Description__c = 'Test Class for invoice';
        insert iliToInsert;
        
      // Now re-query with all required fields
    maica_cc__Invoice_Line_Item__c ili = [
        SELECT Id, Name,
               maica_cc__Support_Item__c,
               maica_cc__Support_Item__r.Name,
               maica_cc__Amount__c,
               maica_cc__Line_Total__c,
               maica_cc__GST_Amount__c,
               maica_cc__Quantity__c,
               maica_cc__Unit_Price__c,
               Service_Detail_Description__c
        FROM maica_cc__Invoice_Line_Item__c
        WHERE Id = :iliToInsert.Id
    ];
    return ili;
    }
    public static void createDocumentMappings4(){
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        Document_Mappings__c docMapping = new Document_Mappings__c();
        docMapping.Document_Token__c = 'BPAY_Reference_Number__c';
        docMapping.Is_Parent_Object_Mapping__c = false;
        docMapping.Is_Child_Object_Mapping__c = false;
        docMapping.Token_Value__c = 'BPAY_Reference_Number__c';
        docMapping.Document_Name__c = 'Invoice_Template'; 
        docMapping.Data_Type__c = 'Text';
        documentMappings.add(docMapping);
        
        Document_Mappings__c docMapping101 = new Document_Mappings__c();
        docMapping101.Document_Token__c = 'maica_cc__NDIS_Number__pc';
        docMapping101.Is_Parent_Object_Mapping__c = true;
        docMapping101.Is_Child_Object_Mapping__c = false;
        docMapping101.Token_Value__c = 'maica_cc__NDIS_Number__pc';
        docMapping101.Document_Name__c = 'Invoice_Template'; 
        docMapping101.Data_Type__c = 'Number';
        documentMappings.add(docMapping101);
        
         Document_Mappings__c docMapping102 = new Document_Mappings__c();
        docMapping102.Document_Token__c = 'FirstName';
        docMapping102.Is_Parent_Object_Mapping__c = true;
        docMapping102.Is_Child_Object_Mapping__c = false;
        docMapping102.Token_Value__c = 'FirstName';
        docMapping102.Document_Name__c = 'Invoice_Template'; 
        docMapping102.Data_Type__c = 'Text';
        documentMappings.add(docMapping102);
        
        Document_Mappings__c docMapping103 = new Document_Mappings__c();
        docMapping103.Document_Token__c = 'LastName';
        docMapping103.Is_Parent_Object_Mapping__c = true;
        docMapping103.Is_Child_Object_Mapping__c = false;
        docMapping103.Token_Value__c = 'LastName';
        docMapping103.Document_Name__c = 'Invoice_Template'; 
        docMapping103.Data_Type__c = 'Text';
        documentMappings.add(docMapping103);
        
        Document_Mappings__c docMapping21 = new Document_Mappings__c();
        docMapping21.Document_Token__c = 'Biller_Code__c';
        docMapping21.Is_Parent_Object_Mapping__c = false;
        docMapping21.Is_Child_Object_Mapping__c = false;
        docMapping21.Token_Value__c = 'Biller_Code__c';
        docMapping21.Document_Name__c = 'Invoice_Template'; 
        docMapping21.Data_Type__c = 'Number';
        documentMappings.add(docMapping21);
         
        Document_Mappings__c docMapping22 = new Document_Mappings__c();
        docMapping22.Document_Token__c = 'maica_cc__Invoice_Date__c';
        docMapping22.Is_Parent_Object_Mapping__c = false;
        docMapping22.Is_Child_Object_Mapping__c = false;
        docMapping22.Token_Value__c = 'maica_cc__Invoice_Date__c';
        docMapping22.Document_Name__c = 'Invoice_Template'; 
        docMapping22.Data_Type__c = 'Date';
        documentMappings.add(docMapping22);
        
        Document_Mappings__c docMapping23 = new Document_Mappings__c();
        docMapping23.Document_Token__c = 'mecwacare_Client_ID__c';
        docMapping23.Is_Parent_Object_Mapping__c = true;
        docMapping23.Is_Child_Object_Mapping__c = false;
        docMapping23.Token_Value__c = 'mecwacare_Client_ID__c';
        docMapping23.Document_Name__c = 'Invoice_Template'; 
        docMapping23.Data_Type__c = 'text';
        documentMappings.add(docMapping23);
         
         Document_Mappings__c docMapping24 = new Document_Mappings__c();
        docMapping24.Document_Token__c = 'maica_cc__Line_Total__c';
        docMapping24.Is_Parent_Object_Mapping__c = false;
        docMapping24.Is_Child_Object_Mapping__c = true;
        docMapping24.Token_Value__c = 'maica_cc__Line_Total__c';
        docMapping24.Document_Name__c = 'Invoice_Template'; 
        docMapping24.Data_Type__c = 'Currency';
        documentMappings.add(docMapping24);
        
        Document_Mappings__c docMapping25 = new Document_Mappings__c();
        docMapping25.Document_Token__c = 'maica_cc__GST_Amount__c';
        docMapping25.Is_Parent_Object_Mapping__c = false;
        docMapping25.Is_Child_Object_Mapping__c = true;
        docMapping25.Token_Value__c = 'maica_cc__GST_Amount__c';
        docMapping25.Document_Name__c = 'Invoice_Template'; 
        docMapping25.Data_Type__c = 'Currency';
        documentMappings.add(docMapping25);
         
        Document_Mappings__c docMapping26 = new Document_Mappings__c();
        docMapping26.Document_Token__c = 'maica_cc__Amount__c';
        docMapping26.Is_Parent_Object_Mapping__c = false;
        docMapping26.Is_Child_Object_Mapping__c = true;
        docMapping26.Token_Value__c = 'maica_cc__Amount__c';
        docMapping26.Document_Name__c = 'Invoice_Template'; 
        docMapping26.Data_Type__c = 'Currency';
        documentMappings.add(docMapping26);
        
        Document_Mappings__c docMapping27 = new Document_Mappings__c();
        docMapping27.Document_Token__c = 'Service_Detail_Description__c';
        docMapping27.Is_Parent_Object_Mapping__c = false;
        docMapping27.Is_Child_Object_Mapping__c = true;
        docMapping27.Token_Value__c = 'Service_Detail_Description__c';
        docMapping27.Document_Name__c = 'Invoice_Template'; 
        docMapping27.Data_Type__c = 'text';
        documentMappings.add(docMapping27);
         
         Document_Mappings__c docMapping28 = new Document_Mappings__c();
        docMapping28.Document_Token__c = 'maica_cc__Quantity__c';
        docMapping28.Is_Parent_Object_Mapping__c = false;
        docMapping28.Is_Child_Object_Mapping__c = true;
        docMapping28.Token_Value__c = 'maica_cc__Quantity__c';
        docMapping28.Document_Name__c = 'Invoice_Template'; 
        docMapping28.Data_Type__c = 'Number';
        documentMappings.add(docMapping28);
        
        Document_Mappings__c docMapping29 = new Document_Mappings__c();
        docMapping29.Document_Token__c = 'maica_cc__Unit_Price__c';
        docMapping29.Is_Parent_Object_Mapping__c = false;
        docMapping29.Is_Child_Object_Mapping__c = true;
        docMapping29.Token_Value__c = 'maica_cc__Unit_Price__c';
        docMapping29.Document_Name__c = 'Invoice_Template'; 
        docMapping29.Data_Type__c = 'Currency';
        documentMappings.add(docMapping29); 
                 
        Document_Mappings__c docMapping30 = new Document_Mappings__c();
        docMapping30.Document_Token__c = 'maica_cc__Funding_Type__c';
        docMapping30.Is_Parent_Object_Mapping__c = false;
        docMapping30.Is_Child_Object_Mapping__c = false;
        docMapping30.Token_Value__c = 'maica_cc__Funding_Type__c';
        docMapping30.Document_Name__c = 'Invoice_Template'; 
        docMapping30.Data_Type__c = 'Picklist';
        documentMappings.add(docMapping30);
        
        Document_Mappings__c docMapping31 = new Document_Mappings__c();
        docMapping31.Document_Token__c = 'maica_cc__Support_Item__r.Name';
        docMapping31.Is_Parent_Object_Mapping__c = false;
        docMapping31.Is_Child_Object_Mapping__c = true;
        docMapping31.Token_Value__c = 'maica_cc__Support_Item__r.Name';
        docMapping31.Document_Name__c = 'Invoice_Template'; 
        docMapping31.Data_Type__c = 'Text';
        documentMappings.add(docMapping31);
        
        Document_Mappings__c docMapping68 = new Document_Mappings__c();
        docMapping68.Document_Token__c = 'BillingStreet';
        docMapping68.Is_Parent_Object_Mapping__c = true;
        docMapping68.Is_Child_Object_Mapping__c = false;
        docMapping68.Token_Value__c = 'BillingStreet';
        docMapping68.Document_Name__c = 'Invoice_Template'; 
        docMapping68.Data_Type__c = 'Text';
        documentMappings.add(docMapping68);
        
        Document_Mappings__c docMapping69 = new Document_Mappings__c();
        docMapping69.Document_Token__c = 'BillingPostalCode';
        docMapping69.Is_Parent_Object_Mapping__c = true;
        docMapping69.Is_Child_Object_Mapping__c = false;
        docMapping69.Token_Value__c = 'BillingPostalCode';
        docMapping69.Document_Name__c = 'Invoice_Template'; 
        docMapping69.Data_Type__c = 'Text';
        documentMappings.add(docMapping69);
        
        Document_Mappings__c docMapping70 = new Document_Mappings__c();
        docMapping70.Document_Token__c = 'BillingState';
        docMapping70.Is_Parent_Object_Mapping__c = true;
        docMapping70.Is_Child_Object_Mapping__c = false;
        docMapping70.Token_Value__c = 'BillingState';
        docMapping70.Document_Name__c = 'Invoice_Template'; 
        docMapping70.Data_Type__c = 'Text';
        documentMappings.add(docMapping70);
        
        Document_Mappings__c docMapping71 = new Document_Mappings__c();
        docMapping71.Document_Token__c = 'BillingCity';
        docMapping71.Is_Parent_Object_Mapping__c = true;
        docMapping71.Is_Child_Object_Mapping__c = false;
        docMapping71.Token_Value__c = 'BillingCity';
        docMapping71.Document_Name__c = 'Invoice_Template'; 
        docMapping71.Data_Type__c = 'Text';
        documentMappings.add(docMapping71);
        
        Document_Mappings__c docMapping72 = new Document_Mappings__c();
        docMapping72.Document_Token__c = 'Balance_Due__c';
        docMapping72.Is_Parent_Object_Mapping__c = true;
        docMapping72.Is_Child_Object_Mapping__c = false;
        docMapping72.Token_Value__c = 'Balance_Due__c';
        docMapping72.Document_Name__c = 'Invoice_Template'; 
        docMapping72.Data_Type__c = 'Text';
        documentMappings.add(docMapping72);
        
        Document_Mappings__c docMapping73 = new Document_Mappings__c();
        docMapping73.Document_Token__c = 'Balance_Due__c';
        docMapping73.Is_Parent_Object_Mapping__c = true;
        docMapping73.Is_Child_Object_Mapping__c = false;
        docMapping73.Token_Value__c = 'Balance_Due__c';
        docMapping73.Document_Name__c = 'Invoice_Template'; 
        docMapping73.Data_Type__c = 'Text';
        documentMappings.add(docMapping73);
        
         Document_Mappings__c docMapping74 = new Document_Mappings__c();
        docMapping74.Document_Token__c = 'Unapplied_Payment__c';
        docMapping74.Is_Parent_Object_Mapping__c = true;
        docMapping74.Is_Child_Object_Mapping__c = false;
        docMapping74.Token_Value__c = 'Unapplied_Payment__c';
        docMapping74.Document_Name__c = 'Invoice_Template'; 
        docMapping74.Data_Type__c = 'Text';
        documentMappings.add(docMapping74);
        
        Document_Mappings__c docMapping75 = new Document_Mappings__c();
        docMapping75.Document_Token__c = 'Days_Overdue_1__c';
        docMapping75.Is_Parent_Object_Mapping__c = true;
        docMapping75.Is_Child_Object_Mapping__c = false;
        docMapping75.Token_Value__c = 'Days_Overdue_1__c';
        docMapping75.Document_Name__c = 'Invoice_Template'; 
        docMapping75.Data_Type__c = 'Text';
        documentMappings.add(docMapping75);
        
         Document_Mappings__c docMapping76 = new Document_Mappings__c();
        docMapping76.Document_Token__c = 'Days_Overdue_2__c';
        docMapping76.Is_Parent_Object_Mapping__c = true;
        docMapping76.Is_Child_Object_Mapping__c = false;
        docMapping76.Token_Value__c = 'Days_Overdue_2__c';
        docMapping76.Document_Name__c = 'Invoice_Template'; 
        docMapping76.Data_Type__c = 'Text';
        documentMappings.add(docMapping76);
        
 		Document_Mappings__c docMapping77 = new Document_Mappings__c();
        docMapping77.Document_Token__c = 'Days_Overdue_3__c';
        docMapping77.Is_Parent_Object_Mapping__c = true;
        docMapping77.Is_Child_Object_Mapping__c = false;
        docMapping77.Token_Value__c = 'Days_Overdue_3__c';
        docMapping77.Document_Name__c = 'Invoice_Template'; 
        docMapping77.Data_Type__c = 'Text';
        documentMappings.add(docMapping77);
        
         Document_Mappings__c docMapping78 = new Document_Mappings__c();
        docMapping78.Document_Token__c = 'Days_Overdue_4__c';
        docMapping78.Is_Parent_Object_Mapping__c = true;
        docMapping78.Is_Child_Object_Mapping__c = false;
        docMapping78.Token_Value__c = 'Days_Overdue_4__c';
        docMapping78.Document_Name__c = 'Invoice_Template'; 
        docMapping78.Data_Type__c = 'Text';
        documentMappings.add(docMapping78);
        
        Document_Mappings__c docMapping79 = new Document_Mappings__c();
        docMapping79.Document_Token__c = 'maica_cc__Total_Amount__c';
        docMapping79.Is_Parent_Object_Mapping__c = false;
        docMapping79.Is_Child_Object_Mapping__c = false;
        docMapping79.Token_Value__c = 'maica_cc__Total_Amount__c';
        docMapping79.Document_Name__c = 'Invoice_Template'; 
        docMapping79.Data_Type__c = 'Currency';
        documentMappings.add(docMapping79);
        
        Document_Mappings__c docMapping80 = new Document_Mappings__c();
        docMapping80.Document_Token__c = 'Total_GST__c';
        docMapping80.Is_Parent_Object_Mapping__c = false;
        docMapping80.Is_Child_Object_Mapping__c = false;
        docMapping80.Token_Value__c = 'Total_GST__c';
        docMapping80.Document_Name__c = 'Invoice_Template'; 
        docMapping80.Data_Type__c = 'Currency';
        documentMappings.add(docMapping80);
        
        Document_Mappings__c docMapping81 = new Document_Mappings__c();
        docMapping81.Document_Token__c = 'Total_Amount_Ex_GST__c';
        docMapping81.Is_Parent_Object_Mapping__c = false;
        docMapping81.Is_Child_Object_Mapping__c = false;
        docMapping81.Token_Value__c = 'Total_Amount_Ex_GST__c';
        docMapping81.Document_Name__c = 'Invoice_Template'; 
        docMapping81.Data_Type__c = 'Currency';
        documentMappings.add(docMapping81);
        
         Document_Mappings__c docMapping82 = new Document_Mappings__c();
        docMapping82.Document_Token__c = 'Total_Amount_Ex_GST__c';
        docMapping82.Is_Parent_Object_Mapping__c = false;
        docMapping82.Is_Child_Object_Mapping__c = false;
        docMapping82.Token_Value__c = 'Total_Amount_Ex_GST__c';
        docMapping82.Document_Name__c = 'Invoice_Template'; 
        docMapping82.Data_Type__c = 'Currency';
        documentMappings.add(docMapping82);
        
         Document_Mappings__c docMapping83 = new Document_Mappings__c();
        docMapping83.Document_Token__c = 'Invoice_Number__c';
        docMapping83.Is_Parent_Object_Mapping__c = false;
        docMapping83.Is_Child_Object_Mapping__c = false;
        docMapping83.Token_Value__c = 'Invoice_Number__c';
        docMapping83.Document_Name__c = 'Invoice_Template'; 
        docMapping83.Data_Type__c = 'Text';
        documentMappings.add(docMapping83);
        
         insert documentMappings;
        
    }
    
    // Fundting type = Agency Managed  & Funding Administrator = null
    public static maica_cc__Invoice__c createInvoice2(Id accId){
        maica_cc__Invoice__c invoiceToInsert = new maica_cc__Invoice__c();
                invoiceToInsert.Account_Name__c = accId;
                invoiceToInsert.maica_cc__Funding_Type__c = 'Plan Managed';
                invoiceToInsert.maica_cc__Funding_Administrator__c = accId;
                invoiceToInsert.Service_Ref__c ='';
                invoiceToInsert.maica_cc__Invoice_Date__c = System.Today();
                invoiceToInsert.BPAY_Reference_Number__c = '32323';
                invoiceToInsert.maica_cc__Due_Date__c = System.Today() + 7;
                invoiceToInsert.Invoice_Type__c = 'Standard Charges';
            
            insert invoiceToInsert;
            
                   maica_cc__Invoice__c invoice = [
                    SELECT Id, Invoice_Number__c, maica_cc__Funding_Type__c,BPAY_Reference_Number__c,Biller_Code__c,
                   maica_cc__Invoice_Date__c,maica_cc__Funding_Administrator__c,Account_Name__r.Name,Account_Name__r.Opted_for_Direct_Debit__c,
                   Invoice_Type__c,Account_Name__r.maica_cc__NDIS_Number__pc,Account_Name__r.BillingStreet,Account_Name__r.BillingCity, Account_Name__r.BillingState, Account_Name__r.BillingPostalCode,
                   Account_Name__r.LastName,Account_Name__r.Unapplied_Payments__c,Payment_Terms_for_Doc1__c, Payment_Terms_for_Doc__c,Account_Name__r.Unapplied_Payment__c, Account_Name__r.Balance_Due__c, Account_Name__c,Total_Amount_Ex_GST__c,
                   Account_Name__r.FirstName,Account_Name__r.Days_Overdue_1__c,Account_Name__r.Days_Overdue_2__c, Account_Name__r.Days_Overdue_3__c, Account_Name__r.Days_OverDue_4__c, maica_cc__Due_Date__c,maica_cc__Total_Amount__c,Total_GST__c,
                   Account_Name__r.mecwacare_Client_ID__c
                    FROM maica_cc__Invoice__c
                    WHERE Id = :invoiceToInsert.Id
        ];
            return invoice;
    }
    
    public static maica_cc__Invoice_Line_Item__c createILI2 (Id invoiceId){
        maica_cc__Support_Item__c supportItem = CreateSupportItem();
        maica_cc__Invoice_Line_Item__c iliToInsert = new maica_cc__Invoice_Line_Item__c();
        iliToInsert.maica_cc__Invoice__c = invoiceId;
        iliToInsert.maica_cc__Quantity__c = 23;
        iliToInsert.maica_cc__Unit_Price__c = 23;
        iliToInsert.maica_cc__GST_Amount__c = 232;
        iliToInsert.maica_cc__Amount__c = 234;
        iliToInsert.maica_cc__Line_Total__c = 23;
        iliToInsert.maica_cc__Support_Item__c = supportItem.Id;
        iliToInsert.Service_Detail_Description__c = 'Test Class for invoice';
        insert iliToInsert;
        
              // Now re-query with all required fields
    maica_cc__Invoice_Line_Item__c ili = [
        SELECT Id, Name,
               maica_cc__Support_Item__c,
               maica_cc__Support_Item__r.Name,
               maica_cc__Amount__c,
               maica_cc__Line_Total__c,
               maica_cc__GST_Amount__c,
               maica_cc__Quantity__c,
               maica_cc__Unit_Price__c,
               Service_Detail_Description__c
        FROM maica_cc__Invoice_Line_Item__c
        WHERE Id = :iliToInsert.Id
    ];
    return ili;
    }
    
    public static void createDocumentMappings5(){
        List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        Document_Mappings__c docMapping43 = new Document_Mappings__c();
        docMapping43.Document_Token__c = 'BPAY_Reference_Number__c';
        docMapping43.Is_Parent_Object_Mapping__c = false;
        docMapping43.Is_Child_Object_Mapping__c = false;
        docMapping43.Token_Value__c = 'BPAY_Reference_Number__c';
        docMapping43.Document_Name__c = 'Invoice_Template'; 
        docMapping43.Data_Type__c = 'Text';
        documentMappings.add(docMapping43);
        
        Document_Mappings__c docMapping32 = new Document_Mappings__c();
        docMapping32.Document_Token__c = 'Biller_Code__c';
        docMapping32.Is_Parent_Object_Mapping__c = false;
        docMapping32.Is_Child_Object_Mapping__c = false;
        docMapping32.Token_Value__c = 'Biller_Code__c';
        docMapping32.Document_Name__c = 'Invoice_Template'; 
        docMapping32.Data_Type__c = 'Number';
        documentMappings.add(docMapping32);
         
        Document_Mappings__c docMapping33 = new Document_Mappings__c();
        docMapping33.Document_Token__c = 'maica_cc__Invoice_Date__c';
        docMapping33.Is_Parent_Object_Mapping__c = false;
        docMapping33.Is_Child_Object_Mapping__c = false;
        docMapping33.Token_Value__c = 'maica_cc__Invoice_Date__c';
        docMapping33.Document_Name__c = 'Invoice_Template'; 
        docMapping33.Data_Type__c = 'Date';
        documentMappings.add(docMapping33);
        
        Document_Mappings__c docMapping34 = new Document_Mappings__c();
        docMapping34.Document_Token__c = 'mecwacare_Client_ID__c';
        docMapping34.Is_Parent_Object_Mapping__c = true;
        docMapping34.Is_Child_Object_Mapping__c = false;
        docMapping34.Token_Value__c = 'mecwacare_Client_ID__c';
        docMapping34.Document_Name__c = 'Invoice_Template'; 
        docMapping34.Data_Type__c = 'text';
        documentMappings.add(docMapping34);
         
         Document_Mappings__c docMapping35 = new Document_Mappings__c();
        docMapping35.Document_Token__c = 'maica_cc__Line_Total__c';
        docMapping35.Is_Parent_Object_Mapping__c = false;
        docMapping35.Is_Child_Object_Mapping__c = true;
        docMapping35.Token_Value__c = 'maica_cc__Line_Total__c';
        docMapping35.Document_Name__c = 'Invoice_Template'; 
        docMapping35.Data_Type__c = 'Text';
        documentMappings.add(docMapping35);
        
        Document_Mappings__c docMapping36 = new Document_Mappings__c();
        docMapping36.Document_Token__c = 'maica_cc__GST_Amount__c';
        docMapping36.Is_Parent_Object_Mapping__c = false;
        docMapping36.Is_Child_Object_Mapping__c = true;
        docMapping36.Token_Value__c = 'maica_cc__GST_Amount__c';
        docMapping36.Document_Name__c = 'Invoice_Template'; 
        docMapping36.Data_Type__c = 'Text';
        documentMappings.add(docMapping36);
         
        Document_Mappings__c docMapping37 = new Document_Mappings__c();
        docMapping37.Document_Token__c = 'maica_cc__Amount__c';
        docMapping37.Is_Parent_Object_Mapping__c = false;
        docMapping37.Is_Child_Object_Mapping__c = true;
        docMapping37.Token_Value__c = 'maica_cc__Amount__c';
        docMapping37.Document_Name__c = 'Invoice_Template'; 
        docMapping37.Data_Type__c = 'Text';
        documentMappings.add(docMapping37);
        
        Document_Mappings__c docMapping38 = new Document_Mappings__c();
        docMapping38.Document_Token__c = 'Service_Detail_Description__c';
        docMapping38.Is_Parent_Object_Mapping__c = false;
        docMapping38.Is_Child_Object_Mapping__c = true;
        docMapping38.Token_Value__c = 'Service_Detail_Description__c';
        docMapping38.Document_Name__c = 'Invoice_Template'; 
        docMapping38.Data_Type__c = 'text';
        documentMappings.add(docMapping38);
         
         Document_Mappings__c docMapping39 = new Document_Mappings__c();
        docMapping39.Document_Token__c = 'maica_cc__Quantity__c';
        docMapping39.Is_Parent_Object_Mapping__c = false;
        docMapping39.Is_Child_Object_Mapping__c = true;
        docMapping39.Token_Value__c = 'maica_cc__Quantity__c';
        docMapping39.Document_Name__c = 'Invoice_Template'; 
        docMapping39.Data_Type__c = 'Number';
        documentMappings.add(docMapping39);
        
        Document_Mappings__c docMapping40 = new Document_Mappings__c();
        docMapping40.Document_Token__c = 'maica_cc__Unit_Price__c';
        docMapping40.Is_Parent_Object_Mapping__c = false;
        docMapping40.Is_Child_Object_Mapping__c = true;
        docMapping40.Token_Value__c = 'maica_cc__Unit_Price__c';
        docMapping40.Document_Name__c = 'Invoice_Template'; 
        docMapping40.Data_Type__c = 'Number';
        documentMappings.add(docMapping40); 
                 
        Document_Mappings__c docMapping41 = new Document_Mappings__c();
        docMapping41.Document_Token__c = 'maica_cc__Funding_Type__c';
        docMapping41.Is_Parent_Object_Mapping__c = false;
        docMapping41.Is_Child_Object_Mapping__c = false;
        docMapping41.Token_Value__c = 'maica_cc__Funding_Type__c';
        docMapping41.Document_Name__c = 'Invoice_Template'; 
        docMapping41.Data_Type__c = 'Picklist';
        documentMappings.add(docMapping41);
        
         Document_Mappings__c docMapping42 = new Document_Mappings__c();
        docMapping42.Document_Token__c = 'maica_cc__Support_Item__r.Name';
        docMapping42.Is_Parent_Object_Mapping__c = false;
        docMapping42.Is_Child_Object_Mapping__c = true;
        docMapping42.Token_Value__c = 'maica_cc__Support_Item__r.Name';
        docMapping42.Document_Name__c = 'Invoice_Template'; 
        docMapping42.Data_Type__c = 'Text';
        documentMappings.add(docMapping42);
		
		Document_Mappings__c docMapping84 = new Document_Mappings__c();
        docMapping84.Document_Token__c = 'BillingStreet';
        docMapping84.Is_Parent_Object_Mapping__c = true;
        docMapping84.Is_Child_Object_Mapping__c = false;
        docMapping84.Token_Value__c = 'BillingStreet';
        docMapping84.Document_Name__c = 'Invoice_Template'; 
        docMapping84.Data_Type__c = 'Text';
        documentMappings.add(docMapping84);
        
        Document_Mappings__c docMapping85 = new Document_Mappings__c();
        docMapping85.Document_Token__c = 'BillingPostalCode';
        docMapping85.Is_Parent_Object_Mapping__c = true;
        docMapping85.Is_Child_Object_Mapping__c = false;
        docMapping85.Token_Value__c = 'BillingPostalCode';
        docMapping85.Document_Name__c = 'Invoice_Template'; 
        docMapping85.Data_Type__c = 'Text';
        documentMappings.add(docMapping85);
        
        Document_Mappings__c docMapping86 = new Document_Mappings__c();
        docMapping86.Document_Token__c = 'BillingState';
        docMapping86.Is_Parent_Object_Mapping__c = true;
        docMapping86.Is_Child_Object_Mapping__c = false;
        docMapping86.Token_Value__c = 'BillingState';
        docMapping86.Document_Name__c = 'Invoice_Template'; 
        docMapping86.Data_Type__c = 'Text';
        documentMappings.add(docMapping86);
        
        Document_Mappings__c docMapping87 = new Document_Mappings__c();
        docMapping87.Document_Token__c = 'BillingCity';
        docMapping87.Is_Parent_Object_Mapping__c = true;
        docMapping87.Is_Child_Object_Mapping__c = false;
        docMapping87.Token_Value__c = 'BillingCity';
        docMapping87.Document_Name__c = 'Invoice_Template'; 
        docMapping87.Data_Type__c = 'Text';
        documentMappings.add(docMapping87);
        
        Document_Mappings__c docMapping88 = new Document_Mappings__c();
        docMapping88.Document_Token__c = 'Balance_Due__c';
        docMapping88.Is_Parent_Object_Mapping__c = true;
        docMapping88.Is_Child_Object_Mapping__c = false;
        docMapping88.Token_Value__c = 'Balance_Due__c';
        docMapping88.Document_Name__c = 'Invoice_Template'; 
        docMapping88.Data_Type__c = 'Text';
        documentMappings.add(docMapping88);
        
        Document_Mappings__c docMapping89 = new Document_Mappings__c();
        docMapping89.Document_Token__c = 'Balance_Due__c';
        docMapping89.Is_Parent_Object_Mapping__c = true;
        docMapping89.Is_Child_Object_Mapping__c = false;
        docMapping89.Token_Value__c = 'Balance_Due__c';
        docMapping89.Document_Name__c = 'Invoice_Template'; 
        docMapping89.Data_Type__c = 'Text';
        documentMappings.add(docMapping89);
        
         Document_Mappings__c docMapping90 = new Document_Mappings__c();
        docMapping90.Document_Token__c = 'Unapplied_Payment__c';
        docMapping90.Is_Parent_Object_Mapping__c = true;
        docMapping90.Is_Child_Object_Mapping__c = false;
        docMapping90.Token_Value__c = 'Unapplied_Payment__c';
        docMapping90.Document_Name__c = 'Invoice_Template'; 
        docMapping90.Data_Type__c = 'Text';
        documentMappings.add(docMapping90);
        
        Document_Mappings__c docMapping91 = new Document_Mappings__c();
        docMapping91.Document_Token__c = 'Days_Overdue_1__c';
        docMapping91.Is_Parent_Object_Mapping__c = true;
        docMapping91.Is_Child_Object_Mapping__c = false;
        docMapping91.Token_Value__c = 'Days_Overdue_1__c';
        docMapping91.Document_Name__c = 'Invoice_Template'; 
        docMapping91.Data_Type__c = 'Text';
        documentMappings.add(docMapping91);
        
         Document_Mappings__c docMapping92 = new Document_Mappings__c();
        docMapping92.Document_Token__c = 'Days_Overdue_2__c';
        docMapping92.Is_Parent_Object_Mapping__c = true;
        docMapping92.Is_Child_Object_Mapping__c = false;
        docMapping92.Token_Value__c = 'Days_Overdue_2__c';
        docMapping92.Document_Name__c = 'Invoice_Template'; 
        docMapping92.Data_Type__c = 'Text';
        documentMappings.add(docMapping92);
        
 		Document_Mappings__c docMapping93 = new Document_Mappings__c();
        docMapping93.Document_Token__c = 'Days_Overdue_3__c';
        docMapping93.Is_Parent_Object_Mapping__c = true;
        docMapping93.Is_Child_Object_Mapping__c = false;
        docMapping93.Token_Value__c = 'Days_Overdue_3__c';
        docMapping93.Document_Name__c = 'Invoice_Template'; 
        docMapping93.Data_Type__c = 'Text';
        documentMappings.add(docMapping93);
        
         Document_Mappings__c docMapping94 = new Document_Mappings__c();
        docMapping94.Document_Token__c = 'Days_Overdue_4__c';
        docMapping94.Is_Parent_Object_Mapping__c = true;
        docMapping94.Is_Child_Object_Mapping__c = false;
        docMapping94.Token_Value__c = 'Days_Overdue_4__c';
        docMapping94.Document_Name__c = 'Invoice_Template'; 
        docMapping94.Data_Type__c = 'Text';
        documentMappings.add(docMapping94);
        
        Document_Mappings__c docMapping95 = new Document_Mappings__c();
        docMapping95.Document_Token__c = 'maica_cc__Total_Amount__c';
        docMapping95.Is_Parent_Object_Mapping__c = false;
        docMapping95.Is_Child_Object_Mapping__c = false;
        docMapping95.Token_Value__c = 'maica_cc__Total_Amount__c';
        docMapping95.Document_Name__c = 'Invoice_Template'; 
        docMapping95.Data_Type__c = 'Currency';
        documentMappings.add(docMapping95);
        
        Document_Mappings__c docMapping96 = new Document_Mappings__c();
        docMapping96.Document_Token__c = 'Total_GST__c';
        docMapping96.Is_Parent_Object_Mapping__c = false;
        docMapping96.Is_Child_Object_Mapping__c = false;
        docMapping96.Token_Value__c = 'Total_GST__c';
        docMapping96.Document_Name__c = 'Invoice_Template'; 
        docMapping96.Data_Type__c = 'Currency';
        documentMappings.add(docMapping96);
        
        Document_Mappings__c docMapping97 = new Document_Mappings__c();
        docMapping97.Document_Token__c = 'Total_Amount_Ex_GST__c';
        docMapping97.Is_Parent_Object_Mapping__c = false;
        docMapping97.Is_Child_Object_Mapping__c = false;
        docMapping97.Token_Value__c = 'Total_Amount_Ex_GST__c';
        docMapping97.Document_Name__c = 'Invoice_Template'; 
        docMapping97.Data_Type__c = 'Currency';
        documentMappings.add(docMapping97);
        
         Document_Mappings__c docMapping98 = new Document_Mappings__c();
        docMapping98.Document_Token__c = 'Total_Amount_Ex_GST__c';
        docMapping98.Is_Parent_Object_Mapping__c = false;
        docMapping98.Is_Child_Object_Mapping__c = false;
        docMapping98.Token_Value__c = 'Total_Amount_Ex_GST__c';
        docMapping98.Document_Name__c = 'Invoice_Template'; 
        docMapping98.Data_Type__c = 'Currency';
        documentMappings.add(docMapping98);
        
         Document_Mappings__c docMapping99 = new Document_Mappings__c();
        docMapping99.Document_Token__c = 'Invoice_Number__c';
        docMapping99.Is_Parent_Object_Mapping__c = false;
        docMapping99.Is_Child_Object_Mapping__c = false;
        docMapping99.Token_Value__c = 'Invoice_Number__c';
        docMapping99.Document_Name__c = 'Invoice_Template'; 
        docMapping99.Data_Type__c = 'Text';
        documentMappings.add(docMapping99);
        
         insert documentMappings;
    }
        public static maica_cc__Invoice__c createMockInvoice(Id participantContactId, Id fundingAdminId) {
    // Create invoice with required fields
    maica_cc__Invoice__c invoice = new maica_cc__Invoice__c(
        maica_cc__Participant__c = participantContactId,
        maica_cc__Funding_Administrator__c = fundingAdminId,
        maica_cc__Funding_Type__c = 'Home Care Package',
        maica_cc__Invoice_Date__c = System.today()
    );

    insert invoice;

    // Retrieve the inserted invoice to get system-generated fields
    invoice = [SELECT Id, maica_cc__Description__c, Invoice_Number__c FROM maica_cc__Invoice__c WHERE Id = :invoice.Id];

    // Update only editable fields
    invoice.maica_cc__Description__c = 'Test Invoice Description';
    update invoice;

    return invoice;
}



    //Statment Records
    public static maica_cc__Service_Agreement__c createSA1(Id accId,Id fundingAdminId){
       maica_cc__Price_List__c priceList = new maica_cc__Price_List__c(
           Name = 'Test Pricebook',
           maica_cc__Funding_Source__c = 'Self Funded',
           maica_cc__Pricing_Structure__c = 'Default',
           maica_cc__Active__c = true
       );
        insert priceList;
       maica_cc__Service_Agreement__c serviceagreement = new maica_cc__Service_Agreement__c();
		Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :accId LIMIT 1];
        serviceagreement.Name = 'Service Agreement';
           serviceagreement.maica_cc__Participant__c = acc.PersonContactId;
           serviceagreement.maica_cc__Funding_Source__c = 'Home Care Package';
        	serviceagreement.maica_cc__Price_List__c = priceList.Id;
           serviceagreement.maica_cc__Funding_Type__c = 'Home Care Package';
           serviceagreement.Opportunity_Owner_Email__c = 'test@test.com';
        serviceagreement.maica_cc__Service_Provider__c = acc.id;
        serviceagreement.maica_cc__Funding_Administrator__c = fundingAdminId;
       insert serviceagreement;
       Date startDate = Date.newInstance(3024, 1, 1);
       Date endDate = Date.newInstance(3024, 12, 12);
       maica_cc__Agreement_Item__c agRec = new maica_cc__Agreement_Item__c(
           maica_cc__Service_Agreement__c = serviceagreement.Id,
           maica_cc__Start_Date__c = startDate,
           maica_cc__End_Date__c = endDate,
           maica_cc__Funding_Type__c = 'Home Care Package'
       );
       insert agRec;
        return serviceagreement;
    }
    public static maica_cc__Service_Agreement_Statement__c statements(Id serviceagreement){
       maica_cc__Service_Agreement_Statement__c statement = new maica_cc__Service_Agreement_Statement__c(
           Dispatch_Date__c = Date.newInstance(2000, 12, 12),
           Dispatch_Status__c = 'Document Generated',
           maica_cc__Service_Agreement__c = serviceagreement,
           maica_cc__Period_Start_Date__c = System.today()
       );
       insert statement;
        return statement;
    } 
        public static Service_Agreement_Statement_Line_Item__c sli(Id Statement){
            Service_Agreement_Statement_Line_Item__c sline = new Service_Agreement_Statement_Line_Item__c(
           Service_Agreement_Statement__c = statement
            );
       insert sline;
    return sline;
    }
    
        
    public static void createDocumentMappings7(){
     List<Document_Mappings__c> documentMappings = new List<Document_Mappings__c>();
        
        Document_Mappings__c docMapping100 = new Document_Mappings__c();
        docMapping100.Document_Token__c = 'HC_Statement_Final_Balance__c';
        docMapping100.Is_Parent_Object_Mapping__c = false;
        docMapping100.Is_Child_Object_Mapping__c = false;
        docMapping100.Token_Value__c = 'HC_Statement_Final_Balance__c';
        docMapping100.Document_Name__c = 'Statement_Template'; 
        docMapping100.Data_Type__c = 'Number';
        documentMappings.add(docMapping100);
        
        Document_Mappings__c docMapping101 = new Document_Mappings__c();
        docMapping101.Document_Token__c = 'Service_Ref__c';
        docMapping101.Is_Parent_Object_Mapping__c = false;
        docMapping101.Is_Child_Object_Mapping__c = false;
        docMapping101.Token_Value__c = 'Service_Ref__c';
        docMapping101.Document_Name__c = 'Statement_Template'; 
        docMapping101.Data_Type__c = 'Text';
        documentMappings.add(docMapping101);
        
                Document_Mappings__c docMapping102 = new Document_Mappings__c();
        docMapping102.Document_Token__c = 'Balance__c';
        docMapping102.Is_Parent_Object_Mapping__c = false;
        docMapping102.Is_Child_Object_Mapping__c = true;
        docMapping102.Token_Value__c = 'Balance__c';
        docMapping102.Document_Name__c = 'Statement_Template'; 
        docMapping102.Data_Type__c = 'Number';
        documentMappings.add(docMapping102);
        
                Document_Mappings__c docMapping103 = new Document_Mappings__c();
        docMapping103.Document_Token__c = 'Amount__c';
        docMapping103.Is_Parent_Object_Mapping__c = false;
        docMapping103.Is_Child_Object_Mapping__c = true;
        docMapping103.Token_Value__c = 'Amount__c';
        docMapping103.Document_Name__c = 'Statement_Template'; 
        docMapping103.Data_Type__c = 'Number';
        documentMappings.add(docMapping103);
        
                Document_Mappings__c docMapping104 = new Document_Mappings__c();
        docMapping104.Document_Token__c = 'Description__c';
        docMapping104.Is_Parent_Object_Mapping__c = false;
        docMapping104.Is_Child_Object_Mapping__c = true;
        docMapping104.Token_Value__c = 'Description__c';
        docMapping104.Document_Name__c = 'Statement_Template'; 
        docMapping104.Data_Type__c = 'Text';
        documentMappings.add(docMapping104);
        
                Document_Mappings__c docMapping105 = new Document_Mappings__c();
        docMapping105.Document_Token__c = 'Type__c';
        docMapping105.Is_Parent_Object_Mapping__c = false;
        docMapping105.Is_Child_Object_Mapping__c = true;
        docMapping105.Token_Value__c = 'Type__c';
        docMapping105.Document_Name__c = 'Statement_Template'; 
        docMapping105.Data_Type__c = 'Number';
        documentMappings.add(docMapping105);
        
                Document_Mappings__c docMapping106 = new Document_Mappings__c();
        docMapping106.Document_Token__c = 'Date_Ref__c';
        docMapping106.Is_Parent_Object_Mapping__c = false;
        docMapping106.Is_Child_Object_Mapping__c = true;
        docMapping106.Token_Value__c = 'Date_Ref__c';
        docMapping106.Document_Name__c = 'Statement_Template'; 
        docMapping106.Data_Type__c = 'date';
        documentMappings.add(docMapping106);
        
        Document_Mappings__c docMapping107 = new Document_Mappings__c();
        docMapping107.Document_Token__c = 'Reference_Number__c';
        docMapping107.Is_Parent_Object_Mapping__c = false;
        docMapping107.Is_Child_Object_Mapping__c = true;
        docMapping107.Token_Value__c = 'Reference_Number__c';
        docMapping107.Document_Name__c = 'Statement_Template'; 
        docMapping107.Data_Type__c = 'Text';
        documentMappings.add(docMapping107);
        
                Document_Mappings__c docMapping108 = new Document_Mappings__c();
        docMapping108.Document_Token__c = 'mecwacare_Client_ID__c';
        docMapping108.Is_Parent_Object_Mapping__c = true;
        docMapping108.Is_Child_Object_Mapping__c = false;
        docMapping108.Token_Value__c = 'mecwacare_Client_ID__c';
        docMapping108.Document_Name__c = 'Statement_Template'; 
        docMapping108.Data_Type__c = 'Text';
        documentMappings.add(docMapping108);
        
                Document_Mappings__c docMapping109 = new Document_Mappings__c();
        docMapping109.Document_Token__c = 'maica_cc__Period_End_Date__c';
        docMapping109.Is_Parent_Object_Mapping__c = false;
        docMapping109.Is_Child_Object_Mapping__c = false;
        docMapping109.Token_Value__c = 'maica_cc__Period_End_Date__c';
        docMapping109.Document_Name__c = 'Statement_Template'; 
        docMapping109.Data_Type__c = 'Date';
        documentMappings.add(docMapping109);
        
                Document_Mappings__c docMapping110 = new Document_Mappings__c();
        docMapping110.Document_Token__c = 'Name';
        docMapping110.Is_Parent_Object_Mapping__c = true;
        docMapping110.Is_Child_Object_Mapping__c = false;
        docMapping110.Token_Value__c = 'Name';
        docMapping110.Document_Name__c = 'Statement_Template'; 
        docMapping110.Data_Type__c = 'Text';
        documentMappings.add(docMapping110);
        
                        Document_Mappings__c docMapping111 = new Document_Mappings__c();
        docMapping111.Document_Token__c = 'BillingStreet';
        docMapping111.Is_Parent_Object_Mapping__c = true;
        docMapping111.Is_Child_Object_Mapping__c = false;
        docMapping111.Token_Value__c = 'BillingStreet';
        docMapping111.Document_Name__c = 'Statement_Template'; 
        docMapping111.Data_Type__c = 'Text';
        documentMappings.add(docMapping111);
        
                        Document_Mappings__c docMapping112 = new Document_Mappings__c();
        docMapping112.Document_Token__c = 'BillingPostalCode';
        docMapping112.Is_Parent_Object_Mapping__c = true;
        docMapping112.Is_Child_Object_Mapping__c = false;
        docMapping112.Token_Value__c = 'BillingPostalCode';
        docMapping112.Document_Name__c = 'Statement_Template'; 
        docMapping112.Data_Type__c = 'Text';
        documentMappings.add(docMapping112);
        
                        Document_Mappings__c docMapping113 = new Document_Mappings__c();
        docMapping113.Document_Token__c = 'BillingState';
        docMapping113.Is_Parent_Object_Mapping__c = true;
        docMapping113.Is_Child_Object_Mapping__c = false;
        docMapping113.Token_Value__c = 'BillingState';
        docMapping113.Document_Name__c = 'Statement_Template'; 
        docMapping113.Data_Type__c = 'Text';
        documentMappings.add(docMapping113);
        
                        Document_Mappings__c docMapping114 = new Document_Mappings__c();
        docMapping114.Document_Token__c = 'BillingCity';
        docMapping114.Is_Parent_Object_Mapping__c = true;
        docMapping114.Is_Child_Object_Mapping__c = false;
        docMapping114.Token_Value__c = 'BillingCity';
        docMapping114.Document_Name__c = 'Statement_Template'; 
        docMapping114.Data_Type__c = 'Text';
        documentMappings.add(docMapping114);
        
        insert documentMappings;
}
    public static void createExceptionLogForInvoice(Id invId) {
        Mecwa_ExceptionLog__c exceptionlog = new Mecwa_ExceptionLog__c();
        exceptionlog.Invoice_Record_Id__c = invId;
        exceptionlog.Invoice__c = invId;
        exceptionlog.Exception_Message__c = 'Failed to Generate Document';
        exceptionlog.Error_Message__c = 'Failed to Generate Document';
       	exceptionlog.Error_Type__c = 'Document';
        insert exceptionlog;
    }
}
