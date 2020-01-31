import bindings from 'bindings';

const addon = bindings('sigar');

export interface ProcState {
  name: string;
  nice: number;
  ppid: number;
  priority: number;
  processor: number;
  state: string;
  threads: number;
  tty: number;
}

export interface ProcStat {
  idle: number;
  running: number;
  sleeping: number;
  stopped: number;
  threads: number;
  total: number;
  zombie: number;
}

export default class Sigar {
  get procList(): number[] {
    return addon.getProcList().map((pid: BigInt) => Number(pid));
  }

  getProcState(pid: number): ProcState {
    return Object.entries(addon.getProcState(BigInt(pid))).reduce(
      (procState: { [key: string]: any }, [key, value]: [string, any]) => {
        if (typeof value === 'bigint') value = Number(value);
        procState[key] = value;
        return procState;
      },
      {}
    ) as ProcState;
  }

  get procStat(): ProcStat {
    return addon.getProcStat();
  }
}
