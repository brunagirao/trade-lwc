import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

//GET PICKLIST VALUES N' OBJECT INFO
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

//DEFINING VARIABLES TO GET PICKLIST AND OBJECT INFO
import CURRENCIES from '@salesforce/schema/Trade__c.Sell_Currency__c';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';

//IMPORT APEX METHODS
import getRate from '@salesforce/apex/NewTradeController.getRate';
import createNewTrade from '@salesforce/apex/NewTradeController.createNewTrade';

//CUSTOM LABELS | ET = Ebury Trading
import ET_BUY_AMOUNT_VALUE_NOT_FOUND from '@salesforce/label/c.ET_BUY_AMOUNT_VALUE_NOT_FOUND';
import ET_BUY_CURRENCY_NOT_SELECTED from '@salesforce/label/c.ET_BUY_CURRENCY_NOT_SELECTED';
import ET_RATE_VALUE_NOT_FOUND from '@salesforce/label/c.ET_RATE_VALUE_NOT_FOUND';
import ET_SELL_AMOUNT_CANNOT_BE_NEGATIVE from '@salesforce/label/c.ET_SELL_AMOUNT_CANNOT_BE_NEGATIVE';
import ET_SELL_CURRENCY_NOT_SELECTED from '@salesforce/label/c.ET_SELL_CURRENCY_NOT_SELECTED';

export default class NewTrade extends NavigationMixin(LightningElement) {

    //API
    @api TOAST_VARIANT = {
        ERROR: 'error',
        SUCCESS: 'success',
        WARNING: 'warning'
    }

    @api TOAST_TITLE = {
        ERROR: 'Error',
        SUCCESS: 'Success',
        WARNING: 'Warning'
    }

    //CUSTOM LABELS
    LABEL = {
        ET_BUY_AMOUNT_VALUE_NOT_FOUND,
        ET_BUY_CURRENCY_NOT_SELECTED,
        ET_RATE_VALUE_NOT_FOUND,
        ET_SELL_AMOUNT_CANNOT_BE_NEGATIVE,
        ET_SELL_CURRENCY_NOT_SELECTED
    }

    //TRACKS
    @track sellCurrencyOptions = [];
    @track buyCurrencyOptions = [];
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

    //CALLBACK  
    connectedCallback() {
        this.resetFields();
    }

    //HANDLES
    handleSelectedSellCurrency(element) {
        console.log('handleSelectedSellCurrency');

        this.sellCurrencySelected = element.target.value;
        console.log('Sell Currency: ', this.sellCurrencySelected);

        if (this.buyCurrencySelected !== undefined && this.buyCurrencySelected !== null && this.buyCurrencySelected !== '') {
            this.getRate();
        }
    }

    handleSelectedBuyCurrency(element) {
        console.log('handleSelectedBuyCurrency');

        this.buyCurrencySelected = element.target.value;
        console.log('Buy Currency: ', this.buyCurrencySelected);

        if (this.sellCurrencySelected !== undefined && this.sellCurrencySelected !== null && this.sellCurrencySelected !== '') {
            this.getRate();
        }

    }

    handleSellAmountChange(element) {
        if (element.target.value < 0) {
            this.showToast(this.TOAST_TITLE.WARNING, this.LABEL.ET_SELL_AMOUNT_CANNOT_BE_NEGATIVE, this.TOAST_VARIANT.WARNING);
        } else if (this.rate !== undefined && this.rate !== null) {
            this.sellAmount = element.target.value;
            this.buyAmount = this.sellAmount * this.rate;
        } else {
            this.showToast(this.TOAST_TITLE.WARNING, this.LABEL.ET_RATE_VALUE_NOT_FOUND, this.TOAST_VARIANT.WARNING);
        }
    }

    //ASYNCS
    async getRate() {
        let response = await getRate({
            sellCurrency: this.sellCurrencySelected,
            buyCurrency : this.buyCurrencySelected,
        });

        let rateResponse = JSON.parse(response.ResponseJSON);

        if (response.HasError || rateResponse.length < 1) {
            this.showToast(this.TOAST_TITLE.ERROR, response.Message, this.TOAST_VARIANT.ERROR);
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
            this.showToast(this.TOAST_TITLE.ERROR, response.Message, this.TOAST_VARIANT.ERROR);
        } else {
            this.showToast(this.TOAST_TITLE.SUCCESS, response.Message, this.TOAST_VARIANT.SUCCESS);
            this.resetFields();
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

        if (this.sellCurrencySelected == undefined || this.sellCurrencySelected == null) {
            this.showToast(this.TOAST_TITLE.ERROR, this.LABEL.ET_SELL_CURRENCY_NOT_SELECTED, this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.buyCurrencySelected == undefined || this.buyCurrencySelected == null) {
            this.showToast(this.TOAST_TITLE.ERROR, this.LABEL.ET_BUY_CURRENCY_NOT_SELECTED, this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.sellAmount < 0) {
            this.showToast(this.TOAST_TITLE.ERROR, this.LABEL.ET_SELL_AMOUNT_CANNOT_BE_NEGATIVE, this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.buyAmount == undefined || this.buyAmount == null) {
            this.showToast(this.TOAST_TITLE.ERROR, this.LABEL.ET_BUY_AMOUNT_VALUE_NOT_FOUND, this.TOAST_VARIANT.ERROR);
            return 0;
        }

        if (this.rate == undefined || this.rate == null) {
            this.showToast(this.TOAST_TITLE.ERROR, this.LABEL.ET_RATE_VALUE_NOT_FOUND, this.TOAST_VARIANT.ERROR);
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

    resetFields() {
        this.sellCurrencySelected = undefined;
        this.buyCurrencySelected  = undefined;
        this.rate                 = undefined;
        this.buyAmount            = undefined;
        this.sellAmount           = undefined;
    }

    //NAVIGATION
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