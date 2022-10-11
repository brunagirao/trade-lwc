import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent }                     from 'lightning/platformShowToastEvent';
import { NavigationMixin }                    from 'lightning/navigation';


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo }     from 'lightning/uiObjectInfoApi';

import CURRENCIES            from '@salesforce/schema/Trade__c.Sell_Currency__c';
import TRADE_OBJECT          from '@salesforce/schema/Trade__c';

import getRate               from '@salesforce/apex/NewTradeController.getRate';
import createNewTrade        from '@salesforce/apex/NewTradeController.createNewTrade';

export default class NewTrade extends NavigationMixin(LightningElement) {

    //API
    @api TOAST_VARIANT = {
       ERROR   : 'error',
       SUCCESS : 'success',
       WARNING : 'warning'
    }
    
    @api TOAST_TITLE = {
       ERROR   : 'Error',
       SUCCESS : 'Success',
       WARNING : 'Warning'
   }

    //TRACKS
    @track sellCurrencyOptions  = [];
    @track buyCurrencyOptions   = [];
    @track sellCurrencySelected;
    @track buyCurrencySelected;
    @track rate;
    @track buyAmount;
    @track sellAmount;
    
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
        
        if (this.buyCurrencySelected !== undefined && this.buyCurrencySelected !== null) {
            this.getRate(); 
        }
    }
    
    handleSelectedBuyCurrency(element) {
        console.log('handleSelectedBuyCurrency');
        
		this.buyCurrencySelected = element.target.value;
        console.log('Buy Currency: ', this.buyCurrencySelected);

        if (this.sellCurrencySelected !== undefined && this.sellCurrencySelected !== null) {
            this.getRate(); 
        }
        
    }

    handleSellAmountChange(element) {
        if (element.target.value < 0) {
            this.showToast(this.TOAST_TITLE.WARNING, 'Sell Amount: Cannot be negative.', this.TOAST_VARIANT.WARNING);
        } else if (this.rate !== undefined && this.rate !== null) {
            this.sellAmount = element.target.value;
            this.buyAmount  =  this.sellAmount * this.rate;
        } else {
            this.showToast(this.TOAST_TITLE.WARNING, 'Rate: No value found.', this.TOAST_VARIANT.WARNING);
        }
    }

    //ASSYNCS
    async getRate() {

        let response  = await getRate({
            sellCurrency : this.sellCurrencySelected,
            buyCurrency  : this.buyCurrencySelected,
        });

        let rateResponse = JSON.parse(response.ResponseJSON);

        if (response.HasError || rateResponse.length < 1) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Erro to get rate', this.TOAST_VARIANT.ERROR);
            setTimeout(() => {
                this.navigateToObjectHome('Trade__c');
            }, '6000');
        } else {
            this.rate = rateResponse.Rate;
        }

    }

    async createNewTrade(tradeInfo) {
        let response = await createNewTrade({
            tradeInfoJSON: JSON.stringify(tradeInfo)
        });
        
        let tradeResponse = JSON.parse(response.ResponseJSON);

        if (response.HasError || tradeResponse.length < 1) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Erro Create New Trade', this.TOAST_VARIANT.ERROR);
        } else {
            this.showToast(this.TOAST_TITLE.SUCCESS, 'Trade Created', this.TOAST_VARIANT.SUCCESS);
            setTimeout(() => {
                this.navigateToRecordPage(tradeResponse.Id, 'Trade__c');
            }, '1000');
        }
    }

    //TOAST
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
    
    //OTHER METHODS
    sendNewTrade() {
        console.log('SEND NEW TRADE');
        if (this.sellCurrencySelected == undefined || this.sellCurrencySelected == null) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Sell Currency: No currency selected.', this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.buyCurrencySelected == undefined || this.buyCurrencySelected == null) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Buy Currency: No currency selected.', this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.sellAmount < 0 ) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Sell Amount: Cannot be negative.', this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.buyAmount == undefined || this.buyAmount == null) {
            this.showToast(this.TOAST_TITLE.ERROR, 'Buy Amount: No value found.', this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.rate == undefined || this.rate == null) { 
            this.showToast(this.TOAST_TITLE.ERROR, 'Rate: No value found.', this.TOAST_VARIANT.ERROR);
            return 0;
        }

        let tradeInfo = {
            sellCurrency : this.sellCurrencySelected,
            buyCurrency  : this.buyCurrencySelected,
            sellAmount   : this.sellAmount,
            buyAmount    : this.buyAmount,
            rate         : this.rate
        }
        
        this.createNewTrade(tradeInfo);
    }

    cancelTrade() {
        setTimeout(() => {
            this.navigateToObjectHome('Trade__c');
        }, '1000');
    }

    navigateToRecordPage(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: 'view'
            }
        });
    }

    navigateToObjectHome(objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'home',
            },
        });
    }
}