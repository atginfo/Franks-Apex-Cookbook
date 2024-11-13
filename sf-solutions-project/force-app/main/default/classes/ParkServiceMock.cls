@isTest
global class ParkServiceMock implements WebServiceMock {
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        
       if(requestName == 'byCountry') {
            // start - specify the response you want to send
            ParkService.byCountryResponse mockResponse = new ParkService.byCountryResponse();
            mockResponse.return_x = new String[] {
                    'Hamburg Wadden Sea National Park', 
                    'Hainich National Park',
                    'Bavarian Forest National Park'
                };
                
            // end
            response.put('response_x', mockResponse);
       }   
   }
}