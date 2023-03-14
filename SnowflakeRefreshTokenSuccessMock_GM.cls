/*
Created By: Christan Gordon
Created Date: 11/27/2022

Description: Used to simulate a successful web callout response that Snowflake would provide when 
receiving a request to refresh/renew an expired authorization token.

Modification History:
Date				Developer 				Description
11/26/2022			Christan Gordon			Initial Creation

*/
global class SnowflakeRefreshTokenSuccessMock implements HttpCalloutMock {
	
    global HttpResponse respond(HttpRequest req){
        
        //Create a fake HTTP Web Callout Response
        HttpResponse authFakeResponse = new HttpResponse();
        
        //Check if the request endpoint contains '/oauth/token-request' and its request body contains 'grant_type=refresh_token'
        //AND also contains 'refresh_token=' AND the set HTTP Method is 'POST'
        if(req.getEndpoint().contains('/oauth/token-request') && req.getBody().contains('grant_type=refresh_token') && req.getBody().contains('refresh_token=') && req.getMethod() == 'POST'){
            
            //Set its Status
            authFakeResponse.setStatus('OK');
            
            //Set its Status Code
            authFakeResponse.setStatusCode(200);
            
            //Used to strore the response body
            String responseBody = '{'+
								  '  \"idpInitiated\" : false,'+
                                  '  \"expires_in\" : 600,'+
                                  '  \"token_type\" : \"Bearer\",'+
                                  '  \"access_token\" : \"ver:1-hint:1353920654-ETMsDgAAAYS2Zj9QABRBRVMvQ0JDL1BLQ1M1UGFkZGltestZwEAABAAEB4gAczhL4Vz6WdlMzEdyAoAAABQMyr2wtHdjgjVZP4dZVQ5Rp3qbJFkC3tYR5AL9s2CqTQ2KzrJsnD/0LXMxQGFOOB6yFrQrjuhaN2rPhgscYgvCotoBFXWnR1j7NXPJd549lMAFPZXi5ymMavk+uGZ0TpnwzL8SnP3\"'+
                                  '}';
            
            //Set the Response Body
            authFakeResponse.setBody(responseBody);

        }
        
        //Return Fake Response
        return authFakeResponse;
        
    }
}