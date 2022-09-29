import ballerinax/java.jdbc;

type HighPayment record {
    string name;
    string department;
    decimal amount;
    string reason;
};

function getHighPaymentDetails(string dbFilePath, decimal  amount) returns HighPayment[]|error {
    //Add your logic here.
    string db = "jdbc:h2:file:".concat(dbFilePath);
    jdbc:Client dbClient = check  new (db, "root", "root");
    stream<HighPayment, error?> resultStream = 
        dbClient->query(`SELECT Employee.name, Employee.department, Payment.amount, Payment.reason
        FROM Payment INNER JOIN Employee
        ON Payment.employee_id=Employee.employee_id
        WHERE Payment.amount > ${amount}
        Order by Payment.payment_id asc
         ;`);
    HighPayment[] highPaymentList = [];
    check from HighPayment highPayment in resultStream
    do {
        highPaymentList.push(highPayment);
    };
    check resultStream.close();
    check dbClient.close();
    return highPaymentList;
}
