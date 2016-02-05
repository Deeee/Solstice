# Solstice code challenge



## Installation

Open and run from Solstice.xworkspace

## Supported Platforms

- iOS

## Methods

- ApplePay.setMerchantId
- ApplePay.makePaymentRequest

## ApplePay.setMerchantId

Set your Apple-given merchant ID.

	ApplePay.setMerchantId("merchant.my.id");

## ApplePay.makePaymentRequest

Request a payment with Apple Pay.

    ApplePay.makePaymentRequest(successCallback, errorCallback, order);

### Parameters

- __order.items__: Array of item objects with form ```{ label: "Item 1", amount: 1.11 }```

### Example

	ApplePay.setMerchantId("merchant.apple.test");
    
    function onError(err) {
        alert(JSON.stringify(err));
    }
    function onSuccess(response) {
        alert(response);
    }
	 
    ApplePay.makePaymentRequest(onSuccess, onError, {
    	items: [
	        { label: "item 1", amount: 1.11 },
	        { label: "item 2", amount: 2.22 }
	    ]
	);

