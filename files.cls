/******************************************************************************************
Purpose : Class for handling Trigger logics on ContentVersion Object.
Name    : MC_GetFilesList

Author  : Cognizant Developer
Version : 1.0 

Modification History
Date          Who        Description  
28/02/2025  Muniappan K  Initial Log
******************************************************************************************/
public with sharing  class MC_GetFilesList {
    
    @InvocableMethod(label='Get Files' description='Returns the list of Files based on ParentRecord' category='Files')
    public static List<List<ContentDocument>> getFiles(List<ID> parentRecordId) {
        List<List<ContentDocument>> contentDocumentArray = new List<List<ContentDocument>>();
        try{
        List<ContentDocument> contentDocumentIdList = new List<ContentDocument>();
        
        for(ContentDocumentLink conDocLink : [SELECT ContentDocumentId, ContentDocument.Title, ContentDOcument.CreatedDate, LinkedEntityId  FROM ContentDocumentLink 
                                              WHERE LinkedEntityId=:parentRecordId WITH SECURITY_ENFORCED]){
                                                  contentDocumentIdList.add(conDocLink.ContentDocument);                             
                                              }
        
        List<ContentDocument> contentDocumentList = [SELECT Id, Title, Description,CreatedDate FROM ContentDocument WHERE ID In: contentDocumentIdList WITH SECURITY_ENFORCED];
                
        for(ContentDocument contDoc : contentDocumentList){
            String hyperLink = '<html lang="ja"><body>'+
                '<a href="https://www.surveymonkey.co.uk">Take the survey now.</a></body></html>';
            contDoc.Title = hyperLink;
        }
        
        contentDocumentArray.add(contentDocumentList);
        
        }Catch(Exception e){
            MC_CommonUtils.insertExceptionLog(e, 'MC_GetFilesList', 'getFiles');
        }
        return contentDocumentArray;
    }

    @AuraEnabled
    public static Map<String, Object> getFilesForLWC(List<ID> parentRecordIds, Integer pageSize, Integer offset, String sortBy, String sortDirection) {
        Set<Id> contentDocIds = new Set<Id>();
        Map<String, Object> response = new Map<String, Object>();
        try{
        Id loginUserId = UserInfo.getUserId();
            Set<Id> onlyOppId = new set<id>();
        
        User loginUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: loginUserId WITH SECURITY_ENFORCED];
        Id loginUserAccId = loginUser.Contact.AccountId;
        System.debug(loginUserAccId);
        
        if(loginUser.ContactId != null && loginUser.Contact.AccountId != null){
            
            parentRecordIds.add(loginUserAccId);
        }
            system.debug(parentRecordIds);
        for (ContentDocumentLink link : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: parentRecordIds WITH SECURITY_ENFORCED]) {
            contentDocIds.add(link.ContentDocumentId);
        }
        
        String query = 'SELECT Id, Title, CreatedDate, ' +
            '(SELECT Id, File_Category__c FROM ContentVersions WHERE IsLatest = TRUE LIMIT 1) ' +
            'FROM ContentDocument WHERE Id IN: contentDocIds ';
        
        if (sortBy != null && sortDirection != null) {
            query += 'ORDER BY ' + sortBy + ' ' + sortDirection + ' ';
        } else {
            query += 'ORDER BY CreatedDate DESC ';
        }
        
        query += 'LIMIT :pageSize OFFSET :offset';
        
        List<ContentDocument> files = Database.query(String.escapeSingleQuotes(query));
        
        Integer totalRecords = [SELECT COUNT() FROM ContentDocument WHERE Id IN :contentDocIds WITH SECURITY_ENFORCED];
        
        response.put('files', files);
        response.put('totalRecords', totalRecords); 
        
        }Catch(Exception e){
            MC_CommonUtils.insertExceptionLog(e, 'MC_GetFilesList', 'getFilesForLWC');
        }
        return response;
    }
    
    @AuraEnabled
    public static void updateFileCategory(List<Id> fileIds, String category) {
        try{
        List<ContentVersion> filesToUpdate = [SELECT Id, File_Category__c FROM ContentVersion WHERE ContentDocumentId IN :fileIds WITH SECURITY_ENFORCED];
        for (ContentVersion file : filesToUpdate) {
            file.File_Category__c = category;
        }
         if (Schema.sObjectType.ContentVersion.isAccessible() && Schema.sObjectType.ContentVersion.isUpdateable()) {
            update filesToUpdate;
       }
        
        }catch(Exception e){
            MC_CommonUtils.insertExceptionLog(e, 'MC_GetFilesList', 'updateFileCategory');
        }
    }
}
