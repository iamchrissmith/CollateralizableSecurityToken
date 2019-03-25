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

contract TokenUser {
    DSToken  token;

    constructor(DSToken token_) public {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        public
        returns (bool)
    {
        return token.transfer(to, amount);
    }

}
contract TokenController {}

contract customTest {
    event log_named_bytes1 (bytes32 key, bytes1 val);
}


contract SecurityTokenTest is customTest, DSTest {
    uint constant initialBalance = 1000;

    SecurityToken token;
    address user1;
    address user2;
    address controller;
    address self;
    bytes32 symbol = "TST";

    function setUp() public {
        controller = address(new TokenController());
        token = createToken();
        user1 = address(new TokenUser(token));
        token.mint(initialBalance);
        user2 = address(new TokenUser(token));
        self = address(this);
        uint result = token.rely(self);
        emit log_named_uint("token address", result);
        bool hope = token.hope(self);
        emit eventListener(self, hope);
    }

    function createToken() internal returns (SecurityToken) {
        return new SecurityToken(controller, symbol);
    }

    function testSetupPreconditions() public {
        assertEq(token.controller(), controller);
        assertEq(token.symbol(), symbol);
        assertEq(token.balanceOf(self), initialBalance);
        assertEq(token.owner(), self);
        assertTrue(token.hope(self));
        // assertTrue(!token.hope(user1));
        // assertTrue(!token.hope(user2));
    }

    function testValidTransfers() public logs_gas {
        uint sentAmount = 250;
        emit log_named_address("token address", address(token));
        emit log_named_uint("token address", token.totalSupply());
        emit log_named_uint("token balance user1", token.balanceOf(user1));
        emit log_named_uint("token balance user2", token.balanceOf(user2));

        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    // function testRejectCanTransferFromBadSender() public logs_gas {
    //     // calling canTransfer when the sender is not on the whitelist
    //     // should result in false, 0x56, 0x00

    //     bytes1 expectedCode = bytes1(0x51);
    //     bool nope = token.nope(user1);
    //     assertTrue(nope);
    //     bool hope = token.hope(user1);
    //     assertTrue(hope);
    //     (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(user1, user2, 1, "");
    //     assertTrue(result);
    //     assertEq32(bytes32(code), bytes32(expectedCode));
    //     assertEq32(appCode, bytes32(0));
    // }
}
