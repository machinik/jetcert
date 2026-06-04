// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// JetCert — On-chain certificate issuer
contract JetCert {
    address public owner;
    struct Certificate {
        string recipientName; string course; string note;
        address recipient; uint256 issuedAt; bool valid;
    }
    Certificate[] public certs;
    mapping(address => uint256[]) private myCerts;
    uint256 public issueFee = 0.01 ether;
    event Issued(uint256 indexed certId, address indexed recipient, string course);
    event Revoked(uint256 indexed certId);
    constructor() { owner = msg.sender; }
    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }
    function issue(address recipient, string calldata recipientName, string calldata course, string calldata note) external payable onlyOwner returns (uint256) {
        require(msg.value >= issueFee, "Fee required");
        certs.push(Certificate(recipientName, course, note, recipient, block.timestamp, true));
        uint256 id = certs.length - 1;
        myCerts[recipient].push(id);
        emit Issued(id, recipient, course);
        return id;
    }
    function revoke(uint256 certId) external onlyOwner {
        require(certId < certs.length, "Invalid");
        certs[certId].valid = false;
        emit Revoked(certId);
    }
    function verify(uint256 certId) external view returns (Certificate memory) { return certs[certId]; }
    function getCerts(address user) external view returns (uint256[] memory) { return myCerts[user]; }
    function certCount() external view returns (uint256) { return certs.length; }
    function setFee(uint256 fee) external onlyOwner { issueFee = fee; }
    function collect() external onlyOwner { payable(owner).transfer(address(this).balance); }

    // ── PUBLIC: anyone can self-certify ─────────────────────────
    event SelfCertified(uint256 indexed certId, address indexed issuer, string course);
    function selfCert(string calldata course, string calldata note)
        external payable returns (uint256)
    {
        require(msg.value >= issueFee, "Fee required");
        certs.push(Certificate(course, course, note, msg.sender, block.timestamp, true));
        uint256 id = certs.length - 1;
        myCerts[msg.sender].push(id);
        emit SelfCertified(id, msg.sender, course);
        return id;
    }

}