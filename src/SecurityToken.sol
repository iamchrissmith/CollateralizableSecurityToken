/// SecurityToken.sol

/// TODOS:
/// [ ] Utilize DSAuth to create a whitelist that validates transfers, transferFroms, controllerTransfers, Redeems? Mints?

/*
 ******************************* IMPORTANT *******************************
 *       This code has not been reviewed, is untested and unaudited.
 *                      Not recommended for mainnet.
 *                         Use at your own risk!
 *************************************************************************
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
        address indexed act,
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

    /**
     * @notice See ERC1594.sol for detailed comments
     */
    function transferWithData(address _to, uint256 _value, bytes calldata _data) external returns (bool) {
        return transfer(_to, _value, _data);
    }

    function transfer(address dst, uint wad, bytes memory _data) public returns (bool) {
        (bool can, byte code, bytes32 appCode) = _canTransferFrom(msg.sender, dst, wad, _data);
        if (can) {
            emit log_data("transferWithData", _data);
            return super.transferFrom(msg.sender, dst, wad);
        } else {
            emit TransferFailure(
                msg.sender,
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

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        return transferFrom(src, dst, wad, "");
    }

    /**
     * @notice See ERC1594.sol for detailed comments
     */
    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external returns (bool) {
        return transferFrom(_from, _to, _value, _data);
    }

    /**
     * @notice See ERC1644.sol for detailed comments
     * Have to manually reuse the transfer balance update code from ds-token as we need to bypass the src = msg.sender check for Controllers
     */
    function controllerTransfer(address src, address dst, uint256 wad, bytes calldata _data, bytes calldata _operatorData)
        external
        onlyController
        stoppable
        returns (bool)
    {
        (bool can, byte code, bytes32 appCode) = _canTransferFrom(src, dst, wad, _data);
        if (can) {
            require(_balances[src] >= wad, "controller-security-token-insufficient-balance");
            _balances[src] = sub(_balances[src], wad);
            _balances[dst] = add(_balances[dst], wad);

            emit ControllerTransfer(msg.sender, src, dst, wad, _data, _operatorData);

            return true;
        } else {
            emit TransferFailure(
                msg.sender,
                src,
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

    function transferFrom(address src, address dst, uint wad, bytes memory _data) public returns (bool) {
        (bool can, byte code, bytes32 appCode) = _canTransferFrom(src, dst, wad, _data);
        if (can) {
            emit log_data("transferFromWithData", _data);
            return super.transferFrom(src, dst, wad);
        } else {
            emit TransferFailure(
                msg.sender,
                src,
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
     * @notice See ERC1594.sol for detailed comments
     */
    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32) {
        return _canTransferFrom(msg.sender, _to, _value, _data);
    }

    /**
     * @notice See ERC1594.sol for detailed comments
     */
    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32) {
        return _canTransferFrom(_from, _to, _value, _data);
    }

    function _canTransferFrom(address src, address dst, uint256 wad, bytes memory _data) internal view returns (bool, byte, bytes32) {
        if (nope(src)) {
            // 0x56 - Invalid Sender
            return (false, 0x56, bytes32(0));
        }

        if (nope(dst)) {
            // 0x57 - Invalid Reciever
            return (false, 0x57, bytes32(0));
        }

        return (true, 0x51, bytes32(0));
    }
}
