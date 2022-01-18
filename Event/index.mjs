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
