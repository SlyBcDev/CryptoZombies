pragma solidity ^0.4.19;

import "./zombieattack.sol";
import "./erc721.sol";

/// @title Un contrat CryptoZombie
/// @author SlyBcDev
/// @notice 
/// @dev 

contract ZombieOwnership is zombieattack,erc721 {

// mapping permettant de stocker une address qui a été approuvée pour réclamer un token
mapping(uint=>address) zombieAppovals;

    // standard erc721 : fonction permettant de savoir combien de token possède l'address
function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerZombieCount[_owner];
  }


    // standard erc721 : permet de savoir à qui appartient ce token
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return zombieToOwner[_tokenId];
  }

 // On transfer le token de façon privée.
function _transfer(address _from, address _to, uint256 _tokenId) private {
      ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
      ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
      zombieToOwner[_tokenId] = _to;
      event Transfer(_from,_to,_tokenId); // on declenche l'evenement Transfer
  }

// la fonction public fait appel à la fonction privée et envoie msg.sender comme argument
  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId){
    _transfer(_to,msg.sender,_tokenId);
  }

// permet de transferer en 2 étapes: 
// 1: on approuve une adresse pour qu'elle reclame le token
  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId){
    zombieAppovals[_tokenId] = _to;
    Approval(msg.sender,_to,_tokenId);
  }

// 2: l'adresse réclame son du.
  function takeOwnership(uint256 _tokenId) public {
    require(msg.sender == zombieApprovals[_tokenId]);
    address owner = ownerOf(_tokenId); // nous avons besoin de l'adresse du proprio
    _transfer(owner,msg.sender,_tokenId);
  }
}