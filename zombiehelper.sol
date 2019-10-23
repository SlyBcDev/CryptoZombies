pragma solidity ¨0.4.19;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding{

    // on initie les frais pour acheter un niveau supplémentaire.
    uint levelUpFee = 0.001 ether;

  // On crée un modifier avec argument qui verifiera que le zombie a bien le level requis.
  modifier aboveLevel (uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  // Fonction permettant au owner de récupérer les fonds(eth) du contrat 
  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }
  // Fonction permettant au owner de changer les frais de levelUp 
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

   // la fonction pour monter d'un niveau en payant verfifie que le montant est ok puis upgrade un niveau
   function levelUp (uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

  // permet aux zombie de niveau 2 et + de changer de nom
  function changeName (uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId){
    zombies[_zombieId].name = _newName;
  }

  // permet aux zombie de niveau 20 et + de changer d'ADN 
  function changeDna (uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId){
    zombies[_zombieId].dna = _newDna;
  }

  // Créons une fonction permettant de retourner l'armée de zombie d'un owner
  function getZombiesByOwner (address _owner) external view returns (uint[]){
      // on declare un tableau dans la memoire "vive" (moins cher que d'ecrire sur la BC), qui est un nouveau tableau dont sa length est egale au nombre de zombie que possède l'owner
    uint[] memory result = new uint [] (ownerZombieCount[_owner]);

    uint counter = 0; // Variable permettant de compter le nombre de zombies du owner 
    for(uint i = 0; i < zombies.length; i++){ // on boucle sur tous les zombies existant
      if(zombieToOwner[i] == _owner){ // si le zombie appartient à _owner
        result[counter] = i; // on ajoute l'ID du zombie au tableau
        counter = counter.add(1); // on augmlente de 1 la qte de zombies de l'armée de owner.
      }
    return result;
  }
}