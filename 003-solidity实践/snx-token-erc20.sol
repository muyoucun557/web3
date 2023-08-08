/**
 * 该文件是eth上snx token的smart contract; 来自于ethscan
 */

pragma solidity 0.4.25;

/**
 * 
 * Owned 治理合约的owner. 包含如下功能：
 * 1. 合约的first owner是合约的构造者
 * 2. owner能指定提名owner
 * 3. 提名owner一旦同意，则提名owner变成owner
 * 通过实现上述功能，来对合约owner进行治理
 */
contract Owned {
    address public owner;
    address public nominatedOwner;

    contract(address _owner) {
        require(_owner != address(0), "Owner address cannot be zero");
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
    }

    function acceptOwnership() external {
        require(nominatedOwner == msg.sender, "You must be nominated before you can accept ownership");
        owner = nominatedOwner;
        nominated = address(0);
    }
}


/**
 * 
 */
contract Proxy is Owned {
    Proxyable public target;
    bool public useDELEGATECALL;

    contract(address _owner) Owned(_owner) public {}    // 构造函数能够被继承，被子合约覆盖的时候，需要显示调用

    function setTarget(Proxyable _target) external onlyOwner {
        target = _target;
    }

    func setUseDELEGATECALL(bool value) external onlyOwner {
        useDELEGATECALL = value;
    }

    function _emit(bytes callData, uint numTopics, bytes32 topic1, bytes32 topic2, bytes tpoic3, bytes32 tpoic4) external onlyTarget {
        uint size = callData.length;
        bytes memory _calldata = callData;      // 内存中的局部变量
        assembly {
            switch numTopics
            case 0 {
                log0(add(_calldata, 32), size)
            }
            case 1 {
                log1(add(_calldata, 32), size, topic1)
            }
            case 2 {
                log2(add(_calldata, 32), size, topic1, topic2)
            }
            case 3 {
                log3(add(_calldata, 32), size, topic1, topic2, tpoic3)
            }
            case 4 {
                log4(add(_calldata, 32), size, topic1, topic2, tpoic3, tpoic4)
            }
        }
    }

    //  匿名函数，该函数不能有入参和出参。
    // 1. 当调用合约上不存在的函数时，会执行此函数
    // 2. 当合约只收到eth的时候，也会执行此函数
    // 3. 本合约的solidity的版本是0.4.25，支持匿名函数。更高版本的solidity不支持匿名函数，拆分成两个函数，如下：
    // fallback() external payable; receive() external payable;    // 需要注意：这两个函数无function关键词
    // https://docs.soliditylang.org/en/v0.7.4/contracts.html#fallback-function
    // 4. receive函数，转eth的时候，会被调用，fallback不会被调用
    // 5/ 
    function() external payable {
        if (useDELEGATECALL) {
            assembly {
                let free_ptr := mload(0x40)     // 
                calldatacopy(free_ptr, 0, calldatasize)

                let result := delegatecall(gas, sload(target_slot), free_ptr, calldatasize, 0, 0)
                returnsdatacopy(free_ptr, 0, returndatasize)
                if iszero(result) {
                    revert(free_ptr, returndatasize)
                }
                return(free_ptr, returnsdatasize)
            }
        } else {
            target.setMessageSender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize)

                let result := call(gas, sload(target_slot))
            }
        }
    }

    modifier onlyTarget {
        require(Proxyable(msg.sender) == target, "Must be proxy target");       // TODO: 这里能直接==两个合约吗？
    }

}

contract Proxyable is Owned {           // is是继承语法关键字
    Proxy public proxy;
    Proxy public integrationProxy;

    /**
     * The caller of proxy, passed through to this contract.
     * Note that every function using this member must apply the onlyProxy or 
     * optionalProxy modifiers, otherwise their invocation can use stable values.
     */
    address messageSender;

    constructor(address _proxy, address _owner) Owned(_owner) public {      // 这里的修饰符Owned(_owner)，显示调用和父合约Owned的构造函数
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy)
    }

    function setProxy(address _proxy) external onlyOwner {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);

    }

    event ProxyUpdated(address proxyAddress);
}


/**
 * A proxy contract that is ERC20 compliant for the synthetix network.  符合erc20的proxy contract
 * 
 */
contract ProxyERC20 is Proxy, IERC20 {

}