import ballerina/http;

function findTheGift(string userID, string 'from, string to) returns Gift|error {
    // Write your answer here.
    // A `Gift` record is initialized to make the given function compilable.
    http:Client fifitEp = check new("http://localhost:9091/activities",{
            retryConfig: {
                interval: 3,
                count: 3,
                backOffFactor: 1.0,
                maxWaitInterval: 40,
                statusCodes: [500]
            },
            timeout: 10
    });

    http:FailoverClient insureEveryoneEp = check new ({
        timeout: 10,
        failoverCodes: [500],
        interval: 5,
        targets: [
            {url: "http://localhost:9092/insurance1"},
            {url: "http://localhost:9092/insurance2"}
        ]
    });

    worker userStepsWorker returns json|error {
        string fitUrlpath = string `/steps/user/${userID}/from/${'from}/to/${to}`;
        return  fifitEp->get(fitUrlpath);
    }
    worker userApiWorker returns json|error {
        string userUrlpath = string `/user/${userID}`;
        return insureEveryoneEp->get(userUrlpath);
    }

    json userStepsResponse = check wait  userStepsWorker;
    Activities activities = check userStepsResponse.cloneWithType();
    int[] stepsArray = from var {value} in activities.activities\-steps
                                select value;
    int totalSteps = stepsArray.reduce(function (int total, int n) returns int { return total + n; },0);
    
    json userApiResponse = check wait userApiWorker;
    UserResult userResult = check userApiResponse.cloneWithType();
    int userAge =  userResult.user.age;
    int score = totalSteps/((100-userAge)/10);
    return finalOutput(score,'from, to);
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

type UserResult record {
    record {
        int age;
    } user;
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
        # message string: Congradulations! You have won the ${type} gift!;
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
