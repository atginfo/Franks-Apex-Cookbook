//1
public with sharing class LeadGenerator {
    
    //2
    private static List<Lead> createLeads(Map<String, List<String>> possibleLeadsMap) {
        
        List<Lead> leadsToInsert = new List<Lead>();
        for (String name : possibleLeadsMap.keySet()) {
            
            List<String> detailsList = possibleLeadsMap.get(name);
            //Seperating String to have first name and last name
            String firstName = name.split(' ')[0];
            String lastName = name.split(' ')[1];

            Lead newLead = new Lead();
            newLead.FirstName = firstName;
            newLead.LastName = lastName;
            newLead.Company = detailsList[0];
            newLead.Title = detailsList[1];
            newLead.Email = detailsList[2];
            newLead.Rating = detailsList[3];
            newLead.Industry = detailsList[4];

            leadsToInsert.add(newLead);
        }

        if(!leadsToInsert.isEmpty()) {
            insert leadsToInsert;
        }

        return leadsToInsert;

    }
    
    //3
    private static List<Account> createAccounts(List<Lead> leadList) {

        List<Account> accToInsert = new List<Account>();
        
        for (Lead l : leadList) {

            if (l.Rating == 'Warm' || l.Rating == 'Hot') {

                Account leadToAccount = new Account();
                leadToAccount.Name = l.Company;
                leadToAccount.Industry = l.Industry;

                accToInsert.add(leadToAccount);
            }
        }

        if (!accToInsert.isEmpty()){
            insert accToInsert;
        }
        
        return accToInsert;
    }

    //4
    public static void startProcess(Map<String, List<String>> possibleLeadsMap) {
        
        List<Lead> newLeads = createLeads(possibleLeadsMap);
        System.debug('Leads List: ' + newLeads.size());

        List<Account> newAccounts = createAccounts(newLeads);
        System.debug('Account List: ' + newAccounts.size());

    }
}