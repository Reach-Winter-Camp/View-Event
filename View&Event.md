# View & Event

`View`和`Event`都在<u>应用初始化</u>阶段定义。

## View

当您希望程序外部的用户（非参与者）了解程序的当前值时，您可以使用视图 `View` 。 

例如，NFT 程序会将当前所有者公开为视图 `View` 。

### View定义

[原文链接](https://docs.reach.sh/rsh/appinit/#ref-programs-appinit-view)

有2种形式来定义 `view` ，下面是2个简单的例子：

```js
View('NFT', { owner: Address })
// 或者
View({ owner: Address })
```

视图(View)由 `View(viewName, viewInterface)` 或 `View(viewInterface)` 定义，其中 `viewName` 是一个标记 `View` 的字符串（起个名字），`viewInterface` 是一个对象，其中的每个字段是相关的合约提供的函数或值。

这些视图可通过 `ctc.views` 对象在前端使用。

在 DApp 中，此应用程序参数的结果称为 `View` 对象。

### View对象

[原文链接](https://docs.reach.sh/rsh/consensus/#ref-programs-consensus-view)

如果 `View` 是一个视图对象，那么它的字段就是相关视图的元素。

这些字段中的每一个都使用 `set` 方法绑定到一个对象，该方法接受要在当前步骤绑定到该视图的函数或值，以及由当前步骤控制的所有步骤（除非另有覆盖）。

如果这个函数没有提供参数，那么对应的视图是未设置的。

### 示例

[index.rsh](View/index.rsh)

```js
//一个模块以'reach 0.1'开头；随后是一系列导入和标识符定义
'reach 0.1';

//声明合约地址最大长度
const BS = Bytes(48);
const MA = Maybe(Address);
const MBS = Maybe(BS);

export const main = Reach.App(
  {},
  //定义参与者为Alice，参与者交互接口包括了NFT和checkView字段
  //在这个程序中，Reach 后端调用前端交互函数，checkView 与程序中每个点的视图的期望值。前端将该值与返回的值进行比较
  //使用了Fun([Domain_0, ..., Domain_N], Range)函数
  [ Participant('Alice', {
      NFT: BS,
      checkView: Fun([Tuple(MA, MBS)], Null),
    }),
    //使用View(viewName, viewInterface)来定义视图
    View('Main', {
      who: Address,
      NFT: BS,
    }),
  ],
  (A, vMain) => {
  //通过.publish 组件发布新数据
  //提交语句，写成 commit();，提交语句的延续，作为 DApp 计算的下一步。换句话说，它结束了当前的共识步骤并允许更多的本地步骤。
    A.publish(); commit();
    //interact.KEY是一个交互表达式，KEY在参与者交互接口中绑定到一个非函数类型即checkView，此处会计算使用者地址和NFT的评估，并发送一个值到前端
    A.only(() => interact.checkView([MA.None(), MBS.None()]));

    A.only(() => {
      const NFT = declassify(interact.NFT); });
    A.publish(NFT);
    //给who和NFT注入值
    vMain.who.set(A);
    vMain.NFT.set(NFT);
    commit();
    //1.有地址也有NFT
    A.only(() => interact.checkView([MA.Some(A), MBS.Some(NFT)]));

    A.publish();
    vMain.who.set();
    commit();
    //2.没有地址但是有NFT
    A.only(() => interact.checkView([MA.None(), MBS.Some(NFT)]));

    A.publish();
    vMain.who.set(A);
    vMain.NFT.set();
    commit();
    //3.有地址但是没有NFT
    A.only(() => interact.checkView([MA.Some(A), MBS.None()]));

    A.publish();
    commit();

    //4.没有地址也没有NFT
    A.only(() => interact.checkView([MA.None(), MBS.None()]));

    //退出语句，写成 exit();停止计算。
    exit();
  }
);

```

[index.mjs](View/index.mjs)

```js
import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

(async () => {
  const stdlib = await loadStdlib();
    //声明assertEq(expected, actual)函数
  const assertEq = (expected, actual) => {
    const exps = JSON.stringify(expected);
    const acts = JSON.stringify(actual);
    console.log('assertEq', {expected, actual}, {exps, acts});
    stdlib.assert(exps === acts) };
  const startingBalance = stdlib.parseCurrency(100);
    //创建了测试账户
  const accAlice = await stdlib.newTestAccount(startingBalance);
    //部署了该应用程序
  const ctcAlice = accAlice.contract(backend);

  const checkView = async (expected) => {
    console.log('checkView', expected);
    //前端将期望值与后端返回的值进行比较
      assertEq(expected, [
      await ctcAlice.v.Main.who(),
      await ctcAlice.v.Main.NFT(),
    ])};

  const NFT = `This is a test NFT`;
  await Promise.all([
    backend.Alice(ctcAlice, { NFT, checkView }),
  ]);

})();
```
终端输出（[index.txt](View/index.txt)）：

```she
checkView [ [ 'None', null ], [ 'None', null ] ]
assertEq {
  expected: [ [ 'None', null ], [ 'None', null ] ],
  actual: [ [ 'None', null ], [ 'None', null ] ]
} {
  exps: '[["None",null],["None",null]]',
  acts: '[["None",null],["None",null]]'
}
checkView [
  [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
  [
    'Some',
    'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
  ]
]
assertEq {
  expected: [
    [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
    [
      'Some',
      'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    ]
  ],
  actual: [
    [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
    [
      'Some',
      'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    ]
  ]
} {
  exps: '[["Some","0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3"],["Some","This is a test NFT\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000"]]',
  acts: '[["Some","0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3"],["Some","This is a test NFT\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000"]]'
}
checkView [
  [ 'None', null ],
  [
    'Some',
    'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
  ]
]
assertEq {
  expected: [
    [ 'None', null ],
    [
      'Some',
      'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    ]
  ],
  actual: [
    [ 'None', null ],
    [
      'Some',
      'This is a test NFT\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    ]
  ]
} {
  exps: '[["None",null],["Some","This is a test NFT\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000"]]',
  acts: '[["None",null],["Some","This is a test NFT\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000\\u0000"]]'
}
checkView [
  [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
  [ 'None', null ]
]
assertEq {
  expected: [
    [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
    [ 'None', null ]
  ],
  actual: [
    [ 'Some', '0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3' ],
    [ 'None', null ]
  ]
} {
  exps: '[["Some","0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3"],["None",null]]',
  acts: '[["Some","0x7095adD1Ce760B095659CC4De5D5e1Ab59D8D9F3"],["None",null]]'
}
checkView [ [ 'None', null ], [ 'None', null ] ]
assertEq {
  expected: [ [ 'None', null ], [ 'None', null ] ],
  actual: [ [ 'None', null ], [ 'None', null ] ]
} {
  exps: '[["None",null],["None",null]]',
  acts: '[["None",null],["None",null]]'
}
```

##  Event

当您希望程序外部的用户（非参与者）了解程序的历史时，您可以使用事件 `Event` 。

 例如，NFT 程序可以在每次所有者更改时发出一个事件，外部用户可以看到所有权变更的历史。

### Event定义

[原文链接](https://docs.reach.sh/rsh/appinit/#ref-programs-appinit-events)

有2种形式来定义 `Event` ：

```js
Events('Logger', {
    log: [UInt, Byte(64)]
})
// 或者
Events({
    log: [UInt, Byte(64)]
})
```

事件(Event)由 `Events(eventName, eventInterface)` 或 `Events(eventInterface)` 定义，其中 `eventName` 是一个标记事件的字符串（起个名字），而 `eventInterface` 是一个对象，其中每个字段都是一个 `Tuple` 类型，表示事件将发出的值的类型。

这些事件通过 `ctc.events` 对象在前端可用。

在 DApp 中，此应用程序参数的结果称为 `Event` 对象。

### Event对象

[原文链接](https://docs.reach.sh/rsh/consensus/#ref-programs-consensus-events)

```js
Logger.log(4, x);
```

如果 `Event` 是一个事件对象，那么它的字段就是相关事件的元素。这些字段中的每一个都是一个函数，其域由事件接口指定。

### 示例

[index.mjs](Event/index.mjs)

```js
import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

// 验证２个是否相等
const assertEq = (a, b) => {
  // 不相等就抛出一个错误：期望相等
  if (!a.eq(b)) {
    throw Error(`Expected ${JSON.stringify(a)} == ${JSON.stringify(b)}`);
  }
}

(async () => {
  // 新建一个用户并与后端关联
  const startingBalance = stdlib.parseCurrency(100);
  const accAlice = await stdlib.newTestAccount(startingBalance);
  const ctcAlice = accAlice.contract(backend);

  // 将后端event对象赋值给e
  const e = ctcAlice.events;

  // 生成一个BigNumber类型，初始为０
  let x = stdlib.bigNumberify(0);

  // 定义查看Event对象的方法
  const getLog = (f) => async () => {
    // 接收Event返回的时间和元素，分别赋值给when,what
    const { when, what } = await f.next();
    // 接收Event最近的发生时间
    const lastTime = await f.lastTime();
    // 判断是否相等
    assertEq(lastTime, when);

    // 输出时间
    console.log(JSON.stringify(when));

    return what;
  }

  // 定义查看Event中x元素的方法
  const getXLog = getLog(e.x_event.x);

  await Promise.all([
    backend.A(ctcAlice, {
      // 实现getX()函数，返回x＋１
      getX: () => x = x.add(1),
      // 实现show()函数，用来显示每次x_event.x的值
      show: async () => {
        const what = await getXLog();
        assertEq(what[0], x);
        
        // 输出x_event中x的值
        console.log(JSON.stringify(what[0]));
        // 换行
        console.log(" ");
      },
    }),
  ]);

})();
```

[index.rsh](Event/index.rsh)

```js
'reach 0.1';
'use strict';

export const main = Reach.App(() => {
  // 接口中定义２个方法
  const A = Participant('A', {
    getX: Fun([], UInt),
    show: Fun([], Null),
  });
  // 定义事件，并取名为x_event
  const E = Events('x_event', {
    x: [UInt],
  });

  init();

  A.publish();

  // 声明一个xl变量用来判定循环是否继续
  var [ xl ] = [ 0 ];
  invariant(balance() == 0);
  while (xl < 5) {
    commit();
    A.only(() => {
      // 解密从前端获取的x
      const x = declassify(interact.getX());
    });
    A.publish(x);

    // 将x传入x_event
    E.x(x);
    A.interact.show();

    [ xl ] = [ x ];
    continue;
  }

  commit();

});
```

终端输出（[index.txt](Event/index.txt)）：

```she
{"type":"BigNumber","hex":"0x4c"}
{"type":"BigNumber","hex":"0x01"}
 
{"type":"BigNumber","hex":"0x4d"}
{"type":"BigNumber","hex":"0x02"}
 
{"type":"BigNumber","hex":"0x4e"}
{"type":"BigNumber","hex":"0x03"}
 
{"type":"BigNumber","hex":"0x4f"}
{"type":"BigNumber","hex":"0x04"}
 
{"type":"BigNumber","hex":"0x50"}
{"type":"BigNumber","hex":"0x05"}
```







