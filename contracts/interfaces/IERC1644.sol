pragma solidity >=0.5 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract IERC1644 is IERC20 {
  
    // Controller Operation
    function isControllable() external view returns (bool);
    function controllerSend(address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;
    function controllerRedeem(address _tokenHolder, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;

    // Controller Events
    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );
}