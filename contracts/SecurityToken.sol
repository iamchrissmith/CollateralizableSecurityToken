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

    constructor(address _controller, bytes32 _symbol)
        ERC1644(_controller, _symbol)
        public
    {

    }
}
