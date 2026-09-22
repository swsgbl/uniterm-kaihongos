cmake_minimum_required(VERSION 3.16)
project(uniterm_entry NONE)
# M1a: entry 模块无自研 C/C++ 源码;native 能力由 @ohos/libssh HAR 提供。
# 此 CMakeLists 仅作为 hvigor externalNativeOptions 的占位骨架,
# 保证构建系统可解析;待 M2 需要自研 native 桥接时再扩展。
message(STATUS "uniterm entry: no native sources (placeholder CMakeLists)")
