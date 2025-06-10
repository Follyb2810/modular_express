// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowFactory {
    address public admin;
    Escrow[] public escrows;
    
    event EscrowCreated(uint indexed escrowId, address indexed buyer, address indexed seller, address escrowAddress);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function createEscrow(address _seller) external payable returns (address) {
        require(msg.value > 0, "Must send ETH to create escrow");
        
        Escrow newEscrow = new Escrow{value: msg.value}(
            msg.sender,
            _seller,
            admin
        );
        
        escrows.push(newEscrow);
        emit EscrowCreated(escrows.length - 1, msg.sender, _seller, address(newEscrow));
        return address(newEscrow);
    }
    
    function getAllEscrows() external view returns (address[] memory) {
        address[] memory addresses = new address[](escrows.length);
        for (uint i = 0; i < escrows.length; i++) {
            addresses[i] = address(escrows[i]);
        }
        return addresses;
    }
    
    function changeAdmin(address _newAdmin) external onlyAdmin {
        admin = _newAdmin;
    }
}

contract Escrow {
    address public admin;
    address public buyer;
    address public seller;
    
    enum State { AWAITING_DELIVERY, COMPLETE, REFUNDED }
    State public currentState;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this");
        _;
    }
    
    constructor(address _buyer, address _seller, address _admin) payable {
        buyer = _buyer;
        seller = _seller;
        admin = _admin;
        currentState = State.AWAITING_DELIVERY;
    }
    
    function confirmDelivery() external onlyBuyer {
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.COMPLETE;
        payable(seller).transfer(address(this).balance);
    }
    
    function requestRefund() external onlyBuyer {
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.REFUNDED;
        payable(buyer).transfer(address(this).balance);
    }
    
    function adminRelease() external onlyAdmin {
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.COMPLETE;
        payable(seller).transfer(address(this).balance);
    }
    
    function adminRefund() external onlyAdmin {
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.REFUNDED;
        payable(buyer).transfer(address(this).balance);
    }
    
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
    
    function getDetails() external view returns (
        address, 
        address, 
        address, 
        State, 
        uint
    ) {
        return (
            admin,
            buyer,
            seller,
            currentState,
            address(this).balance
        );
    }
}