
import ballerinax/java.jdbc;
import ballerina/sql;

function addEmployee(string dbFilePath, string name, string city, string department, int age) returns int {
    do {
        string db = "jdbc:h2:file:".concat(dbFilePath);
        jdbc:Client dbClient = check  new (db, "root", "root");
	    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO Employee 
        (name, city, department, age) VALUES (${name}, ${city}, ${department}, ${age})`);
        check dbClient.close();
        return <int>result.lastInsertId;
    } on fail {
    	return -1;
    }
}


