public with sharing class OpportunityActions {
    public static void assignOpportunities(List<Opportunity> newOpportunities) {
        // Collecte les clés composites
        Set<String> keys = new Set<String>();
        for (Opportunity opp : newOpportunities) {
            keys.add(opp.Composite_Key__c);
        }

        // Récupération les associations
        Map<String, List<Commercial_Team_User_Association__c>> assocsByKey =
            TeamAssignmentService.getAssociationsByKey(keys);

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<User> usersToUpdate = new List<User>();

        for (Opportunity opp : newOpportunities) {
            Commercial_Team_User_Association__c assoc =
                TeamAssignmentService.selectNextAssociation(
                    assocsByKey.get(opp.Composite_Key__c)
                );
            if (assoc != null && opp.OwnerId != assoc.User__c) {
                // Créer une copie de l'opportunité avec les modifications nécessaires
                Opportunity updatedOpp = new Opportunity(
                    Id = opp.Id,
                    OwnerId = assoc.User__c
                );
                oppsToUpdate.add(updatedOpp);

                // Prépare la mise à jour du compteur sur User
                usersToUpdate.add(
                    new User(
                        Id = assoc.User__c,
                        Assignment_Counter__c = assoc.Assignment_Counter__c + 1
                    )
                );
            }
        }

        // DML bulkifiés
        if (!oppsToUpdate.isEmpty()) update oppsToUpdate;
        if (!usersToUpdate.isEmpty()) update usersToUpdate;
    }
}