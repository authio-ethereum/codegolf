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
    function find(bytes _code, bytes32 _k, bytes32[] _l) external {
        // Set mutex to true
        mutex = true;
        // Get rid of compiler warnings
        _k;
        _l;
        uint gas_spent;
        assembly {
            // Copy all of calldata to memory at 0
            calldatacopy(0, 4, sub(calldatasize, 4))
            
            // Get "before" gas
            gas_spent := gas
            // Deploy bytecode with parameters
            let deployed := create(0, 0, sub(calldatasize, 4))
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