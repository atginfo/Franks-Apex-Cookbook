public class ParkLocator {
    public static String[] country(String country){
        ParkService.ParksImplPort port = new ParkService.ParksImplPort();
        String[] parks = port.byCountry(country);
        System.debug('Parks in ' + country + ': ' + parks);
        return parks;
    }
}