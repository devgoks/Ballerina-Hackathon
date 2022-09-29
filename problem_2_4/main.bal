import ballerinax/java.jdbc;

type HighPayment record {
    readonly string payment_id;
    decimal amount;
    string employee_name;
};

type Output record {
    readonly string employee_name;
};

function getHighPaymentEmployees(string dbFilePath, decimal amountLimit) returns string[]|error {
    //Add your logic here
    string db = "jdbc:h2:file:".concat(dbFilePath);

    jdbc:Client dbClient = check  new (db, "root", "root");
    stream<HighPayment, error?> resultStream = 
        dbClient->query(`SELECT Payment.payment_id, Payment.amount, Employee.name as employee_name 
        FROM Payment INNER JOIN Employee
        ON Payment.employee_id=Employee.employee_id
         ;`);
    check dbClient.close();

    table<HighPayment> key(payment_id) outputTable = table [];
    check from HighPayment highPayment in resultStream
    do {
        outputTable.add(highPayment);
    };
    check resultStream.close();
    string[] employeeNames = from var {amount, employee_name} in outputTable
                     where amount > amountLimit order by employee_name ascending
                     select employee_name;
    
    table<Output> key(employee_name) uniqueEmployeeNames = table [];
    foreach var item in employeeNames {
        if !uniqueEmployeeNames.hasKey(item) {
            uniqueEmployeeNames.add({ employee_name : item});
        }
    }
    return uniqueEmployeeNames.keys();
}
