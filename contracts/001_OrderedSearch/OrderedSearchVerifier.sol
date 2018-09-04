pragma solidity ^0.4.24;

/**
 * @title OrderedSearch
 * @author Alexander Wade
 * 
 * ============================
 * ===== AUTHIO CODE GOLF =====
 * ============================
 *
 * submission type: bytecode
 * primary criteria: Least average gas spent over all tested inputs
 * "bonus" criteria: Shortest bytecode
 * description: Return the index at which key _k is found in the ordered list _l, or -1 if it does not exist
 * notes: 
 *  - The values passed in to this function will always be sorted from minimum to maximum
 *  - The test values will be pulled from a large set of randomly generated hashes
 *  - The list may be empty, or may be populated
 *  - Keys may exist more than once in the list
 *
 * Submit your bytecode only at the end of the challenge period, or when all contestants have signaled their
 * completion and readiness to proceed to adjudication.
 */
contract OrderedSearchVerifier {

    // Emitted once a submission is processed
    event Result(int indexed i, uint indexed gas_consumed, uint indexed code_size, bytes bytecode);

    // When the mutex is true, the contract is accepting calls from the deployed contract
    bool public mutex;  

    // Current answer
    int public ans = -2;  

    // Whether the submission answered
    bool public answered;

    /**
     * @dev The function which will be called back by the deployed submission
     * @param _idx The answer to the find query
     */
    function callback(int _idx) external {
        // Ensure the mutex is true
        require(mutex && !answered);
        ans = _idx;
        answered = true;
    } 

    /**
     * @dev Searches the ordered list _l for an occurance of _k. Emits
     *      a Result event containing the output of the algorithm.
     * @param _code The bytecode to deploy
     * @param _k A key for which to search
     * @param _l An ordered (minimum to maximum) list of randomly generated hashes
     */
    function find(bytes memory _code, bytes32 _k, bytes32[] memory _l) public {
        // Set mutex to true
        mutex = true;
        // Get rid of compiler warnings
        _k;
        _l;
        uint gas_spent;
        assembly {
            // Format of calldata:
            // bytecode, _k, _l.length, _l
            let len := mload(_l)
            let ptr := add(add(0x20, _code), mload(_code))

            // Place  _k in memory after the bytecode
            mstore(ptr, _k)
            ptr := add(0x20, ptr)
            // Copy _l into memory after bytecode and _k
            let i := 0x00
            let next := len
            for { } lt(i, add(0x20, mul(0x20, len))) { i := add(0x20, i) } {
                let temp := mload(add(add(0x20, i), _l))
                mstore(add(ptr, i), next)
                next := temp
            }

            // Get "before" gas
            gas_spent := gas
            // Deploy bytecode with parameters - no wei sent, starting from the bytecode
            let cdsize := add(0x40, mload(_code))
            cdsize := add(cdsize, mul(0x20, len))
            let deployed := create(0, add(0x20, _code), cdsize)
            // Calculate gas consumed
            gas_spent := sub(gas_spent, gas)
        }
        // Ensure the submission answered
        require(answered, "submission did not submit an answer");
        delete answered;

        // Set mutex to false
        assert(mutex);
        mutex = false;

        // Emit result event
        emit Result(ans, gas_spent, _code.length, _code);
        // Reset answer
        ans = -2;
    }
}