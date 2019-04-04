pragma solidity ^0.5.2;

/**
 * DAO contract:
 * 1. Collects investors money (ether)
 * 2. Keep track of investor contributions with shares
 * 3. Allow investors to transfer shares
 * 4. allow investment proposals to be created and voted
 * 5. execute successful investment proposals (i.e send money)
 */

contract DAO {
    
    struct Proposal {
        uint id;
        string name;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool executed;
    }
    
    mapping(uint => Proposal) public proposals;
    uint public nextProposalId;
    mapping(address => mapping(uint => bool)) public votes;
    uint  public voteTime;
    uint public quorum; 
    address public admin;
    
    mapping(address => bool) public investors;
    mapping(address => uint) public shares;
    uint public totalShares;
    uint public availableFunds;
    uint public contributionEnd;
    
    constructor(
        uint contributionTime,
        uint _voteTime,
        uint _quorum) 
        public {
            require(_quorum > 0 && _quorum < 100, 'quorum rules');
            contributionEnd = now + contributionTime;
            voteTime = _voteTime;
            quorum = _quorum;
            admin = msg.sender;
    
    }
    
    function contribute() payable external  {
        require(now < contributionEnd, 'cannot contribute after contributionEnd');
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }
    
    function redeemShare(uint amount) external {
        require(shares[msg.sender] >= amount, 'not enough shares');
        require(availableFunds >= amount, 'not enough available funds');
        
        shares[msg.sender] -= amount;
        availableFunds -= amount;
        msg.sender.transfer(amount);
    }
    
    function transferShare(uint amount, address to) external {
         require(shares[msg.sender] >= amount, 'not enough shares');
         shares[msg.sender] -= amount;
         shares[to] += amount;
         investors[to] = true;
    }
    
    function createProposal(
        string calldata name,
        uint amount,
        address payable recipient
        ) external onlyInvestors() {
            
            require(availableFunds >= amount, 'amount too large');
            proposals[nextProposalId] = Proposal(
                nextProposalId,
                name,
                amount,
                recipient,
                0,
                now + voteTime,
                false);
                availableFunds -= amount;
                nextProposalId++;
        }
        
        function vote(uint ProposalId) external onlyInvestors() {
            Proposal storage proposal = proposals[ProposalId];
            require(votes[msg.sender][ProposalId] == false, 'only one vote per investor');
            require(now < proposal.end, 'can only vote until proposal end');
            votes[msg.sender][ProposalId] = true;
            proposal.votes += shares[msg.sender];
        }
        
        function executeProposal(uint proposalId) external onlyAdmin() {
            Proposal storage proposal = proposals[proposalId];
            require(now >= proposal.end, 'cannot execute proposal before end date');
            require(proposal.executed == false, 'already executed');
            require(proposal.votes / totalShares * 100 >= quorum, 'votes below quorum' );
            _transferEther(proposal.amount, proposal.recipient);
            
            
        }
        
        function withdrawEther(uint amount, address payable to) external onlyAdmin() {
            _transferEther(amount, to);
        }
        
        function() payable external{
            availableFunds += msg.value;
        }
        
        function _transferEther(uint amount, address payable to) internal {
            require(amount <= availableFunds, 'not enough funds');
            availableFunds -= amount;
            to.transfer(amount);
        }
        
        modifier onlyInvestors() {
            require(investors[msg.sender] == true, 'only investors');
            _;
        }
        
        modifier onlyAdmin() {
            require(msg.sender == admin, 'only admin');
            _;
        }
        
        