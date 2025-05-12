public with sharing class LeadActionsController {

    @AuraEnabled
    public static void reassignLeads(List<Id> leadIds) {
        // Récupérer les leads en fonction des IDs passés en paramètre
        List<Lead> leadsToReassign = [SELECT Id, Composite_Key__c FROM Lead WHERE Id IN :leadIds];

        // Appeler la méthode assignLeads avec les leads récupérés
        if (!leadsToReassign.isEmpty()) {
            LeadActions.assignLeads(leadsToReassign);
        }
    }
}
