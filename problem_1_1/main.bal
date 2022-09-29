type Cublicle record {
    readonly int cublicleNo;
};

function allocateCubicles(int[] requests) returns int[] {
    // Write your code here
    table<Cublicle> key(cublicleNo) t = table [];
    foreach var item in requests {
        if !t.hasKey(item) {
            t.add({ cublicleNo : item});
        }
    }
    return t.keys().sort();
}
