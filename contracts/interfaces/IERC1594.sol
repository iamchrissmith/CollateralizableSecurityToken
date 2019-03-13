pragma solidity >=0.5 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract IERC1594 is IERC20 {
  // Transfers
    function transferWithData(address _to, uint256 _value, bytes calldata _data) external;
    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;

    // Token Issuance
    function isIssuable() external view returns (bool);
    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;

    // Token Redemption
    function redeem(uint256 _value, bytes calldata _data) external;
    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;

    // Transfer Validity
    function canSend(address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32);
    function canSendFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (bool, byte, bytes32);

    // Issuance / Redemption Events
    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);
}