//Supports the ContactPageWithExtension
public class MyControllerExtension {

    private final Account acct;

    // Pass in the Standard Controller to the Constructor
    // Populate acct record using the getRecord() method
    public MyControllerExtension(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
    }

    public String getGreeting() {
        return 'Hello ' + acct.name + ' (' + acct.id + ')';
    }
}