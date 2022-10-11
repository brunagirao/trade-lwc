public with sharing class NewTradeController {

    @AuraEnabled
    public static ActionResponse.Response getRate(String sellCurrency, String buyCurrency) {

        RateResponse rateResponse;

        EburyTradeSettings__c tradeSettings = EburyTradeSettings__c.getInstance('Default');
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
                throw new CalloutException('CalloutException: ' + response.getBody());
            }

        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }

    }

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

            ActionResponse.Response tradeResponse = new ActionResponse.Response(
                false, 'Trade Created', JSON.serialize(trade)
            );
            return tradeResponse;
            
        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }
    }


    public class RateResponse {
        @AuraEnabled public String  Base      {get; set;} 
        @AuraEnabled public Boolean Success   {get; set;}
        @AuraEnabled public Decimal TimeStamp {get; set;}
        @AuraEnabled public Date    DateRate  {get; set;} 
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
