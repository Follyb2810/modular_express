// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowFactory {
    address public admin;
    uint256 public adminFeePercentage; // Basis points (100 = 1%)
    address[] public allEscrows;
    
    event EscrowCreated(uint indexed escrowId, address indexed buyer, address indexed seller, address escrowAddress);
    event AdminChanged(address newAdmin);
    event FeeChanged(uint newPercentage);
    
    constructor(uint256 _feePercentage) {
        admin = msg.sender;
        adminFeePercentage = _feePercentage;
    }
    
    function createEscrow(
        address _seller,
        uint256 _expiryDays,
        bool _requireMultiSig
    ) external payable returns (address) {
        require(msg.value > 0, "Must send ETH to create escrow");
        
        Escrow newEscrow = new Escrow{value: msg.value}(
            msg.sender,
            _seller,
            admin,
            _expiryDays,
            _requireMultiSig,
            adminFeePercentage
        );
        
        allEscrows.push(address(newEscrow));
        emit EscrowCreated(allEscrows.length - 1, msg.sender, _seller, address(newEscrow));
        return address(newEscrow);
    }
    
    function changeAdmin(address _newAdmin) external {
        require(msg.sender == admin, "Only admin");
        admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }
    
    function setFeePercentage(uint256 _newPercentage) external {
        require(msg.sender == admin, "Only admin");
        require(_newPercentage <= 500, "Max 5% fee");
        adminFeePercentage = _newPercentage;
        emit FeeChanged(_newPercentage);
    }
    
    function getAllEscrows() external view returns (address[] memory) {
        return allEscrows;
    }
    
    function withdrawFees() external {
        payable(admin).transfer(address(this).balance);
    }
}

contract Escrow {
    address public admin;
    address public buyer;
    address public seller;
    uint256 public expiryTime;
    uint256 public adminFee;
    uint256 public amount;
    
    enum State { AWAITING_DELIVERY, COMPLETE, REFUNDED, DISPUTED }
    State public currentState;
    
    bool public requireMultiSig;
    bool public buyerApproved;
    bool public sellerApproved;
    
    event FundsReleased();
    event RefundIssued();
    event DisputeRaised(address by);
    event ResolutionApproved(address by);
    
    modifier onlyParties() {
        require(msg.sender == buyer || msg.sender == seller, "Not a party");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }
    
    modifier notExpired() {
        require(block.timestamp < expiryTime, "Escrow expired");
        _;
    }
    
    constructor(
        address _buyer,
        address _seller,
        address _admin,
        uint256 _expiryDays,
        bool _requireMultiSig,
        uint256 _feePercentage
    ) payable {
        buyer = _buyer;
        seller = _seller;
        admin = _admin;
        amount = msg.value;
        adminFee = (amount * _feePercentage) / 10000;
        expiryTime = block.timestamp + (_expiryDays * 1 days);
        requireMultiSig = _requireMultiSig;
    }
    
    // Buyer confirms they received goods
    function confirmDelivery() external onlyParties notExpired {
        require(msg.sender == buyer, "Only buyer can confirm");
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        
        if (requireMultiSig) {
            buyerApproved = true;
            emit ResolutionApproved(msg.sender);
            
            if (sellerApproved) {
                _releaseFunds();
            }
        } else {
            _releaseFunds();
        }
    }
    
    // Seller confirms they should be paid
    function confirmPayment() external onlyParties notExpired {
        require(msg.sender == seller, "Only seller can confirm");
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        
        if (requireMultiSig) {
            sellerApproved = true;
            emit ResolutionApproved(msg.sender);
            
            if (buyerApproved) {
                _releaseFunds();
            }
        }
    }
    
    function _releaseFunds() private {
        currentState = State.COMPLETE;
        uint256 sellerAmount = amount - adminFee;
        payable(seller).transfer(sellerAmount);
        payable(admin).transfer(adminFee);
        emit FundsReleased();
    }
    
    function requestRefund() external onlyParties notExpired {
        require(msg.sender == buyer, "Only buyer can refund");
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.REFUNDED;
        payable(buyer).transfer(address(this).balance);
        emit RefundIssued();
    }
    
    function raiseDispute() external onlyParties notExpired {
        require(currentState == State.AWAITING_DELIVERY, "Invalid state");
        currentState = State.DISPUTED;
        emit DisputeRaised(msg.sender);
    }
    
    function adminResolution(bool _releaseToSeller) external onlyAdmin {
        require(currentState == State.DISPUTED, "No active dispute");
        
        if (_releaseToSeller) {
            uint256 sellerAmount = amount - adminFee;
            payable(seller).transfer(sellerAmount);
            payable(admin).transfer(adminFee);
        } else {
            payable(buyer).transfer(address(this).balance);
        }
        
        currentState = State.COMPLETE;
    }
    
    function expireEscrow() external {
        require(block.timestamp >= expiryTime, "Not expired yet");
        require(currentState == State.AWAITING_DELIVERY, "Already resolved");
        
        // Default action on expiry - refund buyer
        currentState = State.REFUNDED;
        payable(buyer).transfer(address(this).balance);
        emit RefundIssued();
    }
    
    function getDetails() external view returns (
        address, address, address, State, uint, uint, bool, bool, bool
    ) {
        return (
            admin,
            buyer,
            seller,
            currentState,
            amount,
            expiryTime,
            requireMultiSig,
            buyerApproved,
            sellerApproved
        );
    }
}