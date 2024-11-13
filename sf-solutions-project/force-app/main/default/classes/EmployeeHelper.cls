//Checkpoint 1 class 1
public class EmployeeHelper {
    
    //Grabbing Accounts with empty Number of Employees and giving a random number 
    public static List<Account> addEmployees() {

        //Grabbing Accounts with no number of employees value
        List<Account> accList = [
            SELECT Id, Name, Rating, NumberOfEmployees
            FROM Account
            WHERE NumberOfEmployees = Null
        ];
        
        //Assigning random number employees and labeling rating based off number given
        for (Account acc : accList) {
            
            //Random number generator
            Integer randomEmployees = Integer.valueOf((Math.random() * 1000));
            acc.NumberOfEmployees = randomEmployees;

            if (acc.NumberOfEmployees >= 0 && acc.NumberOfEmployees <= 100) {
                acc.Rating = 'Cold';
            } else if (acc.NumberOfEmployees >= 101 && acc.NumberOfEmployees <= 500) {
                acc.Rating = 'Warm';
            } else if (acc.NumberOfEmployees >= 501) {
                acc.Rating = 'Hot';
            } else {
                acc.Rating = Null;
            }

        }
        if (!accList.isEmpty()) {
            update accList;
        }
        
        return accList;     
    }
}