// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SquidGame {
    mapping(address => uint256) private _balances; // 참여자별 SQD 토큰의 보유량을 관리하는 변수
    mapping(address => bool) private _isRegistered; // 참여자별 첫 방문 여부를 관리하는 변수

    mapping(address => mapping(address => uint256)) private _allowances; // 무시해도 되는 변수

    // 아래와 같은 이벤트를 `emit`하면 웹브라우저에게 어떠한 이벤트가 발생했는지 알려줄 수 있습니다.
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event PlayerEntered(
        address indexed player,
        uint256 betAmount,
        uint256 balance,
        uint256 accumulatedFund
    );

    event PlayerCompleted(bool isTopScorer, uint256 bestScore);

    uint256 private _totalSupply = 2100000000; // 전체 SQD 토큰의 발행량을 관리하는 변수
    uint256 private _totalFund = 0; // 전체 모금액을 관리하는 변수

    string private _symbol = "SQD";

    address private _owner; // owner of this contract

    uint256 private _previousBestScore = type(uint256).max;
    address private _previousBestScorer;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // 구현 완료, 테스트 미완료
    function playerEnters(address player, uint256 betAmount) public virtual {
        /*
        오징어게임에 처음으로 방문한 유저라면 100 SQD를 무료로 지급한다. (`_isRegistered` 사용)
        */
        if (!_isRegistered[player]) {
            _balances[_owner] -= 100;
            _balances[player] += 100;
            _isRegistered[player] = true;
            collectFund(player, betAmount);
        } else {
            // (일단은) 첫 참가자가 아니면 한푼도 주지 않는다.
            collectFund(player, betAmount);
        }
        emit PlayerEntered(player, betAmount, balanceOf(player), _totalFund);
    }

    // 구현 완료, 테스트 미완료
    function playerCompletes(address player, uint256 record) public virtual {
        /*
        참여자가 게임을 완주하면 그 기록을 저장한다.
        이전 기록보다 이 참여자의 기록이 낮으면 (더 빠르면) 업데이트한다.
        */
        if (_previousBestScore > record) {
            _previousBestScore = record;
            _previousBestScorer = player;
            emit PlayerCompleted(true, _previousBestScore);
        } else {
            emit PlayerCompleted(false, _previousBestScore);
        }
    }

    // 구현 완료, 테스트 미완료
    function getAddressWithFastestRecord()
        public
        view
        virtual
        returns (address)
    {
        /*
        playerCompletes에서 이미 최고기록자를 계속 업데이트하고 있었으므로, 여기서는 그냥 그 변수를 반환해주기만 하면 된다.
        */
        return _previousBestScorer;
    }

    function finishGame() public virtual {
        /*
        `winner`에게 상금을 전부 지급하고, `_totalFund`를 초기화한다.
        */
        address winner = getAddressWithFastestRecord();
        _balances[winner] += _totalFund;
        _totalFund = 0;
        _previousBestScorer = address(0);
    }

    // 구현 완료, 테스트 미완료
    function isUserRegistered(address player)
        public
        view
        virtual
        returns (bool, uint256)
    {
        return (_isRegistered[player], _balances[player]);
    }

    function totalFund() public view virtual returns (uint256) {
        return _totalFund;
    }

    // 구현 완료, 테스트 미완료
    function collectFund(address player, uint256 amount) private {
        /*
        player가 amount 만큼 베팅한 경우, balance를 줄이고 totalFund를 늘린다.
        */
        require(
            _balances[player] >= amount,
            "You can't bet more than you have."
        );
        _balances[player] -= amount;
        _totalFund += amount;
    }

    /*
    
    아래 코드는 토큰 발행 / 전송을 위한 기본적인 함수입니다.
    https://github.com/boohyunsik/myERC20/blob/master/myERC20.sol 에서 복붙했습니다.
    
    */

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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
