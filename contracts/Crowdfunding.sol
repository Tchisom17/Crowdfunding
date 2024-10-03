// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    error GoalShouldBeGreaterThanZero();
    error CampaignHasEnded();
    error CampaignOngoing();
    error NoFundsToWithdraw();

    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
    }

    mapping(uint => Campaign) public campaigns;
    uint public campaignCount;
    address public owner;

    event CampaignCreated(
        uint indexed campaignID,
        string title,
        address indexed benefactor,
        uint goal,
        uint deadline
    );
    event DonationReceived(
        uint indexed campaignID,
        address indexed donor,
        uint amount
    );
    event CampaignEnded(
        uint indexed campaignID,
        address indexed benefactor,
        uint amountRaised
    );
    event Withdrawal(
        address indexed owner,
        uint amountRaised
    );

    constructor() {
        owner = msg.sender;
    }

    // Create a new crowdfunding campaign
    function createCampaign(
    string memory _title,
    string memory _description,
    address payable _benefactor,
    uint _goal,
    uint _duration
    ) public {
        checkGoal(_goal);

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: block.timestamp + _duration,
            amountRaised: 0
        });

        emit CampaignCreated(campaignCount, _title, _benefactor, _goal, block.timestamp + _duration);
    }


    // Donate to a specific campaign
    function donate(uint _campaignID) external payable {
        Campaign storage campaign = campaigns[_campaignID];
        checkEndedCampaign(campaign.deadline);

        campaign.amountRaised += msg.value;
        emit DonationReceived(_campaignID, msg.sender, msg.value);
    }

    // End the campaign and transfer funds to the benefactor
    function endCampaign(uint _campaignID) external {
        Campaign storage campaign = campaigns[_campaignID];
        checkOngoingCampaign(campaign.deadline);

        uint amountRaised = campaign.amountRaised;
        campaign.amountRaised = 0;
        campaign.benefactor.transfer(amountRaised);
        // payable(campaign.benefactor).transfer(amountRaised);

        emit CampaignEnded(_campaignID, campaign.benefactor, amountRaised);
    }

    // Withdraw remaining funds from the contract (only owner can use)
    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        checkAvailableFunds(amount);

        payable(owner).transfer(amount);
        
        emit Withdrawal(owner, amount);
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }
    
    function checkGoal(uint _goal) private pure {
        if (_goal < 1) revert GoalShouldBeGreaterThanZero();
    }

    function checkEndedCampaign(uint _deadline) private view {
        if (block.timestamp >= _deadline)
            revert CampaignHasEnded();
    }

    function checkOngoingCampaign(uint _deadline) private view {
        if (block.timestamp < _deadline)
            revert CampaignOngoing();
    }

    function checkAvailableFunds(uint _amount) private pure {
        if (_amount < 1)
            revert NoFundsToWithdraw();
    }
}