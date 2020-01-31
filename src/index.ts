import bindings from 'bindings';

const addon = bindings('sigar');

export default class Sigar {
  get procList(): number[] {
    return addon.getProcList().map((pid: BigInt) => Number(pid));
  }
}
