public with sharing class LeadActions {
    public static void assignLeads(List<Lead> newLeads) {
        // Collecte les clés composites
        Set<String> keys = new Set<String>();
        for (Lead ld : newLeads) {
            keys.add(ld.Composite_Key__c);
        }

        // Récupération des associations
        Map<String, List<Commercial_Team_User_Association__c>> assocsByKey =
            TeamAssignmentService.getAssociationsByKey(keys);

        List<Lead> leadsToUpdate = new List<Lead>();
        List<User> usersToUpdate = new List<User>();

        for (Lead ld : newLeads) {
            Commercial_Team_User_Association__c assoc =
                TeamAssignmentService.selectNextAssociation(
                    assocsByKey.get(ld.Composite_Key__c)
                );
            if (assoc != null) {
                // Créer une copie du lead avec les modifications nécessaires
                Lead updatedLead = new Lead(
                    Id = ld.Id,
                    OwnerId = assoc.User__c
                );
                leadsToUpdate.add(updatedLead);

                // Préparer la mise à jour du compteur sur User
                usersToUpdate.add(
                    new User(
                        Id = assoc.User__c,
                        Assignment_Counter__c = assoc.Assignment_Counter__c + 1
                    )
                );
            }
        }

        // DML bulkifiés
        if (!leadsToUpdate.isEmpty()) update leadsToUpdate;
        if (!usersToUpdate.isEmpty()) update usersToUpdate;
    }
}