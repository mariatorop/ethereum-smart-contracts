// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

contract StockTipContract {
    address public owner;    // stores the Ethereum address of the contract owner.
    uint public tipPrice; // Price for viewing detailed stock tip

    struct StockTip {
        // This defines a custom struct called StockTip, which consists of three string properties: detailedTip, shortTip and reason.
        string shortTip;
        string detailedTip;
        string reason;
    }
    
    mapping(address => StockTip) private tips;   // tips is a mapping that associates owner address with their StockTip objects.
    mapping(address => bool) private hasPaid;        // hasPaid is a mapping that tracks whether a user has paid for a detailed tip.

    event TipAdded(address indexed user, string detailedTip, string shortTip, string reason);
    event TipPriceChanged(uint newPrice);
    event Withdrawal(address indexed owner, uint amount);

    // TipAdded: Triggered when the owner adds a new stock tip.
    // TipPriceChanged: Triggered when the owner changes the tip price.
    // Withdrawal: Triggered when the owner withdraws accumulated fees.

    modifier onlyOwner() {
        // ensures that only the owner can execute certain functions by checking if msg.sender (the caller) is the owner.
        require(msg.sender == owner, "Only the owner can perform this operation");
        _; 
    } 

    constructor(uint _tipPrice) {
        // sets the initial owner to the contract creator and initializes the tipPrice with the provided parameter _tipPrice.
        owner = msg.sender;
        tipPrice = _tipPrice;   // owner should add tip price on deployment
    } 

    function setTipPrice(uint _newPrice) public onlyOwner {
        // allows the owner to change the tip price. It emits a TipPriceChanged event after updating the tipPrice.
        tipPrice = _newPrice;
        emit TipPriceChanged(_newPrice);
    }

    function addTip(string memory _shortTip, string memory _detailedTip, string memory _reason) public onlyOwner{
        // enables the owner to add a new stock tip, including both detailed and short versions. 
        // It updates the tips mapping and emits a TipAdded event.
        tips[msg.sender] = StockTip( _shortTip, _detailedTip, _reason);
        emit TipAdded(msg.sender, _shortTip, _detailedTip, _reason);
    }

    function viewShortTip() public view returns (string memory) {
        // allows any user to view the short version of a tip for free.
        return tips[owner].shortTip;
    }

    function buyDetailedTip() public payable {
        // It checks that the payment is sufficient, marks the user as having paid, and returns nothing.
        require(msg.value >= tipPrice, "Insufficient payment for detailed tip");
        hasPaid[msg.sender] = true;
    }

    function viewDetailedTip() public view returns (string memory, string memory, string memory) {
        // lets users view the detailed tip IF they have paid for it
        if (hasPaid[msg.sender] == true) {
            return (tips[owner].shortTip, tips[owner].detailedTip, tips[owner].reason);
        } else {
            return ("You haven't paid for the tip!", "Please make a payment first.", "Thanks :)");
        }
    }

    function withdrawFees() public onlyOwner {
        // allows the owner to withdraw fees from the contract. 
        // It checks the contract's balance and transfers the funds to the owner.
        uint balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        payable(owner).transfer(balance);
        emit Withdrawal(owner, balance);
    }

    receive() external payable {
        // Receive payments
    }
}