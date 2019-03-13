/// SecurityToken.sol

/// TODOS:
/// [ ] Convert Transfer functions to here and in ERC1644 to use DSToken transfer signatures
/// [ ] Utilize DSAuth to create a whitelist that validates transfers, transferFroms, controllerTransfers, Redeems? Mints?
/// [ ] Tests to show functionality working

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
import "./ERC1594.sol";

contract SecurityToken is ERC1644, ERC1594 {

}