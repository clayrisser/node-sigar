#define NAPI_EXPERIMENTAL
#include <node_api.h>
#include <napi.h>

Napi::Value GetProcArgs(const Napi::CallbackInfo& info);
Napi::Value GetProcList(const Napi::CallbackInfo& info);
Napi::Value GetProcStat(const Napi::CallbackInfo& info);
Napi::Value GetProcState(const Napi::CallbackInfo& info);
