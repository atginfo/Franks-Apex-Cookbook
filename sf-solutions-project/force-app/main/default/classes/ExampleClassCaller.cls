public with sharing class ExampleClassCaller {
    //4
    public static void callMethods() {
        //a.
        Opportunity opp = ExampleClass.createOpportunity('New Opportunity!', 'Qualification');
        //b.
        String oppName = opp.Name;
        //c
        Date oppCloseDate = opp.CloseDate;
        //d
        System.debug('This opportunity is called ' + oppName);
        System.debug('Its close date is ' + oppCloseDate);
        //e
        List<Contact> newContacts = ExampleClass.createContacts();
        System.debug('contacts size: ' + newContacts.size());

    }
}