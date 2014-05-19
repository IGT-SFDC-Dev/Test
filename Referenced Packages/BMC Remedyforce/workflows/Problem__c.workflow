<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_the_ShowDueDateDialog_Field</fullName>
        <field>ShowDueDateDialog__c</field>
        <literalValue>1</literalValue>
        <name>Update the ShowDueDateDialog Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Open popup dialog for recalculating due date when priority of problem changes</fullName>
        <actions>
            <name>Update_the_ShowDueDateDialog_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This rule has been deprecated. If the rule is active, deactivate it.</description>
        <formula>ISCHANGED( FKPriority__c ) &amp;&amp; IF( ShowDueDateDialog__c  = false, true, false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
