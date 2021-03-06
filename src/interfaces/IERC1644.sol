/// IERC1644.sol

/// @title IERC1644 Controller Token Operation (part of the ERC1400 Security Token Standards)
/// @dev https://github.com/ethereum/EIPs/issues/1644

pragma solidity >=0.5 <0.6.0;

contract IERC1644 {
    // Controller Operation
    function isControllable() external view returns (bool);
    function controllerTransfer(address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external returns (bool);
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
