public without sharing class MC_AccountDocGen_Agreements {
 
    public class Wrapper {
        @InvocableVariable(required=true)
        public List<Id> recordIds;
 
        // Optional direct overrides
        @InvocableVariable public String docTemplateName;
        @InvocableVariable public String templateContentVersionId;
 
        // Optional env variable names (DeveloperName of Environment_Variables__mdt)
        @InvocableVariable public String envContentDocVarName;
        @InvocableVariable public String envTemplateNameVarName;
    }
 
    // Default ENV variable devname to look up ContentDocumentId for Account agreements
    private static final String ENV_ACCOUNT = 'Representative_Nomination_ContentId';
 
    // Default DocumentTemplate name (mapping-only template). Change to match your org.
    private static final String DEFAULT_ACCOUNT_TEMPLATE_NAME = 'RepresentativeNominationTemplate';
 
    /**
     * Invocable entry point for Flow
     */
    @InvocableMethod(label='Generate Account Agreement (auto by ENV)')
    public static void generateFromAccountFlow(List<Wrapper> inputs) {
        if (inputs == null || inputs.isEmpty() || inputs[0] == null ||
            inputs[0].recordIds == null || inputs[0].recordIds.isEmpty()) {
            throw new AuraHandledException('No Account Id provided.');
        }
        processAccount(inputs[0]);
    }
 
    /**
     * Public helper to allow calling from Apex directly if desired.
     */
    public static void processAccount(Wrapper w) {
        if (w == null || w.recordIds == null || w.recordIds.isEmpty()) {
            throw new AuraHandledException('No Account Id provided.');
        }
        Id acctId = w.recordIds[0];
        if (acctId == null) {
            throw new AuraHandledException('No Account Id provided.');
        }
 
        // Query Account - add/remove fields to suit your template
        Account acc = [
            SELECT Id, Name, Phone,
                   ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
					PersonEmail
            
            FROM Account
            WHERE Id = :acctId
            LIMIT 1
        ];
 
        if (acc == null) {
            throw new AuraHandledException('Account not found for Id: ' + String.valueOf(acctId));
        }
 
 
 
        // Build tokens map
        Map<String, Object> token = new Map<String, Object>();
        token.put('AccountId', acc.Id);
        token.put('AccountName', acc.Name);
        token.put('AccountPhone', acc.Phone);
 
        token.put('AccountShippingAddress',
            formatAddress(acc.ShippingStreet, acc.ShippingCity, acc.ShippingState, acc.ShippingPostalCode, acc.ShippingCountry)
        );
 
   
        token.put('AccountEmail', acc.PersonEmail == null ? '' : acc.PersonEmail);

 
 
        /* -------- Resolve which DOCX to use (ContentVersionId) via ENV -------- */
 
        String contentVersionId = w.templateContentVersionId;
        String envKey = !String.isBlank(w.envContentDocVarName) ? w.envContentDocVarName : ENV_ACCOUNT;
 
        Map<String,String> envMap = getEnvValuesByNames(new Set<String>{ envKey });
        String contentDocumentIdStr = envMap.get(envKey);
 
        if (String.isBlank(contentVersionId)) {
            if (String.isBlank(contentDocumentIdStr)) {
                throw new AuraHandledException('No Environment Variable found for ' + envKey + ' (Value__c should be a ContentDocumentId).');
            }
            Id contentDocumentId = (Id) contentDocumentIdStr;
 
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
 
        /* -------- Resolve DocumentTemplate (mapping-only template) -------- */
 
        String templateName = !String.isBlank(w.docTemplateName)
                              ? w.docTemplateName
                              : (!String.isBlank(w.envTemplateNameVarName)
                                    ? getEnvValuesByNames(new Set<String>{ w.envTemplateNameVarName }).get(w.envTemplateNameVarName)
                                    : DEFAULT_ACCOUNT_TEMPLATE_NAME);
 
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
 
        /* -------- Build DocumentGenerationProcess request -------- */
 
        String who = acc.Name == null ? 'Account' : acc.Name;
        String title = sanitizeTitle(who+'_Nomination of Representative');
 
        Map<String, Object> req = new Map<String, Object>{
            'templateContentVersionId' => contentVersionId,
            'title'                    => title,
            'keepIntermediate'         => false
        };
 
        DocumentGenerationProcess dgp = new DocumentGenerationProcess();
        dgp.Type                 = 'Generate';
        dgp.RequestText          = JSON.serialize(req);
        dgp.ReferenceObject      = acc.Id;                // file will appear on Account → Files
        dgp.TokenData            = JSON.serialize(token);
        dgp.DocGenApiVersionType = 'Advanced';
        dgp.DocumentTemplateId   = tmpl.Id;
 
        if (!Test.isRunningTest()) insert dgp;
    }
 
    /* ================= Helper methods ================= */
 
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
 
    private static String formatAddress(String street, String city, String state, String pcode, String country) {
        List<String> parts = new List<String>();
        if (!String.isBlank(street))  parts.add(street);
        if (!String.isBlank(city))    parts.add(city);
        if (!String.isBlank(state))   parts.add(state);
        if (!String.isBlank(pcode))   parts.add(pcode);
        if (!String.isBlank(country)) parts.add(country);
        return String.join(parts, ', ');
    }
 
    private static String sanitizeTitle(String inputStr) {
        if (inputStr == null || inputStr.trim() == '') {
            return 'Record';
        }
        String clean = inputStr.replaceAll('[\\\\/:*?"<>|#%&{}$!@`~^+=]', ' ');
        clean = clean.replaceAll('\\s+', '_');
        if (clean.length() > 120) clean = clean.substring(0, 120);
        return clean;
    }
}
