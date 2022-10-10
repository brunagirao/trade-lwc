import { LightningElement, api, track, wire } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo }     from 'lightning/uiObjectInfoApi';

import CURRENCIES            from '@salesforce/schema/Trade__c.Sell_Currency__c';
import TRADE_OBJECT          from '@salesforce/schema/Trade__c';

import getRate from '@salesforce/apex/NewTradeController.getRate';

export default class NewTrade extends LightningElement {

    //TRACKS
    @track sellCurrencyOptions  = [];
    @track buyCurrencyOptions   = [];
    @track sellCurrencySelected;
    @track buyCurrencySelected;
    @track rate;
    
    //WIRES
    @wire(getObjectInfo, { objectApiName: TRADE_OBJECT })
    tradeInfo;

    @wire(getPicklistValues, { recordTypeId: '$tradeInfo.data.defaultRecordTypeId', fieldApiName: CURRENCIES })
    currencyOptions;

    connectedCallback() {}

    //HANDLES
    handleSelectedSellCurrency(element) {
        console.log('handleSelectedSellCurrency');
        
        this.sellCurrencySelected = element.target.value;
        console.log('Sell Currency: ', this.sellCurrencySelected);
        if (this.sellCurrencySelected != undefined || this.sellCurrencySelected != null) {
           this.getRate(); 
        };
    }
    
    handleSelectedBuyCurrency(element) {
        console.log('handleSelectedBuyCurrency');
        
		this.buyCurrencySelected = element.target.value;
        console.log('Buy Currency: ', this.buyCurrencySelected);

        if (this.buyCurrencySelected != undefined || this.buyCurrencySelected != null) {
           this.getRate(); 
        }
    }

    async getRate() {
        console.log('getRate');
        let response  = await getRate({
            sellCurrency : this.sellCurrencySelected,
            buyCurrency  : this.buyCurrencySelected,
        });
        this.rate = response;
    }

}