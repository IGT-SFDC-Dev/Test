@isTest
public with sharing class IGT_AccountContactRoleListTest {
	
	@isTest(SeeAllData=true)
    public static void testAccountContactRoleRelatedList() {
		
		ID salesRecordTypeId = [SELECT Id FROM RecordType where SObjectType='Contact' and DeveloperName='Sales'].Id;
		
    	Account acct = new Account(Name='TestAccount', Customer_Number__c = '1234' + System.now(), BillingStreet='111 Las Vegas Blvd', BillingState='NV', BillingCity='Las Vegas', BillingCountry='US', BillingPostalCode='89123');
        insert acct;
        
        Contact contact = new Contact(RecordTypeId = salesRecordTypeId, FirstName='Test', LastName='Contact', Email='test@yahoo.com', Title='Slot Tech',Job_Function__c='Slot Tech', Phone='(888) 593-1000', AccountId=acct.Id);
        insert contact;
        
        test.startTest();
    	PageReference pageRef = new PageReference('/apex/SelectGameThemes');
	    pageRef.getParameters().put('id', acct.Id);
	    
	    Test.setCurrentPage(pageRef);
	    ApexPages.StandardController sc = new ApexPages.standardController(acct); 
	    IGT_AccountContactRoleExtension controller = new IGT_AccountContactRoleExtension(sc);
	    List<IGT_AccountContactRole__c> contactRoles = controller.getRoles();
	    Integer listSize = controller.getListSize();
	    
	    System.assertEquals(contactRoles.size(), listSize);
	    
	    controller.rtParam = 'All';
	    controller.filterRoles();
	    
	    controller.createNewSalesContact();
	    controller.displayAll();
	    
	    test.stopTest();
    }
}