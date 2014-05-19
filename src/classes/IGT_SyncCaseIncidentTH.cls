/*
    IGT_IncidentHandler
    Class to help handle Incident Triggers
    ------------------------------------------------------------------------------------
    Author           | Date       | Description
    ------------------------------------------------------------------------------------
    Acumen Solutions | 07/05/2013 | Initial creation.
*/
public without sharing class IGT_SyncCaseIncidentTH
{
    public static void syncEmails(List<Case> cases, Map<Id, Case> triggerNewMap)
    {
        List<BMCServiceDesk__IncidentHistory__c> newHistories = new List<BMCServiceDesk__IncidentHistory__c>();
        if (IGT_TriggerUtility.hasSyncedEmails)
        {
            return;
        }
        IGT_TriggerUtility.hasSyncedEmails = true;
        IGT_TriggerUtility.hasCopiedEmails = true;
        
        Id sendActionId;
        {
            List<BMCServiceDesk__Action__c> sendAction = [SELECT Name FROM BMCServiceDesk__Action__c WHERE Name = :IGT_Constants.EMAIL_ACTION LIMIT 1];
            if (sendAction.size() > 0)
            {
                sendActionId = sendAction[0].Id;
            }
        }
        List<BMCServiceDesk__IncidentHistory__c> emailLogs = new List<BMCServiceDesk__IncidentHistory__c>();
        List<EmailMessage> caseMessages = [SELECT ToAddress, FromAddress, TextBody, CreatedById, Subject, CcAddress, ParentId FROM EmailMessage WHERE ParentId IN :cases];
        
        for (EmailMessage message: caseMessages)
        {
            Case msgCase = triggerNewMap.get(message.ParentId);
            if (msgCase.Incident__c == null)
                continue;
            
            if (sendActionId == null)
            {
                message.Subject.addError('Remedyforces Action object of value "Email Sent" must exist in order to copy these emails to the incident.');
                continue;
            }
            
            BMCServiceDesk__IncidentHistory__c emailHistory = new BMCServiceDesk__IncidentHistory__c(
                BMCServiceDesk__description__c = 'Email Sent-Incident #' + msgCase.Incident__r.Name + ' (Ref:IN:' + msgCase.Incident__r.Name + ')',
                BMCServiceDesk__note__c = 'From:' + message.FromAddress + '\nTo:' + message.ToAddress + '\nCc:' + message.CcAddress + 
                '\nSubject:' + message.Subject + '\n\n\n' + message.TextBody, BMCServiceDesk__FKIncident__c = msgCase.Incident__c, 
                BMCServiceDesk__FKUser__c = message.CreatedById, BMCServiceDesk__date__c = DateTime.now(), 
                BMCServiceDesk__FKAction__c = sendActionId); //Record link for BMC Remedyforce user: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseMap.Incident__c + 
                //'\n\n(Ref:IN:' + caseMap.Incident__r.Name + ')\nImportant: Do not change the subject line while replying.', );
            emailLogs.add(emailHistory);
        }
        System.debug('email logs = ' + emailLogs);
        insert emailLogs;
    }
    
    public static void syncCaseFromIncident(List<BMCServiceDesk__Incident__c> triggerNew)
    {
        if (IGT_TriggerUtility.hasHitIncidentUpdate)
        {
            if (IGT_TriggerUtility.hasSyncedIncident)
                return;
            IGT_TriggerUtility.hasSyncedIncident = true;
        }
        /*
        if (IGT_TriggerUtility.testing)
        {
            return;
        }
        IGT_TriggerUtility.testing = true;
        */
        Map<Id, Case> incidentToCaseMap = new Map<Id, Case>();
        Map<Id, BMCServiceDesk__Incident__c> incidentMap = new Map<Id, BMCServiceDesk__Incident__c>(
            [SELECT BMCServiceDesk__FKIncident__c, BMCServiceDesk__FKIncident__r.Ticket__c FROM BMCServiceDesk__Incident__c 
              WHERE Id IN :triggerNew]);
        
        Map<String, String> rTypeMap = new Map<String, String>();
        for (RecordType rType: 
            [SELECT Name, SObjectType FROM RecordType 
              WHERE (SObjectType = 'Case' OR SObjectType = 'BMCServiceDesk__Incident__c') AND (Name = :IGT_Constants.CASE_SYSTEM_RTYPE OR Name = :IGT_Constants.CASE_SERVICE_REQUEST_RTYPE)])
        {
            if (rType.SObjectType == 'Case')
                rTypeMap.put(rType.Name, rType.Id);
            else
                rTYpeMap.put(rType.Id, rType.Name);
        }
        
        Map<String, IGT_CaseIncidentMapping__c> cimMap = IGT_CaseIncidentMapping__c.getAll();
        List<IGT_CaseIncidentMapping__c> cimList = cimMap.values();
        
        String caseQuery = 'SELECT Incident__c, RecordTypeId';
        for (IGT_CaseIncidentMapping__c mapping: cimList)
        {
            if (mapping.Active__c)
            {
                if (mapping.Case_Lookup_Field__c != null)
                {
                    caseQuery += ', ' + mapping.Case_Lookup_Field__c;
                } else
                {
                    caseQuery += ', ' + mapping.Case_Field__c;
                }
            }
        }
        
        caseQuery += ' FROM Case WHERE Incident__c IN (';
        for (BMCServiceDesk__Incident__c incident: triggerNew)
        {
            caseQuery += '\'' + incident.Id + '\',';
        }
        caseQuery = caseQuery.substring(0, caseQuery.length() - 1) + ')';
        
        System.debug('case query = ' + caseQuery);
        List<Case>  cases = Database.query(caseQuery);
        for (Case ticket: cases)
        {
            incidentToCaseMap.put(ticket.Incident__c, ticket);
        }
        
        Map<Id, String> statusMap = new Map<Id, String>();
        for (BMCServiceDesk__Status__c status: [SELECT Name FROM BMCServiceDesk__Status__c WHERE BMCServiceDesk__appliesToIncident__c = true])
        {
            statusMap.put(status.Id, status.Name);
        }
        
        Set<Id> incidentIds = new Set<Id>();
        Id serviceRequestType = IGT_DatabaseUtility.getRecordTypeId('Case', IGT_Constants.CASE_SERVICE_REQUEST_RTYPE);
        List<Case> newCases = new List<Case>();
        List<Case> updCases = new List<Case>();
        for (BMCServiceDesk__Incident__c incident: triggerNew)
        {
            System.debug('incident type = ' + incident.Type__c);
            Case ticket = incidentToCaseMap.get(incident.Id);
            
            if (ticket == null && incident.Ticket__c == null && incident.BMCServiceDesk__FKAccount__c != null)
            {
                ticket = new Case(Incident__c = Incident.Id, RecordTypeId = serviceRequestType, Type = IGT_Constants.CASE_SERVICE_REQUEST_RTYPE);
                incidentToCaseMap.put(incident.Id, ticket);
                newCases.add(ticket);
                incidentIds.add(incident.Id);
            } else if (ticket == null)
            {
                continue;
            }
            
            boolean hasChanges = doCaseFromIncidentSync(ticket, incident, cimList, statusMap, incidentMap, rTypeMap);
            
            if (hasChanges)
            {
                updCases.add(ticket);
            }
        }
        
        if (updCases.size() > 0)
        {
            upsert updCases;
            system.debug('updCases.......'+updCases);
        } else
        {
            IGT_TriggerUtility.testing = false;
        }
        if (newCases.size() > 0)
        {
            List<BMCServiceDesk__Incident__c> createdCaseIncidents = new List<BMCServiceDesk__Incident__c>();
            for (Case ticket: newCases)
            {
                createdCaseIncidents.add(new BMCServiceDesk__Incident__c(Id = ticket.Incident__c, Ticket__c = ticket.Id));
            }
            update createdCaseIncidents;
        }
    }
    
    private static boolean doCaseFromIncidentSync(Case ticket, BMCServiceDesk__Incident__c incident, List<IGT_CaseIncidentMapping__c> cimList,
        Map<Id, String> statusMap, Map<Id, BMCServiceDesk__Incident__c> incidentMap, Map<String, String> rTypeMap)
    {
        boolean hasChanges = false;
        
        String rType = rTypeMap.get(incident.RecordTypeId);
        String caseRType = rTypeMap.get(rType);
        System.debug('rTypeMap = ' + rTypeMap);
        System.debug('rType = ' + rType);
        if (caseRType != null && caseRType != ticket.RecordTypeId)
        {
            hasChanges = true;
            system.debug('hasChanges..1'+hasChanges);
            ticket.Type = rType;
            ticket.RecordTypeId = caseRType;
        }
        System.debug('cimlist = ' + cimList);
        for(IGT_CaseIncidentMapping__c cim: cimList)
        {
            if(cim.Active__c)
            {
                System.debug('fieldwwwwwwwwwww = ' + cim.Incident_Lookup_Field__c);
                System.debug('lookup type = ' + cim.Incident_Lookup_Type__c);
                System.debug('incident field = ' + cim.Incident_FIeld__c);
                System.debug('case field = ' + cim.Case_Field__c);
                if (cim.Incident_Lookup_Field__c != null && cim.Incident_Lookup_Field__c != 'Name')
                {
                    BMCServiceDesk__Incident__c qIncident = incidentMap.get(incident.Id);
                    if (qIncident.BMCServiceDesk__FKIncident__r.Ticket__c != null && ticket.get(cim.Case_Field__c) != qIncident.BMCServiceDesk__FKIncident__r.Ticket__c)
                    {
                        hasChanges = true;
                        system.debug('hasChanges..2'+hasChanges);
                        ticket.put(cim.Case_Field__c, qIncident.BMCServiceDesk__FKIncident__r.Ticket__c);
                    } else if (qIncident.BMCServiceDesk__FKIncident__c == null && ticket.get(cim.Case_Field__c) != null)
                    {
                        hasChanges = true;
                        system.debug('hasChanges..3'+hasChanges);
                        ticket.put(cim.Case_Field__c, null);
                    }
                } else if(cim.Incident_Lookup_Type__c != 'Lookup')
                {
                    System.debug('cfieldn = ' + cim.Incident_Field__c);
                    System.debug('incident = ' + incident);
                        System.debug('incident oval = ' + incident.get(cim.Incident_Field__c));
                        System.debug('ticket oval = ' + ticket.get(cim.Case_Field__c));
                    if (incident.get(cim.Incident_Field__c) != ticket.get(cim.Case_Field__c))
                    {
                        
                        hasChanges = true;
                        system.debug('hasChanges..4'+hasChanges);
                        if (cim.Case_Field__c == 'Type')
                        {
                            if (incident.get(cim.Incident_Field__c) == 'Incident')
                            {
                                ticket.put(cim.Case_Field__c, 'Systems');
                            } else
                            {
                                ticket.put(cim.Case_Field__c, incident.get(cim.Incident_Field__c));
                            }
                        } else
                        {
                            ticket.put(cim.Case_Field__c, incident.get(cim.Incident_Field__c));
                        }
                    }
                } else if(cim.Incident_Lookup_Table__c == 'BMCServiceDesk__Status__c' && 
                    statusMap.get(String.valueOf(incident.get(cim.Incident_Field__c))) != null)
                {
                    System.debug('incident field = ' + cim.Incident_Field__c);
                    System.debug('old ticket val = ' + ticket.get(cim.Case_Field__c));
                    System.debug('incident val = ' + incident.get(cim.Incident_Field__c));
                    System.debug('status map return = ' + (statusMap.get(String.valueOf(incident.get(cim.Incident_Field__c)))));
                    if (statusMap.get(String.valueOf(incident.get(cim.Incident_Field__c))) != ticket.get(cim.Case_Field__c))
                    {
                        hasChanges = true;
                        system.debug('hasChanges..5'+hasChanges);
                        ticket.put(cim.Case_Field__c, statusMap.get(String.valueOf(incident.get(cim.Incident_Field__c))));
                    }
                }
            }
        }
        
        return hasChanges;
    }
    
    public static void syncIncidentFromCase(List<Case> systemsCases)
    {
        if (IGT_TriggerUtility.hasHitCaseUpdate)
        {
            if (IGT_TriggerUtility.hasSyncedCase)
                return;
            IGT_TriggerUtility.hasSyncedCase = true;
        }
        
        Map<Id, BMCServiceDesk__Incident__c> caseToIncidentMap = new Map<Id, BMCServiceDesk__Incident__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>(
            [SELECT ParentId, Parent.Incident__c FROM Case 
              WHERE Id IN :systemsCases]);
        
        Map<String, IGT_CaseIncidentMapping__c> cimMap = IGT_CaseIncidentMapping__c.getAll();
        List<IGT_CaseIncidentMapping__c> cimList = cimMap.values();
        
        Map<String, String> rTypeMap = new Map<String, String>();
        for (RecordType rType: 
            [SELECT Name, SObjectType FROM RecordType 
              WHERE SObjectType = 'Case' OR SObjectType = 'BMCServiceDesk__Incident__c'])
        {
            if (rType.SObjectType == 'Case')
                rTypeMap.put(rType.Id, rType.Name);
            else
                rTypeMap.put(rType.Name, rType.Id);
        }
        
        String incidentQuery = 'SELECT Ticket__c, RecordTypeId';
        for (IGT_CaseIncidentMapping__c mapping: cimList)
        {
            if (mapping.Active__c)
            {
                if (mapping.Incident_Lookup_Field__c != null && mapping.Incident_Lookup_Field__c != 'Name')
                {
                    incidentQuery += ', ' + mapping.Incident_Lookup_Field__c;
                } else
                {
                    incidentQuery += ', ' + mapping.Incident_Field__c;
                }
            }
        }
        
        incidentQuery += ' FROM BMCServiceDesk__Incident__c WHERE Ticket__c IN (';
        for (Case sCase: systemsCases)
        {
            incidentQuery += '\'' + sCase.Id + '\',';
        }
        incidentQuery = incidentQuery.substring(0, incidentQuery.length() - 1) + ')';
        
        List<BMCServiceDesk__Incident__c>  incidents = Database.query(incidentQuery);
        for (BMCServiceDesk__Incident__c incident: incidents)
        {
            caseToIncidentMap.put(incident.Ticket__c, incident);
        }
        
        Map<String, Id> statusMap = new Map<String, Id>();
        for (BMCServiceDesk__Status__c status: [SELECT Name FROM BMCServiceDesk__Status__c WHERE BMCServiceDesk__appliesToIncident__c = true])
        {
            statusMap.put(status.Name, status.Id);
        }
        
        List<BMCServiceDesk__Incident__c> updIncidents = new List<BMCServiceDesk__Incident__c>();
        for (Case ticket: systemsCases)
        {
            BMCServiceDesk__Incident__c incident = caseToIncidentMap.get(ticket.Id);
            if (incident == null && ticket.Incident__c == null)
            {
                System.debug('sync ticket type = ' + ticket.Type);
                incident = new BMCServiceDesk__Incident__c(Ticket__c = ticket.Id);
                caseToIncidentMap.put(ticket.Id, incident);
            } else if (incident == null && ticket.Incident__c != null)
            {
                continue;
            }
            
            boolean hasChanges = doIncidentFromCaseSync(ticket, incident, cimList, statusMap, caseMap, rTypeMap);
            
            if (hasChanges || incident.Id == null)
            {
                updIncidents.add(incident);
            }
        }
        
        upsert updIncidents;
        system.debug('updIncidents....'+updIncidents);
    }
    
    private static boolean doIncidentFromCaseSync(Case ticket, BMCServiceDesk__Incident__c incident, List<IGT_CaseIncidentMapping__c> cimList,
        Map<String, Id> statusMap, Map<Id, Case> caseMap, Map<String, String> rTypeMap)
    {
        boolean hasChanges = false;
        
        String rType = rTypeMap.get(ticket.RecordTypeId);
        String incidentRType = rTypeMap.get(rType);
        System.debug('rTypeMap = ' + rTypeMap);
        System.debug('incidentRType = ' + incidentRType);
        System.debug('rType = ' + rType);
        System.debug('incident.RecordTypeId = ' + incident.RecordTypeId);
        if (incidentRType != null && incidentRType != incident.RecordTypeId)
        {
            hasChanges = true;
            
            incident.RecordTypeId = incidentRType;
        }
        System.debug('cimList = ' + cimList);
        for(IGT_CaseIncidentMapping__c cim: cimList)
        {
            if(cim.Active__c)
            {
                //String cField = ticket.get(cim.Case_Field__c);
                if (cim.Incident_Lookup_Field__c != null && cim.Incident_Lookup_Field__c != 'Name')
                {
                    Case qCase = caseMap.get(ticket.Id);
                    if (qCase.Parent.Incident__c != null && incident.get(cim.Incident_Field__c) != qCase.Parent.Incident__c)
                    {
                        hasChanges = true;
                        incident.put(cim.Incident_Field__c, qCase.Parent.Incident__c);
                    } else if (qCase.ParentId == null && incident.get(cim.Incident_Field__c) != null)
                    {
                        hasChanges = true;
                        incident.put(cim.Incident_Field__c, null);
                    }
                } else if(cim.Incident_Lookup_Type__c != 'Lookup')
                {
                    System.debug('incident field = ' + cim.Incident_Field__c);
                    System.debug('case field = ' + cim.Case_Field__c);
                    if (incident.get(cim.Incident_Field__c) != ticket.get(cim.Case_Field__c))
                    {
                        System.debug('incidnet to case');
                        System.debug('inc val = ' + incident.get(cim.Incident_Field__c));
                        System.debug('ticket val = ' + ticket.get(cim.Case_Field__c));
                        hasChanges = true;
                        incident.put(cim.Incident_Field__c, ticket.get(cim.Case_Field__c));
                    }
                } else if (cim.Incident_Lookup_Table__c == 'BMCServiceDesk__Status__c')
                {
                    if (statusMap.get(String.valueOf(ticket.get(cim.Case_Field__c))) != incident.get(cim.Incident_Field__c))
                    {
                        hasChanges = true;
                        incident.put(cim.Incident_Field__c, statusMap.get(String.valueOf(ticket.get(cim.Case_Field__c))));
                    }
                }
            }
        }
        
        return hasChanges;
    }
    
    public static void deLinkIncident(List<Case> unlinkingCases, Set<Id> incidentIds)
    {
        for (Case ticket: unlinkingCases)
        {
            ticket.Incident__c = null;
        }
        
        removeCaseReference(incidentIds);
    }
    
    @future
    public static void removeCaseReference(Set<Id> incidentIds)
    {
        List<BMCServiceDesk__Incident__c> incidents = [SELECT IGT_Status__c FROM BMCServiceDesk__Incident__c WHERE Id IN :incidentIds];
        for (BMCServiceDesk__Incident__c incident: incidents)
        {
            
            incident.Ticket__c = null;
        }
        
        update incidents;
        for (BMCServiceDesk__Incident__c incident: incidents)
        {
            
            incident.IGT_Status__c = IGT_Constants.INCIDENT_ERROR_STATUS;
        }
        
        update incidents;
        System.debug('incidentIds = ' + incidentIds);
    }
}