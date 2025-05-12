public with sharing class LeadTriggerHandler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI = false;
    
    public LeadTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(List<Lead> newLead)
    {
        system.debug('Lead Trigger On Before Insert');
    }
    public void OnAfterInsert(List<Lead> newLead)
    {
        system.debug('Lead Trigger On After Insert');
        LeadActions.assignLeads(newLead);
    }
    public void OnAfterUpdate( List<Lead> newLead, List<Lead> oldLead, Map<ID, Lead> newLeadMap , Map<ID, Lead> oldLeadMap )
    {
        system.debug('Lead Trigger On After Update ');
    }
    public void OnBeforeUpdate( List<Lead> newLead, List<Lead> oldLead, Map<ID, Lead> newLeadMap , Map<ID, Lead> oldLeadMap )
    {
        system.debug('Lead Trigger On Before Update ');
    }
    
    @future
    public static void OnAfterUpdateAsync(Set<ID> newLeadIDs)
    {
        
    }
    public boolean IsTriggerContext
    {
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext
    {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext
    {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext
    {
        get{ return !IsTriggerContext;}
    }
}