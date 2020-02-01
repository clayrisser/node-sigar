#include "sigar.h"
#include <assert.h>
#define NAPI_EXPERIMENTAL
#include <node_api.h>
#include <napi.h>

Napi::Array GetProcList(const Napi::CallbackInfo& info) {
  Napi::Array proc_list;
  Napi::Env env = info.Env();
  int status;
  sigar_proc_list_t sigar_proc_list;
  sigar_t* sigar;
  sigar_open(&sigar);
  status = sigar_proc_list_get(sigar, &sigar_proc_list);
  assert(status == SIGAR_OK);
  proc_list = Napi::Array::New(env, sigar_proc_list.number);
  for (int i = 0; i < sigar_proc_list.number; i++) {
    sigar_proc_list.data[i];
    proc_list.Set(i, Napi::Number::New(env, sigar_proc_list.data[i]));
  }
  sigar_proc_list_destroy(sigar, &sigar_proc_list);
  sigar_close(sigar);
  return proc_list;
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
  assert(status == SIGAR_OK);
  proc_state = Napi::Object::New(env);
  proc_state.Set("name", Napi::String::New(env, sigar_proc_state.name));
  proc_state.Set("nice", Napi::Number::New(env, sigar_proc_state.nice));
  proc_state.Set("ppid", Napi::Number::New(env, sigar_proc_state.ppid));
  proc_state.Set("priority", Napi::Number::New(env, sigar_proc_state.priority));
  proc_state.Set("processor", Napi::Number::New(env, sigar_proc_state.processor));
  char state[2] = {sigar_proc_state.state};
  proc_state.Set("state", Napi::String::New(env, state));
  proc_state.Set("threads", Napi::Number::New(env, sigar_proc_state.threads));
  proc_state.Set("tty", Napi::Number::New(env, sigar_proc_state.tty));
  sigar_close(sigar);
  return proc_state;
}
