//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Dayton on 11/12/20.
//


import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    
    let productID = "Your Product ID, AppStore Connect -> Features -> In App Purchases -> Product ID"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        //declare current class as the observer delegate who receive the information from SKPaymentTransactionObserver
        SKPaymentQueue.default().add(self)
        
        if isPurchased(){
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPurchased(){
            return quotesToShow.count
            
        }else{
            
        return quotesToShow.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        
        if indexPath.row < quotesToShow.count{
        cell.textLabel?.text = quotesToShow[indexPath.row]
        cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
        }else {
            cell.textLabel?.text = "Get More Quotes"
            cell.textLabel?.textColor = #colorLiteral(red: 0.1137254902, green: 0.6078431373, blue: 0.9647058824, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        
        
        return cell
    }
    
    //MARK: - Table View Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - In App Purchases Method
    func buyPremiumQuotes(){
        if SKPaymentQueue.canMakePayments() {
            //can make payment
            
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            
            //Add payment request to the queue
            SKPaymentQueue.default().add(paymentRequest)
                    
            //To process a payment you need to add one observer object to the queue so that when the queue updated the transaction object after payment is fulfilled, so that the queue can call the observer to provide updated transaction, process them, and remove it from the queue
            //that's why you need to implement the delegate method
            
        }else {
            //can't make payment
            print("User can't make payment")
        }
    }
    
    //will inform us when the transaction have been updated in paymentQueue
       func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
           
           //you can do multiple transaction in one go that are contained in transactions Array
           //Therefore, you need to loop through all of the array and doing operation to each of them
           for transaction in transactions {
               if transaction.transactionState == .purchased {
                   //User payment successful
                   
                   showPremiumQuotes()
                   
                   //end the transaction after it has completed
                   SKPaymentQueue.default().finishTransaction(transaction)
                   
               }else if transaction.transactionState == .failed {
                   //Payment failed
                   
                   if let error = transaction.error {
                       let errorDescription = error.localizedDescription
                       print("Transaction failed due to \(errorDescription)")
                   }
                   //end the transaction after it has completed
                   SKPaymentQueue.default().finishTransaction(transaction)
                   
               }else if transaction.transactionState == .restored {
                   showPremiumQuotes()
                   
                   print("Transaction restored")
                
                //remove restore button if your already restore the quotes
                navigationItem.setRightBarButton(nil, animated: true)
                   
                   SKPaymentQueue.default().finishTransaction(transaction)
               }
           }
           
       }
      
       func showPremiumQuotes() {
        
        //Saving the purchased feature on the app
        UserDefaults.standard.set(true, forKey: productID)
        
        
           // adds a collection inside another var to be appended.
           quotesToShow.append(contentsOf: premiumQuotes)
           tableView.reloadData()
       }
    
    func isPurchased() -> Bool {
              let purchasedStatus = UserDefaults.standard.bool(forKey: productID)
              
              if purchasedStatus {
                  print("Previously Purchased")
                  return true
                  
              }else{
                  print("Never Purchased")
                  return false
              }
              
          }
          
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        
        //ask payment queue to restore previously completed purchases
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

   
}
