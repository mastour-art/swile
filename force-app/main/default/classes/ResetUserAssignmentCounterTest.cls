@isTest
private class ResetUserAssignmentCounterTest {
    @testSetup
    static void setupData() {
        // Créer un utilisateur de test
        Profile p = [SELECT Id FROM Profile WHERE Name='Utilisateur standard' LIMIT 1];
        User u = new User(
            Alias = 'tuser',
            Email = 'test.user@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'fr',
            LocaleSidKey = 'fr_FR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Paris',
            UserName = 'test.user' + DateTime.now().getTime() + '@example.com',
            Assignment_Counter__c = 5
        );
        insert u;
    }

    static testMethod void testBatchAndScheduler() {
        // Récupérer l'utilisateur de test, vérifier compteur diff de 0
        User u = [SELECT Id, Assignment_Counter__c FROM User WHERE Alias='tuser' LIMIT 1];
        System.assertEquals(5, u.Assignment_Counter__c);

        // Lancer le batch directement
        Test.startTest();
            ID batchId = Database.executeBatch(new ResetUserAssignmentCounterBatch(), 50);
        Test.stopTest();

        // Vérifier que le compteur est à 0
        u = [SELECT Assignment_Counter__c FROM User WHERE Id = :u.Id];
        System.assertEquals(0, u.Assignment_Counter__c);
    }
}
