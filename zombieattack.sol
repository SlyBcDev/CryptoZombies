pragma solidity ^0.4.19;

import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper {

// compteur de tirage au sort
uint randNonce = 0;
// probabilité que l'attaquant gagne = 70%
uint attackVictoryProbability = 70;

// fonction générant un nombre aléatoire (attention methode non secure)
function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce.add(1);
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }


// fonction attaquer un zombie
function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId){

  // nous utilisons des copies des zombies attaquant et cible pour éviter les frais
  Zombie storage myZombie = zombies[_zombieId];
  Zombie storage enemyZombie = zombies[_targetId];
  uint rand = randMod(100); // calcul d'un aléatoire entre 0 et 100. 

  if (rand <= attackVictoryProbability) { // Si notre zombie gagne
      myZombie.winCount = myZombie.winCount.add(1);
      myZombie.level = myZombie.level.add(1);
      enemyZombie.lossCount = enemyZombie.lossCount.add(1);
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie"); // on obtient un nouveau zombie
    } else {
      myZombie.lossCount = myZombie.lossCount.add(1);
      enemyZombie.winCount = enemyZombie.winCount.add(1);
      }
      _triggerCoolDown(myZombie); // on lance la fonction qui rajoute 24h d'attente pour une prochaine attaque.

}

}