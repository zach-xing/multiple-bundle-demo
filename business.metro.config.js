const { hasBuildInfo, getCacheFile, isPwdFile } = require('./build');
const bundleInfo = require('./config/bundleInfo.json');

function createModuleIdFactory() {
  const fileToIdMap = new Map();
  let nextId = 10000000;
  let isFirst = false;

  return (path) => {

    const cacheFileId = getCacheFile("./config/bundleInfo.json", path);
    if (cacheFileId) {
      return cacheFileId;
    }

    if (!isFirst && isPwdFile(path)) {
      nextId = bundleInfo[isPwdFile(path)];
      isFirst = true;
    }

    let id = fileToIdMap.get(path);
    if (id === undefined) {
      id = nextId++;
      fileToIdMap.set(path, id);
    }
    return id;
  };
}

function postProcessModulesFilter(module) {
  if (
    module.path.indexOf("__prelude__") >= 0 ||
    module.path.indexOf("polyfills") >= 0
  ) {
    return false;
  }

  if (hasBuildInfo("./config/bundleInfo.json", module.path)) {
    return false;
  }

  return true;
}

module.exports = {

  serializer: {
    createModuleIdFactory: createModuleIdFactory,
    processModuleFilter: postProcessModulesFilter
  }
};
