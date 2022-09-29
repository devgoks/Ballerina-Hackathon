import ballerina/http;

# The exchange rate API base URL
configurable string apiUrl = "http://localhost:8080";

type Rates record {|
    string base;
    map<decimal> rates;
|};

# Convert provided salary to local currency
#
# + salary - Salary in source currency
# + sourceCurrency - Soruce currency
# + localCurrency - Employee's local currency
# + return - Salary in local currency or error
public function convertSalary(decimal salary, string sourceCurrency, string localCurrency) returns decimal|error {
    // TODO: Write your code here
    http:Client api = check new (apiUrl);
    json ratesJson = check api->get("/rates/".concat(sourceCurrency));
    Rates rates = check ratesJson.fromJsonWithType(Rates);
    decimal? localCurrencyRate = rates.rates[localCurrency];
    if localCurrencyRate is () {
        return error("Invalid local currency");
    }
    decimal salaryInLocalCurreny = salary * localCurrencyRate;
    return salaryInLocalCurreny;
}
