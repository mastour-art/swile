public with sharing class LeadReassignController {
    private final ApexPages.StandardController stdController;
    private Lead currentLead;

    public LeadReassignController(ApexPages.StandardController controller) {
        this.stdController = controller;
        // Inclure le champ Composite_Key__c
        stdController.addFields(new List<String>{'Composite_Key__c','OwnerId'});
        this.currentLead = (Lead) stdController.getRecord();
    }

    public PageReference assignLeads() {
        LeadActions.assignLeads(new List<Lead>{currentLead});
        return new PageReference('/' + currentLead.Id);
    }
}
