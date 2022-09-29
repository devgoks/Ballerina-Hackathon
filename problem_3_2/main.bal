import ims/billionairehub;

# Client ID and Client Secret to connect to the billionaire API
configurable string clientId = ?;
configurable string clientSecret = ?;

type Billionaire record {
    string name;
    float netWorth;
    string country;
    string industry;
};

public function getTopXBillionaires(string[] countries, int x) returns string[]|error {
    // Create the client connector
    billionairehub:Client cl = check new ({auth: {clientId, clientSecret}});
    Billionaire[] billionaires = [];
    foreach var country in countries {
        Billionaire[] morebillionaires =  check cl->getBillionaires(country);
        billionaires.push(...morebillionaires);
    }
    string[] topBillionaires = from var {name, netWorth} in billionaires
                                    order by netWorth descending limit x select name;
    return topBillionaires;
}
