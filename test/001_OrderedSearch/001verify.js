let Verifier = artifacts.require('OrderedSearchVerifier')
let GetHelper = artifacts.require('OrderedSearchHelper')

contract('OrderedSearch', function (accounts) {

    // Do not paste submission here!
    let submissions = ["0x00"]

    // Results will go here
    let results = []

    let verifier
    let helper

    // Length of each haystack
    let lenA = 10
    let lenB = 50
    let lenC = 100

    // Seed for each haystack
    let seedA
    let seedB
    let seedC

    // Haystacks
    let haystackA
    let haystackB
    let haystackC

    // Needles to search for in each haystack
    let needleA
    let needleB
    let needleC

    let locA
    let locB
    let locC

    before(async () => {
        //////////////////////////////////////////////////////////
        /////////////// SUBMISSIONS GO HERE PLEASE ///////////////
        //////////////////////////////////////////////////////////
        // Paste bytecode with preceding '0x':
        // submissions.push("0x606060") example

        verifier = await Verifier.new().should.be.fulfilled
        helper = await GetHelper.new().should.be.fulfilled

        console.log("Generating seeds...")
        // Generate seeds
        seedA = 1 + Math.floor(Math.random() * 100000) // Generate a random number between 1 and 100,000
        seedB = 1 + Math.floor(Math.random() * 100000) // Generate a random number between 1 and 100,000
        seedC = 1 + Math.floor(Math.random() * 100000) // Generate a random number between 1 and 100,000
        console.log("S-A:" + seedA + "\nS-B:" + seedB + "\nS-C:" + seedC)

        console.log("Building haystacks...")
        // Create haystacks
        haystackA = await helper.get.call(lenA, seedA).should.be.fulfilled
        haystackB = await helper.get.call(lenB, seedB).should.be.fulfilled
        haystackC = await helper.get.call(lenC, seedC).should.be.fulfilled

        // Ensure valid length for each
        haystackA.length.should.be.eq(lenA)
        haystackB.length.should.be.eq(lenB)
        haystackC.length.should.be.eq(lenC)

        console.log("Finding needles...")
        // Grab a search value from each haystack
        needleA = haystackA[lenA - 1]
        needleB = haystackB[lenB - 1]
        needleC = haystackC[lenC - 1]

        // If any of the seeds are under 10,000, set the needle for that haystack equal to a different needle
        // This should give roughly a 1 in 10 chance that the needle requested is not in the haystack
        if (seedA < 10000)
            needleA = needleB
        
        if (seedB < 10000)
            needleB = needleC

        if (seedC < 10000)
            needleC = needleA

        console.log("N-A:" + needleA + "\nN-B:" + needleB + "\nN-C:" + needleC)
        
        // Sort each haystack in ascending order
        haystackA.sort()
        haystackB.sort()
        haystackC.sort()

        // console.log("H-A:" + haystackA + "\nH-B:" + haystackB + "\nH-C:" + haystackC)
        
        // Get indices of each location
        locA = haystackA.indexOf(needleA)
        locB = haystackB.indexOf(needleB)
        locC = haystackC.indexOf(needleC)

        console.log("L-A:" + locA + "\nL-B:" + locB + "\nL-C:" + locC)
    })

    for (var i = 0; i < submissions.length; i++) {
        describe("Submission " + i, async () => {

            let logs
            let target

            it("should find needle A in the first haystack", async () => {
                console.log(submissions[i])
                console.log(needleA)
                console.log(haystackA)
                logs = await verifier.find(submissions[i], needleA, haystackA).should.be.fulfilled.then((tx) => {
                    return tx.logs
                })
                // Only 1 event should have been emitted
                logs.length.should.be.eq(1)
                target = logs[0]

                // Print results
                console.log("S-" + i + " Results for A:")
                console.log("Index: " + target.args['i'])
                console.log("GasUsed: " + target.args['gas_consumed'])
                console.log("CodeSize: " + target.args['code_size'])
                // console.log("ByteCode: " + target.args['bytecode'])
            })

            it("should find needle B in the second haystack", async () => {
                logs = await verifier.find(submissions[i], needleB, haystackB).should.be.fulfilled.then((tx) => {
                    return tx.logs
                })
                // Only 1 event should have been emitted
                logs.length.should.be.eq(1)
                target = logs[0]

                // Print results
                console.log("S-" + i + " Results for B:")
                console.log("Index: " + target.args['i'])
                console.log("GasUsed: " + target.args['gas_consumed'])
                console.log("CodeSize: " + target.args['code_size'])
                // console.log("ByteCode: " + target.args['bytecode'])
            })

            it("should find needle C in the third haystack", async () => {
                logs = await verifier.find(submissions[i], needleC, haystackC).should.be.fulfilled.then((tx) => {
                    return tx.logs
                })
                // Only 1 event should have been emitted
                logs.length.should.be.eq(1)
                target = logs[0]

                // Print results
                console.log("S-" + i + " Results for C:")
                console.log("Index: " + target.args['i'])
                console.log("GasUsed: " + target.args['gas_consumed'])
                console.log("CodeSize: " + target.args['code_size'])
                // console.log("ByteCode: " + target.args['bytecode'])
            })
        })
    }
})