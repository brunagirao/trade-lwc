/************************************************************************************************
* Name      : ActionResponse
* Purpose   : Be a partner of response callouts
* Author    : Bruna Girão
* Date      : 07-10-2022  
--------------------------------------------------------------------------------------------------
Date                Modified By            Description
--------------------------------------------------------------------------------------------------
10-10-2022          Bruna Girão         create class 
***************************************************************************************************/
public with sharing class ActionResponse {
    public ActionResponse() {}

    public class Response {

        @AuraEnabled public Boolean HasError      {get; set;}
        @AuraEnabled public Boolean BusinessError {get; set;}
        @AuraEnabled public String Message        {get; set;}
        @AuraEnabled public String ResponseJSON   {get; set;}

        public Response (Boolean businessError, String message, String responseJSON) {
            this.HasError       = businessError;
            this.BusinessError  = businessError;
            this.Message        = message;
            this.ResponseJSON   = responseJSON;
        }

        public Response (Exception e) {
            this.HasError       = true;
            this.businessError  = false;
            this.Message        = e.getMessage();
            this.ResponseJSON   = '';
        }

        public Response (String exMessage) {
            this.HasError       = true;
            this.businessError  = false;
            this.Message        = exMessage;
            this.ResponseJSON   = '';
        }
    }
}