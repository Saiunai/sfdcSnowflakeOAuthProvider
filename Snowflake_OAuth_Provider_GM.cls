/*
Created By: Christan Gordon
Created Date: 10/28/2022

Description: Used to provide a custom Auth. Provider to Snowflake's API

Documentation Reference Links:
AuthProviderCallbackState - https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderCallbackState.htm#apex_class_Auth_AuthProviderCallbackState
AuthProviderTokenResponse - https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderTokenResponse.htm#apex_class_Auth_AuthProviderTokenResponse

Modification History:
Date				Developer 				Description
10/28/2022			Christan Gordon			Initial Creation

*/

global class Snowflake_OAuth_Provider extends Auth.AuthProviderPluginClass {
    
    //Used to store the OAuth Client Id
    private String oauthClientId;
    
    //Used to store the OAuth Client Secret
    private String oauthClientSecret;
        
    //Used to store the OAuth Callback URL
    private String oauthRedirectURI;
    
    //Used to store the OAuth Username from Snowflake
    private String oauthUsername;
        
    //Used to store the OAuth Authorization Endpoint
    private String oauthAuthEndpoint;
        
    //Used to store OAuth Authorization Endpoint
    private String oauthAuthURL;
    
    //Used to store the OAuth Secret or Refresh Token
    private String oauthSecretOrRefreshToken;
        
    //Used to store the OAuth Access Token
    private String oauthAccessToken;
    
    //Used to store the OAuth Authorization Code. This code is needed to exchange for an access token
    private String oauthAuthCode;
    
    //Used to store the token OAuth Token Endpoint
    private String oauthTokenEndpoint;

    //Used to store the Custom Metadata API that contains info needed to connect to Snowflake
    private String Snowflake_Connection_Custom_Metadata_API = 'Snowflake_Connection_Info__mdt'; 
    
    //Used to store the custom authentication provider name
    private String customAuthProviderName = 'Snowflake_OAuth_Provider';  
    
    //Used to set the Custom Metadata API that the OAuth Provider will use to initiate the connection
    global String getCustomMetadataType(){
        
        return Snowflake_Connection_Custom_Metadata_API;
        
    }
    
    //Used to initiate the authorization process
    //This will navigate the user to the Snowflake Login Screen webpage to authorize the connection
    global PageReference initiate(Map<String,String> oauthProviderConfig, String oauthRequestState){
        
        //Used to store the OAuth Client Id
        oauthClientId = oauthProviderConfig.get('OAuth_Client_ID__c');
 
        //Used to store the OAuth Callback URL
        oauthRedirectURI = oauthProviderConfig.get('OAuth_Redirect_URI__c');
        
        //Used to store the OAuth Authorization Endpoint
        oauthAuthEndpoint = oauthProviderConfig.get('OAuth_Authorization_Endpoint__c');
        
        //Generate the OAuth Authorization Endpoint and its parameters
        String oauthAuthURL = oauthAuthEndpoint+'?client_id='+EncodingUtil.urlEncode(oauthClientId,'UTF-8')+'&response_type=code&redirect_uri='+oauthRedirectURI+'&state='+oauthRequestState;
                
        //Create an instance of the PageReference and set it to OAuth Page
        PageReference snowFlakeOauthAuthPage = new PageReference(oauthAuthURL);
        
        //Set the state parameter
        snowFlakeOauthAuthPage.getParameters().put('state',oauthRequestState);
        
        //Redirect the user to the Snowflake Login Page to authenticate the connection.
        //After the user authenticates the connection, Snowflake will send back a code and append it to the callback URL. 
        //The handleCallback method is then invoked. 
        return snowFlakeOauthAuthPage;
        
    }
    
    //Used to handle the information received from Snowflake that is appended to the CallBackURL
    global Auth.AuthProviderTokenResponse handleCallback(Map<String,String> oauthProviderConfig, Auth.AuthProviderCallbackState oauthRedirectState){ 
                
        //Store the query parameters of the authentication request. This will contain the code value sent back from Snowflake
        Map<String, String> oauthCallbackProperties = oauthRedirectState.queryParameters;
        
        //Used to store the custom authentication provider name
        customAuthProviderName = 'Snowflake_OAuth_Provider';
        
        //Used to store the OAuth Authorization Code returned from the callback. This code is needed to exchange for an access token
        oauthAuthCode = oauthCallbackProperties.get('code');
        
        //Used to store the token OAuth Token Endpoint
        oauthTokenEndpoint = oauthProviderConfig.get('OAuth_Token_Endpoint__c');
        
        System.debug('oauthCallbackProperties: '+JSON.serializePretty(oauthCallbackProperties));
        
        //Used to store the state received from the callback. 
        //This should match the oauthRequestState field value in the initiate method
        String state = oauthCallbackProperties.get('state');
        
        //Used to store the client Id
        oauthClientId = oauthProviderConfig.get('OAuth_Client_ID__c');
        
        //Used to store the client secret
        oauthClientSecret = oauthProviderConfig.get('OAuth_Client_Secret__c');
        
		//Used to store the token request endpoint
		String oauthTokenRequestEndpoint = oauthProviderConfig.get('OAuth_Token_Endpoint__c');        
        
        //Used to store the redirect url/uri
        oauthRedirectURI = oauthProviderConfig.get('OAuth_Redirect_URI__c'); 
        
        //Callout to the Token Endpoint with the code value retrieved---------------------------------------------------
        //Used to create a HTTP to initiate the request
       	Http accessTokenCalloutInitiate = new Http();
        
        //Used to store information about the HTTP Request
        HttpRequest accessTokenCalloutRequest = new HttpRequest();
        
        //Used to capture the HTTP Response received
        HttpResponse accessTokenCalloutResponse = new HttpResponse();
        
        //Set the Token Callout Request Parameters-------------------------
        //Set the Content Type of the Header
        accessTokenCalloutRequest.setHeader('content-type','application/x-www-form-urlencoded');
           
        //Prepare the header of the Token Request
        //Convert the string, oauthClientId+':'+oauthClientSecret into a primitive data type
        Blob client_Id_Client_Secret_Data = Blob.valueOf(oauthClientId+':'+oauthClientSecret);
		
        //Convert primitive data type into Base64 binary data. This is a header required per Snowflake Doc: https://docs.snowflake.com/en/user-guide/oauth-custom.html#scope
        String client_Id_Client_Secret_Base64 = EncodingUtil.base64Encode(client_Id_Client_Secret_Data);
        
        //Set the header of the Token Request
        accessTokenCalloutRequest.setHeader('Authorization', 'Basic '+client_Id_Client_Secret_Base64);
        
        //Set the Token Request Endpoint
        accessTokenCalloutRequest.setEndpoint(oauthTokenRequestEndpoint);
        
        //Set the Token Request HTTP Method
        accessTokenCalloutRequest.setMethod('POST');
        
        //Create the body of the Token Request
        String requestBody = 'grant_type=authorization_code' +
             				 '&code='+oauthAuthCode+
              	             '&redirect_uri='+oauthRedirectURI;
        
        //Set the body of the request
        accessTokenCalloutRequest.setBody(requestBody);
        
        //Initiate the Access Token Request Web Callout to retrieve an access and refresh token from Snowflake in exchange for the authorization code we received earlier
        //Store the request response details within accessTokenCalloutResponse
        accessTokenCalloutResponse = accessTokenCalloutInitiate.send(accesstokenCalloutRequest);
        
        //Output the HTTP Status Code of the callout 
        System.debug('Access Token Request - Status Code: '+accessTokenCalloutResponse.toString());
        
        //Deserialize the JSON Request Body returned
        Map<String, Object> accessTokenResponseDetails = (Map<String,Object>)JSON.deserializeUntyped(accessTokenCalloutResponse.getBody());
        
        //Output accessTokenResponseDetails in the debug log for reference
        System.debug(JSON.serializePretty(accessTokenResponseDetails));
        
        //Check if the map contains are error key. Per Snowflake, an error key will be included if an error occurred 
        if(accessTokenResponseDetails.containsKey('error')){
            
            //Output that an error occurred in debug log
            System.debug('An Error Occurred during the Access Token Request...');
            
            //Output the error message that was returned
            System.debug('The following error message was returned: '+(String)accessTokenResponseDetails.get('error'));
            
        }
        
        //Else check if map contains the following keys, "access_token"
        else if(accessTokenResponseDetails.containsKey('access_token')){
            
            //Output that the request was a success in debug log
            System.debug('The Access Token Request was Successful! An Access Token was Returned');
        
        	//Used to store the OAuth Access Token
        	oauthAccessToken = (String)accessTokenResponseDetails.get('access_token');
            
            //Check if map also contains a "refresh_token"
            if(accessTokenResponseDetails.containsKey('refresh_token')){
            
            	//Output that the request was a success in debug log
            	System.debug('A Refresh Token was also Returned');
        
        		//Used to store the OAuth Refresh Token
                oauthSecretOrRefreshToken = (String)accessTokenResponseDetails.get('refresh_token');
            
            }
            
        }
        
        //Construct and return a new Auth.AuthProviderTokenResponse instance with the information retrieved
        return new Auth.AuthProviderTokenResponse(customAuthProviderName, oauthAccessToken, oauthSecretOrRefreshToken, state); 
 
    } 
    
    //Used to retrieve information from the custom authentication provider about the current user
    //Information about the current Salesforce user executing this OAuth Connection will be stored instead.
    //Ideally, one should query the details of the user from the external system if possible 
    global Auth.UserData getUserInfo(Map<String,String> oauthProviderConfig, Auth.AuthProviderTokenResponse response) { 
         
        //Construct and return a new Auth.UserData instance with the current Salesforce User Info
        return new Auth.UserData(UserInfo.getUserId(), 
                                 UserInfo.getFirstName(), 
                                 UserInfo.getLastName(), 
                                 UserInfo.getName(), 
                                 UserInfo.getUserEmail(), 
                                 'link', 
                                 UserInfo.getUserName(),
                                 UserInfo.getLocale(), 
                                 'Saleforce', null, new Map<String,String>()); 
        
    }
    
    //Used to refresh the access token when expired.
    //NOTE: Refresh Token expires every 90 days. User must go through the auth login flow to receive a new access token when this occurs. 
    //If you would like to increase the refresh timeout to more than 90 days, then you will need to contact the Snowflake Support. 
    //They can increase the maximum timeout
    global override Auth.OAuthRefreshResult refresh(Map<String,String> oauthProviderConfig, String refreshToken){
        
        //Used to store the redirect url/uri
        oauthRedirectURI = oauthProviderConfig.get('OAuth_Redirect_URI__c'); 
        
        //Used to store the client Id
        oauthClientId = oauthProviderConfig.get('OAuth_Client_ID__c');
        
        //Used to store the client secret
        oauthClientSecret = oauthProviderConfig.get('OAuth_Client_Secret__c');
        
		//Used to store the token request endpoint
		String oauthTokenRequestEndpoint = oauthProviderConfig.get('OAuth_Token_Endpoint__c');        
        
        //Used to store the redirect url/uri
        oauthRedirectURI = oauthProviderConfig.get('OAuth_Redirect_URI__c'); 
        
        //Callout to the Token Endpoint with the code value retrieved---------------------------------------------------
        //Used to create a HTTP to initiate the request
       	Http accessTokenCalloutInitiate = new Http();
        
        //Used to store information about the HTTP Request
        HttpRequest accessTokenCalloutRequest = new HttpRequest();
        
        //Used to capture the HTTP Response received
        HttpResponse accessTokenCalloutResponse = new HttpResponse();
        
        //Set the Token Callout Request Parameters-------------------------
        //Set the Content Type of the Header
        accessTokenCalloutRequest.setHeader('content-type','application/x-www-form-urlencoded');
           
        //Prepare the header of the Token Request
        //Convert the string, oauthClientId+':'+oauthClientSecret into a primitive data type
        Blob client_Id_Client_Secret_Data = Blob.valueOf(oauthClientId+':'+oauthClientSecret);
		
        //Convert primitive data type into Base64 binary data. 
        //This is a header required per Snowflake Doc: https://docs.snowflake.com/en/user-guide/oauth-custom.html#scope
        String client_Id_Client_Secret_Base64 = EncodingUtil.base64Encode(client_Id_Client_Secret_Data);
        
        //Set the header of the Token Request
        accessTokenCalloutRequest.setHeader('Authorization', 'Basic '+client_Id_Client_Secret_Base64);
        
        //Set the Token Request Endpoint
        accessTokenCalloutRequest.setEndpoint(oauthTokenRequestEndpoint);
        
        //Set the Token Request HTTP Method
        accessTokenCalloutRequest.setMethod('POST');
        
        //Used to store any potential errors that may occur while refreshing an access token
        String oauthRefreshTokenRequestError = '';
        
        System.debug('Refresh Token: '+refreshToken);
        
        //Create the body of the Refresh Token Request
		String requestBody = 'grant_type=refresh_token'+
              	             //'&redirect_uri='+oauthRedirectURI+
            				 '&refresh_token='+EncodingUtil.urlEncode(refreshToken, 'UTF-8');
        
        //Set the body of the request
        accessTokenCalloutRequest.setBody(requestBody);
        
        System.debug('Refresh Request Body: '+accessTokenCalloutRequest.getBody());
        
        //Initiate the Refresh Access Token Request Web Callout to retrieve a new access token from Snowflake
        //Store the request response details within accessTokenCalloutResponse
        accessTokenCalloutResponse = accessTokenCalloutInitiate.send(accesstokenCalloutRequest);
        
        //Output the HTTP Status Code of the callout 
        System.debug('Refresh Access Token Request - Status Code: '+accessTokenCalloutResponse.toString());
        
        //Deserialize the JSON Request Body returned
        Map<String, Object> accessTokenResponseDetails = (Map<String,Object>)JSON.deserializeUntyped(accessTokenCalloutResponse.getBody());
        
        //Output accessTokenResponseDetails in the debug log for reference
        System.debug(JSON.serializePretty(accessTokenResponseDetails));
        
        //Check if the map contains are error key. Per Snowflake, an error key will be included if an error occurred 
        if(accessTokenResponseDetails.containsKey('error')){
            
            //Output that an error occurred in debug log
            System.debug('An Error Occurred While Refreshing the Access Token...');
            
            //Store the error received in oauthRefreshTokenRequestError
            oauthRefreshTokenRequestError = (String)accessTokenResponseDetails.get('error');
                
            //Output the error message that was returned
            System.debug('The following error message was returned: '+oauthRefreshTokenRequestError);
            
        }
        
        //Else check if map contains the following keys, "access_token"
        else if(accessTokenResponseDetails.containsKey('access_token')){
            
            //Output that the request was a success in debug log
            System.debug('The Refresh Access Token Request was Successful! A New Access Token was Returned!');
        
        	//Used to store the OAuth Access Token
        	oauthAccessToken = (String)accessTokenResponseDetails.get('access_token');
  
        }
        
        //Return an OAuthRefreshResult instance with the info received
        return new Auth.OAuthRefreshResult(oauthAccessToken,refreshToken,oauthRefreshTokenRequestError);
        
    }
}