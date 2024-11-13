public with sharing class ExampleClass {
    
    //1
    public static Opportunity createOpportunity(String opportunityName, String stageName) {
        Opportunity opp = new Opportunity();
        opp.Name = opportunityName;
        opp.CloseDate = Date.today().addDays(30);
        opp.StageName = stageName;
        opp.Amount = 500;
        opp.Type = 'New Customer';
        opp.Description = 'Example Opportunity';

        return opp;
    }

    //2
    public static List<String> lastNames = new List<String>{
        'Garcia',
        'Pepper',
        'Smith',
        'Wang',
        'Anderson'
    };

    //3
    public static List<Contact> createContacts(){
        
        List<Contact> conList = new List<Contact>();
        
        for (String lastName : lastNames) {
            Contact con = new Contact();
            con.LastName = lastName;
            con.FirstName = 'J';
            conList.add(con);
        }

        return conList;
    }
}