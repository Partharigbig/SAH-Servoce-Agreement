/******************************************************************************************
Purpose : Helper Class for handling Trigger logics on ContentVersion Object.
Name    : MC_ContentVersionTriggerHelper

Author  : Cognizant Developer
Version : 1.0

Modification History
Date          Who        Description  
28/02/2025  Muniappan K  Initial Log
******************************************************************************************/
public with sharing class MC_ContentVersionTriggerHelper {
    public static boolean stop=false;
    

    public MC_ContentVersionTriggerHelper() {
        

    }
    public void updateSharingPrivacyInsert(List<ContentVersion> newList, Map<Id, ContentVersion> oldMap) {
         List<ContentVersion> cvList= new List<ContentVersion>();
                String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
        Pattern dateTimePattern = Pattern.compile('\\d{2}/\\d{2}/\\d{4} \\d{2}:\\d{2}:\\d{2}');
        
        for(ContentVersion cv:newList){
       
                     system.debug('==='+cv.FileType );
                   
                    if(cv.FileType!='SNOTE'){
                     ContentVersion cv1=new ContentVersion(Id=cv.Id);
                    cv1.SharingPrivacy = (cv.File_Category__c == 'Private') ? 'P' : 'N';
                    cv1.Title = cv.Title +' '+ cv.CreatedDate.format(dateTimeFormat);
                        if(cv1.Title.Contains('Care Plan')){
                            cv1.File_Category__c =  'Care Plan/ task list';	
                            cv1.Title = cv.Title;
                        }
                        else if(cv1.Title.Contains('Service_Agreement')){
                            cv1.File_Category__c= 'Service Agreement';
                            cv1.Title = cv.Title;
                        }
                     cvList.add(cv1);
                    }
        }
                        if(!cvList.isEmpty()){
                            stop=true;
                            update cvList;
                        }
                   // }
                
    }

    //trigger method to update the ContentDocument Title with Naming Convention of Created Date and Sharing Privacy
    /*
    * MethodName: updateSharingPrivacy
    * Developed By: Muniappan K
    * Input: trigger.new,trigger.oldMap
    * OutPut: Field update
    */
    public void updateSharingPrivacy(List<ContentVersion> newList, Map<Id, ContentVersion> oldMap) {
            
        String dateTimeFormat = 'dd/MM/yyyy HH:mm:ss';
        Pattern dateTimePattern = Pattern.compile('\\d{2}/\\d{2}/\\d{4} \\d{2}:\\d{2}:\\d{2}');
        
        try{
            User us=[select id from user where Id=:UserInfo.getUserId()];
            for (ContentVersion cv : newList) {
                if (oldMap != null && oldMap.containsKey(cv.Id) && cv.File_Category__c != oldMap.get(cv.Id).File_Category__c && cv.FileType != 'SNOTE' && cv.FileType != null) {
                    cv.SharingPrivacy = (cv.File_Category__c == 'Private') ? 'P' : 'N';
                } else if (oldMap == null && cv.Title != null && cv.Id==null) {
                    
                    //system.debug('==='+cv.FileType +' '+User.UITheme);
                    cv.SharingPrivacy = (cv.File_Category__c == 'Private') ? 'P' : 'N';
                    cv.Title = cv.Title + ' ' + cv.CreatedDate.format(dateTimeFormat);
                    System.debug(cv.Title);
                }
                
                if(!stop){
                if (oldMap != null && oldMap.containsKey(cv.Id) && cv.Title != oldMap.get(cv.Id).Title && cv.FileType != 'SNOTE' && cv.FileType != null) {
                     system.debug('===1');
                    String oldTitle = oldMap.get(cv.Id).Title;
                    String newTitle = cv.Title;
                    
                    String oldDateTime = (oldTitle.length() >= 19) ? oldTitle.substring(oldTitle.length() - 19) : '';
                    String newDateTime = (newTitle.length() >= 19) ? newTitle.substring(newTitle.length() - 19) : '';
                    
                    Boolean isOldDateTimeValid = dateTimePattern.matcher(oldDateTime).matches();
                    Boolean isNewDateTimeValid = dateTimePattern.matcher(newDateTime).matches();
                    
                    String oldTitleWithoutDateTime = isOldDateTimeValid ? oldTitle.substring(0, oldTitle.length() - 19).trim() : oldTitle;
                    String newTitleWithoutDateTime = isNewDateTimeValid ? newTitle.substring(0, newTitle.length() - 19).trim() : newTitle;
                    
                    if ((!isNewDateTimeValid || (oldDateTime != newDateTime)) && cv.FileType != 'SNOTE' && cv.FileType != null) {
                        cv.addError(System.Label.MC_ErrMsgFileTitle);
                        continue;
                    }
                    
                    if (isOldDateTimeValid && isNewDateTimeValid && cv.FileType != 'SNOTE' && cv.FileType != null) {
                        cv.Title = newTitleWithoutDateTime + ' ' + System.Now().format(dateTimeFormat);
                    }

                    else if (isNewDateTimeValid && cv.FileType != 'SNOTE' && cv.FileType != null) {
                        cv.Title = newTitleWithoutDateTime + ' ' + System.Now().format(dateTimeFormat);
                    }
                    stop=true;
                }
            }
            }
        }catch(Exception e) {
            MC_CommonUtils.insertExceptionLog(e, 'MC_ContentVersionTriggerHelper', 'updateSharingPrivacy');
        }
    }
}
