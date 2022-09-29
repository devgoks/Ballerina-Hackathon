import problem_3_5.customers;
import problem_3_5.sales;

type Q "Q1"|"Q2"|"Q3"|"Q4";

type Quarter [int, Q];

type CustomerTotalPurchase record {
    readonly string customerId;
    decimal amount;
};

function findTopXCustomers(Quarter[] quarters, int x) returns customers:Customer[]|error {
    // TODO Implement your logic here
    //loop through quaters api and find sales in those quaters and combine each quater as we loop
    sales:Sales[] allSales = [];
    sales:Sales[] salesForQuater = [];
    sales:Client salesClient = check new("http://localhost:8080/sales");
    foreach Quarter item in quarters {
        string quater;
        int year; 
        [year, quater] = item;
        salesForQuater =  check salesClient->get(year,quater);
        allSales.push(...salesForQuater);
    }

    //find total customer purchase per customer
    table<CustomerTotalPurchase> key(customerId) customerTotalPurchase = table [];
    foreach var item in allSales {
        CustomerTotalPurchase? customerPurchase = customerTotalPurchase[item.customerId];
        if customerPurchase is () {
            customerTotalPurchase.add({ customerId: item.customerId, amount: item.amount});
        }else{
            customerPurchase.amount += item.amount;
        }
    }

    //filter top customers
    CustomerTotalPurchase[] topCustomers = from var customer in customerTotalPurchase 
                    order by customer.amount descending limit x select customer;

    //call customer client to get customer details for each top customer
    customers:Customer[] finalOutput = [];
    customers:Customer customer;
    customers:Client customerClient = check new("http://localhost:8080/customers");
    foreach var item in topCustomers {
        customer = check customerClient->getBycustomerid(item.customerId);
        finalOutput.push(customer); 
    }
    return finalOutput;
}
