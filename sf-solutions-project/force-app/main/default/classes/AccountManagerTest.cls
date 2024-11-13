@IsTest
private class AccountManagerTest {
    
    @isTest static void testGetAccount() {
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://yourInstance.my.salesforce.com/services/apexrest/Accounts/' + recordId +'/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account thisAccount = AccountManager.getAccount();
        // Verify results
        Assert.isTrue(thisAccount != null);
        
    }
    
    // Helper method
    static Id createTestRecord() {
       
        // Create test account
        Account accountTest = new Account(
            Name='Test Record'
            );
        insert accountTest;
        
        // Create test contact
        Contact contactTest = new Contact(
        	FirstName='Frank',
            LastName='Berni',
            AccountId = accountTest.id
        );
       	insert contactTest; 
        
        return accountTest.Id;
    }

}