// Introduce your solution here.
import ballerina/http;

// type PersonAccount record {
//     string name;
//     int account\ No;
// };

service http:Service / on new http:Listener(8080) {

    resource function get menu() returns http:Ok {
         http:Ok ok = {body: { "Butter Cake": 15, "Chocolate Cake": 20, "Tres Leches": 25}};
         return ok;
    }
}
