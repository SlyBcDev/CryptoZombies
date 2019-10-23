pragma solidity ^0.4.19;

// On commence par importer le contrat ownable (issu et validé par la communauté ethereum)
// qui permet de gérer l'apparetenance et le controle d'un contrat
import "./ownable.sol"; 
import "./safemath.sol";


contract ZombieFactory is ownable{

using SafeMath for uint256;
using SafeMath32 for uint32;
using SafeMath16 for uint16;

    // Les evenements permettent de communiquer avec le front end
    // Ils sont initiés en début de contrat et seront appelés plus tard.
    event NewZombie(uint zombieId, string name, uint dna);

    // permet d'etre sur que dna soit de 16 chiffres
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days; // Temps de recharge avant qu'un zombie puisse attaquer de nouveau.

    // un zombie est une structure avec un nom et un ADN
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime; // ici, le fait que 2 uint32 se suivent, permettra à solidity de regrouper les 2 variables et ainsi economiser du GAS
        uint16 winCount;
        uint16 lossCount;
    
    }

    // tableau des zombies existant
    Zombie[] public zombies;

    // en recherchant un uint (id du zombie) nous trouverons à quelle adresse appartient ce zombie.
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // fonction privée qui crée un zombie à partir d'un nom et ADN et le stock dans le tableau
    function _createZombie(string _name, uint _dna) internal { // internal parce que la fonction est appellé par un autre contrat.
        uint id = zombies.push(Zombie(_name, _dna,1,uint32(now + cooldownTime),0,0))-1; // zombies.push() renvoie un uint de la longueur du tableau,on créé une id avec ce uint.
                                                // Au dessus nous donnons 1 au level de base du zombie
                                                    // et nous initions le moment ou il pourra attaquer (on transforme le timestamp en uint32 car il est nativement uint256)


        zombieToOwner[id] = msg.sender; // l'id du zombie est attribuée à l'address de msg.sender
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1); // on augmente le nombre de zombie que possède msg.sender

        // puis on appel l'evenement .
        NewZombie(id, _name, _dna);
    }

    // fonction permettant de générer un ADN aléatoire.
    function _generateRandomDna(string _str) private view returns (uint) {
        // keccak256 (variante de SHA3) permet de return un nbr "aléatoire" de 256bits
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    // On donne un nom et solidity créé un zombie à partir de celui-ci 
    // Solidity fait appel à la fonction de génération d'ADN aléatoire 
       function createRandomZombie(string _name) public {

        //Nous vérifions d'abord que msg.sender n'a pas déjà 1 ou plusieurs zombie.   
        require(ownerZombieCount[msg.sender]==0,"Vous ne pouvez créer qu'un seul zombie!");
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}

