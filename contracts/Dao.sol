// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
/// @title Dao Voting.
contract Dao {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single member.
    struct Member {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal\
        address member;
        uint loc;
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
        address reciever;
    }

    address public chairperson;
    uint public balance;
    uint public length;

    // This declares a state variable that
    // stores a `Member` struct for each possible address.
    mapping(address => Member) public members;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;
    Member[] public members_list;

    /// Create a new dao and choose first proposal choose one of `proposalNames`.
    constructor(bytes32[] memory proposalNames) {

        chairperson = msg.sender;
        Member memory chairpersonStruct = Member(1,false,address(0),0,msg.sender,0);
        members[chairperson] = chairpersonStruct;
        members_list.push(members[chairperson]);
        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0,
                reciever:msg.sender
            }));
        }
        length=1;
    }

    // Give `member` the right to vote on this ballot.
    // May only be called by `chairperson`.
    /*
    Functions have to be specified as being external, public, internal or private. For state variables, external is not possible.

    external
    External functions are part of the contract interface, which means they can be called from other contracts and via transactions. An external function f cannot be called internally (i.e. f() does not work, but this.f() works).

    public
    Public functions are part of the contract interface and can be either called internally or via messages. For public state variables, an automatic getter function (see below) is generated.

    internal
    Those functions and state variables can only be accessed internally (i.e. from within the current contract or contracts deriving from it), without using this. This is the default visibility level for state variables.

    private
    Private functions and state variables are only visible for the contract they are defined in and not in derived contracts
    */
    function giveRightToVote(address member) external {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !members[member].voted,
            "The member already voted."
        );
        require(members[member].weight == 0);
        require(members[member].loc !=0 );
        members[member].weight = 1;
        members_list.push(members[member]);

    }

    // It is important to also provide the
    // `payable` keyword here, otherwise the function will
    // automatically reject all Ether sent to it.
    function joinDao() payable public{
        require(
            msg.value == 200,
            "correctAmountDeposited"
        );
        Member memory newMember = Member(0,false,address(0),0,msg.sender,length);
        members[msg.sender] = newMember;
        members_list.push(members[msg.sender]);
        balance+=balance;
        length+=1;
    }
    function getMembers() public view
    returns (address[] memory)
    {
         // storage keyword defines a variable as permantely stored with the smart contract
         address[] memory  _members_list = new address[](length);
         for (uint i = 0; i < members_list.length; i++) {
           _members_list[i]=members_list[i].member;

         }
         return _members_list;
    }

    /// Delegate your vote to the Member `to`.
    function delegate(address to) external {
        // assigns reference
        Member storage sender = members[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (members[to].delegate != address(0)) {
            to = members[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        // Since `sender` is a reference, this
        // modifies `memebers[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Member storage delegate_ = members[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) external {
        Member storage sender = members[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
    //memory clarifes somethings as temporarily stored, will be wiped once the action is complete
    function newProposal(bytes32[] memory proposalNames) public  {
        require(chairperson == msg.sender);
        members[chairperson].weight = 1;
        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        delete proposals;
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0,
                reciever:msg.sender
            }));
        }
        for (uint i = 0; i < members_list.length; i++) {
            members_list[i].weight=1;
            members[members_list[i].member] = members_list[i];

        }
    }
}
