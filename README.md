# multiple-bundle-demo

测试多个bundle加载的demo

## ios 的打包 bundle 脚本的修改

RN 官方的 打包 bundle 脚本默认做的行为都有这些：

1. 环境准备（比如设置调试模式、IP地址获取）
2. 配置判断 （比如看是不是模拟器调试，如果是的话，直接exit 0了）
3. 路径设置（设置 RN_DIR 目录的路径、设置项目根目录路径、Hermes引擎的位置、还有Node的位置等等）
4. 工具检查（比如检查Hermse能不能用、bundle的配置参数、还有sourceMap的配置）
5. Metro打包（构建完Metro配置命令后，就开始执行，打包出jsbundle文件，还有资源文件）
6. Hermes编译（看是否启用了Hermes，如果用了则把jsbundle文件需要转成字节码的形式）
7. 结果验证（就看打出来的jsbundle文件是不是存在，如果不存在就报错，存在就结束了）

现在需要对这个脚本进行魔改，让能打包出两个jsbundle文件

