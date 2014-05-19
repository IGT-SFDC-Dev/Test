/*
 * Class : IGT_CreateAndLinkProblemController
 * Description: Allows to create a Problem record and link it to Incident
 *              Also Maps following Incident field values with Problem field values.
 *              Incident Fields -System,Product,Component,Impact,Urgency,Subject,Resolution
 *              Problem Fields-System,Product,Component,Impact,Urgency,Short Description,Long Description
 * Author : PSL
 */

public with sharing class IGT_CreateAndLinkProblemController {
    
    public  BMCServiceDesk__Incident__c incObj {get;set;}
    public  BMCServiceDesk__Problem__c probObj {get;set;}
    private List<BMCServiceDesk__Incident__c> incList {get;set;}
    private List<BMCServiceDesk__Problem__c> pList {get;set;}
    
    public IGT_CreateAndLinkProblemController (ApexPages.StandardController controller){
    
        incObj = (BMCServiceDesk__Incident__c)controller.getRecord();
     }
     String incidentId {get;set;}
     public IGT_CreateAndLinkProblemController(){
          incidentId =Apexpages.currentPage().getParameters().get('incId');
          
          this.copyIncidentAndCreateProblem();
     }
     
     public void copyIncidentAndCreateProblem(){
     
     //System.debug('incidentId ' + incidentId );
     String OwnerPrefix = Schema.SObjectType.User.getKeyPrefix();
         incList = [Select b.Name, b.Subject__c,b.IGT_Symptom__c, b.IGT_ReferenceSystem__c, b.IGT_ReferenceProduct__c, b.Impact__c,b.Urgency__c,b.OwnerId, BMCServiceDesk__incidentDescription__c , BMCServiceDesk__incidentResolution__c
                                                  From BMCServiceDesk__Incident__c b WHERE Id =: incidentId  ];
        
         if(incList != null && incList.size() > 0 ){
          //System.debug('incList ' + incList );
          
          List<BMCServiceDesk__Problem__c> pList = new List<BMCServiceDesk__Problem__c>();
          pList.add(new  BMCServiceDesk__Problem__c( IGT_Symptom__c = incList[0].IGT_Symptom__c , IGT_ReferenceSystem__c = incList[0].IGT_ReferenceSystem__c, IGT_ReferenceProduct__c = incList[0].IGT_ReferenceProduct__c, LongDescription__c = incList[0].BMCServiceDesk__incidentResolution__c, BMCServiceDesk__Problem_Description__c = incList[0].BMCServiceDesk__incidentDescription__c,BMCServiceDesk__shortDescription__c = incList[0].Subject__c,Impact__c = incList[0].Impact__c,Urgency__c = incList[0].Urgency__c ));        
          
          if(((String)incList[0].OwnerId).startsWith(OwnerPrefix))
          {
                 pList[0].Reportedby__c =  incList[0].OwnerId;        
          }
          try
          {
           // insert pList;
            
            probObj = pList.get(0);    
          }
          catch(Exception e)
          {
            for(BMCServiceDesk__Problem__c tempProb:pList)
            {
                tempProb.addError('Error while creating problem');
            }
          }
          pList = [SELECT NAME,IGT_Symptom__c, IGT_ReferenceSystem__c , IGT_ReferenceProduct__c , BMCServiceDesk__Work_Around__c , BMCServiceDesk__Problem_Description__c , BMCServiceDesk__FKUrgency__c , BMCServiceDesk__FKImpact__c FROM BMCServiceDesk__Problem__c WHERE ID =:pList[0].Id];
          if(pList != null && pList.size() > 0){
              try
              {
               // insert new BMCServiceDesk__Incident_Problem_Link__c(Name = incList[0].Name +'_'+pList[0].Name, BMCServiceDesk__FKIncident__c = incidentId, BMCServiceDesk__FKProblem__c = pList[0].id );
              }
              catch(Exception e)
              {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Error while linking problem');
                ApexPages.addMessage(msg); 
              }
          }
         }
         
         
         //return new Pagereference('/apex/IGTCreateAndLinkProblemPage?id='+ incidentId );
     
     }
     
     public PageReference createIncidentLink(){
      
     	try
          {
            insert probObj;
          }
          catch(Exception e)
           {
            for(BMCServiceDesk__Problem__c tempProb:pList)
            {
                tempProb.addError('Error while creating problem');
                
                
            }
            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Error while creating problem: ' + e.getMessage());
            ApexPages.addMessage(msg); 
                
            return null;
          }
   
          try
          	{
          		
          pList = [SELECT NAME,IGT_Symptom__c, IGT_ReferenceSystem__c , IGT_ReferenceProduct__c , BMCServiceDesk__Work_Around__c , BMCServiceDesk__Problem_Description__c , BMCServiceDesk__FKUrgency__c , BMCServiceDesk__FKImpact__c FROM BMCServiceDesk__Problem__c WHERE ID =:probObj.Id];
          if(pList != null && pList.size() > 0){
              //try
              //{
               insert new BMCServiceDesk__Incident_Problem_Link__c(Name = incList[0].Name +'_'+pList[0].Name, BMCServiceDesk__FKIncident__c = incidentId, BMCServiceDesk__FKProblem__c = pList[0].id );
            }
          }
          catch(Exception e)
              {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Error while linking problem: ' + e.getMessage());
                ApexPages.addMessage(msg); 
                
                return null;
              }
          
          
          return new Pagereference('/'+ incidentId );
     }
     
     public PageReference cancel()
     {
       return new Pagereference('/'+ incidentId );
       
      //return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));  
     }
}