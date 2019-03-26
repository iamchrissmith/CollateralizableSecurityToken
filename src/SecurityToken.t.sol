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
        token.rely(self);
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
        assertTrue(!token.hope(user1));
        assertTrue(!token.hope(user2));
    }

    function testRejectCanTransferFromBadSender() public logs_gas {
        // calling canTransfer when the sender is not on the whitelist
        // should result in false, 0x56, 0x00
        bytes1 expectedCode = 0x56;
        bool nope = token.nope(user1);
        assertTrue(nope);
        (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(user1, user2, 1, "");
        assertTrue(!result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testRejectCanTransferForBadRecipient() public logs_gas {
        // calling canTransfer when the recipient is not on the whitelist
        // should result in false, 0x57, 0x00
        bytes1 expectedCode = 0x57;
        bool nope = token.nope(user2);
        assertTrue(nope);
        (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(self, user2, 1, "");
        assertTrue(!result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testPassCanTransferForGoodToFrom() public logs_gas {
        // calling canTransfer when the sender and recipient are on the whitelist
        // should result in true, 0x51, 0x00
        bytes1 expectedCode = 0x51;
        token.rely(user1);
        bool hopeUser = token.hope(user1);
        assertTrue(hopeUser);
        (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(user1, 1, "");
        assertTrue(result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testValidTransfers() public logs_gas {
        // transfer between two valid participants should succeed
        uint sentAmount = 250;
        emit log_named_address("token address", address(token));
        emit log_named_uint("token address", token.totalSupply());
        emit log_named_uint("token balance user1", token.balanceOf(user1));
        emit log_named_uint("token balance user2", token.balanceOf(user2));

        bool hopeUser = token.hope(user1);
        assertTrue(hopeUser);
        bool hopeSelf = token.hope(self);
        assertTrue(hopeSelf);
        token.transfer(user1, sentAmount);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    function testInvalidTransfersSender() public logs_gas {
        // transfer between from invalid sender should fail
        uint sentAmount = 250;

        token.deny(self);
        bool hopeUser = token.hope(user1);
        assertTrue(hopeUser);
        bool nopeSelf = token.nope(self);
        assertTrue(nopeSelf);
        token.transfer(user1, sentAmount);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    function testInvalidTransfersRecipient() public logs_gas {
        // transfer between to invalid recipient should fail
        uint sentAmount = 250;

        token.rely(self);
        token.deny(user1);
        bool nopeUser = token.nope(user1);
        assertTrue(nopeUser);
        bool hopeSelf = token.hope(self);
        assertTrue(hopeSelf);
        token.transfer(user1, sentAmount);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }
}
