// This class supports the ContactPageCustom
public class MyCustomController {

    String name;
  
    public String getName(){
      return 'My full name';
    }

    /*
    // Using the get; and set; methods, contactList can be used in our Visualforce page
    // Expanded version: public List<Contact> contactList { get {return contactList;} set {contactList = value;} }
    public List<Contact> contactList {get; set;}

    // Constructor runs before the getter and setter methods run
    public MyCustomController(){
      fetchContacts();
    }

    // Populate the contactList variable with the following query
    public void fetchContacts(){
      contactList = [SELECT Id, Name, Email, Title FROM Contact];
  
    }*/

    //Alternate design pattern. More efficient since the query doesnt run 
    //until the variable is access somewhere in our code
    public List<Contact> contactList {
        get {
          if (contactList == null) {
            contactList = [SELECT Id, Name, Email, Phone, Title FROM Contact];
          }
          return contactList;
        }
        set;
      }

}