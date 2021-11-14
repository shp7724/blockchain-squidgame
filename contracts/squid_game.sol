// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ERC20 {
    mapping (address => uint256) private _balances;  // 참여자별 SQD 토큰의 보유량을 관리하는 변수
    mapping (address => uint256) private _fund;  // 참여자별 모금액을 관리하는 변수
    mapping (address => uint256) private _records;  // 참여자별 완주 기록을 관리하는 변수
    mapping (address => bool) private _isFirsts;  // 참여자별 첫 방문 여부를 관리하는 변수

    mapping (address => mapping (address => uint256)) private _allowances;  // 무시해도 되는 변수

    // 아래와 같은 이벤트를 `emit`하면 웹브라우저에게 어떠한 이벤트가 발생했는지 알려줄 수 있습니다.
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 private _totalSupply = 2100000000;  // 전체 SQD 토큰의 발행량을 관리하는 변수
    uint256 private _totalFund = 0;  // 전체 모금액을 관리하는 변수

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function playerEnters(address player) public virtual {
        /*
        TODO: 오징어게임에 처음으로 방문한 유저라면 100 SQD를 무료로 지급한다. (`_isFirsts` 사용)

        코드 수정해보겠습니다.!!!!
        */
    }

    // 참여자가 게임을 완주하면 그 기록을 저장한다.
    function playerCompletes(address player, uint256 record) public virtual {
        _records[player] = record
    }
    
    function getAddressWithFastestRecord() public view virtual returns (address) {
        /*
        TODO: `_records` 변수에서 가장 빠른 기록을 가진 참여자의 지갑 주소를 반환한다.
        */
    }

    function finishGame() public virtual {
        /*
        TODO: `winner`에게 상금을 전부 지급하고, `_totalFund`와 `_fund`, `_records` 변수를 초기화한다.
        */
        address winner = getAddressWithFastestRecord();
    }

    /*
    
    아래 코드는 토큰 발행 / 전송을 위한 기본적인 함수입니다.
    https://github.com/boohyunsik/myERC20/blob/master/myERC20.sol 에서 복붙했습니다.
    
    */

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 2;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}