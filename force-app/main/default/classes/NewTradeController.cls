public with sharing class NewTradeController {

    @AuraEnabled
    public static Decimal getRate(String sellCurrency, String buyCurrency) {
        System.debug('NewTradeController | getRate');
        Decimal rate;
        //get token from Custom Settings
        EburyTradeSettings__c tradeSettings = EburyTradeSettings__c.getInstance('Default');
        String apiKey = tradeSettings.ApiKey__c;
        System.debug('apiKey => ' + apiKey);
        
        if(String.isNotBlank(sellCurrency) && String.isNotBlank(buyCurrency)) {
            
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint('callout:GetLatestExchangeRate'+'/latest?symbols=' + buyCurrency + '&base=' + sellCurrency);
            request.setHeader('apikey', apiKey);
            request.setTimeout(20000);
            Http http = new Http();
            
            try {
                HttpResponse response = http.send(request);

                if(response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                    Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> ratesMap = (Map<String, Object>)resultsMap.get('rates');
                    rate = (Decimal)ratesMap.get(buyCurrency);
                } else {
                    throw new CalloutException('CalloutException: ' + response.getBody());
                }

            } catch (Exception e) {
                System.debug('Callout exception: ' + e.getMessage());
            }
        }
        return rate;
    }
}
