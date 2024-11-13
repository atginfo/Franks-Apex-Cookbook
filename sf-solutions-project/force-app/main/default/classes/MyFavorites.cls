public class MyFavorites {

    // Class level variable
    public String beverage = 'Coca-Cola';

    // Static Class level variable
    public static String classDescription = 'All my favorite things.';

    public MyFavorites() {

        // Local Variable
        String message = 'Hello from MyFavorites constructor method!';
        System.debug(message);

        // Call method
        listFavoriteThings();

    }

    // Method to list our favorite things
    public static void listFavoriteThings(){

        String flower = 'roses';
        String animal = 'kittens';

        System.debug('Raindrops on ' + flower + ' and whiskers on ' + animal + '...');

    }

    // Add method to MyFavorites class
    public static void printFavoriteColor(String color){
        System.debug('My favorite color is ' + color + '!');
    }

    // Add method to MyFavorites class
    public static String addPeanuts(String dessert){

        String dessertWithPeanuts = dessert + ' with Peanuts!';
        return dessertWithPeanuts;

    }



}