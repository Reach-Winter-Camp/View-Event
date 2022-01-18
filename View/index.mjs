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
