/*
Created By: Christan Gordon
Created Date: 11/26/2022

Description: Used to simulate a successful web callout response that Snowflake would provide when 
receiving a request to exchange an authorization code for an authorization token.

Modification History:
Date				Developer 				Description
11/26/2022			Christan Gordon			Initial Creation

*/

@isTest
global class SnowflakeAuthTokenSuccessMock implements HttpCalloutMock  {

    global HttpResponse respond(HttpRequest req){
        
        //Create a fake HTTP Web Callout Response
        HttpResponse authFakeResponse = new HttpResponse();
        
        //Check if the request endpoint contains '/oauth/token-request' and its request body contains 'grant_type=authorization_code'
        //AND also contains 'code=' AND the set HTTP Method is 'POST'
        if(req.getEndpoint().contains('/oauth/token-request') && req.getBody().contains('grant_type=authorization_code') && req.getBody().contains('code=') && req.getMethod() == 'POST'){
            
            //Set its Status
            authFakeResponse.setStatus('OK');
            
            //Set its Status Code
            authFakeResponse.setStatusCode(200);
            
            //Used to strore the response body
            String responseBody = '{'+
								  '  \"idpInitiated\" : false,'+
                                  '  \"refresh_token_expires_in\" : 7775999,'+
                                  '  \"expires_in\" : 599,'+
                                  '  \"scope\" : \"refresh_token session:role:USERADMIN\",'+
                                  '  \"username\" : \"TEST_USER\",'+
                                  '  \"token_type\" : \"Bearer\",'+
                                  '  \"refresh_token\" : \"ver:2-hint:11739209733-did:2001-ETMsDtestAAAYS2Zj9PABRBRVMvQ0JDL1BLQ1M1UGFkZGluZwEAABAAEKY837AE3Ok1U18zOM/SMrUAAADwfnMcjBuz0ZIYlOpWNn4+srjKQZPIApWkYO4NcogTgSPo3vfD6jPSxvs8d5OmN44aIgVTyGpV26PcZDmPo4S5xci0D2I37J5utB3Nv/kg49bVnFItg6fkQy2zf13kMeC06KQV4gVr35WPQ+Y0odPEBOZ/wgq1UmtXMYGdkS7IUCr7t+qiP0jI8ujdbeZ09gECf3hSA5hUtI1Usomm6ABIzcxsLUgxFEal9+Uy79dhnJRvTmtGYbG2o0iDRnxiCJLMQCP1q1wXoUgO5hAv5wh0eyHafAG3xl0CebvHjqN4wGdSWBwFDS5K1Q+b7KILNigfABTo49jTxAxuJuidrhMPtjofSA7sMg==\",'+
                                  '  \"access_token\" : \"ver:1-hint:11739205641-ETMsDgAAAYS2Zj9QABRBRVMvQ0JDL1BLQ1M1UGFkZGltestZwEAABAAEB4gAczhL4Vz6WdlMzEdyAoAAABQMyr2wtHdjgjVZP4dZVQ5Rp3qbJFkC3tYR5AL9s2CqTQ2KzrJsnD/0LXMxQGFOOB6yFrQrjuhaN2rPhgscYgvCotoBFXWnR1j7NXPJd549lMAFPZXi5ymMavk+uGZ0TpnwzL8SnP3\"'+
                                  '}';
            
            //Set the Response Body
            authFakeResponse.setBody(responseBody);

        }
        
        //Return Fake Response
        return authFakeResponse;
        
    }
    
}