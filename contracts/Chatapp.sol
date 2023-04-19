//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Chatapp{
    struct user{
        string name;
        friend[] friendList;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct allUsersStruct{
        string name;
        address accountAddress;
    }

    allUsersStruct[] allUsers;

    mapping(address=>user) userList;
    mapping(bytes32=>message[]) allMessages;

    function isUserExist(address pubkey) public view returns(bool){
       return bytes(userList[pubkey].name).length == 0;   
    }

    function createUser(string calldata name) external {
        require(isUserExist(msg.sender)==false, "User already exists");
        require(bytes(name).length>0, "User can not be empty");

        userList[msg.sender].name = name;
        allUsers.push(allUsersStruct(name, msg.sender));
    }

    function getUserName(address pubkey) external view returns(string memory) {
        require(isUserExist(pubkey), "User is not registered");
        return userList[pubkey].name;
    }

    function addFriend(address friendKey, string calldata name) external{
        require(isUserExist(friendKey), "Friend is not registered");
        require(isUserExist(msg.sender), "Create an account first");
        require(msg.sender !=friendKey, "User can not add themselves");
        require(isFriend(friendKey, msg.sender)==false, "Users are already friends");

        _addFriend(msg.sender, friendKey, name);
        _addFriend(friendKey, msg.sender, userList[msg.sender].name );

    }

    function isFriend(address pubkey1, address pubkey2) internal view returns(bool){
        for(uint256 i=0; i<userList[pubkey1].friendList.length; i++){
            if(userList[pubkey1].friendList[i].pubkey==pubkey2) return true;
        }

        return false;
    }

    function _addFriend(address ownerKey, address friendKey, string memory name) internal{
        friend memory newFriend = friend(friendKey, name);
        userList[ownerKey].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns(friend[] memory) {
        return userList[msg.sender].friendList;
    }

    function getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1<pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else {
            return keccak256(abi.encodePacked(pubkey2, pubkey1)); 
        }
    }

    function sendMessage(address friendKey, string calldata _msg) external{
        require(isUserExist(friendKey), "Friend is not registered");
        require(isUserExist(msg.sender), "Create an account first");
        require(isFriend(friendKey, msg.sender), "Users are not friends");

        bytes32 chatCode = getChatCode(msg.sender, friendKey);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    function readMessages(address friendKey) external view returns(message[] memory){
         bytes32 chatCode = getChatCode(msg.sender, friendKey);
         return allMessages[chatCode];
    }

    function getAllUsers() public view returns(allUsersStruct[] memory){
        return allUsers;
    }

}