pragma solidity ^0.4.19;

//Nous importons le contrat zombieFactory
import "./zombieFactory.sol";

// Créons une interface pour avoir accés à la fonction getKitty du smartContract CryptoKittys
contract KittyInterface{
    function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
);
}

// Nous créons un nouveau contrat qui herite des propriétées du contrat précédent ZombiFactory.
contract ZombieFeeding is ZombieFactory{

// On initie kittyContract qui est une kittyInterface de l'address du contrat de cryptoKitties

//address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;

KittyInterface kittyContract; //= KittyInterface(ckAddress);

// modifier pour vérifier que le zombie appartient bien à msg.sender
modifier ownerOf (uint _zombieId) {
  require(msg.sender == zombieToOwner[_zombieId]);
  _;
}

// ici une fonction qui permet de parramettrer manuellement et de façon externe l'adresse du contrat cryptokitties.
function setKittyContractAddress(address _address) external onlyOwner { // onlyOwner est un modifier hérité de ownable qui restreint l'utilisation de cette fonction au propriétaire.
    kittyContract = KittyInterface(_address);
  }

// permettra d'instancier le moment ou le zombie pourra de nouveau attaquer
function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

// renverra un booléen pour savoir si le zombi a attendu suffisament avant de pouvoir de nouveau attaquer
function _isReady(Zombie storage _zombie) internal view returns( bool ){
    return (_zombie.readyTime <= now);
  }

 function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal ownerOf(_zombieId){ //internal pour plus de securité
    // myZombie est une copie du zombie du zombie de msg.sender
    Zombie storage myZombie = zombies[_zombieId];

    require(_isReady(myZombie)); // on verifie que le zombie a attendu suffisament de temps.
    // verifions que l'adn soit bien de 16 chiffres
    _targetDna = _targetDna % dnaModulus;
    //faisons la moyenne des 2 adn
    uint newDna = (myZombie.dna + _targetDna) / 2;

    // Nous voulons que l'adn d'un chat Zombie finisse par 99
    if (keccak256(_species) == keccak256("kitty")){
        newDna = newDna - newDna % 100 + 99;
        //Si newDna est 334455. Alors newDna % 100 est 55, donc newDna - newDna % 100 est 334400. Enfin on ajoute 99 pour avoir 334499.
    }

    // créons notre nouveau zombie (sans nom)
    _createZombie("NoName", newDna);

    // on rajoute 1 jour afin que le zombie ne puisse pas remanger avant
    _triggerCooldown(myZombie);
  }

  // Une fonction qui va permettre de nourrir notre zombie avec l'ADN d'un cryptokitties
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    // on récupère la 10ème variable mise en retour par la fonction get kitty du contrat kitties.
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}