//1
public with sharing class DmlExamples {
    //2
    public static Account createAccount(String accountName) {
        Account acc = new Account();
        acc.Name = accountName;
        insert acc;
        return acc;
    }

    //3
    public static Account updateAccount(Account accToUpdate) {
        accToUpdate.Name = accToUpdate.Name.toUpperCase();
        update accToUpdate;
        return accToUpdate;
    }

    //4
    public static void deleteAccount(Account accToDelete) {
        delete accToDelete;
    }
}