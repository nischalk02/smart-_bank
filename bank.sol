// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/// @title A simulator for banking system
/// @author Nishcal Khetan
/// @notice You can use this contract for only the most basic functioning
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

interface cETH {
    
    // define functions of COMPOUND we'll be using
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}


contract PersonalBankAccount {

    uint totalContractBalance = 0;

    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    function getTotalContractBalance() public view returns(uint){
        return totalContractBalance;
    }  
   
    mapping(address => uint) balances;
    mapping(address => uint) depositTimestamps;

    
    function addBalance() public payable {
        balances[msg.sender] = msg.value;
        totalContractBalance = totalContractBalance + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
        // send ethers to mint()
        ceth.mint{value: msg.value}();

    }


    function getAccountBalance(address userAddress) public view returns(uint256){
        return ceth.balanceOf(userAddress) * ceth.exchangeRateStored()/ 1e18;
    }
    
    function withdraw() public payable {
        
        //CAN YOU OPTIMIZE THIS FUNCTION TO HAVE FEWER LINES OF CODE?
        
        address payable withdrawTo = payable(msg.sender);
        uint amountToTransfer = getAccountBalance(msg.sender);
        
        totalContractBalance = totalContractBalance - amountToTransfer;
        balances[msg.sender] = 0;

        ceth.redeem(getAccountBalance(msg.sender));

    }
    
    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }
    
}
