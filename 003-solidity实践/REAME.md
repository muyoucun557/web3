# solidity

remix如何调试多合约（一个合约调用另外一个合约）？

ipfs是什么？
swarm是什么？

下面是一个demo
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
```

<strong>授权部分</strong>
```comment
// SPDX-License-Identifier: GPL-3.0
```
指定授权类型，可以参看https://spdx.org/licenses/
上述例子使用的授权是GPL-3.0。如果不想做任何授权，可以使用Unlicense

<strong>solidity版本</strong>
```solidity
pragma solidity >=0.7.0 <0.9.0;
```

这里指定的solidity版本是[0.7.0,0.9.0)。是告诉编译器当前代码使用的solidity的版本。

<strong>注解</strong>
```Comment
    /**
     * @dev Store value in variable
     * @param num value to store
     */
```


## 实现加减乘除的合约
```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Cacl {
    int public result;
    
    function add(int a, int b) public returns(int c) {
        result = a + b;
        c = result;
    }

    function min(int a, int b) public returns(int) {
        result = a - b;
        return result;
    }

    function mul(int a, int b) public returns(int) {
        result = a * b;
        return result;
    }

    function div(int a, int b) public returns(int) {
        result = a / b;
        return result;
    }
}
```

<strong>public关键字</strong>
public关键字能给变量、方法提供最大的权限，让它们可供外部、内部、子合约访问到。
public关键使用在变量上的时候，会默认给合约添加一个同名方法，用于查询该变量值。

<strong>returns关键字</strong>
合约的方法能返回多个值。

