import ballerina/http;

function findTheGiftSimple(string userID, string 'from, string to) returns Gift|error {
    // Write your answer here for Part A.
    // An `http:Client` is initialized for you. Please note that it does not include required security configurations.
    // A `Gift` record is initialized to make the given function compilable.
    int totalSteps = check callActivitiesStepsApi(userID,'from,to);
    return finalOutput(totalSteps, 'from, to);
}

function findTheGiftComplex(string userID, string 'from, string to) returns Gift|error {
    // Write your answer here for Part B.
    // Two `http:Client`s are initialized for you. Please note that they do not include required security configurations.
    // A `Gift` record is initialized to make the given function compilable.
    int totalSteps = check callActivitiesStepsApi(userID,'from,to);
    final http:Client insureEveryoneEp = check new("https://localhost:9092/insurance", auth = {
            username: "alice",
            password: "123"
        },
        secureSocket = {
            cert: "./resources/public.crt"
        }
    );
    string userUrlpath = string `/user/${userID}`;
    json userApiJson = check insureEveryoneEp->get(userUrlpath);
    int userAge = check userApiJson.user.age;
    int score = totalSteps/((100-userAge)/10);
    return finalOutput(score, 'from, to);
}

function callActivitiesStepsApi(string userID, string 'from, string to)  returns int | error {
    final http:Client fifitEp = check new("https://localhost:9091/activities", auth = {
        refreshUrl: tokenEndpoint,
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret,
                scopes: ["admin"],
                clientConfig: {
                    secureSocket: {
                        cert: "./resources/public.crt"
                    }
                }
            },
            secureSocket = {
                cert: "./resources/public.crt"
            }
    );
    string fitUrlpath = string `/steps/user/${userID}/from/${'from}/to/${to}`;
    json jsonOutput = check fifitEp->get(fitUrlpath);
    Activities activities = check jsonOutput.cloneWithType();
    int[] stepsArray = from var {value} in activities.activities\-steps
                                select value;
    int totalSteps = stepsArray.reduce(function (int total, int n) returns int { return total + n; },0); 
    return totalSteps;
}

function finalOutput(int score, string 'from, string to) returns Gift|error {
    Types outputType = SILVER;
    if score >= SILVER_BAR && score < GOLD_BAR {
        outputType = SILVER;
    }else if score >= GOLD_BAR && score < PLATINUM_BAR {
        outputType = GOLD;
    }else if score >= PLATINUM_BAR {
        outputType = PLATINUM;
    }
    Gift gift = {
        eligible: true,
        score: score,
        'from: 'from,
        to:to,
        details: {'type: outputType, message: string `Congratulations! You have won the ${outputType} gift!`}
    };             
    return gift;
}

type Activities record {
    record {|
        string date;
        int value;
    |}[] activities\-steps;
};

type Gift record {
    boolean eligible;
    int score;
    # format yyyy-mm-dd
    string 'from;
    # format yyyy-mm-dd
    string to;
    record {|
        Types 'type;
        # message string: Congratulations! You have won the ${type} gift!;
        string message;
    |} details?;
};

enum Types {
    SILVER,
    GOLD,
    PLATINUM
}

const int SILVER_BAR = 5000;
const int GOLD_BAR = 10000;
const int PLATINUM_BAR = 20000;
