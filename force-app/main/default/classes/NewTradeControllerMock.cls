global with sharing class NewTradeControllerMock implements HttpCalloutMock{
    
	private Integer httpCode;

    public NewTradeControllerMock(Integer httpCode) {
        this.httpCode = httpCode;
    }

    public NewTradeControllerMock() {}

    public HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();

        switch on httpCode {
            when 200 {
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setHeader('Apikey', 'ZWKQQTDGZQCKMLCXQPN3T7EPLVECWTJK958XYTVB');
                response.setBody(getSuccessfulCall());
            } 

            when 201 {
                response.setStatus('ERROR');
                response.setStatusCode(httpCode);
                response.setHeader('Apikey', 'ZWKQQTDGZQCKMLCXQPN3T7EPLVECWTJK958XYTVB');
                response.setBody(getInvalidBaseCurrencyErrorCall());
            }

            when 202 {
                response.setStatus('ERROR');
                response.setStatusCode(httpCode);
                response.setHeader('Apikey', 'ZWKQQTDGZQCKMLCXQPN3T7EPLVECWTJK958XYTVB');
                response.setBody(getInvalidCurrencyCodesErrorCall());
            }
            
            when 401 {
                response.setStatus('ERROR');
                response.setStatusCode(httpCode);
                response.setBody(getErrorCall());
            }
            
            when else {
                response.setStatus('ERROR');
                response.setStatusCode(httpCode);
            }
        }

        return response;
    }

    private String getSuccessfulCall(){
        return (
                '    { ' +
                '        "base": "EUR",'+
                '        "date": "2022-10-12",'+
                '        "rates": { ' +
                            '"USD": 0.971076' +
                          '},' +
                '        "success": true,'+
                '        "timestamp": 1665574624'+
                '    } '
                );
    }

    private String getErrorCall(){
        return ('{'+
                    '"description": "Unauthorized",'+
                    '"message": "No API key found in request" '+
                '}');
    }

    private String getInvalidBaseCurrencyErrorCall(){
        return ('{'+
                    '"error": { '+
                        '"code": 201 '+
                        '"type": "invalid_base_currency" '+
                    '},' +
                    '"success": false '+
                '}');
    }

    private String getInvalidCurrencyCodesErrorCall(){
        return ('{'+
                    '"error": { '+
                        '"code": 202 '+
                        '"info": "You have provided one or more invalid Currency Codes. [Required format: currencies=EUR,USD,GBP,...]" '+
                        '"type": "invalid_currency_codes" '+
                    '},' +
                    '"success": false '+
                '}');
    }

    
}
