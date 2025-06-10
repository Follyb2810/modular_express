// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiPartyEscrow {
    address public admin;
    
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    
    struct EscrowAgreement {
        address buyer;
        address seller;
        uint256 amount;
        EscrowState state;
    }
    
    mapping(bytes32 => EscrowAgreement) public escrows;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier onlyParties(bytes32 escrowId) {
        EscrowAgreement storage agreement = escrows[escrowId];
        require(
            msg.sender == agreement.buyer || 
            msg.sender == agreement.seller, 
            "Not a party to this escrow"
        );
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function createEscrow(
        bytes32 escrowId, 
        address _seller
    ) external payable {
        require(msg.value > 0, "Must send ETH to create escrow");
        require(escrows[escrowId].buyer == address(0), "Escrow ID already exists");
        
        escrows[escrowId] = EscrowAgreement({
            buyer: msg.sender,
            seller: _seller,
            amount: msg.value,
            state: EscrowState.AWAITING_DELIVERY
        });
    }
    
    function confirmDelivery(bytes32 escrowId) external onlyParties(escrowId) {
        EscrowAgreement storage agreement = escrows[escrowId];
        require(agreement.state == EscrowState.AWAITING_DELIVERY, "Invalid state");
        
        agreement.state = EscrowState.COMPLETE;
        payable(agreement.seller).transfer(agreement.amount);
    }
    
    function requestRefund(bytes32 escrowId) external onlyParties(escrowId) {
        EscrowAgreement storage agreement = escrows[escrowId];
        require(agreement.state == EscrowState.AWAITING_DELIVERY, "Invalid state");
        agreement.state = EscrowState.REFUNDED;
        payable(agreement.buyer).transfer(agreement.amount);
    }
    
    function adminRelease(bytes32 escrowId) external onlyAdmin {
        EscrowAgreement storage agreement = escrows[escrowId];
        require(
            agreement.state == EscrowState.AWAITING_DELIVERY, 
            "Invalid state"
        );
        agreement.state = EscrowState.COMPLETE;
        payable(agreement.seller).transfer(agreement.amount);
    }
    
    function adminRefund(bytes32 escrowId) external onlyAdmin {
        EscrowAgreement storage agreement = escrows[escrowId];
        require(
            agreement.state == EscrowState.AWAITING_DELIVERY, 
            "Invalid state"
        );
        agreement.state = EscrowState.REFUNDED;
        payable(agreement.buyer).transfer(agreement.amount);
    }
    
    function getEscrowDetails(bytes32 escrowId) external view returns (
        address, 
        address, 
        uint256, 
        EscrowState
    ) {
        EscrowAgreement storage agreement = escrows[escrowId];
        return (
            agreement.buyer,
            agreement.seller,
            agreement.amount,
            agreement.state
        );
    }
}