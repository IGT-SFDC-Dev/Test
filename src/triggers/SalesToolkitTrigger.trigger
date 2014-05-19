trigger SalesToolkitTrigger on Sales_Toolkit__c (before update, after update, after insert) {
    
    List<Sales_Toolkit__c> inclToolkitsEmail = new List<Sales_Toolkit__c>();
    List<Sales_Toolkit__c> updatedToolkits = new List<Sales_Toolkit__c>();
    
    for(Sales_Toolkit__c s: Trigger.new){
    	if (Trigger.isAfter && Trigger.isInsert) {
    			Sales_Toolkit__c s2 = [select Opportunity_Name__r.AccountId, RecordType.Name from Sales_Toolkit__c where Id =: s.Id limit 1];    			
    			if (s2.RecordType.Name == 'Europe Travel Request') {
    				Sales_Toolkit__c s3 = s.clone(true, true);
    				s3.Account__c = s2.Opportunity_Name__r.AccountId;
    				updatedToolkits.add(s3);
    			}
    	}
        if (Trigger.isAfter && Trigger.isUpdate) {
        	Sales_Toolkit__c previous = Trigger.oldMap.get(s.ID);
        	
            //if ((s.last_sent_email_date__c != previous.last_sent_email_date__c) || (previous.Sig_Received__c == false && s.Sig_Received__c) || (previous.Sig_Required__c == false && s.Sig_Required__c)) {
            if (s.last_sent_email_date__c != previous.last_sent_email_date__c) {
                inclToolkitsEmail.add(s);
            }
            
            if (inclToolkitsEmail.size() > 0) {
                EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Sales_Worksheet_MJP'];
                
                // Obtain our Routing Rules
                List<FS_Routing_Rule__c> routeRules = [SELECT CreatedById, CreatedDate, CurrencyIsoCode, IsDeleted, Name, Field_Service_Office__c, LastActivityDate, LastModifiedById, LastModifiedDate, Mailbox__c, OwnerId, Id, Sales_Group__c, Sales_Group_Description__c, Sales_Office__c, Sales_Office_Description__c, SystemModstamp FROM FS_Routing_Rule__c];
                
                List<ID> accountIds = new List<ID>();
                List<ID> ownerIds = new List<ID>();
                for (Sales_Toolkit__c toolkit: inclToolkitsEmail) {
                    accountIds.add(toolkit.Account__c);
                    ownerIds.add(toolkit.OwnerId);
                }
                
                // go up Account Hiearchy to obtain Sales Office and Sales Group
                List<Account> accts = [select Sales_Office__c, Sales_Group__c from Account where ID IN: accountIds];
                List<User> users = [select Name, Email from User where ID IN: ownerIds];
                
                Integer count = 0;
                for (Sales_Toolkit__c toolkit: inclToolkitsEmail) {
                    String salesOffice = accts.get(count).Sales_Office__c;
                    String salesGroup = accts.get(count).Sales_Group__c;
                    String ownerName = users.get(count).Name;
                    
                    System.debug('Sales Office: ' + salesOffice);
                    System.debug('Sales Group: ' + salesGroup);
                    System.debug('Owner Name: ' + ownerName);
                    
                    List<String> toEmailAddresses = executeRules(routeRules, salesOffice, salesGroup);
                    System.debug('Email Addresses Found: ' + toEmailAddresses.size());
                    
                    if (toEmailAddresses.size() > 0) {
                        for (String e: toEmailAddresses) {
                            System.debug('Email Address Found: ' + e);
                            /*
                            to do:  move to admin or custom settings
                            */
                            if (Functions.isProduction()) {
                                String[] ccAddresses = new String[]{'David.Petersen@igt.com'};
                                if (ownerName == 'Barb Harpling' || ownerName == 'Sean Rivera' || ownerName == 'Michael Caldrone') {         
                                    ccAddresses.add('donna.Lemieux@igt.com');
                                } else if (ownerName == 'Gary Gartley' || ownerName == 'Mark Chan') {
                                    ccAddresses.add('celia.camacho@igt.com');
                                }
                                CommonsUtil.sendEmail(toolkit.Id, et.Id, e, ccAddresses);
                            } else {
                                CommonsUtil.sendEmail(toolkit.Id, et.Id, e);
                            }
                        }
                    } else {
                        // TO DO: No Results Found, a Systems Exception is created
                        System.debug('Exception - No Email Addresses Found.');
                        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + toolkit.Id;
                        String msg = 'Could not find any routing rules for Sales Toolkit ID: <a href="' + fullRecordURL + '">' + toolkit.Name + '</a> with Sales Office: ' + salesOffice + ' and Sales Group: ' + salesGroup;  
                        CommonsUtil.handleException('Sales Toolkit - Routing Exception', msg);
                    }
                    count++;
                }   
            }
        }
        
        if (updatedToolkits.size() > 0) update updatedToolkits;
        
    }
    
    private List<String> executeRules(List<FS_Routing_Rule__c> routeRules, String salesOffice, String salesGroup) {
        List<String> toEmailAddresses = new List<String>();
        
        Boolean FOUND_MATCH = false;
        // match by both fields
        for (FS_Routing_Rule__c rule: routeRules) {
            if (rule.Sales_Office__c == salesOffice && rule.Sales_Group__c == salesGroup) {
                toEmailAddresses.add(rule.Mailbox__c);
                FOUND_MATCH = true;
            }
        }
        
        // match by Sales Office
        if (!FOUND_MATCH) {
            for (FS_Routing_Rule__c rule: routeRules) {
                if (rule.Sales_Office__c == salesOffice) {
                    toEmailAddresses.add(rule.Mailbox__c);
                }
            }
        }
        
        return toEmailAddresses;
    }
}