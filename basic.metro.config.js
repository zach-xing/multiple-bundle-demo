const { clean, hasBuildInfo } = require("./build");
const fs = require("fs");

function createModuleIdFactory() {
  const fileToIdMap = new Map();
  let nextId = 0;

  clean("./config/bundleInfo.json");
  return (path) => {
    let id = fileToIdMap.get(path) ? fileToIdMap.get(path) : nextId++;
    fileToIdMap.set(path, id);

    if (!hasBuildInfo("./config/bundleInfo.json", path)) {
      const cacheFile = require("./config/bundleInfo.json");
      cacheFile[path] = id;
      fs.writeFileSync("./config/bundleInfo.json", JSON.stringify(cacheFile));
    }

    return id;
  };
}

module.exports = {

  serializer: {
    createModuleIdFactory: createModuleIdFactory,
  }
};
