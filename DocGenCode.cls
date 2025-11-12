public without sharing class MC_OpportunityDocGen_Agreements {

    /* ================= Public Flow API ================= */

    public class Wrapper {
        @InvocableVariable(required=true)
        public List<Id> recordIds;                 // Opportunity Id(s) – first used

        // Optional direct overrides (kept for flexibility; you can ignore in Flow)
        @InvocableVariable public String docTemplateName;             // DocumentTemplate.Name
        @InvocableVariable public String templateContentVersionId;    // ContentVersion.Id

        // Optional: dynamic by ENV variable *names* (DeveloperName of Environment_Variables__mdt)
        // If you leave these blank, the class will auto-pick by Funding Source:
        //  SAH_Agreement_ContentId / NDIS_Agreement_ContentId / Service_Agreement_ContentId
        @InvocableVariable public String envContentDocVarName;        // Value__c = ContentDocumentId
        @InvocableVariable public String envTemplateNameVarName;      // Value__c = DocumentTemplate.Name
    }

    @InvocableMethod(label='Generate Agreement (auto by Funding Source)')
    public static void generateFromFlow(List<Wrapper> inputs) {
        if (inputs == null || inputs.isEmpty() || inputs[0] == null ||
            inputs[0].recordIds == null || inputs[0].recordIds.isEmpty()) {
            throw new AuraHandledException('No Opportunity Id provided.');
        }
        process(inputs[0]);
    }

    /* ================= Implementation ================= */

    // Generic template to reuse for all agreements (mapping-only template; must be Active)
    private static final String DEFAULT_TEMPLATE_NAME = 'GeneralServiceAgreementTemplate';

    // ENV DeveloperNames we’ll use when Flow doesn’t override
    private static final String ENV_SAH   = 'SAH_Agreement_ContentId';
    private static final String ENV_NDIS  = 'NDIS_Agreement_ContentId';
    private static final String ENV_GEN   = 'Service_Agreement_ContentId';

    // Which Funding Source goes to which ENV DeveloperName
    private static String pickEnvKeyByFunding(String fundingSource) {
        if (String.isBlank(fundingSource)) return ENV_GEN;
        String fs = fundingSource.trim();
        if (fs == 'Support at Home') return ENV_SAH;
        if (fs == 'NDIS')            return ENV_NDIS;
        // Block Funding, DVA, Self Funding, Partner organisation, etc.
        return ENV_GEN;
    }

    private static void process(Wrapper w) {
        Id oppId = w.recordIds[0];

        /* -------- Opportunity -------- */
        Opportunity opp = null;
        List<Opportunity> oppRows = [
            SELECT Id, Name, StageName, CloseDate, Amount,
                   AccountId, Funding__c, Funding_Source__c, Funding_Administrator__c, Agreement_Start_Date__c,
            Agreement_End_Date__c, Opportunity_Owner__c, OwnerId, Transfer_from_another_provider__c, Previous_Service_Exit_Date__c
            FROM Opportunity
            WHERE Id = :oppId
            LIMIT 1
        ];
        if (!oppRows.isEmpty()) opp = oppRows[0];
        if (opp == null) {
            throw new AuraHandledException('Opportunity not found for Id: ' + String.valueOf(oppId));
        }
        
        /* -------- Opportunity Owner (User) -------- */
        User oppOwner = null;
        if (opp.OwnerId != null) {
                List<User> ownerRows = [
                    SELECT Id, Name, Email, MobilePhone
                    FROM User
                    WHERE Id = :opp.OwnerId
                    LIMIT 1
                ];
                if (!ownerRows.isEmpty()) oppOwner = ownerRows[0];
        }

        /* -------- Account (Person Account) -------- */
        Account acc = null;
        if (opp.AccountId != null) {
            List<Account> accRows = [
                SELECT Id, Name, Phone, PersonMobilePhone, PersonEmail, Salutation,
                       FirstName, LastName, Date_of_Birth__c, PersonContactId, Description,
                       Home_Address__Street__s, Home_Address__City__s, Home_Address__StateCode__s,
                       Home_Address__PostalCode__s, Home_Address__CountryCode__s, Region__c, maica_cc__NDIS_Number__pc, 
                	   ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                	   BillingStreet, BillingCity, BillingState,BillingPostalCode, BillingCountry, Payment_Method__c	
                FROM Account
                WHERE Id = :opp.AccountId
                LIMIT 1
            ];
            if (!accRows.isEmpty()) acc = accRows[0];
        }
        
        // Funding Administrator Lookup (Account)
            Account fundingAdmin = null;
            if (opp.Funding_Administrator__c != null) {
                fundingAdmin = [
                    SELECT Id, Name, Phone, PersonEmail,
                           BillingStreet, BillingCity, BillingState,
                           BillingPostalCode, BillingCountry
                    FROM Account
                    WHERE Id = :opp.Funding_Administrator__c
                    LIMIT 1
                ];
            }
        
        // --- Related: Service Agreement (latest by CreatedDate)
        maica_cc__Service_Agreement__c sa = null;
        List<maica_cc__Service_Agreement__c> saRows = [
            SELECT Id,
            Opportunity__c,
            maica_cc__Start_Date__c,
            maica_cc__End_Date__c,
            maica_cc__Funding_Source__c
            FROM maica_cc__Service_Agreement__c
            WHERE Opportunity__c = :opp.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!saRows.isEmpty()) sa = saRows[0];
        
        /*---------OpportunityProduct--------*/
        List<OpportunityLineItem> oliList = [
                SELECT Id,
                       Quantity,
                       UnitPrice,
                       TotalPrice,
                       Service_Frequency__c,
                       Product2.Name,
                       Product2.Support_Item__r.Name
                FROM OpportunityLineItem
                WHERE OpportunityId = :opp.Id
            ];

        /* -------- Funding parent -------- */
        maica_cc__Funding__c funding = null;
        if (opp.Funding__c != null) {
            List<maica_cc__Funding__c> fRows = [
                SELECT Id, Name, maica_cc__Start_Date__c, maica_cc__End_Date__c, Funding_Type__c
                FROM maica_cc__Funding__c
                WHERE Id = :opp.Funding__c
                LIMIT 1
            ];
            if (!fRows.isEmpty()) funding = fRows[0];
        }

        /* -------- Funding Items (child of Funding) -------- */
        List<maica_cc__Funding_Item__c> fundingItemList = new List<maica_cc__Funding_Item__c>();
        if (funding != null) {
            fundingItemList = [
                SELECT Id, Name, maica_cc__Budget_Type__c,
                       maica_cc__Approved_Amount__c, maica_cc__Spent_Amount__c, maica_cc__Remaining_Amount__c,
                       maica_cc__Entry_Date__c, maica_cc__Effective_Date__c, maica_cc__End_Date__c,
                       maica_cc__Funding__c
                FROM maica_cc__Funding_Item__c
                WHERE maica_cc__Funding__c = :funding.Id
            ];
        }

        /* -------- ContactContactRelation (PoA only) -------- */
        List<ContactContactRelation> ccrList = new List<ContactContactRelation>();
        if (acc != null && acc.PersonContactId != null) {
            ccrList = [
                SELECT Id, ContactId, RelatedContactId,
                       Power_of_Attorney__c, Relationship__c, Next_of_Kin__c,
                       RelatedContact.Name, RelatedContact.Phone, RelatedContact.Email,
                       RelatedContact.MailingStreet, RelatedContact.MailingCity,
                       RelatedContact.MailingState, RelatedContact.MailingPostalCode,
                       RelatedContact.MailingCountry
                FROM ContactContactRelation
                WHERE ContactId = :acc.PersonContactId
                  AND Power_of_Attorney__c != null
            ];
        }
        
        /* -------- ContactContactRelation (Carers only) -------- */
        List<ContactContactRelation> ccrCarers = new List<ContactContactRelation>();
        if (acc != null && acc.PersonContactId != null) {
            ccrCarers = [
                SELECT Id, RelatedContactId,
                       RelatedContact.Name, RelatedContact.Phone, RelatedContact.Email,
                       RelatedContact.MailingStreet, RelatedContact.MailingCity,
                       RelatedContact.MailingState, RelatedContact.MailingPostalCode,
                       RelatedContact.MailingCountry,
                       Additional_responsibility__c
                FROM ContactContactRelation
                WHERE ContactId = :acc.PersonContactId
                  AND Additional_responsibility__c INCLUDES ('Carer')
            ];
        }

        /* -------- Flags from Funding Items -------- */
        Boolean showPartG_AT_HM = false;
        Boolean showPartH_Restorative = false;
        Boolean showPartI_EndOfLife  = false;
        for (maica_cc__Funding_Item__c fi : fundingItemList) {
            String bt = fi.maica_cc__Budget_Type__c;
            if (bt == null) continue;
            bt = bt.trim();
            if (bt == 'Assistive technology' ||
                bt == 'Home modifications' ||
                bt == 'Assistive technology specified needs') showPartG_AT_HM = true;
            if (bt == 'Restorative care pathway') showPartH_Restorative = true;
            if (bt == 'End of life pathway')      showPartI_EndOfLife  = true;
        }
        
    // ===================== GROUP FUNDING ITEMS BY PART =====================
        List<maica_cc__Funding_Item__c> grpAT = new List<maica_cc__Funding_Item__c>();
        List<maica_cc__Funding_Item__c> grpHM = new List<maica_cc__Funding_Item__c>();
        List<maica_cc__Funding_Item__c> grpR  = new List<maica_cc__Funding_Item__c>(); // Restorative
        List<maica_cc__Funding_Item__c> grpI  = new List<maica_cc__Funding_Item__c>(); // End-of-life
         
        for (maica_cc__Funding_Item__c fi : fundingItemList) {
            String bt = (fi.maica_cc__Budget_Type__c == null) ? '' : fi.maica_cc__Budget_Type__c.toLowerCase();
         
            if (bt.contains('assistive technology')) {
                grpAT.add(fi);
            } else if (bt.contains('home modification')) {
                grpHM.add(fi);
            } else if (bt.contains('restorative care')) {
                grpR.add(fi);
            } else if (bt.contains('end of life')) {
                grpI.add(fi);
            }
        }
         
        // ===================== CREATE ROLLUPS PER GROUP =====================
        PartRollup gAT = new PartRollup(grpAT);
        PartRollup gHM = new PartRollup(grpHM);
        PartRollup gR  = new PartRollup(grpR);
        PartRollup gI  = new PartRollup(grpI);
        
        Set<Id> atFiIds = new Set<Id>();
        Set<Id> hmFiIds = new Set<Id>();
        for (maica_cc__Funding_Item__c fi : grpAT) atFiIds.add(fi.Id);
        for (maica_cc__Funding_Item__c fi : grpHM) hmFiIds.add(fi.Id);
         
        // Pull Entitlements linked to those Funding Items
        List<maica_cc__Entitlement__c> entRows = new List<maica_cc__Entitlement__c>();
        if (!atFiIds.isEmpty() || !hmFiIds.isEmpty()) {
            entRows = [
                SELECT Id, Name, maica_cc__Approved_Amount__c, maica_cc__Funding_Item__c
                FROM maica_cc__Entitlement__c
                WHERE maica_cc__Funding_Item__c IN :atFiIds OR maica_cc__Funding_Item__c IN :hmFiIds
                ORDER BY CreatedDate ASC
            ];
        }
         
        // Index entitlements by Funding Item Id
        Map<Id, List<maica_cc__Entitlement__c>> entsByFI = new Map<Id, List<maica_cc__Entitlement__c>>();
        for (maica_cc__Entitlement__c e : entRows) {
            if (!entsByFI.containsKey(e.maica_cc__Funding_Item__c)) {
                entsByFI.put(e.maica_cc__Funding_Item__c, new List<maica_cc__Entitlement__c>());
            }
            entsByFI.get(e.maica_cc__Funding_Item__c).add(e);
        }
    
        /* -------- Approved Services (child of Funding) -------- */
        List<maica_cc__Approved_Service__c> approvedServices = new List<maica_cc__Approved_Service__c>();
            if (funding != null) {
                approvedServices = [
                    SELECT Id, Name
                    FROM maica_cc__Approved_Service__c
                    WHERE maica_cc__Funding__c = :funding.Id
                    ORDER BY CreatedDate ASC
                ];
            }

        /* -------- Tokens -------- */
        Map<String, Object> token = new Map<String, Object>();

        // Opportunity
        token.put('OppName', opp.Name);
        token.put('OppStage', opp.StageName);
        token.put('OppCloseDate', formatDate(opp.CloseDate));
        token.put('OppAmount', formatCurrency(opp.Amount));
        token.put('FundingSource', opp.Funding_Source__c);
        token.put('OppOwner', opp.Opportunity_Owner__c);
        token.put('OppAgreementStartDate', formatDate(opp.Agreement_Start_Date__c));
		token.put('OppAgreementEndDate',   formatDate(opp.Agreement_End_Date__c));
        token.put('OppTFromAnotherProv', opp.Transfer_from_another_provider__c);
        token.put('OppPrevservExitDate', formatDate(opp.Previous_Service_Exit_Date__c));
        
        // Opportunity Owner (User)
        if (oppOwner != null) {
            token.put('OppOwner', oppOwner.Name);
            token.put('UserEmail', oppOwner.Email);
            token.put('UserMobilePhone', oppOwner.MobilePhone);
        } else {
            token.put('OppOwner', '');
            token.put('UserEmail', '');
            token.put('UserMobilePhone', '');
        }

        // Account
        if (acc != null) {
            token.put('AccountName', acc.Name);
            token.put('AccountTitle', acc.Salutation);
            token.put('AccountFirstName', acc.FirstName);
            token.put('AccountLastName', acc.LastName);
            token.put('AccountDOB', formatDate(acc.Date_of_Birth__c));
            token.put('AccountPhone', acc.Phone);
            token.put('AccountMobile', acc.PersonMobilePhone);
            token.put('AccountEmail', acc.PersonEmail);
            token.put('AccountRegion', acc.Region__c);
            token.put('AccountNDISNumber', acc.maica_cc__NDIS_Number__pc);
            token.put('AccountDescription', acc.Description);
            token.put('AccountPaymentMeth',acc.Payment_Method__c);
            token.put('AccountHomeAddress',
                formatAddress(
                    acc.Home_Address__Street__s,
                    acc.Home_Address__City__s,
                    acc.Home_Address__StateCode__s,
                    acc.Home_Address__PostalCode__s,
                    acc.Home_Address__CountryCode__s
                )
            );
            token.put('AccountShippingAddress',
                formatAddress(
                    acc.ShippingStreet,
                    acc.ShippingCity,
                    acc.ShippingState,
                    acc.ShippingPostalCode,
                    acc.ShippingCountry
                    )
                );
            token.put('AccountBillingAddress',
                formatAddress(
                    acc.BillingStreet,
                    acc.BillingCity,
                    acc.BillingState,
                    acc.BillingPostalCode,
                    acc.BillingCountry
                    )
                );
        }
        
        //Funding Administrator Token Mapping
                if (fundingAdmin != null) {
                    token.put('FundingAdminName', fundingAdmin.Name);
                    token.put('FundingAdminEmail', fundingAdmin.PersonEmail);
                    token.put('FundingAdminPhone', fundingAdmin.Phone);
                 
                    // Combine address neatly into one string
                    String addr = '';
                    List<String> addrParts = new List<String>{
                        fundingAdmin.BillingStreet,
                        fundingAdmin.BillingCity,
                        fundingAdmin.BillingState,
                        fundingAdmin.BillingPostalCode,
                        fundingAdmin.BillingCountry
                    };
                    for (String p : addrParts) {
                        if (!String.isBlank(p)) addr += p + ', ';
                    }
                    if (addr.endsWith(', ')) addr = addr.substring(0, addr.length() - 2);
                 
                    token.put('FundingAdminBillingAddress', addr);
                } else {
                    token.put('FundingAdminName', '');
                    token.put('FundingAdminEmail', '');
                    token.put('FundingAdminPhone', '');
                    token.put('FundingAdminBillingAddress', '');
                }
        // Tokens sourced from Service Agreement (fallback to Opportunity)
            token.put('ServiceStartDate',
                      sa != null ? formatDate(sa.maica_cc__Start_Date__c)
                                 : formatDate(opp.Agreement_Start_Date__c));
             
            token.put('ServiceEndDate',
                      sa != null ? formatDate(sa.maica_cc__End_Date__c)
                                 : formatDate(opp.Agreement_End_Date__c));
             
            token.put('SA_FundingSource',
                      sa != null && !String.isBlank(sa.maica_cc__Funding_Source__c)
                        ? sa.maica_cc__Funding_Source__c
                        : opp.Funding_Source__c);
        	Date baseStart = (sa != null && sa.maica_cc__Start_Date__c != null)
            ? sa.maica_cc__Start_Date__c
            : opp.Agreement_Start_Date__c;
        	Date serviceReviewDate = (baseStart != null) ? baseStart.addMonths(12) : null;
            token.put('ServiceReviewDate',
                serviceReviewDate == null ? '' : formatDate(serviceReviewDate));
        
		// Product/Support Item List
        List<Map<String, Object>> productOut = new List<Map<String, Object>>();
        Integer pcount = 1;
         
        for (OpportunityLineItem oli : oliList) {
            // Build one row for each product line
            Map<String, Object> row = new Map<String, Object>();
         
            row.put('RowNumber', pcount);
            row.put('SupportItemName',
                (oli.Product2 != null && oli.Product2.Support_Item__r != null)
                    ? oli.Product2.Support_Item__r.Name
                    : (oli.Product2 != null ? oli.Product2.Name : null)
            );
            row.put('ServiceFrequency',
                !String.isBlank(oli.Service_Frequency__c)
                    ? oli.Service_Frequency__c
                    : oli.Period_Type__c
            );
            row.put('Quantity', oli.Quantity);
            row.put('UnitPrice', oli.UnitPrice);
            row.put('TotalPrice', oli.TotalPrice);
         
            productOut.add(row);
            pcount++;
        }
         
        // Add this to your token map
        token.put('ProductUnits', productOut);		
        
        // Funding (parent)
        if (funding != null) {
            token.put('FundingName', funding.Name);
            token.put('FundingStartDate', formatDate(funding.maica_cc__Start_Date__c));
            token.put('FundingEndDate',   formatDate(funding.maica_cc__End_Date__c));
            token.put('FundingType',      funding.Funding_Type__c);
        }

        // CCR list
        List<Map<String, Object>> ccrOut = new List<Map<String, Object>>();
        Integer cIdx = 0;
        for (ContactContactRelation ccr : ccrList) {
            cIdx++;
            Map<String, Object> row = new Map<String, Object>();
            row.put('RelatedContactName',   ccr.RelatedContact != null ? ccr.RelatedContact.Name  : null);
            row.put('RelatedContactPhone',  ccr.RelatedContact != null ? ccr.RelatedContact.Phone : null);
            row.put('RelatedContactEmail',  ccr.RelatedContact != null ? ccr.RelatedContact.Email : null);
            row.put('RelatedContactAddress',
                ccr.RelatedContact != null
                ? formatAddress(ccr.RelatedContact.MailingStreet,
                                ccr.RelatedContact.MailingCity,
                                ccr.RelatedContact.MailingState,
                                ccr.RelatedContact.MailingPostalCode,
                                ccr.RelatedContact.MailingCountry)
                : null);
            row.put('PowerOfAttorney', ccr.Power_of_Attorney__c);
            row.put('Relationship',    ccr.Relationship__c);
            row.put('IsNextOfKin',     ccr.Next_of_Kin__c);
            row.put('RowNumber',       cIdx);
            ccrOut.add(row);
        }
        token.put('CCRList', ccrOut);
        
        /* -------- Tokens: CCR Carers list -------- */
        List<Map<String, Object>> carerOut = new List<Map<String, Object>>();
        Integer carerIdx = 1;
                for (ContactContactRelation ccr : ccrCarers) {
                    Map<String, Object> row = new Map<String, Object>();
                    row.put('RowNumber', carerIdx++);
                    row.put('RelatedContactName', ccr.RelatedContact != null ? ccr.RelatedContact.Name : null);
                    row.put('RelatedContactPhone', ccr.RelatedContact != null ? ccr.RelatedContact.Phone : null);
                    row.put('RelatedContactEmail', ccr.RelatedContact != null ? ccr.RelatedContact.Email : null);
                    row.put('RelatedContactAddress',
                        ccr.RelatedContact != null
                        ? formatAddress(
                              ccr.RelatedContact.MailingStreet,
                              ccr.RelatedContact.MailingCity,
                              ccr.RelatedContact.MailingState,
                              ccr.RelatedContact.MailingPostalCode,
                              ccr.RelatedContact.MailingCountry
                          )
                        : null
                    );
            carerOut.add(row);
        }
        token.put('CarerCCRList', carerOut);                 // repeating block data
        token.put('showCarerCCRs', !carerOut.isEmpty());     // optional boolean to toggle section

        // Funding Items list
        List<Map<String,Object>> fiOut = new List<Map<String,Object>>();
        for (maica_cc__Funding_Item__c fi : fundingItemList) {
            Map<String,Object> row = new Map<String,Object>();
            row.put('FundingItemName', fi.Name);
            row.put('BudgetType', fi.maica_cc__Budget_Type__c);

            // raw
            row.put('ApprovedAmount',  fi.maica_cc__Approved_Amount__c);
            row.put('SpentAmount',     fi.maica_cc__Spent_Amount__c);
            row.put('RemainingAmount', fi.maica_cc__Remaining_Amount__c);
            row.put('EntryDate',       formatDate(fi.maica_cc__Entry_Date__c));
            row.put('EffectiveDate',   formatDate(fi.maica_cc__Effective_Date__c));
            row.put('EndDate',         formatDate(fi.maica_cc__End_Date__c));

            // display
            row.put('Approved_Amount_Display',   formatCurrency(fi.maica_cc__Approved_Amount__c));
            row.put('Spent_Amount_Display',      formatCurrency(fi.maica_cc__Spent_Amount__c));
            row.put('Remaining_Amount_Display',  formatCurrency(fi.maica_cc__Remaining_Amount__c));

            // tier
            row.put('FundingTier', classifyTier(fi.maica_cc__Approved_Amount__c));

            fiOut.add(row);
        }
        token.put('FundingItemList', fiOut);

        // Flags
        token.put('showPartG_AT_HM',        showPartG_AT_HM);
        token.put('showPartH_Restorative',  showPartH_Restorative);
        token.put('showPartI_EndOfLife',    showPartI_EndOfLife);
        
       // Buckets (separate AT and HM for Part G) 
		/* ===================== PART G: AT (Assistive Technology) ===================== */
        token.put('AT_StartDate',     gAT.minStart == null ? '' : formatDate(gAT.minStart));
        token.put('AT_EndDate',       gAT.maxEnd   == null ? '' : formatDate(gAT.maxEnd));
        token.put('AT_ApprovedAmount', gAT.totalApproved == null ? '' : formatCurrency(gAT.totalApproved));
        token.put('AT_FundingTier',   classifyTier(gAT.totalApproved));    // optional text display
         
        // AT tier checkboxes (use these tokens in the four checkboxes)
        token.put('AT_Tier_500',    renderBox(gAT.totalApproved != null && gAT.totalApproved <= 500));
        token.put('AT_Tier_2000',   renderBox(gAT.totalApproved != null && gAT.totalApproved > 500   && gAT.totalApproved <= 2000));
        token.put('AT_Tier_15000',  renderBox(gAT.totalApproved != null && gAT.totalApproved > 2000  && gAT.totalApproved <= 15000));
        token.put('AT_Tier_Other',  renderBox(gAT.totalApproved != null && gAT.totalApproved > 15000));
         
        /* ===================== PART G: HM (Home Modifications) ===================== */
        token.put('HM_StartDate',     gHM.minStart == null ? '' : formatDate(gHM.minStart));
        token.put('HM_EndDate',       gHM.maxEnd   == null ? '' : formatDate(gHM.maxEnd));
        token.put('HM_ApprovedAmount', gHM.totalApproved == null ? '' : formatCurrency(gHM.totalApproved));
        token.put('HM_FundingTier',   classifyTier(gHM.totalApproved));    // optional text display
         
        // HM tier checkboxes (use these tokens in the four checkboxes)
        token.put('HM_Tier_500',    renderBox(gHM.totalApproved != null && gHM.totalApproved <= 500));
        token.put('HM_Tier_2000',   renderBox(gHM.totalApproved != null && gHM.totalApproved > 500   && gHM.totalApproved <= 2000));
        token.put('HM_Tier_15000',  renderBox(gHM.totalApproved != null && gHM.totalApproved > 2000  && gHM.totalApproved <= 15000));
        token.put('HM_Tier_Other',  renderBox(gHM.totalApproved != null && gHM.totalApproved > 15000));
         
        /* ===================== PART H: Restorative Care ===================== */
        token.put('Restorative_StartDate',     gR.minStart == null ? '' : formatDate(gR.minStart));
        token.put('Restorative_EndDate',       gR.maxEnd   == null ? '' : formatDate(gR.maxEnd));
        token.put('Restorative_ApprovedAmount', gR.totalApproved == null ? '' : formatCurrency(gR.totalApproved));
        token.put('Restorative_Tier',          classifyTier(gR.totalApproved));
        token.put('Restorative_Tier_6000', renderBox(gR.totalApproved != null && gR.totalApproved <= 6000));
        token.put('Restorative_Tier_Other', renderBox(gR.totalApproved != null && gR.totalApproved > 6000));
       /* ===================== PART H: Services to be delivered (Entitlements Table) ===================== */
        List<Map<String,Object>> restorativeRows = new List<Map<String,Object>>();
        Integer rIdx = 1;
         
        // 1) Collect restorative Funding Item Ids
        Set<Id> rFiIds = new Set<Id>();
        for (maica_cc__Funding_Item__c fi : grpR) rFiIds.add(fi.Id);
         
        // 2) Query all entitlements in one SOQL and bucket by Funding Item
        if (!rFiIds.isEmpty()) {
            for (maica_cc__Entitlement__c e : [
                SELECT Id, Name, maica_cc__Approved_Amount__c, maica_cc__Funding_Item__c
                FROM maica_cc__Entitlement__c
                WHERE maica_cc__Funding_Item__c IN :rFiIds
            ]) {
                List<maica_cc__Entitlement__c> bucket = entsByFi.get(e.maica_cc__Funding_Item__c);
                if (bucket == null) {
                    bucket = new List<maica_cc__Entitlement__c>();
                    entsByFi.put(e.maica_cc__Funding_Item__c, bucket);
                }
                bucket.add(e);
            }
        }
        // 3) Build table rows
        for (maica_cc__Funding_Item__c fi : grpR) {
                    List<maica_cc__Entitlement__c> entList = entsByFi.get(fi.Id);
                    if (entList == null) continue;
                    
                    for (maica_cc__Entitlement__c ent : entList) {
                        Map<String,Object> row = new Map<String,Object>();
                        row.put('RowNumber', rIdx++);
                        row.put('EntitlementName', ent.Name);
                        row.put('Frequency', '');
                        row.put('ExpectedDates', '');
                        row.put('AssociatedProvider', '');
                        row.put('Price_Display', formatCurrency(ent.maica_cc__Approved_Amount__c));
                        restorativeRows.add(row);
                    }
                }
         
        token.put('Restorative_Services', restorativeRows);
        token.put('showRestorativeServices', !restorativeRows.isEmpty());
 
        /* ===================== PART I: End-of-Life Care ===================== */
        token.put('EOL_StartDate',     gI.minStart == null ? '' : formatDate(gI.minStart));
        token.put('EOL_EndDate',       gI.maxEnd   == null ? '' : formatDate(gI.maxEnd));
        token.put('EOL_ApprovedAmount', gI.totalApproved == null ? '' : formatCurrency(gI.totalApproved));
        token.put('EOL_Tier',          classifyTier(gI.totalApproved));
        
        // ============== AT entitlements table ==============
        List<Map<String,Object>> AT_Entitlements = new List<Map<String,Object>>();
        Decimal atEntTotal = 0;
        for (maica_cc__Funding_Item__c fi : grpAT) {
            for (maica_cc__Entitlement__c e : entsByFI.get(fi.Id)) {
                Map<String,Object> row = new Map<String,Object>();
                row.put('EntitlementName', e.Name);
                row.put('Approved_Amount_Display', formatCurrency(e.maica_cc__Approved_Amount__c));
                AT_Entitlements.add(row);
                if (e.maica_cc__Approved_Amount__c != null) atEntTotal += e.maica_cc__Approved_Amount__c;
            }
        }
        token.put('AT_Entitlements', AT_Entitlements);
        token.put('AT_Entitlements_Total', formatCurrency(atEntTotal));
         
        // ============== HM entitlements table ==============
        List<Map<String,Object>> HM_Entitlements = new List<Map<String,Object>>();
        Decimal hmEntTotal = 0;
        for (maica_cc__Funding_Item__c fi : grpHM) {
            for (maica_cc__Entitlement__c e : entsByFI.get(fi.Id)) {
                Map<String,Object> row = new Map<String,Object>();
                row.put('EntitlementName', e.Name);
                row.put('Approved_Amount_Display', formatCurrency(e.maica_cc__Approved_Amount__c));
                HM_Entitlements.add(row);
                if (e.maica_cc__Approved_Amount__c != null) hmEntTotal += e.maica_cc__Approved_Amount__c;
            }
        }
        token.put('HM_Entitlements', HM_Entitlements);
        token.put('HM_Entitlements_Total', formatCurrency(hmEntTotal));
        
        /* -------- Tokens: Approved Services -------- */
		List<String> approvedServiceIds = new List<String>();
 
            if (!approvedServices.isEmpty()) {
                Integer asIdx = 1;
                for (maica_cc__Approved_Service__c asRec : approvedServices) {
                    // Add Auto Number ID (Name) to the list
                    approvedServiceIds.add(asIdx + '. ' + asRec.Name);
                    asIdx++;
                }
            }
             
            // Build one combined formatted string for DocGen
            // Each item appears on a new line
            String approvedServiceListStr = String.join(approvedServiceIds, '\n');
             
            //Add to main token map
            token.put('ApprovedServiceList', approvedServiceListStr);
                    
        /* -------- Resolve which DOCX to use (ContentVersionId) via ENV -------- */

        // Allow direct override from Flow (rare)
        String contentVersionId = w.templateContentVersionId;

        // If Flow passed a specific ENV key, use it; else auto-pick by Funding Source
        String envKey = !String.isBlank(w.envContentDocVarName)
                        ? w.envContentDocVarName
                        : pickEnvKeyByFunding(opp.Funding_Source__c);

        // Fetch ENV values
        Map<String,String> envMap = getEnvValuesByNames(new Set<String>{ envKey });
        String contentDocumentIdStr = envMap.get(envKey);

        if (String.isBlank(contentVersionId)) {
            if (String.isBlank(contentDocumentIdStr)) {
                throw new AuraHandledException('No Environment Variable found for ' + envKey + ' (Value__c should be a ContentDocumentId).');
            }
            Id contentDocumentId = (Id) contentDocumentIdStr;

            // Resolve latest ContentVersionId for the ContentDocumentId
            List<ContentVersion> cv = [
                SELECT Id
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId
                ORDER BY VersionNumber DESC NULLS LAST
                LIMIT 1
            ];
            if (cv.isEmpty()) {
                throw new AuraHandledException('No ContentVersion found for ContentDocumentId ' + contentDocumentIdStr);
            }
            contentVersionId = cv[0].Id;
        }

        /* -------- Resolve the generic DocumentTemplate (mapping-only) -------- */

        String templateName = !String.isBlank(w.docTemplateName)
                              ? w.docTemplateName
                              : (!String.isBlank(w.envTemplateNameVarName)
                                    ? getEnvValuesByNames(new Set<String>{ w.envTemplateNameVarName }).get(w.envTemplateNameVarName)
                                    : DEFAULT_TEMPLATE_NAME);

        List<DocumentTemplate> tmplRows = [
            SELECT Id, Name
            FROM DocumentTemplate
            WHERE Name = :templateName AND IsActive = true
            LIMIT 1
        ];
        if (tmplRows.isEmpty()) {
            throw new AuraHandledException('Active DocumentTemplate not found for Name: ' + templateName);
        }
        DocumentTemplate tmpl = tmplRows[0];

        /* -------- Title naming: -------- */

        String who = (acc != null ? acc.Name : opp.Name);
        String ts  = Datetime.now().format('dd/MM/yyyy_HH:mm:ss');
        String niceFS = String.isBlank(opp.Funding_Source__c) ? 'Unknown' : opp.Funding_Source__c.replace(' ', '');
        String rawTitle = who + '_' + niceFS + '_' + 'Service Agreement';
        String title = sanitizeTitle(rawTitle);

        /* -------- Build DocGen request for DOCX output -------- */

        Map<String, Object> req = new Map<String, Object>{
            'templateContentVersionId' => contentVersionId,
            'title'                    => title,
            'keepIntermediate'         => false
        };

        DocumentGenerationProcess dgp = new DocumentGenerationProcess();
        dgp.Type                 = 'Generate';           // DOCX output
        dgp.RequestText          = JSON.serialize(req);
        dgp.ReferenceObject      = opp.Id;               // File will appear on Opportunity → Files
        dgp.TokenData            = JSON.serialize(token);
        dgp.DocGenApiVersionType = 'Advanced';
        dgp.DocumentTemplateId   = tmpl.Id;

        if (!Test.isRunningTest()) insert dgp;
    }

    /* ================= Helpers ================= */
    // Render a “checkbox” using Unicode (DocGen-friendly)
    private static String renderBox(Boolean b) {
        return (b == true ? '☒' : '☐');
    }
    // Roll-up of min start, max end, and total approved for a set of Funding Items
    private class PartRollup {
        public Date    minStart;
        public Date    maxEnd;
        public Decimal totalApproved;
        
        public PartRollup(List<maica_cc__Funding_Item__c> items) {
            for (maica_cc__Funding_Item__c x : items) {
                if (x.maica_cc__Start_Date__c != null &&
                    (minStart == null || x.maica_cc__Start_Date__c < minStart)) {
                        minStart = x.maica_cc__Start_Date__c;
                    }
                if (x.maica_cc__End_Date__c != null &&
                    (maxEnd == null || x.maica_cc__End_Date__c > maxEnd)) {
                        maxEnd = x.maica_cc__End_Date__c;
                    }
                if (x.maica_cc__Approved_Amount__c != null) {
                    totalApproved = (totalApproved == null ? 0 : totalApproved)
                        + x.maica_cc__Approved_Amount__c;
                }
            }
        }
    }
    /** Read Environment_Variables__mdt by DeveloperName and return map<DeveloperName, Value__c> */
    private static Map<String,String> getEnvValuesByNames(Set<String> developerNames) {
        Map<String,String> out = new Map<String,String>();
        if (developerNames == null || developerNames.isEmpty()) return out;
        for (Environment_Variables__mdt ev :
             [SELECT DeveloperName, Value__c
              FROM Environment_Variables__mdt
              WHERE DeveloperName IN :developerNames]) {
            out.put(ev.DeveloperName, ev.Value__c);
        }
        return out;
    }

    private static String formatDate(Date d) {
        if (d == null) return '';
        return Datetime.newInstance(d.year(), d.month(), d.day(), 0, 0, 0).format('dd/MM/yyyy');
    }
    private static String formatCurrency(Decimal v) {
        if (v == null) return '';
        return '$' + String.valueOf(v.setScale(2));
    }
    private static String formatAddress(String street, String city, String state, String pcode, String country) {
        List<String> parts = new List<String>();
        if (!String.isBlank(street))  parts.add(street);
        if (!String.isBlank(city))    parts.add(city);
        if (!String.isBlank(state))   parts.add(state);
        if (!String.isBlank(pcode))   parts.add(pcode);
        if (!String.isBlank(country)) parts.add(country);
        return String.join(parts, ', ');
    }
    private static String classifyTier(Decimal amt) {
        if (amt == null) return '';
        if (amt <= 500)        return '$0 - $500';
        if (amt <= 2000)       return '$501 - $2000';
        if (amt <= 15000)      return '$2001 - $15000';
        return 'Above $15000';
    }
    private static String sanitizeTitle(String inputStr) {
    if (inputStr == null || inputStr.trim() == '') {
        return 'Record';
    }
    // Remove invalid filename characters and extra spaces
    String clean = inputStr.replaceAll('[\\\\/:*?"<>|#%&{}$!@`~^+=]', ' ');
    clean = clean.replaceAll('\\s+', '_');  // collapse spaces into underscores
 
    // Truncate safely if too long (max 120 chars)
    if (clean.length() > 120) {
        clean = clean.substring(0, 120);
    }
    return clean;
}
}
