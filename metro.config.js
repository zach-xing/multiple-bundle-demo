const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const pathSep = require('path').sep;

function createModuleIdFactory() {
    //获取命令行执行的目录，__dirname是nodejs提供的变量
    const projectRootPath = __dirname;
    return (path) => {
        console.log('[createModuleIdFactory] path:', path);
        let name = '';
 
        if (path.indexOf(projectRootPath) === 0) {
            /*
              这里是react native 自带库以外的其他库，因是绝对路径，带有设备信息，
              为了避免重复名称,可以保留node_modules直至结尾
              如/{User}/{username}/{userdir}/node_modules/xxx.js 需要将设备信息截掉
            */
            name = path.substr(projectRootPath.length + 1);
            console.log('root libraries:' + name);
        }
        //最后在将斜杠替换为空串或下划线
        let regExp = pathSep === '\\' ? new RegExp('\\\\', "gm") : new RegExp(pathSep, "gm");
        name = name.replace(regExp, '_');
        console.log('==========================final name:', name);

        return name;
    };
}

function processModuleFilter(module) {
    console.log('[processModuleFilter] module:', module);

    //过滤掉node_modules内的模块（基础包内已有）
    if (module.path.indexOf(pathSep + 'node_modules' + pathSep) > 0) {
        /*
          但输出类型为js/script/virtual的模块不能过滤，一般此类型的文件为核心文件，
          如InitializeCore.js。每次加载bundle文件时都需要用到。
        */
        if ('js' + pathSep + 'script' + pathSep + 'virtual' === module.output[0].type) {
            return true;
        }
        return false;
    }
    console.log('[processModuleFilter] module.path:', module.path);
    //其他就是应用代码
    return true;
}

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
    resolver: {
        assetExts: ['ico', 'png', 'ttf'],
        // 添加平台特定的扩展名解析
        platforms: ['android', 'ios', 'native', 'web'],
        // 添加模块扩展名解析
        sourceExts: ['js', 'jsx', 'ts', 'tsx', 'json'],
        // 添加别名映射，使用我们的mock模块解决missing-asset-registry-path问题
        // alias: {
        //     'missing-asset-registry-path': require.resolve('./src/mocks/missing-asset-registry-path'),
        // },
        // 添加额外的解析规则
        resolverMainFields: ['react-native', 'browser', 'main'],
    },
    createModuleIdFactory,
    processModuleFilter,
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
