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
    }

    @isTest
    public static void createNewTradeSuccessTest() {
       
        Test.startTest();
        
           Trade__c trade = [
             SELECT Buy_Amount__c, Buy_Currency__c, 
                    Rate__c, Sell_Amount__c, Sell_Currency__c
               FROM Trade__c 
              WHERE Sell_Currency__c IN ('USD', 'GBP', 'EUR')
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

            try {
                ActionResponse.Response response = NewTradeController.createNewTrade(null);
                System.assertEquals(response.HasError, true);
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
            
        Test.stopTest();
    }
}
