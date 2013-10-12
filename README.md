bitcoin
=======

This is an iOS 5.1 app for displaying the bitcoin exchange rate with USD.

The app was built on this sample code (http://www.raywenderlich.com/5492/working-with-json-in-ios-5), hence the naming. This should be changed in the next iteration.

At the moment, whenever either of the USD or BTC quantities is updated, the program gets a new ticker from MtGox, and computed the price based on a weighted average of the most recent transaction prices. 

There is one method to call MTGOX and parse the data, then the UI is updated based set on various 'update' flags, that tell us what information we need to extract from Mt.Gox (i.e. buying or selling, USD->BTC or BTC->USD).

The user can type in their price in BTC or USD, and the update flags will be set such to update the label next to it with the correct converted quantity.

The program uses an asynchronous call to get the data from MtGox- in the meantime it should show a 'loading' label.

A define flag in ViewController.h sets the commission rate.

**Next Steps**
The next step was to allow processing of different currencies - what would have happened is that the MtGox API URL would be changed based on user input, i.e. "USD", "EUR", "GBP", etc.. and the labels would be changed to reflect the new currency. (No other changes are needed).