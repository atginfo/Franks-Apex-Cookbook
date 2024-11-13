public with sharing class AccountHelper {
    
    public static Account createAccount(String accountName, String industry, Integer numEmployees) {
        
        //Create a new instance of an account record and populate various fields
        Account acc = new Account();
        acc.Name = accountName;
        acc.Industry = industry;
        acc.NumberOfEmployees = numEmployees;

        return acc;

    }
}