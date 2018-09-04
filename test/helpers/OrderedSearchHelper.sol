pragma solidity ^0.4.24;

/**
 * @title OrderedSearchHelper
 * @dev Generates an array of hashes
 */
contract OrderedSearchHelper {

    /**
     * @dev Returns an array of bytes32 values of length _len corresponding to some passed-in seed
     * @param _len The size of the resulting array
     * @param _seed The seed from which the values in the array will be derived
     * @return arr An unsorted array of hashes
     */
    function get(uint _len, uint _seed) external pure returns (bytes32[] memory arr) {
        arr = new bytes32[](_len);

        for (uint i = 0; i < _len; i++)
            arr[i] = hash(_seed, i);
    }

    /**
     * @dev Returns the hash of a seed an index
     * @param _seed The seed from which the hash is derived
     * @param _i The index to hash with the seed
     * @return h The hash of the seed and index
     */
    function hash(uint _seed, uint _i) private pure returns (bytes32 h) {
        assembly {
            mstore(0, _seed)
            mstore(32, _i)
            h := keccak256(0, 64)
        }
    }
}