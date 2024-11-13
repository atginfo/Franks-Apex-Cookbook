@isTest
private class ParkLocatorTest {
    @isTest static void testCallout() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        
        // Call the method that invokes a callout
        String[] germanParks = new String[]{'Hamburg Wadden Sea National Park', 'Hainich National Park', 'Bavarian Forest National Park'};
        String[] result = ParkLocator.country('Germany');
        // Verify that a fake result is returned
        Assert.areEqual(germanParks, result);
    }

}