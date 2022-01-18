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
