public with sharing class HelloWorld {

    public HelloWorld(String someString) {
        this(new List<String>{someString});
    }

    public HelloWorld(List<String> stringList) {
        System.debug('Hello from HelloWorld Constructor method that accepts a List of Strings!');

        for (String someValue : stringList) {
            System.debug(someValue);
        }
    }

}