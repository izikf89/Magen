// SPDX-License-Identifier: mit
pragma solidity >=0.6.0 <0.8.0;

import "../@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DateTime.sol";
import "./NewToken.sol";

contract Magen {
    address private _owner;
    mapping(string => Position) positions;
    mapping(address => Visit[]) visitOfClient;
    string[] positionsArr;
    address[] clientNeedInsulation;
    NewToken[] tokens;

    struct Client {
        address _address;
        uint256 timeIn;
        uint256 timeOut;
    }

    struct Visit {
        string positionName;
        uint256 timeIn;
        uint256 timeOut;
    }

    struct Position {
        mapping(address => Client) clients;
        address[] clientsArr;
    }

    constructor() {
        _owner = msg.sender;
        delete positionsArr;
        delete clientNeedInsulation;
        delete tokens;
    }

    function addPosition(string memory name) public {
        positionsArr.push(name);
        positions[name];
    }

    function startVisit(address clientAddress, string calldata positionName) public {
        positions[positionName].clients[clientAddress] = Client(clientAddress, block.timestamp,0);
        positions[positionName].clientsArr.push(clientAddress);

        visitOfClient[clientAddress].push(Visit(positionName, block.timestamp, 0));
    }

    function finishVisit(address clientAddress, string memory positionName)
        public
    {
        positions[positionName].clients[clientAddress].timeOut = block.timestamp;

        Visit[] storage visits = visitOfClient[clientAddress];
        visits[visits.length - 1].timeOut = block.timestamp;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function infection(address clientAddress) public payable returns (address[] memory) {
        Visit[] storage visits = visitOfClient[clientAddress];
        uint256 prevTenDaysTime = block.timestamp - (10 * 24 * 60 * 60);
        delete clientNeedInsulation;

        for (uint8 i = 0; i < visits.length; i++) {
            Visit memory visit = visits[i];
            if (visit.timeOut < prevTenDaysTime) continue;

            Position storage pos = positions[visit.positionName];

            for (uint8 j = 0; j < pos.clientsArr.length; j++) {
                Client memory client = pos.clients[pos.clientsArr[j]];

                if((client.timeIn >= visit.timeIn  && client.timeIn <= visit.timeOut) || (client.timeOut >= visit.timeIn  && client.timeOut <= visit.timeOut))
                    clientNeedInsulation.push(client._address);
                
            }

            DateTime._DateTime memory dt = DateTime.parseTimestamp(visit.timeIn + (10 * 24 * 60 * 60));
            string memory coinName = string(abi.encodePacked(
                        "Insulation_until_",
                        uintToString(dt.year),
                        "_",
                        uintToString(dt.month),
                        "_",
                        uintToString(dt.day)
                    )
                );
            NewToken t = new NewToken(clientNeedInsulation.length, coinName, coinName);
            tokens.push(t);

            for (uint8 j = 0; j < clientNeedInsulation.length; j++) {
                t.send(clientNeedInsulation[j]);
            }
        }

        return clientNeedInsulation;
    }

    function chekcInfection(address account)
        public
        view
        returns (string memory)
    {
        string memory infections = "";

        for (uint8 i = 0; i < tokens.length; i++)
            if (tokens[i].balanceOf(account) > 0)
                infections = string(
                    abi.encodePacked(infections, ", ", tokens[i].name())
                );

        return infections;
    }

    function uintToString(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}