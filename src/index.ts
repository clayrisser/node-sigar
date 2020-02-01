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
    return addon.getProcList();
  }

  getProcState(pid: number): ProcState {
    return addon.getProcState(pid);
  }

  get procStat(): ProcStat {
    return addon.getProcStat();
  }
}
