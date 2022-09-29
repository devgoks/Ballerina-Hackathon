import ballerina/io;
import ballerinax/java.jdbc;
import ballerina/sql;

type Payment record {
    readonly int employee_id;
    decimal amount;
    string reason;
    string date;
};

function addPayments(string dbFilePath, string paymentFilePath) returns error|int[] {
    //Add your logich here
    Payment[]  payments;
    json content = check io:fileReadJson(paymentFilePath);
    payments = check content.cloneWithType();

    string db = "jdbc:h2:file:".concat(dbFilePath);
    jdbc:Client dbClient = check  new (db, "root", "root");

    sql:ParameterizedQuery[] insertQueries =
        from var data in payments
        select `INSERT INTO Payment (employee_id, amount, reason,date)
                VALUES (${data.employee_id}, ${data.amount}, ${data.reason},
                ${data.date})`;

    sql:ExecutionResult[] result = check dbClient->batchExecute(insertQueries);

    int[] generatedIds = [];
    foreach var summary in result {
        generatedIds.push(<int>summary.lastInsertId);
    }
    check dbClient.close();
    return generatedIds;
}
