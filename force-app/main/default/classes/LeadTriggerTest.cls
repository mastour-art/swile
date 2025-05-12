@isTest
private class LeadTriggerTest {
    
    @testSetup
    static void setupData() {
        // Create Users
        Profile p = [SELECT Id FROM Profile WHERE Name='Utilisateur standard' LIMIT 1];
        List<User> users = new List<User>();
        User uManager = new User(
            Username = 'testusermanager123@swile.com',
        Email = 'testusermanager@swile.com',
        LastName = 'Manager',
        Alias = 'mng1',
        TimeZoneSidKey = 'Europe/Paris',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id,
        IsActive = true
            );
        users.add(uManager);
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
        IsActive = true
            );
        users.add(uSales1);
        insert users;
        
        // Create RecordTypes for Commercial Team
        RecordType rtSales = [SELECT Id FROM RecordType WHERE SObjectType='Commercial_Team__c' AND DeveloperName='sales_team' LIMIT 1];
        RecordType rtManager = [SELECT Id FROM RecordType WHERE SObjectType='Commercial_Team__c' AND DeveloperName='manager_team' LIMIT 1];
        
        // Create a Manager Team
        Commercial_Team__c teamManager = new Commercial_Team__c(
            Name = 'FR-Manager-(1-100)',
        RecordTypeId = rtManager.Id,
        country_code__c = 'FR',
        employee_range__c = '1 - 100'
            );
        insert teamManager;
        
        // Create a Commercial Team
        Commercial_Team__c teamSales = new Commercial_Team__c(
            Name = 'FR-(1-100)-Meal Voucher',
        RecordTypeId = rtSales.Id,
        manager_team__c = teamManager.Id,
        country_code__c = 'FR',
        employee_range__c = '1 - 100',
        product_interest__c = 'Meal Voucher'
            );
        insert teamSales;
        
        // Associate user to team
        List<Commercial_Team_User_Association__c> assocs = new List<Commercial_Team_User_Association__c>();
        Commercial_Team_User_Association__c assocManager = new Commercial_Team_User_Association__c(
            Commercial_Team__c = teamManager.Id,
        User__c = uManager.Id
            );
        assocs.add(assocManager);
        Commercial_Team_User_Association__c assocSales1 = new Commercial_Team_User_Association__c(
            Commercial_Team__c = teamSales.Id,
        User__c = uSales1.Id
            );
        assocs.add(assocSales1);
        insert assocs;
    }
    
    static testMethod void testLeadAssignment() {
        test.startTest();
        Lead l = new Lead(
            FirstName = 'Marc',
        country_code__c = 'FR',
        LastName = 'Spector',
        Company = 'Spector Group',
        LeadSource = 'Marketing',
        Product_Interest__c = 'Meal Voucher',
        employee_range__c = '1 - 100'
            );
        
        insert l;
        test.stopTest();

        User uSlaes = [SELECT Id FROM User WHERE Alias = 'sls1'];
        Lead leadAssigned = [SELECT Id, OwnerId FROM Lead WHERE Id = :l.Id];
        System.assertEquals(leadAssigned.OwnerId, uSlaes.Id);
    }
}