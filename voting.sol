pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract Voting {
    
      mapping(address => bool) public voters;
      
      struct Choice {
          uint id;
          string name;
          uint votes;
          
      }
      
      struct Ballot {
          uint id;
          string name;
          Choice[] choices;
          uint end;
      }
      
      mapping(uint => Ballot) ballots;
      uint nextBallotId;
      address public admin;
      mapping(address => mapping(uint => bool)) public votes;
      
      constructor() public {
          admin = msg.sender;
          
      }
      
      function addVoters(address[] calldata _voters) external onlyAdmin() {
          for(uint i = 0; i < _voters.length; i++) {
              voters[_voters[i]] = true;
          }
      }
      
      function createBallot(
          string memory name,
          string[] memory choices,
          uint offset
          ) public onlyAdmin() {
              
              ballots[nextBallotId].id = nextBallotId;
              ballots[nextBallotId].name = name;
              ballots[nextBallotId].end = now + offset;
              for(uint i=0; i < choices.length; i++){
                  ballots[nextBallotId].choices.push(Choice(i, choices[i], 0));
              }
              
          }
          
          function vote(uint ballotId, uint choiceId) external {
              require(voters[msg.sender] == true, 'only approved voters');
              require(votes[msg.sender][ballotId] == false, 'only one vote per voter');
              require(now < ballots[ballotId].end, 'only vote till end date');
              votes[msg.sender][ballotId] = true;
              ballots[ballotId].choices[choiceId].votes++;
              
          }
          
          function results(uint ballotId) 
          view 
          external
          returns(Choice[] memory) {
              require(now >= ballots[ballotId].end, 'voting still open');
              return ballots[ballotId].choices;
          }
          
          modifier onlyAdmin() {
              require(msg.sender == admin, 'only admin');
              _;
          }
    
    
}

