/*
Created By: Christan Gordon
Created Date: 11/27/2022

Description: Used to provide test code coverage for Snowflake_OAuth_Provider apex class.

Modification History:
Date				Developer 				Description
11/26/2022			Christan Gordon			Initial Creation

*/
@isTest
public class Snowflake_OAuth_Provider_Test {

    //Used to store the OAuth Client Id
    public static String oauthClientId = 'clientId123test';
    
    //Used to store the OAuth Client Secret
    public static String oauthClientSecret = 'clientSecret123test';
    
    //Used to store the OAuth Authorization Endpoint
    public static String oauthAuthEndpoint = 'https://testAccount123.snowflakecomputing.com/oauth/authorize';
    
    //Used to store the OAuth Token Authorization Endpoint
    public static String oauthTokenEndpoint = 'https://testAccount123.snowflakecomputing.com/oauth/token-request';
    
    //Used to store the OAuth Redirect Endpoint
    public static String oauthRedirectUrl = 'https://test.salesforce.com/services/authcallback/Snowflake_OAuth_Provider';
    
    //Used to store the OAuth Authorization Code
    public static String oauthCode = 'codeTest123';
    
    //Used to store the OAuth Callback State
    public static String oauthState = 'stateTest123';
    
    //Used to set the test refresh token
    public static String refreshToken = 'refreshTokenTest123';
    
    //Used to set the test authorization token
    public static String oauthToken = 'authTokenTest123';
    
    //Used to provide test code coverage for the initiate method
    @isTest
    public static void initiateTest(){
        
        //CREATE TEST DATA-------------------------------------------------------------------------------------
        
        //Create a test data mapping of the Snowflake OAuth Custom Metadata
        Map<String, String> testSnowflakeConnectionInfo = new Map<String, String>();
        
        //Set the OAuth Client Id
        testSnowflakeConnectionInfo.put('OAuth_Client_ID__c', oauthClientId);
       
        //Set the OAuth Callback URL
        testSnowflakeConnectionInfo.put('OAuth_Redirect_URI__c', oauthRedirectUrl);
        
        //Set the OAuth Authorization Endpoint
        testSnowflakeConnectionInfo.put('OAuth_Authorization_Endpoint__c', oauthAuthEndpoint);
        
        //Create a new PageReference to store the returned value
        PageReference testAuthPage;
        
        //Create a new instance of the Snowflake OAuth Provider
        Snowflake_OAuth_Provider testSnowflakeAuthProvider = new Snowflake_OAuth_Provider();
        
        //START/INITIATE TEST-------------------------------------------------
        System.Test.startTest();
        
		//Invoke the initiate method to retrieve the test PageReference that the user would be sent to
		testAuthPage = testSnowflakeAuthProvider.initiate(testSnowflakeConnectionInfo, oauthState);      
       
        //END TEST
        System.Test.stopTest();
        
        //EVALUATE RESULTS---------------------------------------------
        //If success, the page parameter should contain state
        System.assertEquals(true, testAuthPage.getParameters().containsKey('state'), 'The Authorization Page does NOT contain a state parameter');
        
        //If success, the page parameter should contain client Id
        System.assertEquals(true, testAuthPage.getParameters().containsKey('client_id'), 'The Authorization Page does NOT contain a Client Id parameter');
        
        //If success, the page parameter should contain client secret
		System.assertEquals(true, testAuthPage.getParameters().containsKey('response_type'), 'The Authorization Page does NOT contain a Response Type parameter'); 

		//If success, the page parameter should contain client secret
		System.assertEquals(true, testAuthPage.getParameters().containsKey('redirect_uri'), 'The Authorization Page does NOT contain a Redirect URI parameter');  
        
    }
    
    //Used to provide test code coverage for the handleCallback method if a successful response is received
    @isTest
    public static void handleCallbackSuccessTest(){
		
        //Set the fake successful web response
        Test.setMock(HttpCalloutMock.class, new SnowflakeAuthTokenSuccessMock());
		        
        //CREATE TEST DATA----------------------------------------------------------------------
       	//Used to store test auth provider config info
       	Map<String,String> oauthProviderConfig = new Map<String,String>();
        
        //Set the OAuth Token Endpoint
        oauthProviderConfig.put('OAuth_Token_Endpoint__c', oauthTokenEndpoint);
        
        //Set OAuth Client ID
        oauthProviderConfig.put('OAuth_Client_ID__c', oauthClientId);

        //Set OAuth Client Secret
        oauthProviderConfig.put('OAuth_Client_Secret__c', oauthClientSecret);
        
        //Set OAuth Token Endpoint
        oauthProviderConfig.put('OAuth_Client_Secret__c', oauthClientSecret);
        
        //Set OAuth Redirect URL
        oauthProviderConfig.put('OAuth_Redirect_URI__c', oauthRedirectUrl);
        
        //Used to store the queryParameters for the Auth.AuthProviderCallbackState 
        Map<String,String> testQueryParameters = new Map<String,String>();
        
        //Set the Authorization Code
        testQueryParameters.put('code', oauthCode);
        
        //Set the OAuth state
        testQueryParameters.put('state', oauthState);
       
        //Create a fake Auth.AuthProviderCallbackState instance
        Auth.AuthProviderCallbackState testOauthCallbackInfo = new Auth.AuthProviderCallbackState(new Map<string,String>(),'bodyTest', testQueryParameters);
        
        //Create a fake Auth.AuthProviderTokenResponse instance to return the results
        Auth.AuthProviderTokenResponse testTokenResponse = new Auth.AuthProviderTokenResponse('','','','');
        
        //Create a new instance of the Snowflake OAuth Provider
        Snowflake_OAuth_Provider testSnowflakeAuthProvider = new Snowflake_OAuth_Provider();
        
        //START TEST----------------------------------------------------------------------------
        System.Test.startTest();
        
        //Invoke the handleCallback method
        testTokenResponse = testSnowflakeAuthProvider.handleCallback(oauthProviderConfig, testOauthCallbackInfo);
        
        System.Test.stopTest();
        //END TEST------------------------------------------------------------------------------
        
        //EVALUATE RESULTS----------------------------------------------------------------------
        //If successful, an access token should have been stored
        System.assertEquals(true, testTokenResponse.oauthToken != '', 'NO OAuth Token was Stored!');
        
        //If successful, an refresh token should have been stored
        System.assertEquals(true, testTokenResponse.oauthSecretOrRefreshToken != '', 'NO OAuth Refresh Token was Stored!');
        
    }
    
    //Used to provide test code coverage for the getUserInfo method if a successful response is received
    @isTest
    public static void getUserInfoTest(){
        
        //CREATE TEST DATA----------------------------------------------------------------------------------------------
        //Create a fake Auth.UserData instance to return the results
        Auth.UserData testUserData = new Auth.UserData('', '', '', '', '', '', '', '', '', '', new Map<String,String>());
        
        //Create a new instance of the Snowflake OAuth Provider
        Snowflake_OAuth_Provider testSnowflakeAuthProvider = new Snowflake_OAuth_Provider();
        
        //START TEST--------------------------------------------------------------------------------------------------------------
        System.Test.startTest();
        
        //Invoke the getUserData method
        testUserData = testSnowflakeAuthProvider.getUserInfo(new Map<String, String>(), new Auth.AuthProviderTokenResponse('','','',''));
        
        System.Test.stopTest();
        //END TEST----------------------------------------------------------------------------------------------------------------
        
        //EVALUATE RESULTS--------------------------------------------------------------------------------------------------------
        //If successful, the Identification Id of the test user stored is the current user's Salesforce Id
        System.assertEquals(UserInfo.getUserId(), testUserData.identifier, 'The Test User Identifier Id do MATCH the current User\'s Salesforce Id. Identifier Id: '+testUserData.identifier);
        
        //If successful, the first name of the test user stored is the current user's first name
        System.assertEquals(UserInfo.getFirstName(), testUserData.firstname, 'The Test User First Name do MATCH the current User\'s First Namw. First Name: '+testUserData.firstname);
        
        //If successful, the last name of the test user stored is the current user's last name
        System.assertEquals(UserInfo.getLastName(), testUserData.lastname, 'The Test User Last Name do MATCH the current User\'s Last Name. Last Name: '+testUserData.lastname);
        
    }
    
    //Used to provide test code coverage for the refresh method if a successful response is received
    @isTest
    public static void refreshSuccessTest(){
		
        //Set the fake successful web response
        Test.setMock(HttpCalloutMock.class, new SnowflakeRefreshTokenSuccessMock());
		        
        //CREATE TEST DATA----------------------------------------------------------------------
       	//Used to store test auth provider config info
       	Map<String,String> oauthProviderConfig = new Map<String,String>();
        
        //Set the OAuth Token Endpoint
        oauthProviderConfig.put('OAuth_Token_Endpoint__c', oauthTokenEndpoint);
        
        //Set OAuth Client ID
        oauthProviderConfig.put('OAuth_Client_ID__c', oauthClientId);

        //Set OAuth Client Secret
        oauthProviderConfig.put('OAuth_Client_Secret__c', oauthClientSecret);
        
        //Set OAuth Token Endpoint
        oauthProviderConfig.put('OAuth_Client_Secret__c', oauthClientSecret);
        
        //Set OAuth Redirect URL
        oauthProviderConfig.put('OAuth_Redirect_URI__c', oauthRedirectUrl);
        
        //Create a fake Auth.AuthProviderTokenResponse instance to return the results
        Auth.OAuthRefreshResult testRefreshResult = new Auth.OAuthRefreshResult(oauthToken,'','');
        
        //Create a new instance of the Snowflake OAuth Provider
        Snowflake_OAuth_Provider testSnowflakeAuthProvider = new Snowflake_OAuth_Provider();
        
        //START TEST----------------------------------------------------------------------------
        System.Test.startTest();
        
        //Invoke the refresh method
        testRefreshResult = testSnowflakeAuthProvider.refresh(oauthProviderConfig, refreshToken);
        
        System.Test.stopTest();
        //END TEST------------------------------------------------------------------------------
                
        //EVALUATE RESULTS----------------------------------------------------------------------
        //If successful, the access token used should be updated with the new value
        System.assertEquals(true, testRefreshResult.accessToken != oauthToken, 'The OAuth Authorization Token was not Updated!');
        
        //If successful, the access token should match the value stored in the fake response
        System.assertEquals(true, testRefreshResult.accessToken == 'ver:1-hint:1353920654-ETMsDgAAAYS2Zj9QABRBRVMvQ0JDL1BLQ1M1UGFkZGltestZwEAABAAEB4gAczhL4Vz6WdlMzEdyAoAAABQMyr2wtHdjgjVZP4dZVQ5Rp3qbJFkC3tYR5AL9s2CqTQ2KzrJsnD/0LXMxQGFOOB6yFrQrjuhaN2rPhgscYgvCotoBFXWnR1j7NXPJd549lMAFPZXi5ymMavk+uGZ0TpnwzL8SnP3', 'The New OAuth Authorization Token Does Not Match the Token Response Received. Current OAuth Token: '+testRefreshResult.accessToken);
        
    }  
}
