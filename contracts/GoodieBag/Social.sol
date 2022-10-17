// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// a contract which handles the creation of new stratergies
// any account can create a new stratergy and it will be mapped to their address
// a stratergy includes a string name,  an array of tokens, and an optional convience fee
contract Social {
    event NewStratergy(
        address indexed account,
        string name,
        address[] tokens,
        uint256 fee
    );
    event ChangedStratergy(
        address indexed account,
        string name,
        address[] tokens,
        uint256 fee
    );
    /*  
    ================================================================
                        Structs and Mappings
    ================================================================ 
    */

    // a struct which defines a stratergy
    struct stratergy {
        string name;
        address[] tokens;
        uint256 fee;
    }

    // a mapping which maps an address to a stratergy
    mapping(address => mapping(uint256 => stratergy)) public stratergies;

    // a mapping which maps the number of stratergies an address has created
    mapping(address => uint256) public stratergyCount;

    /*  
    ================================================================
                        External Functions
    ================================================================ 
    */

    function createStratergy(
        address[] memory _tokens,
        string memory _name,
        uint256 _fee
    ) external {
        stratergies[msg.sender][stratergyCount[msg.sender]] = stratergy(
            _name,
            _tokens,
            _fee
        );
        stratergyCount[msg.sender] += 1;
        emit NewStratergy(msg.sender, _name, _tokens, _fee);
    }

    function editStratergy(
        address[] memory _tokens,
        string memory _name,
        uint256 _fee,
        uint256 _index
    ) external {
        stratergies[msg.sender][_index] = stratergy(_name, _tokens, _fee);
        emit ChangedStratergy(msg.sender, _name, _tokens, _fee);
    }

    /*
    ================================================================
                        Public returns
    ================================================================
    */

    function getStratergy(address _account, uint256 _index)
        public
        view
        returns (stratergy memory)
    {
        return stratergies[_account][_index];
    }
}
