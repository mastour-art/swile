public with sharing class OpportunityReassignController {
    private final ApexPages.StandardController stdController;
    private Opportunity currentOpportunity;

    public OpportunityReassignController(ApexPages.StandardController controller) {
        this.stdController = controller;
        // Inclure le champ Composite_Key__c
        stdController.addFields(new List<String>{'Composite_Key__c'});
        this.currentOpportunity = (Opportunity) stdController.getRecord();
    }

    public PageReference assignOpportunities() {
        OpportunityActions.assignOpportunities(new List<Opportunity>{currentOpportunity});
        return new PageReference('/' + currentOpportunity.Id);
    }
}
