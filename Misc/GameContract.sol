
contract CQToken is ERC20{
    uint private _airdropMaxLimit;
    uint private _startNumber;
    uint private _prizePool;
    address private _owner;
    address[] private _tickets;

    mapping(uint => bool) private _powHash;
    mapping(address => uint8) private _airdropTimes;
    mapping(address => bool) private _allowAccounts;
    mapping(address => bool) private _adminAccounts;
    
    event getFlag(address);
    event log(uint,string);
    event luckyLog(address,uint);
    event powLog(uint,bytes,address);
   
    
    constructor() ERC20("ChunQiuGameCoin","CQGC"){
        _airdropMaxLimit = 3;
        _prizePool = 1000000;
        _owner = msg.sender;
        _startNumber = block.number;
        _allowAccounts[_owner] = true;
    }
    
    // modifier
    modifier onlyOwner(){
        require(_msgSender() == _owner, "Only allow owner");
        _;
    }
    
    modifier onlyPlayer(){
        require(_allowAccounts[_msgSender()] == true, "Only ChunQiuGame's Player can play this game!");
        require(tx.origin == msg.sender, "Not allow use contrace");
        _;
    }

    modifier onlyAdmin(){
        if(_msgSender() != _owner){
            require(_adminAccounts[_msgSender()] == true, "Only admin account can use.");
        }
        _;
    }
    
    ///---------------------------------------------------------
    
    // get flag
    function payForFlag() public onlyPlayer{
        _burn(_msgSender(), 10000000);
        emit getFlag(_msgSender());
    }
    
    // airdrop
    function airdrop() public onlyPlayer{
        address msgSender = _msgSender();
        require(balanceOf(msgSender) == 0, "Not Allow!");
        require(_airdropTimes[msgSender] < _airdropMaxLimit, "Time end");
        _mint(msgSender,100000);
        _airdropTimes[msgSender] += 1;
    }
    
    // lottery start ----------------------------------------------------------
    function buyTicket() public onlyPlayer{
        _burn(_msgSender(),20000);
        _prizePool += 20000;
        _tickets.push(_msgSender());
    }
    
    function lottery() public onlyOwner{
        uint256 len = _tickets.length;
        emit log(_tickets.length,"tickets length");
        emit log(block.number,"block number");
        //require(_tickets.length >= 10 && block.number - _startNumber >= 20, "Not the right time yet");
        if(_tickets.length >= 20 && block.number - _startNumber >= 20){
            uint8 luckyPlayerNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%len);
            uint bonus = uint(_prizePool * 9 / 10);
            emit luckyLog(_tickets[luckyPlayerNumber],block.timestamp);
            _prizePool = uint(_prizePool / 10) + 1000000;
            _mint(_tickets[luckyPlayerNumber],bonus);

            _startNumber = block.number;
            delete _tickets;
            // uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
        }
    }
    
    // lottery end ---------------------------------------------------------
    
    
    
    // return info ----------------------------------------------------------
    function getOwner() public view returns(address){
        return _owner;
    }
    
    function getPrizePool() public view returns(uint){
        return _prizePool;
    }
    
    function getStartNumber() public view returns(uint){
        return _startNumber;
    }
    
    function isAllowAccount(address addr_) public view returns(bool){
        return _allowAccounts[addr_];
    }

    function isAdminAccount(address addr_) public view returns(bool){
        return _adminAccounts[addr_];
    }
    
    function canLottery() public onlyOwner view returns(bool){
        return _tickets.length >= 20 && block.number - _startNumber >= 20;
    }
    // fallback
    fallback() payable external onlyPlayer{
        _mint(_msgSender(),msg.value/1 ether * 10000);
    }
}