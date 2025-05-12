@isTest
private class ResetUserAssignmentCounterBatchTest {
    
    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Utilisateur standard' LIMIT 1];
        
        User uSales1 = new User(
            Username = 'testusersales123@swile.com',
        Email = 'testusersales1@swile.com',
        LastName = 'Sales1',
        Alias = 'sls1',
        TimeZoneSidKey = 'Europe/Paris',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id,
        Assignment_Counter__c = 5,
        IsActive = true
            );
        
        insert uSales1;
    }
    
    static testMethod void testBatchResetCounter() {
        System.assertEquals([SELECT Id, Assignment_Counter__c FROM User WHERE Alias = 'sls1'].Assignment_Counter__c, 5);

        Test.startTest();
        ResetUserAssignmentCounterBatch batch = new ResetUserAssignmentCounterBatch();
        ID batchJobId = Database.executeBatch(batch);
        Test.stopTest();

        System.assertEquals([SELECT Id, Assignment_Counter__c FROM User WHERE Alias = 'sls1'].Assignment_Counter__c, 0);
    }
    
}