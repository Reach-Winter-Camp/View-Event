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
