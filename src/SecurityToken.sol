/// SecurityToken.sol

/// TODOS:
/// [ ] Tests to show functionality working
/// [ ] Utilize DSAuth to create a whitelist that validates transfers, transferFroms, controllerTransfers, Redeems? Mints?

/*
 * This code has not been reviewed, is untested and unaudited.
 * Not recommended for mainnet.
 * Use at your own risk!
*/

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.0;

import "./ERC1644.sol";

contract SecurityToken is ERC1644 {

    mapping (address => uint) public wards;

    function hope(address usr) public view returns (bool) { return wards[usr] == 1; }
    function nope(address usr) public view returns (bool) { return wards[usr] == 0; }

    function rely(address usr) public auth { wards[usr] = 1; }
    function deny(address usr) public auth { wards[usr] = 0; }

    event TransferFailure(
        address indexed src,
        address indexed dst,
        uint wad,
        bool status,
        byte code,
        bytes32 appCode,
        bytes _data
    );

    constructor(address _controller, bytes32 _symbol)
        ERC1644(_controller, _symbol)
        public
    {}

    function transfer(address dst, uint wad) public returns (bool) {
        return transfer(dst, wad, "");
    }

    function transfer(address dst, uint wad, bytes memory _data) public returns (bool) {
        (bool can, byte code, bytes32 appCode) = canTransferFrom(msg.sender, dst, wad, _data);
        if (can) {
            return _transferWithData(dst, wad, _data);
        } else {
            emit TransferFailure(
                msg.sender,
                dst,
                wad,
                can,
                code,
                appCode,
                _data
            );
            return can;
        }
    }

    /**
     * @notice Transfers of securities may fail for a number of reasons. So this function will used to understand the
     * cause of failure by getting the byte value. Which will be the ESC that follows the EIP 1066. ESC can be mapped
     * with a reson string to understand the failure cause, table of Ethereum status code will always reside off-chain
     *
     * This implimentation uses a simple whitelist to check that the _from and the _to are whitelisted to trade the token
     *
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     * @param _data The `bytes _data` allows arbitrary data to be submitted alongside the transfer.
     * @return bool It signifies whether the transaction will be executed or not.
     * @return byte Ethereum status code (ESC)
     * @return bytes32 Application specific reason code
     */
    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32) {
        return canTransferFrom(msg.sender, _to, _value, _data);
    }

    /**
     * @notice Transfers of securities may fail for a number of reasons. So this function will used to understand the
     * cause of failure by getting the byte value. Which will be the ESC that follows the EIP 1066. ESC can be mapped
     * with a reson string to understand the failure cause, table of Ethereum status code will always reside off-chain
     *
     * This implimentation uses a simple whitelist to check that the _from and the _to are whitelisted to trade the token
     *
     * @param _from address The address which you want to transfer from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     * @param _data The `bytes _data` allows arbitrary data to be submitted alongside the transfer.
     * @return bool It signifies whether the transaction will be executed or not.
     * @return byte Ethereum status code (ESC)
     * @return bytes32 Application specific reason code
     */
    function canTransferFrom(address _from, address _to, uint256 _value, bytes memory _data) public view returns (bool, byte, bytes32) {
        if (nope(_from)) {
            // 0x56 - Invalid Sender
            return (false, 0x56, bytes32(0));
        }

        if (nope(_to)) {
            // 0x57 - Invalid Reciever
            return (false, 0x57, bytes32(0));
        }

        return (true, 0x51, bytes32(0));
    }
}
