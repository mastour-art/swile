//without sharing, pour permettre aux managers de modifier l'enregistrement utilisateur
public without sharing class TeamMemberController {

    @AuraEnabled(cacheable=true)
    public static List<User> getMyTeamMembers() {
        Id currentUserId = UserInfo.getUserId();

        // Récupérer les RecordTypeIds
        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.SObjectType.Commercial_Team__c.getRecordTypeInfosByDeveloperName();
        Id rtManager = rtMap.get('manager_team').getRecordTypeId();
        Id rtSales   = rtMap.get('sales_team').getRecordTypeId();

        // 1) Équipes Manager où le users est associé
        List<Id> managerTeamIds = new List<Id>();
        for (Commercial_Team_User_Association__c assoc 
             : [SELECT Commercial_Team__c
                FROM Commercial_Team_User_Association__c
                WHERE User__c = :currentUserId
                  AND Commercial_Team__r.RecordTypeId = :rtManager]) {
            managerTeamIds.add(assoc.Commercial_Team__c);
        }
        if (managerTeamIds.isEmpty()) {
            return new List<User>();
        }

        // 2) Équipes Sales rattachées à ces Équipes Manager
        List<Id> salesTeamIds = new List<Id>();
        for (Commercial_Team__c team 
             : [SELECT Id
                FROM Commercial_Team__c
                WHERE RecordTypeId = :rtSales
                  AND Manager_Team__c IN :managerTeamIds]) {
            salesTeamIds.add(team.Id);
        }
        if (salesTeamIds.isEmpty()) {
            return new List<User>();
        }

        // 3) Users actifs de ces Sales Teams
        return [
            SELECT Id, Name, is_absent__c, assignment_counter__c
            FROM User
            WHERE IsActive = TRUE
              AND Id IN (
                  SELECT user__c
                  FROM Commercial_Team_User_Association__c
                  WHERE Commercial_Team__c IN :salesTeamIds
              )
        ];
    }

    @AuraEnabled
    public static void updateUserPresence(List<Id> userIds, Boolean isAbsent) {
        try {
            Map<Id, User> userUpdatesMap = new Map<Id, User>();

            // 1) Charger uniquement les users à modifier
            for (User u : [SELECT Id, Is_Absent__c FROM User WHERE Id IN :userIds]) {
                if (u.Is_Absent__c != isAbsent) {
                    u.Is_Absent__c = isAbsent;
                    userUpdatesMap.put(u.Id, u);
                }
            }

            // 2) Si passage à présent, réaligner le compteur
            if (!isAbsent && !userUpdatesMap.isEmpty()) {
                Map<Id, List<Id>> userToTeams = new Map<Id, List<Id>>();
                for (Commercial_Team_User_Association__c assoc :
                    [SELECT User__c, Commercial_Team__c
                    FROM Commercial_Team_User_Association__c
                    WHERE User__c IN :userUpdatesMap.keySet()]) {

                    // Vérification si la clé existe et ajout si non
                    if (!userToTeams.containsKey(assoc.User__c)) {
                        userToTeams.put(assoc.User__c, new List<Id>());
                    }
                    userToTeams.get(assoc.User__c).add(assoc.Commercial_Team__c);
                }

                // 3) Réaligner le compteur pour chaque utilisateur
                for (Id userId : userToTeams.keySet()) {
                    AggregateResult ar = [
                        SELECT MAX(Assignment_Counter__c) maxCnt
                        FROM User
                        WHERE Id IN (
                            SELECT User__c
                            FROM Commercial_Team_User_Association__c
                            WHERE Commercial_Team__c IN :userToTeams.get(userId)
                        )
                    ];
                    Decimal maxVal = (Decimal) ar.get('maxCnt');
                    if (maxVal != null) {
                        userUpdatesMap.get(userId).Assignment_Counter__c = maxVal.intValue();
                    }
                }
            }

            if (!userUpdatesMap.isEmpty()) {
                update userUpdatesMap.values();
            }

        } catch (Exception e) {
            throw new AuraHandledException(
                'Erreur lors de la mise à jour de la présence : ' + e.getMessage()
            );
        }
    }
}