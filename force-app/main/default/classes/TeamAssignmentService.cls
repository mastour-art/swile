public with sharing class TeamAssignmentService {
    /**
     * Charge les associations Sales non absentes,
     * groupées par clé, triées sur Assignment_Counter__c.
     */
    public static Map<String, List<Commercial_Team_User_Association__c>>
        getAssociationsByKey(Set<String> keys) {

        Id salesRtId = Schema.SObjectType.Commercial_Team__c
            .getRecordTypeInfosByDeveloperName()
            .get('sales_team')
            .getRecordTypeId();

        // récupérer toutes les associations Sales
        List<Commercial_Team_User_Association__c> assocs = [
            SELECT Team_Composite_Key__c, User__c, Assignment_Counter__c
            FROM Commercial_Team_User_Association__c
            WHERE Team_Composite_Key__c IN :keys
              AND Commercial_Team__r.RecordTypeId = :salesRtId
              AND Is_Absent__c = FALSE
            ORDER BY Assignment_Counter__c ASC
        ];
        // grouper les résultats par clé
        Map<String, List<Commercial_Team_User_Association__c>> mapKeyToAssocs = 
            new Map<String, List<Commercial_Team_User_Association__c>>();
        for (Commercial_Team_User_Association__c a : assocs) {
            if (!mapKeyToAssocs.containsKey(a.Team_Composite_Key__c)) {
                mapKeyToAssocs.put(a.Team_Composite_Key__c, 
                    new List<Commercial_Team_User_Association__c>());
            }
            mapKeyToAssocs.get(a.Team_Composite_Key__c).add(a);
        }
        return mapKeyToAssocs;
    }

    /** 
     *  selectioner la nouvelle asso en retirant en tête et remettre dans la file (cyclique)
     */
    public static Commercial_Team_User_Association__c
        selectNextAssociation(List<Commercial_Team_User_Association__c> listAssocs) {
        if (listAssocs == null || listAssocs.isEmpty()) return null;
        Commercial_Team_User_Association__c chosen = listAssocs.remove(0);
        listAssocs.add(chosen);
        return chosen;
    }
}
