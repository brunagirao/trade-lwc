
# Ebury Trading App
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/trade.jpeg)
## Ebury Requirements Test
- We want to build a new web application that will allow us to create and store foreign exchange trades.
- The main view is the Ebury Trading application, which contains a Trade list view, displaying the list of already booked trades and the relevant fields

## What I used in this project
- Apex Class
- Apex Test Class
- Apex Mock Class
- [Fixer API](https://apilayer.com/marketplace/fixer-api#pricing)
- Lightning Web Component (LWC)
- Custom Labels
- Named Credentials
- Custom Settings


## IMPORTANT! | Ebury Custom Settings
- After push the components of this project in Salesforce a **Custom Setting** named **Ebury Custom Setting** will be created. So, you need fill the follow field with the correct data for the code execute as expected:
- **ApiKey**: get your key in  [Fixer API](https://apilayer.com/marketplace/fixer-api#pricing) site.
- **Ebury Queue:** TradeReviewers
- **Template Email Notification:** NewTrade


### **REQ1.** New Trade View [Done]
- **Sell Currency and Buy Currency:** initial value should be empty.
- **App:**  retrieve latest rate for the selected currency pair and display it.
- **Buy Amount:**  not be editable and be automatically calculated.
- **Rate:** not be editable.
- **Buy Amount formula:**  Sell Amount x Rate. 

### What I Made?

- I created the **New Trade View** using **LWC** as imagem below provided in the test.
- I used the **newTrade.js** of the **NewTrade LWC** provided in the test.
- I added the fields to view and follow the requirements above:  

#### Wireframe
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/new_trade_ebury.png)

#### Screen  I created | Initial field values 
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/new_trade_bruna.png)

####  Screen after selected currency pairs
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/new_trade_bruna_currency_pairs.png)

#### Screen after fill Sell Amount 
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/new_trade_bruna_buy_amount_calculeted.png)

### **REQ2.** Send a notification after Trade Creation [Done]
- Notify all users in a queue named **Trade Reviewers**.
- Content of notification: <br>
		“A new trade has been created with the following data: <br>
		Sell Currency: {sell ccy} <br>
		Sell Amount: {sell amount} <br>
		Buy Currency: {buy ccy} <br>
		Buy Amount: {buy amount} <br>
		Rate: {rate} <br>
		Booked Date: {date} <br>
		Link to the trade: {trade link}"
    
### What I Made?

- I created a **Classic Email Template** named **New Trade** and add the **Template Content** provided in the test.
- I created a **Queue** named **Trade Reviewers**
- I created a **Custom Settings** named **Ebury Trading Settings** to store the main app settings.

#### Classic Email Template
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/classic_email_template.png)
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/classic_email_template_detail.png)

#### Queue
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/queue.png)

####  Custom Settings
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/custom_settings.png)
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/custom_settings_detail.png)

### **REQ3.**  Create a connection with a External Service(API) | Fixer.io | Get Latest Rate [Done]
- Create a connection with a **External Service(API)** to get Latest Rate
- Use **fixer.io(API)** to get Latest Rate.
- Use the class **NewTradeController** provided in the test to make the connection to **API Fixer.io**

### What I Made?
- I created add the link fixer.io to **CSP Trusted Sites** in Salesforce
- I created a **Named Credentials** named **GetLatestExchangeRate** to add the fixer.io endpoint that I use to make the callouts to get the latest rates.
- I added the **ApiKey** provided by fixer.io in the **Ebury Trade Settings (Custom Setting)**
- I created a standard class of response named **ActionResponse**
- I used the endpoint **/latest** of the API (returns real-time exchange rate data for all available or a specific set of currencies).

####  CSP Trusted Sites
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/csp_trusted_sites.png)

#### Named Credentials
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/named_credentials.png)

####  Ebury Trade Settings
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/custom_settings.png)
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/custom_settings_detail.png)

### **REQ4.** Test Class Coverage [Done]
- Create a connection with a **External Service(API)** to get Latest Rate
- Use **fixer.io(API)** to get Latest Rate.
- Use the class **NewTradeController** provided in the test to make the connection to **API Fixer.io**

### What I Made?
- I created a mock class named **NewTradeControllerMock** to simulate the callouts to fixer.io
- I created a test class named **NewTradeControllerTest**.
- I **covered 100%** of the classes used in this test.

###  Test Class Coverage
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/test_class.png)
![My Image](https://github.com/brunagirao/trade-lwc/blob/master/images/test_class_resumed.png)

### **REQ4.**Salesforce CLI and Salesforce DX [Done]
- This application will be deployed using **Salesforce CLI and Salesforce DX**
- Update the **build.sh** script to create the scratch org if needed and leave it ready for testing.

### What I Made?
- I worked with the **SFDX and CLI** developement to push, retrieve, run test and so on.
- I updated the **buil.sh** with the command needed to:
	- create scratch org
	- set the scratch org as default
	- push the changes
	- execute tests

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
