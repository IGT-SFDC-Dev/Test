@isTest(seeAllData=false)
public class IGT_InsertPhysicalLocationTest
{
      static Account testAccount;
      //method to create test account and BMC_PhysicalLocation CMDB Class
      public static void initData()
      {
          Id ClassId=IGT_TestClassHelper.createCMDBClass('BMC_PhysicalLocation');
          System.assertNotEquals(ClassId,null);
          
          testAccount=new Account(Name='Test'+System.now(),Customer_Number__c='111');
          insert testAccount;
          System.assertNotEquals(testAccount,null);
      }
      
      //method to test when account is created,Physical location CI and Account CI Link is created
      public static testMethod void testPLisCreated() {       
        initData();
        testAccount=[Select Id,Name,Customer_Number__c from Account where Id=:testAccount.Id];
        test.startTest();        
        List<BMCServiceDesk__BMC_PhysicalLocation__c> phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());
        List<BMCServiceDesk__BMC_BaseElement__c> beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());  
        BMCServiceDesk__BMC_PhysicalLocation__c phyLoc=phyLocList[0];
        BMCServiceDesk__BMC_BaseElement__c baseEle= beList[0];
        System.assertEquals(phyLoc.Account__c ,testAccount.Id);
        System.assertEquals(phyLoc.Name,testAccount.Name);
        System.assertEquals(baseEle.CI_Name__c,testAccount.Name);
        System.assertEquals(baseEle.Name,testAccount.Name+'__'+testAccount.Customer_Number__c);
        System.assertEquals(baseEle.BMCServiceDesk__Name__c,testAccount.Name+'__'+testAccount.Customer_Number__c);
        List<BMCServiceDesk__Account_CI_Link__c> accCIList=[Select Id,BMCServiceDesk__FKAccount__c,BMCServiceDesk__FKConfiguration_Item__c from BMCServiceDesk__Account_CI_Link__c where BMCServiceDesk__FKConfiguration_Item__c=:beList[0].Id and BMCServiceDesk__FKAccount__c=:testAccount.Id];
        System.assertEquals(true,!accCIList.isEmpty());
        test.stoptest();
    }
    //method to test when account Name and Customer Number of Account is updated,corresponding fields of physcical location and base element are updated
    public static testMethod void testPLisUpdated_ForNameAndCustNumber() {       
        initData();
        testAccount.Name='Temp'+System.now();
        testAccount.Customer_Number__c='22';
        update testAccount;
        System.assertNotEquals(testAccount,null);
        testAccount=[Select Id,Name,Customer_Number__c from Account where Id=:testAccount.Id];
        test.startTest();        
        List<BMCServiceDesk__BMC_PhysicalLocation__c> phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());
        List<BMCServiceDesk__BMC_BaseElement__c> beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());  
        BMCServiceDesk__BMC_PhysicalLocation__c phyLoc=phyLocList[0];
        BMCServiceDesk__BMC_BaseElement__c baseEle= beList[0];
        System.assertEquals(phyLoc.Account__c ,testAccount.Id);
        System.assertEquals(phyLoc.Name,testAccount.Name);
        System.assertEquals(baseEle.CI_Name__c,testAccount.Name);
        System.assertEquals(baseEle.Name,testAccount.Name+'__'+testAccount.Customer_Number__c);
        System.assertEquals(baseEle.BMCServiceDesk__Name__c,testAccount.Name+'__'+testAccount.Customer_Number__c);
        test.stoptest();
    }
    
    //method to test when Name of Account is updated,corresponding fields of physcical location and base element are updated
    
    public static testMethod void testPLisUpdated_ForName() {       
        initData();
        testAccount.Name='Temp'+System.now();
        update testAccount;
        System.assertNotEquals(testAccount,null);
        testAccount=[Select Id,Name,Customer_Number__c from Account where Id=:testAccount.Id];
        test.startTest();        
        List<BMCServiceDesk__BMC_PhysicalLocation__c> phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());
        List<BMCServiceDesk__BMC_BaseElement__c> beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());  
        BMCServiceDesk__BMC_PhysicalLocation__c phyLoc=phyLocList[0];
        BMCServiceDesk__BMC_BaseElement__c baseEle= beList[0];
        System.assertEquals(phyLoc.Account__c ,testAccount.Id);
        System.assertEquals(phyLoc.Name,testAccount.Name);
        System.assertEquals(baseEle.CI_Name__c,testAccount.Name);
        System.assertEquals(baseEle.Name,testAccount.Name+'__'+testAccount.Customer_Number__c);
        System.assertEquals(baseEle.BMCServiceDesk__Name__c,testAccount.Name+'__'+testAccount.Customer_Number__c);
        test.stoptest();
    }
    //method to test when Customer Number of Account is updated,corresponding fields of physcical location and base element are updated
    public static testMethod void testPLisUpdated_ForCustNumber() {       
        initData();
        testAccount.Customer_Number__c='1122';
        update testAccount;
        testAccount=[Select Id,Name,Customer_Number__c from Account where Id=:testAccount.Id];
        test.startTest();        
        List<BMCServiceDesk__BMC_PhysicalLocation__c> phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());
        List<BMCServiceDesk__BMC_BaseElement__c> beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());  
        BMCServiceDesk__BMC_PhysicalLocation__c phyLoc=phyLocList[0];
        BMCServiceDesk__BMC_BaseElement__c baseEle= beList[0];
        System.assertEquals(phyLoc.Account__c ,testAccount.Id);
        System.assertEquals(phyLoc.Name,testAccount.Name);
        System.assertEquals(baseEle.Name,testAccount.Name+'__'+testAccount.Customer_Number__c);
        System.assertEquals(baseEle.BMCServiceDesk__Name__c,testAccount.Name+'__'+testAccount.Customer_Number__c);
        test.stoptest();
    }
    //method to test if the account does not have physical location, then the physical location is created for the account when the account is updated
    public static testMethod void testPLisCreated_ForAccountWithNoPL() {       
        initData();
        testAccount=[Select Id,Name,Customer_Number__c from Account where Id=:testAccount.Id];
        test.startTest();    
        List<BMCServiceDesk__BMC_PhysicalLocation__c> phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());   
        List<BMCServiceDesk__BMC_BaseElement__c> beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());  
        delete beList;
        phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(false,!phyLocList.isEmpty());
        update testAccount;
        System.assertNotEquals(testAccount,null);
        phyLocList =[Select Id,BMCServiceDesk__InstanceID__c,Name,Account__c from BMCServiceDesk__BMC_PhysicalLocation__c where Account__c=:testAccount.Id];
        System.assertEquals(true,!phyLocList.isEmpty());
        beList=[Select Id,Name,CI_Name__c,BMCServiceDesk__InstanceID__c,BMCServiceDesk__Name__c from BMCServiceDesk__BMC_BaseElement__c where BMCServiceDesk__InstanceID__c=:phyLocList[0].BMCServiceDesk__InstanceID__c];
        System.assertEquals(true,!beList.isEmpty());
        BMCServiceDesk__BMC_PhysicalLocation__c phyLoc=phyLocList[0];
        BMCServiceDesk__BMC_BaseElement__c baseEle= beList[0];
        System.assertEquals(phyLoc.Account__c ,testAccount.Id);
        System.assertEquals(phyLoc.Name,testAccount.Name);
        System.assertEquals(baseEle.Name,testAccount.Name+'__'+testAccount.Customer_Number__c);
        System.assertEquals(baseEle.BMCServiceDesk__Name__c,testAccount.Name+'__'+testAccount.Customer_Number__c);
        test.stoptest();
    }
}