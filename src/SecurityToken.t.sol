/// SecurityToken.t.sol -- test for SecurityToken.sol

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

import "./SecurityToken.sol";
import "ds-test/test.sol";

contract TokenUser {}
contract TokenController {}


contract SecurityTokenTest is DSTest {
    SecurityToken token;
    address user1;
    address controller;
    address self;

    function setUp() public {
        user1 = address(new TokenUser());
        controller = address(new TokenController());
        token = createToken();
    }

    function createToken() internal returns (SecurityToken) {
        return new SecurityToken(controller, "TST");
    }

    function testSetupPrecondition() public {
        assertEq(token.controller(), controller);
    }
}
