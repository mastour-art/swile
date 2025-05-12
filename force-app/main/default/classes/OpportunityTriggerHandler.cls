public with sharing class OpportunityTriggerHandler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI = false;
    
    public OpportunityTriggerHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    public void OnBeforeInsert(List<Opportunity> newOpportunity)
    {
        system.debug('Opportunity Trigger On Before Insert');
    }
    public void OnAfterInsert(List<Opportunity> newOpportunity)
    {
        system.debug('Opportunity Trigger On After Insert');
        OpportunityActions.assignOpportunities(newOpportunity);
    }
    public void OnAfterUpdate( List<Opportunity> newOpportunity, List<Opportunity> oldOpportunity, Map<ID, Opportunity> newOpportunityMap , Map<ID, Opportunity> oldOpportunityMap )
    {
        system.debug('Opportunity Trigger On After Update ');
    }
    public void OnBeforeUpdate( List<Opportunity> newOpportunity, List<Opportunity> oldOpportunity, Map<ID, Opportunity> newOpportunityMap , Map<ID, Opportunity> oldOpportunityMap )
    {
        system.debug('Opportunity Trigger On Before Update ');
    }
    
    @future
    public static void OnAfterUpdateAsync(Set<ID> newOpportunityIDs)
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