
// SPDX-License-Identifier: mit
pragma solidity >=0.6.0 <0.8.0;


import "../@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NewToken is ERC20 {
    address _owner;

    constructor(uint amount, string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, amount);

        _owner = msg.sender;
    }

     function send(address receiver) public {
        approve(_owner, 1);
        transferFrom(_owner, receiver, 1);
    }
}