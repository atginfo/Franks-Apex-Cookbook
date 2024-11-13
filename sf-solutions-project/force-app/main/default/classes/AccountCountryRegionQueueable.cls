public with sharing class AccountCountryRegionQueueable implements Queueable{

    private List<Account> parentAccountList;
    private Map<String, List<String>> countryBySubRegionMap = new Map<String, List<String>>();

    //Assigning our parentAccount List and our Map which consists of each Subregion to their Countries
    public AccountCountryRegionQueueable(List<Account> parentAccountList) {
        this.parentAccountList = parentAccountList;
        countryBySubRegionMap.put('Southeast Asia', new List<String>{'India'});
        countryBySubRegionMap.put('Africa', new List<String>{'Kenya'});
        countryBySubRegionMap.put('South America', new List<String>{'Argentina','Chile'});

    }

    public void execute(QueueableContext qc) {
        
        List<Account> countryAccToInsert = new List<Account>();

        //Double for loop used to save code space and efficiently add Child Accounts for each Country
        for (Account acc : parentAccountList) {

            if (countryBySubRegionMap.containsKey(acc.Subregion__c)) {
                
                for (String country : countryBySubRegionMap.get(acc.Subregion__c)) {

                    Account countryAcc = new Account();
                    countryAcc.ParentId = acc.Id;
                    countryAcc.Name = acc.Name + ' ' + country;
                    countryAcc.Region_Country__c = country;
                    countryAccToInsert.add(countryAcc);
                } 
            }  
        }

        //Making sure the list is not empty to insert Child Accounts
        if (!countryAccToInsert.isEmpty()) {

            insert countryAccToInsert;
        }
    }
}