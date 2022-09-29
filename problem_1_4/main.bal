import ballerina/io;
import ballerina/xmldata;

type FuelEvent record {
    readonly string employeeId;
    string odometerReading;
    string gallons;
    string gasPrice;
};

type Output record {
    readonly string employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    // Write your code here
   xml content = check io:fileReadXml(inputFilePath);

    json jsonContent = check xmldata:toJson(content, {preserveNamespaces: false, attributePrefix: ""});

    json innerJson = check jsonContent.FuelEvents.FuelEvent;

    FuelEvent[] fuelRecords = check innerJson.cloneWithType();

    FuelEvent[] sortedFuelRecords = from var {employeeId,odometerReading,gallons,gasPrice} in fuelRecords
    order by employeeId 
    select {employeeId,odometerReading,gallons,gasPrice};

    table<Output> key(employeeId) outputTable = table [];
    int lastTripMiles = 0;
    foreach var item in sortedFuelRecords {
        Output? output = outputTable[item.employeeId];
        decimal gasPrice = check decimal:fromString(item.gasPrice);
        decimal gallons = check decimal:fromString(item.gallons);
        int odometerReading = check int:fromString(item.odometerReading);
        if output is () {
            outputTable.add({
                employeeId : item.employeeId, 
                gasFillUpCount: 1,
                totalFuelCost:  gasPrice * gallons,
                totalGallons : gallons,
                totalMilesAccrued: 0
                });
                lastTripMiles = odometerReading;
        }else{
            output.gasFillUpCount += 1;
            output.totalFuelCost = output.totalFuelCost + (gasPrice * gallons);
            output.totalGallons += gallons;
            output.totalMilesAccrued = output.totalMilesAccrued + (odometerReading - lastTripMiles);
            lastTripMiles= odometerReading;
        }
    }
    Output[] outArr = outputTable.toArray();

    xml xmlOutput = xml`<s:employeeFuelRecords xmlns:s="http://www.so2w.org">${from var {employeeId,gasFillUpCount,totalFuelCost,totalGallons,totalMilesAccrued} in outArr select xml`<s:employeeFuelRecord employeeId="${employeeId}"><s:gasFillUpCount>${gasFillUpCount}</s:gasFillUpCount><s:totalFuelCost>${totalFuelCost}</s:totalFuelCost><s:totalGallons>${totalGallons}</s:totalGallons><s:totalMilesAccrued>${totalMilesAccrued}</s:totalMilesAccrued></s:employeeFuelRecord>`}</s:employeeFuelRecords>`;
           
    io:Error? result =  io:fileWriteXml(outputFilePath, xmlOutput);
    return result;
}