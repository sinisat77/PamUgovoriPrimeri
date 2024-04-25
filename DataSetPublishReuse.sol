// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.18;


/*

1.acc Deploy()
1.acc objaviSkupPodataka("21bdf05c2e98cc4f36e2ba242dc5ca74", "2c0c0a06ffcc9009a33eade898c486ac")
2.acc zahtevajSkupPodataka("21bdf05c2e98cc4f36e2ba242dc5ca74")
2.acc pristanakNaUslove() 
2.acc objaviNoviRad("ba0cc46b0d2cdcc5725b8c39ea10c03d")    - hes novog rada
kada korisnik kreira rad koji eksploatise originalne podatke
pridrizavajuci se zadatih uslova koroscenja, uz hes novonastalog rada. 

*/



contract EksploatacijaSkupovaPodataka {

    address autorSkupaPodataka;
    string hesSkupaPodataka; 
    string hesUslovaKoriscenjaPodataka;
    address reuser;
    string hesRada; 
    // Događaj koji se emituje kada se objave novi podaci
    event evObjavaSkupaPodataka(
        address _author,
        string _hesSkupaPodataka,
        string _hesUslovaKoriscenjaPodataka
    );
    // Događaj koji se emituje kada korisnik izrazi želju za korišćenjem određenih podataka 
    event evZahtevZaSkupPodataka(
        address _reuser,
        string _hesSkupaPodataka
    );
    // Događaj koji se emituje kada se podaci otpuste pod zadatim uslovima korišćenja
    event evPristanakNaUslove(
        address _from,
        address _to,
        string _hesSkupaPodataka,
        string _hesUslovaKoriscenjaPodataka
    );

    // Događaj koji se emituje kada se rad zasnovan na originalnom skupu podataka objavi
    event evObjavaRada(
        address _reuser,
        string _workHash,
        string _hesSkupaPodataka,
        string _hesUslovaKoriscenjaPodataka
    );




    function objaviSkupPodataka(string memory _hesSkupaPodataka , string memory _hesUslovaKoriscenjaPodataka)
    public returns (bool) {
        hesSkupaPodataka = _hesSkupaPodataka;
        hesUslovaKoriscenjaPodataka = _hesUslovaKoriscenjaPodataka;
        autorSkupaPodataka = msg.sender;
        emit evObjavaSkupaPodataka(autorSkupaPodataka, hesSkupaPodataka, hesUslovaKoriscenjaPodataka);
        return true;
    }

    function zahtevajSkupPodataka(string memory _hesSkupaPodataka)
    public returns (bool) {
        assert(keccak256(abi.encodePacked(_hesSkupaPodataka)) == keccak256(abi.encodePacked(hesSkupaPodataka))); 
        emit evZahtevZaSkupPodataka(msg.sender, _hesSkupaPodataka);
        return true;
    }

    function pristanakNaUslove() 
    public returns(bool) {
        reuser = msg.sender;
        emit evPristanakNaUslove(reuser, autorSkupaPodataka,
        hesSkupaPodataka, hesUslovaKoriscenjaPodataka);
        return true;
    }

    function objaviNoviRad(string memory _workHash)
    public returns (bool) {
        hesRada = _workHash;
        emit evObjavaRada(msg.sender, hesRada, hesSkupaPodataka, hesUslovaKoriscenjaPodataka);
        return true;
    }
} // end contract
