// Supports the OpportunityPageCustom 
public class OpportunityController {

    // Working with the set property in order to insert new values into the record 
    public Opportunity newOppty {get; set;}
  
    public OpportunityController(){
      // Create a new instance of an Opportunity record
      newOppty = new Opportunity();
    }
  
    public void createOpportunity(){
  
      // Insert to database
      insert newOppty;
  
      // After insert, re-initialize the newOppty variable so that the form clears in the VF page
      newOppty = new Opportunity();
    }
  }