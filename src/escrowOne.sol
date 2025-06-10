// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public admin;
    address public buyer;
    address public seller;
    
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }
    State public currentState;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this");
        _;
    }
    
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this");
        _;
    }
    
    constructor(address _buyer, address _seller) {
        admin = msg.sender;
        buyer = _buyer;
        seller = _seller;
        currentState = State.AWAITING_PAYMENT;
    }
    
    function deposit() external payable onlyBuyer {
        require(currentState == State.AWAITING_PAYMENT, "Already paid");
        currentState = State.AWAITING_DELIVERY;
    }
    
    function confirmDelivery() external onlyBuyer {
        require(currentState == State.AWAITING_DELIVERY, "Not in delivery state");
        currentState = State.COMPLETE;
        payable(seller).transfer(address(this).balance);
    }
    
    function refundBuyer() external onlyAdmin {
        require(currentState == State.AWAITING_DELIVERY, "Cannot refund in current state");
        currentState = State.COMPLETE;
        payable(buyer).transfer(address(this).balance);
    }
    
    function releaseToSeller() external onlyAdmin {
        require(currentState == State.AWAITING_DELIVERY, "Cannot release in current state");
        currentState = State.COMPLETE;
        payable(seller).transfer(address(this).balance);
    }
    
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}