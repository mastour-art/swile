@isTest
private class LeadReassignControllerTest {
    @isTest
    static void testAssignLeads() {
        // Création d'un Lead de test
        Lead testLead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            country_code__c = 'FR',
            product_interest__c = 'Gift',
            employee_range__c = '1 - 100'
        );
        insert testLead;

        // Initialisation du contrôleur standard
        ApexPages.StandardController sc = new ApexPages.StandardController(testLead);
        LeadReassignController controller = new LeadReassignController(sc);

        // Exécution de la méthode assignLeads
        Test.startTest();
        PageReference result = controller.assignLeads();
        Test.stopTest();

        // Vérification du résultat
        System.assertNotEquals(null, result, 'La PageReference ne doit pas être nulle');
        System.assert(result.getUrl().contains(testLead.Id), 'L\'URL doit contenir l\'ID du Lead');
    }
}
