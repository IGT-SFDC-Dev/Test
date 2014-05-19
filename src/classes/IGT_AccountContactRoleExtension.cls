/*
	IGT_AccountContactRoleExtension
	Custom VF RelatedList Component
	------------------------------------------------------------------------------------
	Author           | Date       | Description
	------------------------------------------------------------------------------------
	Paul Payne (IGT) | 04/17/2013 | Initial creation.
*/
public with sharing class IGT_AccountContactRoleExtension {

	public ApexPages.StandardSetController ssc {get; private set;}
	public String rtParam {get; set; }
	private String query;
	private ID accountId;
    public Integer listSize { get; set; }
	
	public IGT_AccountContactRoleExtension(ApexPages.StandardController stdController) {
		this(ApexPages.currentPage().getParameters().get('id'));
	}
    
	public IGT_AccountContactRoleExtension() {
		this(ApexPages.currentPage().getParameters().get('id'));
	}
	
	public IGT_AccountContactRoleExtension(String accountId) {
		this.accountId = accountId;
	
        listSize = [select COUNT() from IGT_AccountContactRole__c where Account__c =: accountId];
        
		query = 'select Id, Account__r.Id, Account__r.BillingStreet, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingCountry, Account__r.BillingPostalCode, Name, Contact_Record_Type__c, Active__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.Title, Contact__r.Job_Function__c, Contact__r.Phone from IGT_AccountContactRole__c where Account__c=\'' + accountId + '\'';
		String filterQuery = query + ' and Contact_Record_Type__c=\'Sales\' and Active__c=true';
		
		ssc = new ApexPages.StandardSetController(Database.Query(filterQuery));
		ssc.setPageSize(5);
	}
		
	public List<IGT_AccountContactRole__c> getRoles() {
		return (List<IGT_AccountContactRole__c>) ssc.getRecords();
	}
	
	public PageReference filterRoles() {
		SObject[] empty = new List<SObject>();
		ssc.setSelected(empty);
		String filterQuery = query;
		if (rtParam != 'All') filterQuery += ' and Contact_Record_Type__c=\'' +  rtParam + '\'';
		if (rtParam == 'Sales') filterQuery += ' and Active__c=true';
		ssc = new ApexPages.StandardSetController(Database.Query(filterQuery));
		ssc.setPageSize(5);
		if(ssc.getRecords().size() == 0) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No matching Accounts found.'));
		}
		
		return null;
	}
	
	public PageReference createNewSalesContact() {		
		try {
			//IGT_AccountContactRole__c contactRole = (IGT_AccountContactRole__c) ssc.getRecords().get(0);
			Account acct = [select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where Id =: accountId limit 1];
						
			Schema.DescribeSObjectResult objDesc = Contact.SObjectType.getDescribe();
			Map<String,Schema.RecordTypeInfo> recordTypeInfo = objDesc.getRecordTypeInfosByName();
			String recordTypeId = recordTypeInfo.get('Sales').getRecordTypeId();
			String prefixId = objDesc.getKeyPrefix();
			
			String url = '/003/e?retURL=%2F' + accountId + '&accid=' + accountId + '&RecordType=' + recordTypeId;
			String addressURL = '&street=' + EncodingUtil.urlEncode(acct.BillingStreet, 'UTF-8') + '&city=' + EncodingUtil.urlEncode(acct.BillingCity, 'UTF-8') + '&state=' + EncodingUtil.urlEncode(acct.BillingState, 'UTF-8') + 'zip=' + acct.BillingPostalCode + '&country=' + acct.BillingCountry;
			
			PageReference nextPage = new PageReference(url + addressURL + '&ent=Contact');
			nextPage.setRedirect(false);
			nextPage.getParameters().remove('inline'); 
			
			return nextPage;
			
		} catch(Exception e) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
			return null;
		}
	}
	
	public PageReference displayAll() {
		try {
			IGT_AccountContactRole__c contactRole = (IGT_AccountContactRole__c) ssc.getRecords().get(0);
			
			Schema.DescribeSObjectResult objDesc = IGT_AccountContactRole__c.SObjectType.getDescribe();
			String prefixId = objDesc.getKeyPrefix();
			
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Info, prefixId));
			
			String url = '/' + prefixId + '?rlid=00Na000000BA8BX&id=' + contactRole.Account__r.Id;
			PageReference nextPage = new PageReference(url);
			nextPage.setRedirect(true);
			
			return nextPage;
			
		} catch(Exception e) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
			return null;
		}
	}
}