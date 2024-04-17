// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.18;

/*

1.acc Deploy()
2.acc addRecord(
0x9858a2843a0e042aeed757bb098b2d91c89297af9eb7218c14767d64f4732ebf,
 0x4befc983195a2db39b7a1559ab3cf7ba3c6a038ba130114f5c4547a017f977ba,
  12)

1.acc checkRecord(

0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
0x4befc983195a2db39b7a1559ab3cf7ba3c6a038ba130114f5c4547a017f977ba )

1.acc checkbalance(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 )

1.acc transferfunds(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)  value = 1ETH

1. acc checkbalance (0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)


*/ 

contract HealthData {
    
    struct Record {
        uint data_hash;
        uint time_mined;
        uint accessLevel;  // Numerički kod pristupa
    }
    
    address owner;
    
    mapping (address => mapping (uint => Record)) repository;
    mapping (address => uint) tokens;
    
    // Event koji uključuje opis pristupa
    event RecordAdded(
        address indexed patient,
        uint indexed full_hash,
        uint time_mined,
        uint accessCode,
        string accessDescription
    );

    // Eventi za prenos sredstava
    event FundsTransferred(address indexed patient, uint amount);
    event FundsReturned(address indexed sender, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function addRecord(uint dhash, uint fhash, uint accessCode) public {
        require(repository[msg.sender][fhash].time_mined == 0, "Record already exists");
        
        repository[msg.sender][fhash] = Record({
            data_hash: dhash,
            time_mined: block.timestamp,
            accessLevel: accessCode
        });
        
        ++tokens[msg.sender];
        string memory accessDescription = parseAccessCode(accessCode);
        emit RecordAdded(msg.sender, fhash, block.timestamp, accessCode, accessDescription);
    }
    
    function parseAccessCode(uint accessCode) internal pure returns (string memory) {
        string[5] memory tumacenje = ["RESEARCH", "PHARMA", "INSURANCE", "HEALTH REGUL", "HOSP"];
        string memory dozvola = "";
        uint code = accessCode;
        uint i = 0;

        while (code != 0) {
            uint digit = code % 10;
            if (digit > 0 && digit <= 5) {
                dozvola = string(abi.encodePacked(tumacenje[digit - 1], "; ", dozvola));
            }
            code /= 10;
            i++;
        }

        return dozvola;
    }

    function checkRecord(address patient, uint fhash) public view returns (uint, uint, uint) {
        Record memory rec = repository[patient][fhash];
        return (rec.data_hash, rec.time_mined, rec.accessLevel);
    }

    function checkBalance(address patient) public view returns (uint) {
        return tokens[patient];
    }

    function transferFunds(address payable patient) public payable {
        require(msg.sender == owner && msg.sender != patient, "Only provider can transfer funds to users.");
        
        uint amount = tokens[patient] * 1000000000000000000;
        require(amount > 0, "Patient has no tokens");
        require(msg.sender.balance >= amount && msg.value >= amount, "Not enough funds");

        (bool sent, ) = patient.call{value: amount}("");
        require(sent, "Transfer failed");
        emit FundsTransferred(patient, amount);


        /*Ako je vlasnik ugovora poslao više sredstava nego što je potrebno,
         višak se vraća vlasniku. Ako povrat sredstava ne uspe,
          transakcija se prekida s porukom "Refund failed."*/
        
        if (msg.value > amount) {
            (bool success, ) = msg.sender.call{value: msg.value - amount}("");
            require(success, "Refund failed");
            emit FundsReturned(msg.sender, msg.value - amount);
        }




        tokens[patient] = 0;
    }
}