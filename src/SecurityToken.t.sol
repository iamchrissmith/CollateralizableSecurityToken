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
    SecurityToken  token;

    constructor(SecurityToken token_) public {
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

    function doApprove(address recipient, uint amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doCanTransfer(address to, uint amount, bytes memory data)
        public
        view
        returns (bool, byte, bytes32)
    {
        return token.canTransfer(to, amount, data);
    }

}
contract TokenController {
    SecurityToken  token;

    modifier tokenSet() {
        require(address(token) != address(0));
        _;
    }

    function setToken(SecurityToken token_) public {
        token = token_;
    }

    function doControllerTransfer(address from, address to, uint amount, bytes memory data, bytes memory operatorData)
        public
        tokenSet
        returns (bool)
    {
        return token.controllerTransfer(from, to, amount, data, operatorData);
    }
}

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
        TokenController(controller).setToken(token);
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
        assertTrue(token.allowed(self));
        assertTrue(!token.allowed(user1));
        assertTrue(!token.allowed(user2));
    }

    function testRejectCanTransferBadSender() public logs_gas {
        // calling canTransfer when the sender is not on the whitelist
        // should result in false, 0x56, 0x00
        bytes1 expectedCode = 0x56;
        bool nope = token.allowed(user1);
        assertTrue(!nope);
        (bool result, bytes1 code, bytes32 appCode) = TokenUser(user1).doCanTransfer(user2, 1, "");
        assertTrue(!result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testRejectCanTransferForBadRecipient() public logs_gas {
        // calling canTransfer when the recipient is not on the whitelist
        // should result in false, 0x57, 0x00
        bytes1 expectedCode = 0x57;
        bool nope = token.allowed(user2);
        assertTrue(!nope);
        (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(user2, 1, "");
        assertTrue(!result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testPassCanTransferForGoodToFrom() public logs_gas {
        // calling canTransfer when the sender and recipient are on the whitelist
        // should result in true, 0x51, 0x00
        bytes1 expectedCode = 0x51;
        token.rely(user1);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        (bool result, bytes1 code, bytes32 appCode) = token.canTransfer(user1, 1, "");
        assertTrue(result);
        assertEq(code, expectedCode);
        assertEq32(appCode, bytes32(0));
    }

    function testValidTransfer() public logs_gas {
        // transfer between two valid participants should succeed
        uint sentAmount = 250;

        token.rely(user1);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        bool result = token.transfer(user1, sentAmount);
        assertTrue(result);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    function testInvalidTransferSender() public logs_gas {
        // transfer between from invalid sender should fail
        uint sentAmount = 250;

        token.deny(self);
        token.rely(user1);
        bool nopeSelf = token.allowed(self);
        assertTrue(!nopeSelf);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool result = token.transfer(user1, sentAmount);
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }

    function testInvalidTransferRecipient() public logs_gas {
        // transfer between to invalid recipient should fail
        uint sentAmount = 250;

        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        bool nopeUser = token.allowed(user1);
        assertTrue(!nopeUser);
        bool result = token.transfer(user1, sentAmount);
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }

    function testValidTransferFrom() public logs_gas {
        // transferFrom between two valid participants should succeed
        uint sentAmount = 250;
        token.approve(user2, sentAmount);

        token.rely(user1);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        bool result = TokenUser(user2).doTransferFrom(self, user1, sentAmount);
        assertTrue(result);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    function testInvalidTransferFromSender() public logs_gas {
        // transferFrom from invalid sender should fail
        uint sentAmount = 250;
        token.approve(user2, sentAmount);

        token.deny(self);
        token.rely(user1);
        bool nopeSelf = token.allowed(self);
        assertTrue(!nopeSelf);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool result = TokenUser(user2).doTransferFrom(self, user1, sentAmount);
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }

    function testInvalidTransferFromRecipient() public logs_gas {
        // transferFrom to invalid recipient should fail
        uint sentAmount = 250;
        token.approve(user2, sentAmount);

        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        bool nopeUser = token.allowed(user1);
        assertTrue(!nopeUser);
        bool result = TokenUser(user2).doTransferFrom(self, user1, sentAmount);
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }

    function testValidControllerTransfer() public logs_gas {
        // transferFrom between two valid participants should succeed
        uint sentAmount = 250;

        token.rely(user1);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        address setController = token.controller();
        assertEq(setController, controller);
        bool result = TokenController(controller).doControllerTransfer(self, user1, sentAmount, "", "forceTransfer by controller");
        assertTrue(result);
        assertEq(token.balanceOf(user1), sentAmount);
        assertEq(token.balanceOf(self), initialBalance - sentAmount);
    }

    function testInvalidControllerTransferSender() public logs_gas {
        // transferFrom from invalid sender should fail
        uint sentAmount = 250;

        token.deny(self);
        token.rely(user1);
        bool nopeSelf = token.allowed(self);
        assertTrue(!nopeSelf);
        bool hopeUser = token.allowed(user1);
        assertTrue(hopeUser);
        bool result = TokenController(controller).doControllerTransfer(self, user1, sentAmount, "", "forceTransfer by controller");
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }

    function testInvalidControllerTransferRecipient() public logs_gas {
        // transferFrom to invalid recipient should fail
        uint sentAmount = 250;

        bool hopeSelf = token.allowed(self);
        assertTrue(hopeSelf);
        bool nopeUser = token.allowed(user1);
        assertTrue(!nopeUser);
        bool result = TokenController(controller).doControllerTransfer(self, user1, sentAmount, "", "forceTransfer by controller");
        assertTrue(!result);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(self), initialBalance);
    }
}
