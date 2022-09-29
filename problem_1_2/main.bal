import ballerina/io;

type FuelRecord record {
    readonly int employeeId;
    int odometerReading;
    decimal gallons;
    decimal gasPrice;
};

type Output record {
    readonly int employeeId;
    int gasFillUpCount;
    decimal totalFuelCost;
    decimal totalGallons;
    int totalMilesAccrued;
};

function processFuelRecords(string inputFilePath, string outputFilePath) returns error? {
    // Write your code here
    FuelRecord[]  fuelRecords = [];

    fuelRecords = check  io:fileReadCsv(inputFilePath);

    FuelRecord[] sortedFuelRecords = from var {employeeId,odometerReading,gallons,gasPrice} in fuelRecords 
        order by employeeId 
        select {employeeId,odometerReading,gallons,gasPrice};

    table<Output> key(employeeId) outputTable = table [];
    int lastTripMiles = 0;
    foreach var item in sortedFuelRecords {
        Output? output = outputTable[item.employeeId];
        if output is () {
            outputTable.add({
                employeeId : item.employeeId, 
                gasFillUpCount: 1,
                totalFuelCost: item.gasPrice * item.gallons,
                totalGallons: item.gallons,
                totalMilesAccrued: 0
                });
                lastTripMiles = item.odometerReading;
        }else{
            output.gasFillUpCount += 1;
            output.totalFuelCost = output.totalFuelCost + (item.gasPrice * item.gallons);
            output.totalGallons += item.gallons;
            output.totalMilesAccrued = output.totalMilesAccrued + (item.odometerReading - lastTripMiles);
            lastTripMiles= item.odometerReading;
        }
    }
    
    io:Error? result = io:fileWriteCsv(outputFilePath, outputTable.toArray());
    return result;
}
