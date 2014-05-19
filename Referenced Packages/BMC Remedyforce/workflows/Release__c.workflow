<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notifies_the_Owner_on_Status_Change</fullName>
        <description>Notifies the Owner on Status Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SDE_Emails/ReleaseStatusNotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_owner_on_release_status_change</fullName>
        <description>Notify owner on release status change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FKReleaseCoordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SDE_Emails/Notify_owner_on_release_status_change</template>
    </alerts>
    <alerts>
        <fullName>Notify_owner_when_the_status_is_marked_as_failed</fullName>
        <description>Notify owner when the status is marked as failed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SDE_Emails/Release_is_marked_as_Failed</template>
    </alerts>
    <alerts>
        <fullName>Notify_the_owner_on_new_release_creation</fullName>
        <description>Notify the owner on new release creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FKReleaseCoordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SDE_Emails/Notify_owner_on_new_release_creation</template>
    </alerts>
    <rules>
        <fullName>Notify the Owner when a Release is marked as Failed</fullName>
        <actions>
            <name>Notify_owner_when_the_status_is_marked_as_failed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Release__c.Release_Failed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notify the Owner when a Release is marked as Failed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify the owner on new release creation</fullName>
        <actions>
            <name>Notify_the_owner_on_new_release_creation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify owner on new release creation</description>
        <formula>(State__c = True)  ||  (State__c = False)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify the owner on release status change</fullName>
        <actions>
            <name>Notify_owner_on_release_status_change</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify owner on release status change</description>
        <formula>ISCHANGED( FKStatus__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
