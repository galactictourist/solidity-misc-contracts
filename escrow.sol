pragma solidity ^0.5.2;

contract Escrow {
    
    address public payer;
    address payable public payee;
    address public lawyer;
    uint public amount;
    
    constructor(
        address _payer, 
        address payable _payee,
        uint _amount
        ) public {
            
            payer = _payer;
            payee = _payee;
            amount = _amount;
            lawyer = msg.sender;
        }
        
        function deposit() payable public {
            
            require(msg.sender == payer, 'sender must be payer');
            require(address(this).balance <= amount);
        }
        
        function release() public {
            
            require(address(this).balance == amount, 'balance is not correct');
            require(msg.sender == lawyer, 'only lawyer can release funds');
            
            payee.transfer(amount);
            
        }
        
        function balanceOf() view public returns(uint){
            return address(this).balance;
        }
        
        
}