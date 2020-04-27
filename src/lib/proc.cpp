#include "sigar.h"
#include <string.h>
#define NAPI_EXPERIMENTAL
#include <node_api.h>
#include <napi.h>

Napi::Value GetProcArgs(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  Napi::Array proc_args;
  int status;
  sigar_proc_args_t sigar_proc_args;
  sigar_t* sigar;
  if (info.Length() < 1) {
    Napi::TypeError::New(env, "Wrong number of arguments")
      .ThrowAsJavaScriptException();
    return env.Null();
  }
  if (!info[0].IsNumber()) {
    Napi::TypeError::New(env, "Wrong arguments").ThrowAsJavaScriptException();
    return env.Null();
  }
  double arg0 = info[0].As<Napi::Number>().DoubleValue();
  sigar_open(&sigar);
  status = sigar_proc_args_get(sigar, arg0, &sigar_proc_args);
  proc_args = Napi::Array::New(env, sigar_proc_args.number);
  if (status == SIGAR_OK) {
    for (int i = 0; i < sigar_proc_args.number; i++) {
      proc_args.Set(i, Napi::String::New(env, sigar_proc_args.data[i]));
    }
  }
  sigar_proc_args_destroy(sigar, &sigar_proc_args);
  sigar_close(sigar);
  return proc_args;
}

Napi::Value GetProcList(const Napi::CallbackInfo& info) {
  Napi::Array proc_list;
  Napi::Env env = info.Env();
  int status;
  sigar_proc_list_t sigar_proc_list;
  sigar_t* sigar;
  sigar_open(&sigar);
  status = sigar_proc_list_get(sigar, &sigar_proc_list);
  if (status != SIGAR_OK) {
    Napi::TypeError::New(env,
                         "Failed to get proc list"
                         ).ThrowAsJavaScriptException();
    return env.Null();
  }
  proc_list = Napi::Array::New(env, sigar_proc_list.number);
  for (int i = 0; i < sigar_proc_list.number; i++) {
    proc_list.Set(i, Napi::Number::New(env, sigar_proc_list.data[i]));
  }
  sigar_proc_list_destroy(sigar, &sigar_proc_list);
  sigar_close(sigar);
  return proc_list;
}

Napi::Value GetProcStat(const Napi::CallbackInfo& info) {
  Napi::Object proc_stat;
  Napi::Env env = info.Env();
  int status;
  sigar_proc_stat_t sigar_proc_stat;
  sigar_t* sigar;
  sigar_open(&sigar);
  status = sigar_proc_stat_get(sigar, &sigar_proc_stat);
  if (status != SIGAR_OK) {
    Napi::TypeError::New(env,
                         "Failed to get proc stat"
                         ).ThrowAsJavaScriptException();
    return env.Null();
  }
  proc_stat = Napi::Object::New(env);
  proc_stat.Set("idle", Napi::Number::New(env, sigar_proc_stat.idle));
  proc_stat.Set("running", Napi::Number::New(env, sigar_proc_stat.running));
  proc_stat.Set("sleeping", Napi::Number::New(env, sigar_proc_stat.sleeping));
  proc_stat.Set("stopped", Napi::Number::New(env, sigar_proc_stat.stopped));
  proc_stat.Set("threads", Napi::Number::New(env, sigar_proc_stat.threads));
  proc_stat.Set("total", Napi::Number::New(env, sigar_proc_stat.total));
  proc_stat.Set("zombie", Napi::Number::New(env, sigar_proc_stat.zombie));
  sigar_close(sigar);
  return proc_stat;
}

Napi::Value GetProcState(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  Napi::Object proc_state;
  int status;
  sigar_proc_state_t sigar_proc_state;
  sigar_t* sigar;
  if (info.Length() < 1) {
    Napi::TypeError::New(env, "Wrong number of arguments")
      .ThrowAsJavaScriptException();
    return env.Null();
  }
  if (!info[0].IsNumber()) {
    Napi::TypeError::New(env, "Wrong arguments").ThrowAsJavaScriptException();
    return env.Null();
  }
  double arg0 = info[0].As<Napi::Number>().DoubleValue();
  sigar_open(&sigar);
  status = sigar_proc_state_get(sigar, arg0, &sigar_proc_state);
  proc_state = Napi::Object::New(env);
  if (status == SIGAR_OK) {
    proc_state.Set("name", Napi::String::New(env, sigar_proc_state.name));
    proc_state.Set("nice", Napi::Number::New(env, sigar_proc_state.nice));
    proc_state.Set("ppid", Napi::Number::New(env, sigar_proc_state.ppid));
    proc_state.Set("priority", Napi::Number::New(env, sigar_proc_state.priority));
    proc_state.Set("processor", Napi::Number::New(env, sigar_proc_state.processor));
    char state[2] = {sigar_proc_state.state};
    proc_state.Set("state", Napi::String::New(env, state));
    proc_state.Set("threads", Napi::Number::New(env, sigar_proc_state.threads));
    proc_state.Set("tty", Napi::Number::New(env, sigar_proc_state.tty));
  }
  sigar_close(sigar);
  return proc_state;
}
