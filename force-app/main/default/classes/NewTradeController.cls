/************************************************************************************************
* Name      : NewTradeController
* TestClass : NewTradeControllerTest
* Purpose   : Controller class of Trade__c object
* Author    : Bruna Girão
* Date      : 07-10-2022  
--------------------------------------------------------------------------------------------------
Date                Modified By            Description
--------------------------------------------------------------------------------------------------
07-10-2022          Bruna Girão         create class 
09-10-2022          Bruna Girão         create logic to get rate from fixer.io
                                        adjust return of the getRate method
                                        create the inner class RateResponse
10-10-2022          Bruna Girão         create createNewTrade methods
11-10-2022          Bruna Girão         create sendNotificationNewTrade to notify users about 
                                        new trades
12-10-2022          Bruna Girão         remove unused fields NewTradeController
                                        add ET_TRADE_CREATED_SUCCESS custom label to createNewTrade
                                        method
***************************************************************************************************/
public with sharing class NewTradeController {

    public static EburyTradeSettings__c tradeSettings = EburyTradeSettings__c.getInstance('Default');

    /**
    * @descripiton returns real-time exchange rate data 
    *  for all available or a specific set of currencies
    * @author Bruna Girão 
    * @param sellCurrency 
    * @param buyCurrency 
    * @return ActionResponse.Response 
    **/
    @AuraEnabled
    public static ActionResponse.Response getRate(String sellCurrency, String buyCurrency) {

        RateResponse rateResponse;
        String apiKey = tradeSettings.ApiKey__c;
            
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:GetLatestExchangeRate'+'/latest?symbols=' + buyCurrency + '&base=' + sellCurrency);
        request.setHeader('apikey', apiKey);
        request.setTimeout(20000);
        Http http = new Http();
        
        try {
            HttpResponse response = http.send(request);

            if(response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                
                Map<String, Object> resultMap  = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> ratesMap   = (Map<String, Object>) resultMap.get('rates');
                rateResponse = new RateResponse(ratesMap, buyCurrency);

                ActionResponse.Response responseRate = new ActionResponse.Response(
                    false, '', JSON.serialize(rateResponse)
                );
                return responseRate;

            } else {
                return new ActionResponse.Response(response.getBody());
            }

        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }

    }

    /**
    * @description create a new Trade__c record in Salesforce
    * @author Bruna Girão
    * @param tradeInfoJSON 
    * @return ActionResponse.Response 
    **/
    @AuraEnabled
    public static ActionResponse.Response createNewTrade(String tradeInfoJSON){

        try {
            TradeInfo info = (TradeInfo)JSON.deserialize(tradeInfoJSON, TradeInfo.class);

            Trade__c trade = new Trade__c (
                Sell_Currency__c    = info.SellCurrency, 
                Buy_Currency__c     = info.BuyCurrency, 
                Sell_Amount__c      = info.SellAmount,
                Buy_Amount__c       = info.BuyAmount, 
                Rate__c             = info.Rate
            );
            insert trade;

            Trade__c newTrade = [
                SELECT Id, Name,
                       Buy_Amount__c, Buy_Currency__c, 
                       Sell_Amount__c, Sell_Currency__c,
                       Rate__c, CreatedDate
                  FROM Trade__c 
                 WHERE Id =: trade.Id
                 LIMIT 1
            ];

            if(newTrade != null) {
                sendNotificationNewTrade(newTrade);
            }
            
            ActionResponse.Response tradeResponse = new ActionResponse.Response(
                false, System.Label.ET_TRADE_CREATED_SUCCESS + ' ' + newTrade.Name, JSON.serialize(trade)
            );
            return tradeResponse;
            
        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }
    }

    /**
    * @description send a notification to the user when Trade__c record is created
    * @author Bruna
    * @param newTrade 
    **/
    public static void sendNotificationNewTrade(Trade__c newTrade) {

        String tradeQueue                    = tradeSettings.EburyQueue__c;
        String tradeEmailTemplate            = tradeSettings.TemplateEmailNotification__c;
        Set<String> userEmails               = new Set<String>();
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        
        try {

            for(User user :[
                SELECT Email 
                  FROM User 
                 WHERE Id IN 
                    (
                        SELECT UserOrGroupId 
                        FROM GroupMember 
                        WHERE Group.DeveloperName =: tradeQueue
                    )
            ]) 
            {
                userEmails.add(user.Email);
            }

            EmailTemplate emailTemplate = [
                SELECT Id, Name, Subject, 
                       Body, HTMLValue, 
                       DeveloperName 
                  FROM EmailTemplate 
                 WHERE DeveloperName =: tradeEmailTemplate
            ];

            String HTMLBody  = emailTemplate.HTMLValue;
            String tradeLink = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Trade__c/' + newTrade.Id + '/view';

            HTMLBody = HTMLBody.replace('{!Trade__c.Sell_Currency__c}' ,String.valueOf(newTrade.Sell_Currency__c ));
            HTMLBody = HTMLBody.replace('{!Trade__c.Sell_Amount__c}'   ,String.valueOf(newTrade.Sell_Amount__c   ));
            HTMLBody = HTMLBody.replace('{!Trade__c.Buy_Currency__c}'  ,String.valueOf(newTrade.Buy_Currency__c  ));
            HTMLBody = HTMLBody.replace('{!Trade__c.Buy_Amount__c}'    ,String.valueOf(newTrade.Buy_Amount__c    ));
            HTMLBody = HTMLBody.replace('{!Trade__c.Rate__c}'          ,String.valueOf(newTrade.Rate__c          ));
            HTMLBody = HTMLBody.replace('{!Trade__c.CreatedDate}'      ,String.valueOf(newTrade.CreatedDate.format('dd-MM-yyyy h:mm a')));
            HTMLBody = HTMLBody.replace('{!Trade__c.Link}'             ,String.valueOf(tradeLink                 ));
            
            for(String userEmail : userEmails) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.toAddresses = new String[] {userEmail}; 
                mail.setSubject (emailTemplate.Subject); 
                mail.setHtmlBody(HTMLBody);

                mails.add(mail);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);

            for(Messaging.SendEmailResult result : results) {
                if(!result.isSuccess()) {
                    System.debug('The email failed to send: ' + result.getErrors());
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
    }

    public class RateResponse {
        @AuraEnabled public Decimal Rate      {get; set;}

        public RateResponse () {}

        public RateResponse (Map<String, Object> ratesMap, String buyCurrency) {
            this.Rate   = (Decimal)ratesMap.get(buyCurrency);
        }  
    }

    public class TradeInfo {
        @AuraEnabled public String  SellCurrency {get; set;} 
        @AuraEnabled public String  BuyCurrency  {get; set;}  
        @AuraEnabled public Decimal SellAmount   {get; set;}   
        @AuraEnabled public Decimal BuyAmount    {get; set;} 
        @AuraEnabled public Decimal Rate         {get; set;} 

        public TradeInfo () {}
    }

}
