import { LightningElement, api, track, wire } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CURRENCIES from '@salesforce/schema/Trade__c.Sell_Currency__c';
import { getObjectInfo  } from 'lightning/uiObjectInfoApi';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';

export default class NewTrade extends LightningElement {
    //TRACKS
    @track currencyOptionList  = [];
    @track sellCurrencyOptions = [];
    @track buyCurrencyOptions  = [];
    

    //WIRES
    @wire(getObjectInfo, { objectApiName: TRADE_OBJECT })
    tradeInfo;

    @wire(getPicklistValues, { recordTypeId: '$tradeInfo.data.defaultRecordTypeId', fieldApiName: CURRENCIES })
    currencyOptions;
    

    connectedCallback() {
    }

    //HANDLES
    handleSelectedSellCurrency(element) {
        console.log('handleSelectedSellCurrency');
        
		let sellCurrency = element.target.value;
		console.log('Sell Currency: ', sellCurrency);
    }
    
    handleSelectedBuyCurrency(element) {
        console.log('handleSelectedBuyCurrency');
        
		let buyCurrency = element.target.value;
		console.log('Buy Currency: ', buyCurrency);
	}

}