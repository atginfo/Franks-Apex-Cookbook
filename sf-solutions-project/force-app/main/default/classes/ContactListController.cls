// Supports the ContactPageCustomActions 
public class ContactListController {

    // Get and Set contactList variable
    public List<Contact> contactList {get; set;}
  
    // Create class variable that can be changed based on the methods below
    public String additionalFilter = '';
  
    public ContactListController(){
      fetchContacts();
    }
  
    public void fetchContacts(){
      //Using Database.query method which takes in a stringified version of our SOQL query  
      contactList = Database.query(
          'SELECT Id, NAme, Title, Email ' +
          'FROM Contact ' + additionalFilter
      );
    }
    
    //This method adds a filter to the page when the button is clicked
    public void showCFOS(){
      additionalFilter = 'WHERE Title = \'CFO\'';
      fetchContacts();
    }
    
    //This method clears the filter made when clicked
    public void showAllContacts(){
      additionalFilter = '';
      fetchContacts();
    }
  
  }