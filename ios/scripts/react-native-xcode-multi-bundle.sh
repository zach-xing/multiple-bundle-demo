#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#
# 魔改版本：支持多bundle构建
# 基于官方 react-native-xcode.sh 脚本修改

# Bundle React Native app's code and image assets.
# This script is supposed to be invoked as part of Xcode build process
# and relies on environment variables (including PWD) set by Xcode

# Print commands before executing them (useful for troubleshooting)
set -x -e

echo "🚀 魔改版React Native Xcode脚本启动 - 支持多bundle构建"

# 检查必要的环境变量
echo "🔍 检查环境变量..."
echo "  PWD: $PWD"
echo "  CONFIGURATION: $CONFIGURATION"
echo "  PLATFORM_NAME: $PLATFORM_NAME"
echo "  CONFIGURATION_BUILD_DIR: $CONFIGURATION_BUILD_DIR"
echo "  UNLOCALIZED_RESOURCES_FOLDER_PATH: $UNLOCALIZED_RESOURCES_FOLDER_PATH"

# 修复PATH环境变量问题 - 确保能找到node和npm
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# 如果存在nvm，也添加到PATH中
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# 如果存在Homebrew，也添加到PATH中
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

echo "🔧 当前PATH: $PATH"
echo "🔧 当前Node.js版本: $(node --version 2>/dev/null || echo 'Node.js not found')"
echo "🔧 当前npm版本: $(npm --version 2>/dev/null || echo 'npm not found')"
echo "🔧 当前npx版本: $(npx --version 2>/dev/null || echo 'npx not found')"

DEST="$CONFIGURATION_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH"

# Enables iOS devices to get the IP address of the machine running Metro
if [[ ! "$SKIP_BUNDLING_METRO_IP" && "$CONFIGURATION" = *Debug* && ! "$PLATFORM_NAME" == *simulator ]]; then
  for num in 0 1 2 3 4 5 6 7 8; do
    IP=$(ipconfig getifaddr en${num} || echo "")
    if [ ! -z "$IP" ]; then
      break
    fi
  done
  if [ -z "$IP" ]; then
    IP=$(ifconfig | grep 'inet ' | grep -v ' 127.' | grep -v ' 169.254.' |cut -d\   -f2  | awk 'NR==1{print $1}')
  fi

  echo "$IP" > "$DEST/ip.txt"
fi

if [[ "$SKIP_BUNDLING" ]]; then
  echo "SKIP_BUNDLING enabled; skipping."
  exit 0;
fi

case "$CONFIGURATION" in
  *Debug*)
    if [[ "$PLATFORM_NAME" == *simulator ]]; then
      if [[ "$FORCE_BUNDLING" ]]; then
        echo "FORCE_BUNDLING enabled; continuing to bundle."
      else
        echo "Skipping bundling in Debug for the Simulator (since the packager bundles for you). Use the FORCE_BUNDLING flag to change this behavior."
        exit 0;
      fi
    else
      echo "Bundling for physical device. Use the SKIP_BUNDLING flag to change this behavior."
    fi

    DEV=true
    ;;
  "")
    echo "$0 must be invoked by Xcode"
    exit 1
    ;;
  *)
    DEV=false
    ;;
esac

# 修复路径计算
# 获取当前脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（从ios/scripts向上两级）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# React Native目录（从项目根目录的node_modules）
REACT_NATIVE_DIR="$PROJECT_ROOT/node_modules/react-native"

echo "📁 脚本目录: $SCRIPT_DIR"
echo "📁 项目根目录: $PROJECT_ROOT"
echo "🔧 React Native目录: $REACT_NATIVE_DIR"

# 验证目录是否存在
if [ ! -d "$REACT_NATIVE_DIR" ]; then
    echo "❌ 错误: React Native目录不存在: $REACT_NATIVE_DIR"
    exit 1
fi

cd "$PROJECT_ROOT" || exit

# 检查并定义入口文件
echo "📄 检查入口文件..."
BASIC_ENTRY="$PROJECT_ROOT/src/basic/index.js"
BUSINESS_ENTRY="$PROJECT_ROOT/src/business/index.js"

# 检查基础包入口文件
if [ ! -f "$BASIC_ENTRY" ]; then
    echo "❌ 错误: 基础包入口文件不存在: $BASIC_ENTRY"
    exit 1
fi

# 检查业务包入口文件
if [ ! -f "$BUSINESS_ENTRY" ]; then
    echo "❌ 错误: 业务包入口文件不存在: $BUSINESS_ENTRY"
    exit 1
fi

echo "✅ 基础包入口文件: $BASIC_ENTRY"
echo "✅ 业务包入口文件: $BUSINESS_ENTRY"

# check and assign NODE_BINARY env
# 修复node-binary.sh路径
NODE_BINARY_SCRIPT="$REACT_NATIVE_DIR/scripts/node-binary.sh"
if [ -f "$NODE_BINARY_SCRIPT" ]; then
    echo "✅ 找到node-binary.sh: $NODE_BINARY_SCRIPT"
    # shellcheck source=/dev/null
    source "$NODE_BINARY_SCRIPT"
else
    echo "❌ 错误: node-binary.sh不存在: $NODE_BINARY_SCRIPT"
    exit 1
fi

echo "🔧 Node.js二进制文件: $NODE_BINARY"

HERMES_ENGINE_PATH="$PODS_ROOT/hermes-engine"
[ -z "$HERMES_CLI_PATH" ] && HERMES_CLI_PATH="$HERMES_ENGINE_PATH/destroot/bin/hermesc"

# If hermesc is not available and USE_HERMES is not set to false, show error.
if [[ $USE_HERMES != false && -f "$HERMES_ENGINE_PATH" && ! -f "$HERMES_CLI_PATH" ]]; then
  echo "error: Hermes is enabled but the hermesc binary could not be found at ${HERMES_CLI_PATH}." \
       "Perhaps you need to run 'bundle exec pod install' or otherwise " \
       "point the HERMES_CLI_PATH variable to your custom location." >&2
  exit 2
fi

[ -z "$NODE_ARGS" ] && export NODE_ARGS=""

[ -z "$CLI_PATH" ] && CLI_PATH="$REACT_NATIVE_DIR/scripts/bundle.js"

[ -z "$BUNDLE_COMMAND" ] && BUNDLE_COMMAND="bundle"

[ -z "$COMPOSE_SOURCEMAP_PATH" ] && COMPOSE_SOURCEMAP_PATH="$REACT_NATIVE_DIR/scripts/compose-source-maps.js"

# 多bundle配置
if [[ -z "$BUNDLE_CONFIG" ]]; then
  CONFIG_ARG=""
else
  CONFIG_ARG="--config $BUNDLE_CONFIG"
fi

if [[ -z "$BUNDLE_NAME" ]]; then
  BUNDLE_NAME="main"
fi

case "$PLATFORM_NAME" in
  "macosx")
    BUNDLE_PLATFORM="macos"
    ;;
  *)
    BUNDLE_PLATFORM="ios"
    ;;
esac

if [ "${IS_MACCATALYST}" = "YES" ]; then
  BUNDLE_PLATFORM="ios"
fi

# 多bundle构建逻辑
if [[ "$CONFIGURATION" = *Release* ]]; then
  echo "📦 Release模式: 开始构建多bundle..."
  
  # 构建基础包
  echo " 构建基础包 (basic)..."
  BASIC_BUNDLE_FILE="$CONFIGURATION_BUILD_DIR/basic.jsbundle"
  BASIC_CONFIG_ARG="--config $PROJECT_ROOT/basic.metro.config.js"
  
  echo "   命令: $NODE_BINARY $NODE_ARGS $CLI_PATH $BUNDLE_COMMAND $BASIC_CONFIG_ARG --entry-file $BASIC_ENTRY --platform $BUNDLE_PLATFORM --dev $DEV --reset-cache --bundle-output $BASIC_BUNDLE_FILE --assets-dest $DEST"
  
  "$NODE_BINARY" $NODE_ARGS "$CLI_PATH" $BUNDLE_COMMAND \
    $BASIC_CONFIG_ARG \
    --entry-file "$BASIC_ENTRY" \
    --platform $BUNDLE_PLATFORM \
    --dev $DEV \
    --reset-cache \
    --bundle-output "$BASIC_BUNDLE_FILE" \
    --assets-dest "$DEST" \
    $EXTRA_PACKAGER_ARGS
  
  if [[ $? -eq 0 ]]; then
    echo "✅ 基础包构建成功: $BASIC_BUNDLE_FILE"
  else
    echo "❌ 基础包构建失败"
    exit 1
  fi
  
  # 构建主包（使用业务包作为入口，它会自动包含基础包）
  echo "🔄 构建主包 (main)..."
  MAIN_BUNDLE_FILE="$CONFIGURATION_BUILD_DIR/main.jsbundle"
  
  echo "   命令: $NODE_BINARY $NODE_ARGS $CLI_PATH $BUNDLE_COMMAND $CONFIG_ARG --entry-file $BUSINESS_ENTRY --platform $BUNDLE_PLATFORM --dev $DEV --reset-cache --bundle-output $MAIN_BUNDLE_FILE --assets-dest $DEST"
  
  "$NODE_BINARY" $NODE_ARGS "$CLI_PATH" $BUNDLE_COMMAND \
    $CONFIG_ARG \
    --entry-file "$BUSINESS_ENTRY" \
    --platform $BUNDLE_PLATFORM \
    --dev $DEV \
    --reset-cache \
    --bundle-output "$MAIN_BUNDLE_FILE" \
    --assets-dest "$DEST" \
    $EXTRA_PACKAGER_ARGS
  
  if [[ $? -eq 0 ]]; then
    echo "✅ 主包构建成功: $MAIN_BUNDLE_FILE"
  else
    echo "❌ 主包构建失败"
    exit 1
  fi
  
  # 生成bundle信息文件
  echo " 生成bundle信息文件..."
  cat > "$DEST/bundle-info.json" << EOF
{
  "version": "$($NODE_BINARY -e "console.log(require('$PROJECT_ROOT/package.json').version)")",
  "buildTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "configuration": "$CONFIGURATION",
  "platform": "$PLATFORM_NAME",
  "bundles": {
    "basic": {
      "path": "basic.jsbundle",
      "entry": "$BASIC_ENTRY",
      "description": "基础工具函数包"
    },
    "main": {
      "path": "main.jsbundle",
      "entry": "$BUSINESS_ENTRY",
      "description": "主应用包（包含业务逻辑和基础包引用）"
    }
  }
}
EOF
  
  echo "✅ Bundle信息文件生成完成: $DEST/bundle-info.json"
  
  # 设置主bundle文件路径（用于后续处理）
  BUNDLE_FILE="$MAIN_BUNDLE_FILE"
  
else
  echo "🔧 Debug模式: 使用标准bundle构建..."
  
  # 在Debug模式下，我们使用业务包作为主入口
  ENTRY_FILE="$BUSINESS_ENTRY"
  echo "🔧 Debug模式使用入口文件: $ENTRY_FILE"
  
  # 标准bundle构建（保持官方逻辑）
  BUNDLE_FILE="$CONFIGURATION_BUILD_DIR/$BUNDLE_NAME.jsbundle"
  
  EXTRA_ARGS=()
  
  EMIT_SOURCEMAP=
  if [[ ! -z "$SOURCEMAP_FILE" ]]; then
    EMIT_SOURCEMAP=true
  fi
  
  PACKAGER_SOURCEMAP_FILE=
  if [[ $EMIT_SOURCEMAP == true ]]; then
    if [[ $USE_HERMES != false ]]; then
      PACKAGER_SOURCEMAP_FILE="$CONFIGURATION_BUILD_DIR/$(basename "$SOURCEMAP_FILE")"
    else
      PACKAGER_SOURCEMAP_FILE="$SOURCEMAP_FILE"
    fi
    EXTRA_ARGS+=("--sourcemap-output" "$PACKAGER_SOURCEMAP_FILE")
  fi
  
  # Hermes doesn't require JS minification.
  if [[ $USE_HERMES != false && $DEV == false ]]; then
    EXTRA_ARGS+=("--minify" "false")
  fi
  
  # 修复配置命令问题 - 避免使用 npx react-native config
  # 直接使用项目根目录的配置，避免环境变量问题
  if [[ -n "$CONFIG_JSON" ]]; then
    EXTRA_ARGS+=("--load-config" "$CONFIG_JSON")
  elif [[ -n "$CONFIG_CMD" ]]; then
    EXTRA_ARGS+=("--config-cmd" "$CONFIG_CMD")
  else
    # 使用更安全的配置方式，避免依赖外部命令
    echo "🔧 使用默认配置，跳过config命令..."
    # 不添加 --config-cmd 参数，让bundle.js使用默认配置
  fi
  
  echo " Debug模式构建命令: $NODE_BINARY $NODE_ARGS $CLI_PATH $BUNDLE_COMMAND $CONFIG_ARG --entry-file $ENTRY_FILE --platform $BUNDLE_PLATFORM --dev $DEV --reset-cache --bundle-output $BUNDLE_FILE --assets-dest $DEST"
  
  # shellcheck disable=SC2086
  "$NODE_BINARY" $NODE_ARGS "$CLI_PATH" $BUNDLE_COMMAND \
    $CONFIG_ARG \
    --entry-file "$ENTRY_FILE" \
    --platform "$BUNDLE_PLATFORM" \
    --dev $DEV \
    --reset-cache \
    --bundle-output "$BUNDLE_FILE" \
    --assets-dest "$DEST" \
    "${EXTRA_ARGS[@]}" \
    $EXTRA_PACKAGER_ARGS
fi

# Hermes处理（支持多bundle）
if [[ $USE_HERMES == false ]]; then
  # 非Hermes模式：直接复制bundle文件
  if [[ "$CONFIGURATION" != *Release* ]]; then
    cp "$BUNDLE_FILE" "$DEST/"
    BUNDLE_FILE="$DEST/$BUNDLE_NAME.jsbundle"
  fi
else
  echo "🔧 Hermes模式：开始编译bundle文件..."
  
  # 设置Hermes编译器参数
  EXTRA_COMPILER_ARGS=
  if [[ $DEV == true ]]; then
    EXTRA_COMPILER_ARGS=-Og
  else
    EXTRA_COMPILER_ARGS=-O
  fi
  
  if [[ $EMIT_SOURCEMAP == true ]]; then
    EXTRA_COMPILER_ARGS="$EXTRA_COMPILER_ARGS -output-source-map"
  fi
  
  # 处理基础包（basic.jsbundle）
  if [[ "$CONFIGURATION" = *Release* ]]; then
    echo "🔧 编译基础包 (basic.jsbundle)..."
    BASIC_BUNDLE_SOURCE="$CONFIGURATION_BUILD_DIR/basic.jsbundle"
    BASIC_BUNDLE_OUTPUT="$DEST/basic.jsbundle"
    
    if [[ -f "$BASIC_BUNDLE_SOURCE" ]]; then
      echo "   编译: $BASIC_BUNDLE_SOURCE → $BASIC_BUNDLE_OUTPUT"
      
      "$HERMES_CLI_PATH" -emit-binary -max-diagnostic-width=80 $EXTRA_COMPILER_ARGS \
        -out "$BASIC_BUNDLE_OUTPUT" "$BASIC_BUNDLE_SOURCE"
      
      if [[ $? -eq 0 ]]; then
        echo "✅ 基础包Hermes编译成功"
      else
        echo "❌ 基础包Hermes编译失败"
        exit 1
      fi
      
      # 处理基础包的Source Map
      if [[ $EMIT_SOURCEMAP == true ]]; then
        BASIC_SOURCEMAP_SOURCE="$CONFIGURATION_BUILD_DIR/basic.jsbundle.map"
        BASIC_SOURCEMAP_OUTPUT="$DEST/basic.jsbundle.map"
        
        if [[ -f "$BASIC_SOURCEMAP_SOURCE" ]]; then
          echo "   处理基础包Source Map..."
          cp "$BASIC_SOURCEMAP_SOURCE" "$BASIC_SOURCEMAP_OUTPUT"
        fi
      fi
    else
      echo "⚠️ 警告: 基础包源文件不存在: $BASIC_BUNDLE_SOURCE"
    fi
  fi
  
  # 处理主包（main.jsbundle）
  echo "🔧 编译主包 (main.jsbundle)..."
  MAIN_BUNDLE_SOURCE="$CONFIGURATION_BUILD_DIR/main.jsbundle"
  MAIN_BUNDLE_OUTPUT="$DEST/main.jsbundle"
  
  if [[ -f "$MAIN_BUNDLE_SOURCE" ]]; then
    echo "   编译: $MAIN_BUNDLE_SOURCE → $MAIN_BUNDLE_OUTPUT"
    
    "$HERMES_CLI_PATH" -emit-binary -max-diagnostic-width=80 $EXTRA_COMPILER_ARGS \
      -out "$MAIN_BUNDLE_OUTPUT" "$MAIN_BUNDLE_SOURCE"
    
    if [[ $? -eq 0 ]]; then
      echo "✅ 主包Hermes编译成功"
    else
      echo "❌ 主包Hermes编译失败"
      exit 1
    fi
    
    # 处理主包的Source Map
    if [[ $EMIT_SOURCEMAP == true ]]; then
      MAIN_SOURCEMAP_SOURCE="$CONFIGURATION_BUILD_DIR/main.jsbundle.map"
      MAIN_SOURCEMAP_OUTPUT="$DEST/main.jsbundle.map"
      
      if [[ -f "$MAIN_SOURCEMAP_SOURCE" ]]; then
        echo "   处理主包Source Map..."
        cp "$MAIN_SOURCEMAP_SOURCE" "$MAIN_SOURCEMAP_OUTPUT"
      fi
    fi
    
    # 设置主bundle文件路径（用于后续处理）
    BUNDLE_FILE="$MAIN_BUNDLE_OUTPUT"
  else
    echo "❌ 错误: 主包源文件不存在: $MAIN_BUNDLE_SOURCE"
    exit 1
  fi
  
  # 清理临时文件
  if [[ $EMIT_SOURCEMAP == true ]]; then
    echo "🧹 清理临时Source Map文件..."
    rm -f "$CONFIGURATION_BUILD_DIR"/*.jsbundle.map
  fi
fi

# 验证bundle文件
if [[ $DEV != true && ! -f "$BUNDLE_FILE" ]]; then
  echo "error: File $BUNDLE_FILE does not exist. Your environment is misconfigured as Metro was not able to produce the bundle so your release application won't work!" >&2
  exit 2
fi

echo "🎉 魔改版React Native Xcode脚本执行完成！"