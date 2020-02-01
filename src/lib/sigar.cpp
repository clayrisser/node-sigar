#include "proc.h"
#define NAPI_EXPERIMENTAL
#include <node_api.h>
#include <napi.h>

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getProcArgs"),
              Napi::Function::New(env, GetProcArgs));
  exports.Set(Napi::String::New(env, "getProcList"),
              Napi::Function::New(env, GetProcList));
  exports.Set(Napi::String::New(env, "getProcStat"),
              Napi::Function::New(env, GetProcStat));
  exports.Set(Napi::String::New(env, "getProcState"),
              Napi::Function::New(env, GetProcState));
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
