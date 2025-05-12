@isTest
private class TeamMemberControllerTest {
    
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
        User uSales2 = new User(
            Username = 'testusersales456@swile.com',
        Email = 'testusersales2@swile.com',
        LastName = 'Sales2',
        Alias = 'sls2',
        TimeZoneSidKey = 'Europe/Paris',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id,
        IsActive = true
            );
        users.add(uSales2);
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
        Commercial_Team_User_Association__c assocSales2 = new Commercial_Team_User_Association__c(
            Commercial_Team__c = teamSales.Id,
        User__c = uSales2.Id
            );
        assocs.add(assocSales2);
        insert assocs;
    }
    
    static testMethod void testGetAndUpdatePresence() {
        
        User uMg = [SELECT Id FROM User WHERE Alias = 'mng1' LIMIT 1];
        User usl1 = [SELECT Id FROM User WHERE Alias = 'sls1' LIMIT 1];
        User usl2 = [SELECT Id FROM User WHERE Alias = 'sls2' LIMIT 1];
        usl1.is_absent__c = true;
        update usl1;
        
        Test.startTest();
        System.runAs(uMg) {
            List<User> team = TeamMemberController.getMyTeamMembers();
            System.assertEquals(team.size(), 2);
            
            TeamMemberController.updateUserPresence(new List<Id>{usl1.Id}, false);
            TeamMemberController.updateUserPresence(new List<Id>{usl2.Id}, true);
        }
        Test.stopTest();
        
        System.assertEquals([SELECT Id, is_absent__c FROM User WHERE Alias = 'sls1' LIMIT 1].is_absent__c, false);
        System.AssertEquals([SELECT Id, is_absent__c FROM User WHERE Alias = 'sls2' LIMIT 1].is_absent__c, true);
    }
}