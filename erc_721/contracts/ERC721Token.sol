pragma solidity >=0.7.0 <0.9.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

interface ERC721 /* is ERC165 */ {
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract ERC721Token is ERC721 {
    using Address for address;
    
    mapping(address => uint) private ownerToTokenCount;
    mapping(uint => address) private idToToken;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVE = 0x150b7a02; 

    function balanceOf(address _owner) external view returns (uint256){
        return ownerToTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        return idToToken[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(msg.sender == _from, "Can't author the transfer token"); // 
        require(_from == idToToken[_tokenId], "Can't author the transfer token");

        ownerToTokenCount[_from] -= 1; //nguoi so huu token nos se tru di 1 neu chuyen di 
        ownerToTokenCount[_to] += 1; //nguoi lai phia tren
        idToToken[_tokenId] = _to; //ko dc quen, khi chuyen di thi chuyen thanh dia chi vi nguoi kia

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable{
        _safeTransferFrom(_from, _to, _tokenId, data);

    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
         _safeTransferFrom(_from, _to, _tokenId, "");
    }
   
   function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) internal{
        require(msg.sender == _from, "Can't author the transfer token"); // 
        require(_from == idToToken[_tokenId], "Can't author the transfer token");

        ownerToTokenCount[_from] -= 1; //nguoi so huu token nos se tru di 1 neu chuyen di 
        ownerToTokenCount[_to] += 1; //nguoc lai phia tren
        idToToken[_tokenId] = _to; //ko dc quen, khi chuyen di thi chuyen thanh dia chi vi nguoi kia

        emit Transfer(_from, _to, _tokenId);
        if(_to.isContract()){
            // bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data); 
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data); //khi su dung no la 1 dia chi vi co the nhan
            require(retval == MAGIC_ON_ERC721_RECEIVE , "This is SMC, so can't tranfer token"); //neu no la 1 smc thi no chua ma doan dau cua ma bytecode, luu y
            // bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            // require(retval == MAGIC_ON_ERC721_RECEIVE);
        }
   }

   function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4){

   }
}