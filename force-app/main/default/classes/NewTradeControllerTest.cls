@isTest
public with sharing class NewTradeControllerTest {
    
    @TestSetup
    static void makeData(){
        
        List<Trade__c> newTrades = new List<Trade__c>();

        Trade__c tradeEUR = new Trade__c (
            Sell_Currency__c    = 'EUR',
            Buy_Currency__c     = 'USD',
            Sell_Amount__c      = 1000,
            Buy_Amount__c       = 1000 * 1.253,
            Rate__c             = 1.253
        );
        newTrades.add(tradeEUR);

        Trade__c tradeUSD = new Trade__c (
            Sell_Currency__c    = 'USD',
            Buy_Currency__c     = 'EUR',
            Sell_Amount__c      = 1500,
            Buy_Amount__c       = 1500 * 0.398,
            Rate__c             = 0.398
        );
        newTrades.add(tradeUSD);

        Trade__c tradeGBP = new Trade__c (
            Sell_Currency__c    = 'GBP',
            Buy_Currency__c     = 'EUR',
            Sell_Amount__c      = 2500,
            Buy_Amount__c       = 2500 * 1.458,
            Rate__c             = 1.458
        );
        newTrades.add(tradeGBP);
        insert newTrades;

        EburyTradeSettings__c eburySettings = new EburyTradeSettings__c(
            Name                            = 'Default',
            ApiKey__c                       = 'ZWKQQTDGZQCKMLCXQPN3T7EPLVECWTJK958XYTVB',
            EburyQueue__c                   = 'TradeReviewers',
            TemplateEmailNotification__c    = 'NewTrade'
        );
        insert eburySettings;
    }

    @isTest
    public static void getRateSuccessTest(){
        Test.setMock(HttpCalloutMock.class, new NewTradeControllerMock(200));

        Test.startTest();

            ActionResponse.Response response = NewTradeController.getRate('EUR', 'USD');
            System.assertEquals(response.HasError, false);

        Test.stopTest();
    }

    @isTest
    public static void getRateInvalidBaseCurrencyErrorTest(){
        Test.setMock(HttpCalloutMock.class, new NewTradeControllerMock(201));  

        Test.startTest();

            ActionResponse.Response response = NewTradeController.getRate('EUR', 'USD');
            System.assertEquals(response.HasError, true);

        Test.stopTest();
    }

    @isTest
    public static void getRateInvalidCurrencyCodesErrorTest(){
        Test.setMock(HttpCalloutMock.class, new NewTradeControllerMock(202));  

        Test.startTest();
        
            ActionResponse.Response response = NewTradeController.getRate('EUR', 'USD');
            System.assertEquals(response.HasError, true);

        Test.stopTest();
    }

    @isTest
    public static void getRateUnauthorizedErrorTest(){
        Test.setMock(HttpCalloutMock.class, new NewTradeControllerMock(401));    

        Test.startTest();

            ActionResponse.Response response = NewTradeController.getRate('EUR', 'USD');
            System.assertEquals(response.HasError, true);

        Test.stopTest();
    }

    @isTest
    public static void getRateGenericErrorTest(){
        Test.setMock(HttpCalloutMock.class, new NewTradeControllerMock()); 

        Test.startTest();

            ActionResponse.Response response = NewTradeController.getRate('EUR', 'USD');
            System.assertEquals(response.HasError, true);

        Test.stopTest();
    }

    @isTest
    public static void createNewTradeSuccessTest() {
       
        Test.startTest();
        
           Trade__c trade = [
             SELECT Buy_Amount__c, Buy_Currency__c, 
                    Rate__c, Sell_Amount__c, Sell_Currency__c
               FROM Trade__c 
              WHERE Sell_Currency__c =: 'GBP'
              LIMIT 1
            ];

            String tradeInfoJSON =  JSON.serialize(trade);

            ActionResponse.Response response = NewTradeController.createNewTrade(tradeInfoJSON);
            System.assertEquals(response.HasError, false);
            
        Test.stopTest();
    }

    @isTest
    public static void createNewTradeErrorTest() {
        
        Test.startTest();

            ActionResponse.Response response = NewTradeController.createNewTrade(null);
            System.assertEquals(response.HasError, true);
            new ActionResponse.Response('Error');
            
        Test.stopTest();
    }

    @isTest
    public static void sendNotificationNewTradeSuccessTest() {

        Test.startTest();
        
           Trade__c trade = [
             SELECT Id, Buy_Amount__c, Buy_Currency__c, 
                    Rate__c, Sell_Amount__c, Sell_Currency__c,
                    CreatedDate
               FROM Trade__c 
              WHERE Sell_Currency__c =: 'USD'
              LIMIT 1
            ];

            NewTradeController.sendNotificationNewTrade(trade);
            System.assertNotEquals(trade, null);
            
        Test.stopTest();

    }

    @isTest
    public static void sendNotificationNewTradeErrorTest() {

        Test.startTest();

            Trade__c trade = null;

            NewTradeController.sendNotificationNewTrade(null);
            System.assertEquals(trade, null);

        Test.stopTest();
    }

    @isTest
    public static void emptyConstructorsTest() {

        Test.startTest();

            NewTradeController.RateResponse rateResponse = new NewTradeController.RateResponse();
            NewTradeController.TradeInfo tradeInfo       = new NewTradeController.TradeInfo();
            ActionResponse  actionResponse               = new ActionResponse();

        Test.stopTest();
    }
}
