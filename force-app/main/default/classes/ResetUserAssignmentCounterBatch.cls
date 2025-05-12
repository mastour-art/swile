public class ResetUserAssignmentCounterBatch implements Database.Batchable<SObject>, Database.Stateful {
    //écupérer tous les utilisateurs dont le compteur != 0
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Assignment_Counter__c FROM User WHERE Assignment_Counter__c != 0 AND Assignment_Counter__c != NULL'
        );
    }

    //remettre à zéro pour chaque lot
    public void execute(Database.BatchableContext bc, List<User> scope) {
        for (User u : scope) {
            u.Assignment_Counter__c = 0;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}